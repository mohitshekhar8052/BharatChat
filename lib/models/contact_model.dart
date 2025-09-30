import 'package:flutter_contacts/flutter_contacts.dart';

class ContactModel {
  final String id;
  final String displayName;
  final String phoneNumber;
  final String email;
  final String? photoUrl;
  final bool isRegistered; // Whether the contact is registered in our app
  final String? userId; // Firebase user ID if registered
  final DateTime? lastSeen;
  final bool isOnline;

  ContactModel({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    this.photoUrl,
    this.isRegistered = false,
    this.userId,
    this.lastSeen,
    this.isOnline = false,
  });

  // Create from device contact using flutter_contacts
  factory ContactModel.fromFlutterContact(Contact contact) {
    final phoneNumber = contact.phones.isNotEmpty
        ? contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '')
        : '';

    final email = contact.emails.isNotEmpty ? contact.emails.first.address : '';

    return ContactModel(
      id: contact.id,
      displayName: contact.displayName,
      phoneNumber: phoneNumber,
      email: email,
      photoUrl: null,
    );
  }

  // Create from Firestore data
  factory ContactModel.fromMap(Map<String, dynamic> map, String id) {
    return ContactModel(
      id: id,
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      isRegistered: map['isRegistered'] ?? false,
      userId: map['userId'],
      lastSeen: map['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
          : null,
      isOnline: map['isOnline'] ?? false,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'isRegistered': isRegistered,
      'userId': userId,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'isOnline': isOnline,
      'syncedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Create a copy with updated fields
  ContactModel copyWith({
    String? id,
    String? displayName,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    bool? isRegistered,
    String? userId,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return ContactModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isRegistered: isRegistered ?? this.isRegistered,
      userId: userId ?? this.userId,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'ContactModel(id: $id, displayName: $displayName, phoneNumber: $phoneNumber, isRegistered: $isRegistered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactModel &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ phoneNumber.hashCode ^ email.hashCode;
  }
}
