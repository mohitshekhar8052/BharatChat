import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Request permission to access contacts
  Future<bool> requestContactPermission() async {
    try {
      final status = await Permission.contacts.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting contact permission: $e');
      return false;
    }
  }

  /// Check if contact permission is granted
  Future<bool> hasContactPermission() async {
    try {
      final status = await Permission.contacts.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking contact permission: $e');
      return false;
    }
  }

  /// Get all contacts from device
  Future<List<ContactModel>> getDeviceContacts() async {
    try {
      // Request permission using flutter_contacts built-in method
      if (!await FlutterContacts.requestPermission()) {
        throw Exception('Contact permission denied');
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      final List<ContactModel> contactModels = [];

      for (final contact in contacts) {
        // Only include contacts with phone numbers or emails
        if (contact.phones.isNotEmpty || contact.emails.isNotEmpty) {
          contactModels.add(ContactModel.fromFlutterContact(contact));
        }
      }

      return contactModels;
    } catch (e) {
      print('Error getting device contacts: $e');
      throw Exception('Failed to get contacts: $e');
    }
  }

  /// Sync device contacts with Firestore
  Future<void> syncContactsWithDatabase() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final deviceContacts = await getDeviceContacts();
      final batch = _firestore.batch();

      // Get user's contact collection reference
      final userContactsRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts');

      for (final contact in deviceContacts) {
        final docRef = userContactsRef.doc(contact.id);
        batch.set(docRef, contact.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
      print('Successfully synced ${deviceContacts.length} contacts');
    } catch (e) {
      print('Error syncing contacts: $e');
      throw Exception('Failed to sync contacts: $e');
    }
  }

  /// Get synced contacts from Firestore
  Future<List<ContactModel>> getSyncedContacts() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts')
          .orderBy('displayName')
          .get();

      return snapshot.docs.map((doc) {
        return ContactModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting synced contacts: $e');
      throw Exception('Failed to get contacts: $e');
    }
  }

  /// Get contacts stream for real-time updates
  Stream<List<ContactModel>> getContactsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ContactModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Find registered users among contacts
  Future<List<ContactModel>> findRegisteredContacts() async {
    try {
      final contacts = await getSyncedContacts();
      final List<ContactModel> registeredContacts = [];

      // Check which contacts are registered users
      for (final contact in contacts) {
        if (contact.phoneNumber.isNotEmpty) {
          // Search for users by phone number
          final userQuery = await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: contact.phoneNumber)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            final userData = userQuery.docs.first.data();
            final userId = userQuery.docs.first.id;

            registeredContacts.add(
              contact.copyWith(
                isRegistered: true,
                userId: userId,
                photoUrl: userData['photoURL'] ?? userData['image'],
                isOnline: userData['isOnline'] ?? false,
                lastSeen: userData['lastSeen'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(userData['lastSeen'])
                    : null,
              ),
            );
          }
        }

        if (contact.email.isNotEmpty &&
            !registeredContacts.any((c) => c.id == contact.id)) {
          // Search for users by email
          final userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: contact.email)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            final userData = userQuery.docs.first.data();
            final userId = userQuery.docs.first.id;

            registeredContacts.add(
              contact.copyWith(
                isRegistered: true,
                userId: userId,
                photoUrl: userData['photoURL'] ?? userData['image'],
                isOnline: userData['isOnline'] ?? false,
                lastSeen: userData['lastSeen'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(userData['lastSeen'])
                    : null,
              ),
            );
          }
        }
      }

      // Update the contact records with registration status
      await _updateContactRegistrationStatus(registeredContacts);

      return registeredContacts;
    } catch (e) {
      print('Error finding registered contacts: $e');
      throw Exception('Failed to find registered contacts: $e');
    }
  }

  /// Update contact registration status in database
  Future<void> _updateContactRegistrationStatus(
    List<ContactModel> registeredContacts,
  ) async {
    try {
      if (currentUserId == null) return;

      final batch = _firestore.batch();
      final userContactsRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts');

      for (final contact in registeredContacts) {
        final docRef = userContactsRef.doc(contact.id);
        batch.update(docRef, {
          'isRegistered': contact.isRegistered,
          'userId': contact.userId,
          'photoUrl': contact.photoUrl,
          'isOnline': contact.isOnline,
          'lastSeen': contact.lastSeen?.millisecondsSinceEpoch,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error updating contact registration status: $e');
    }
  }

  /// Search contacts by name or phone number
  Future<List<ContactModel>> searchContacts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getSyncedContacts();
      }

      final contacts = await getSyncedContacts();
      final lowercaseQuery = query.toLowerCase();

      return contacts.where((contact) {
        return contact.displayName.toLowerCase().contains(lowercaseQuery) ||
            contact.phoneNumber.contains(query) ||
            contact.email.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching contacts: $e');
      return [];
    }
  }

  /// Delete a contact from database
  Future<void> deleteContact(String contactId) async {
    try {
      if (currentUserId == null) return;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      print('Error deleting contact: $e');
      throw Exception('Failed to delete contact: $e');
    }
  }

  /// Get contact by ID
  Future<ContactModel?> getContactById(String contactId) async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts')
          .doc(contactId)
          .get();

      if (doc.exists) {
        return ContactModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting contact by ID: $e');
      return null;
    }
  }

  /// Get registered contacts stream for real-time updates
  Stream<List<ContactModel>> getRegisteredContactsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('contacts')
        .where('isRegistered', isEqualTo: true)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ContactModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Initialize contact sync on app start
  Future<void> initializeContactSync() async {
    try {
      final hasPermission = await hasContactPermission();
      if (hasPermission) {
        await syncContactsWithDatabase();
        await findRegisteredContacts();
      }
    } catch (e) {
      print('Error initializing contact sync: $e');
    }
  }
}
