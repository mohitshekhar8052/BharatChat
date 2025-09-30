import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _usersCollection = 'users';

  // Create or update user profile in Firestore
  static Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    String? status,
    String? bio,
    String? phoneNumber,
    String? dateOfBirth,
    String? location,
    String? website,
    List<String>? interests,
    String? profession,
    String? company,
    String? education,
    String? gender,
    Map<String, bool>? privacy,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'displayName': displayName ?? '',
        'photoURL': photoURL ?? '',
        'status': status ?? 'Hey there! I am using XtrChat',
        'bio': bio ?? 'Just another chat app user enjoying conversations!',
        'phoneNumber': phoneNumber ?? '',
        'dateOfBirth': dateOfBirth ?? '',
        'location': location ?? '',
        'website': website ?? '',
        'interests': interests ?? [],
        'profession': profession ?? '',
        'company': company ?? '',
        'education': education ?? '',
        'gender': gender ?? '',
        'privacy':
            privacy ??
            {
              'showEmail': false,
              'showPhone': false,
              'showLocation': false,
              'showBio': true,
              'showStatus': true,
              'allowFriendRequests': true,
            },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
        'profileCompleted': false,
        'totalChats': 0,
        'totalMessages': 0,
        'friends': [],
        'blockedUsers': [],
        'settings': {
          'darkMode': false,
          'notifications': true,
          'soundEnabled': true,
          'vibrationEnabled': true,
          'lastSeenEnabled': true,
          'readReceiptsEnabled': true,
          'typingIndicatorEnabled': true,
        },
        'deviceInfo': {
          'platform': '',
          'deviceModel': '',
          'appVersion': '',
          'lastLoginDevice': '',
        },
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? status,
    String? bio,
    String? phoneNumber,
    String? dateOfBirth,
    String? location,
    String? website,
    List<String>? interests,
    String? profession,
    String? company,
    String? education,
    String? gender,
    Map<String, bool>? privacy,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['photoURL'] = photoURL;
      if (status != null) updateData['status'] = status;
      if (bio != null) updateData['bio'] = bio;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;
      if (location != null) updateData['location'] = location;
      if (website != null) updateData['website'] = website;
      if (interests != null) updateData['interests'] = interests;
      if (profession != null) updateData['profession'] = profession;
      if (company != null) updateData['company'] = company;
      if (education != null) updateData['education'] = education;
      if (gender != null) updateData['gender'] = gender;
      if (privacy != null) updateData['privacy'] = privacy;
      if (settings != null) updateData['settings'] = settings;
      if (deviceInfo != null) updateData['deviceInfo'] = deviceInfo;

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      return await getUserProfile(currentUser.uid);
    } catch (e) {
      throw Exception('Failed to get current user profile: $e');
    }
  }

  // Stream user profile data (real-time updates)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(
    String uid,
  ) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots();
  }

  // Stream current user profile
  static Stream<DocumentSnapshot<Map<String, dynamic>>?>
  streamCurrentUserProfile() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return streamUserProfile(currentUser.uid);
  }

  // Update user online status
  static Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {'isOnline': isOnline, 'lastSeen': FieldValue.serverTimestamp()},
      );
    } on FirebaseException catch (e) {
      // If permission denied, just log it but don't throw an error
      if (e.code == 'permission-denied') {
        print(
          'Permission denied when updating online status. This is normal if Firestore rules are restrictive.',
        );
        return; // Don't throw error for permission issues
      }
      throw Exception('Failed to update online status: $e');
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  // Get all users (for contacts/search)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection(_usersCollection).get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Search users by email or display name
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final emailQuery = await _firestore
          .collection(_usersCollection)
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final nameQuery = await _firestore
          .collection(_usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final Set<String> uniqueIds = {};
      final List<Map<String, dynamic>> results = [];

      // Add email results
      for (final doc in emailQuery.docs) {
        if (!uniqueIds.contains(doc.id)) {
          uniqueIds.add(doc.id);
          results.add({...doc.data(), 'id': doc.id});
        }
      }

      // Add name results
      for (final doc in nameQuery.docs) {
        if (!uniqueIds.contains(doc.id)) {
          uniqueIds.add(doc.id);
          results.add({...doc.data(), 'id': doc.id});
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Delete user profile
  static Future<void> deleteUserProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Initialize user profile on first login
  static Future<void> initializeUserProfile(User user) async {
    try {
      // Check if user profile already exists
      final existingProfile = await getUserProfile(user.uid);

      if (existingProfile == null) {
        // Create new profile
        await createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL ?? '',
        );
      } else {
        // Update existing profile with latest auth data
        await updateUserProfile(
          displayName: user.displayName,
          photoURL: user.photoURL,
        );
      }

      // Set user as online
      await updateOnlineStatus(true);
    } catch (e) {
      throw Exception('Failed to initialize user profile: $e');
    }
  }

  // Set user offline when logging out
  static Future<void> setUserOffline() async {
    try {
      await updateOnlineStatus(false);
    } catch (e) {
      // Log the error but don't throw it to prevent sign out from failing
      print('Could not set user offline status: $e');
      // Continue with the sign out process even if this fails
    }
  }

  // Stream all users (for contacts screen)
  static Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection(_usersCollection).snapshots();
  }

  // ENHANCED USER DETAILS MANAGEMENT

  // Update user privacy settings
  static Future<void> updatePrivacySettings({
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    bool? showBio,
    bool? showStatus,
    bool? allowFriendRequests,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final privacyData = <String, dynamic>{};
      if (showEmail != null) privacyData['privacy.showEmail'] = showEmail;
      if (showPhone != null) privacyData['privacy.showPhone'] = showPhone;
      if (showLocation != null) {
        privacyData['privacy.showLocation'] = showLocation;
      }
      if (showBio != null) privacyData['privacy.showBio'] = showBio;
      if (showStatus != null) privacyData['privacy.showStatus'] = showStatus;
      if (allowFriendRequests != null) {
        privacyData['privacy.allowFriendRequests'] = allowFriendRequests;
      }

      privacyData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .update(privacyData);
    } catch (e) {
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  // Update user app settings
  static Future<void> updateAppSettings({
    bool? darkMode,
    bool? notifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? lastSeenEnabled,
    bool? readReceiptsEnabled,
    bool? typingIndicatorEnabled,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final settingsData = <String, dynamic>{};
      if (darkMode != null) settingsData['settings.darkMode'] = darkMode;
      if (notifications != null) {
        settingsData['settings.notifications'] = notifications;
      }
      if (soundEnabled != null) {
        settingsData['settings.soundEnabled'] = soundEnabled;
      }
      if (vibrationEnabled != null) {
        settingsData['settings.vibrationEnabled'] = vibrationEnabled;
      }
      if (lastSeenEnabled != null) {
        settingsData['settings.lastSeenEnabled'] = lastSeenEnabled;
      }
      if (readReceiptsEnabled != null) {
        settingsData['settings.readReceiptsEnabled'] = readReceiptsEnabled;
      }
      if (typingIndicatorEnabled != null) {
        settingsData['settings.typingIndicatorEnabled'] =
            typingIndicatorEnabled;
      }

      settingsData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .update(settingsData);
    } catch (e) {
      throw Exception('Failed to update app settings: $e');
    }
  }

  // Update device information
  static Future<void> updateDeviceInfo({
    String? platform,
    String? deviceModel,
    String? appVersion,
    String? lastLoginDevice,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final deviceData = <String, dynamic>{};
      if (platform != null) deviceData['deviceInfo.platform'] = platform;
      if (deviceModel != null) {
        deviceData['deviceInfo.deviceModel'] = deviceModel;
      }
      if (appVersion != null) deviceData['deviceInfo.appVersion'] = appVersion;
      if (lastLoginDevice != null) {
        deviceData['deviceInfo.lastLoginDevice'] = lastLoginDevice;
      }

      deviceData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .update(deviceData);
    } catch (e) {
      throw Exception('Failed to update device info: $e');
    }
  }

  // Add interest to user profile
  static Future<void> addInterest(String interest) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {
          'interests': FieldValue.arrayUnion([interest]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to add interest: $e');
    }
  }

  // Remove interest from user profile
  static Future<void> removeInterest(String interest) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {
          'interests': FieldValue.arrayRemove([interest]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to remove interest: $e');
    }
  }

  // Add friend to user's friend list
  static Future<void> addFriend(String friendUid) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {
          'friends': FieldValue.arrayUnion([friendUid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to add friend: $e');
    }
  }

  // Remove friend from user's friend list
  static Future<void> removeFriend(String friendUid) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {
          'friends': FieldValue.arrayRemove([friendUid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  // Block user
  static Future<void> blockUser(String userUid) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {
          'blockedUsers': FieldValue.arrayUnion([userUid]),
          'friends': FieldValue.arrayRemove([
            userUid,
          ]), // Remove from friends if blocked
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock user
  static Future<void> unblockUser(String userUid) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {
          'blockedUsers': FieldValue.arrayRemove([userUid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Mark profile as completed
  static Future<void> markProfileCompleted() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(_usersCollection).doc(currentUser.uid).update(
        {'profileCompleted': true, 'updatedAt': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      throw Exception('Failed to mark profile as completed: $e');
    }
  }

  // Search users by display name with enhanced filtering
  static Future<List<Map<String, dynamic>>> searchUsersByName(
    String query,
  ) async {
    try {
      if (query.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return {
        'totalChats': userData['totalChats'] ?? 0,
        'totalMessages': userData['totalMessages'] ?? 0,
        'friendsCount': (userData['friends'] as List?)?.length ?? 0,
        'interestsCount': (userData['interests'] as List?)?.length ?? 0,
        'joinedDate': userData['createdAt'],
        'lastUpdated': userData['updatedAt'],
        'profileCompleted': userData['profileCompleted'] ?? false,
      };
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  // Increment user message count
  static Future<void> incrementMessageCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .update({
            'totalMessages': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Failed to increment message count: $e');
      // Don't throw error as this is not critical
    }
  }

  // Increment user chat count
  static Future<void> incrementChatCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .update({
            'totalChats': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Failed to increment chat count: $e');
      // Don't throw error as this is not critical
    }
  }
}
