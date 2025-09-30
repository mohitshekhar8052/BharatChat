class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final String status;
  final String bio;
  final String phoneNumber;
  final String dateOfBirth;
  final String location;
  final String website;
  final List<String> interests;
  final String profession;
  final String company;
  final String education;
  final String gender;
  final Map<String, bool> privacy;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> deviceInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isEmailVerified;
  final bool profileCompleted;
  final int totalChats;
  final int totalMessages;
  final List<String> friends;
  final List<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoURL = '',
    this.status = 'Hey there! I am using XtrChat',
    this.bio = 'Just another chat app user enjoying conversations!',
    this.phoneNumber = '',
    this.dateOfBirth = '',
    this.location = '',
    this.website = '',
    this.interests = const [],
    this.profession = '',
    this.company = '',
    this.education = '',
    this.gender = '',
    this.privacy = const {
      'showEmail': false,
      'showPhone': false,
      'showLocation': false,
      'showBio': true,
      'showStatus': true,
      'allowFriendRequests': true,
    },
    this.settings = const {
      'darkMode': false,
      'notifications': true,
      'soundEnabled': true,
      'vibrationEnabled': true,
      'lastSeenEnabled': true,
      'readReceiptsEnabled': true,
      'typingIndicatorEnabled': true,
    },
    this.deviceInfo = const {
      'platform': '',
      'deviceModel': '',
      'appVersion': '',
      'lastLoginDevice': '',
    },
    this.createdAt,
    this.updatedAt,
    this.isOnline = false,
    this.lastSeen,
    this.isEmailVerified = false,
    this.profileCompleted = false,
    this.totalChats = 0,
    this.totalMessages = 0,
    this.friends = const [],
    this.blockedUsers = const [],
  });

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      status: map['status'] ?? 'Hey there! I am using XtrChat',
      bio: map['bio'] ?? 'Just another chat app user enjoying conversations!',
      phoneNumber: map['phoneNumber'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      location: map['location'] ?? '',
      website: map['website'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      profession: map['profession'] ?? '',
      company: map['company'] ?? '',
      education: map['education'] ?? '',
      gender: map['gender'] ?? '',
      privacy: Map<String, bool>.from(
        map['privacy'] ??
            {
              'showEmail': false,
              'showPhone': false,
              'showLocation': false,
              'showBio': true,
              'showStatus': true,
              'allowFriendRequests': true,
            },
      ),
      settings: Map<String, dynamic>.from(
        map['settings'] ??
            {
              'darkMode': false,
              'notifications': true,
              'soundEnabled': true,
              'vibrationEnabled': true,
              'lastSeenEnabled': true,
              'readReceiptsEnabled': true,
              'typingIndicatorEnabled': true,
            },
      ),
      deviceInfo: Map<String, dynamic>.from(
        map['deviceInfo'] ??
            {
              'platform': '',
              'deviceModel': '',
              'appVersion': '',
              'lastLoginDevice': '',
            },
      ),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen']?.toDate(),
      isEmailVerified: map['isEmailVerified'] ?? false,
      profileCompleted: map['profileCompleted'] ?? false,
      totalChats: map['totalChats'] ?? 0,
      totalMessages: map['totalMessages'] ?? 0,
      friends: List<String>.from(map['friends'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'status': status,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'location': location,
      'website': website,
      'interests': interests,
      'profession': profession,
      'company': company,
      'education': education,
      'gender': gender,
      'privacy': privacy,
      'settings': settings,
      'deviceInfo': deviceInfo,
      'isOnline': isOnline,
      'isEmailVerified': isEmailVerified,
      'profileCompleted': profileCompleted,
      'totalChats': totalChats,
      'totalMessages': totalMessages,
      'friends': friends,
      'blockedUsers': blockedUsers,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? status,
    String? bio,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  // Check if user is online based on last seen time
  bool get isRecentlyActive {
    if (isOnline) return true;
    if (lastSeen == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    // Consider user active if last seen within 5 minutes
    return difference.inMinutes < 5;
  }

  // Get formatted last seen time
  String get lastSeenFormatted {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields =
        8; // displayName, bio, phoneNumber, dateOfBirth, location, profession, interests, photoURL

    if (displayName.isNotEmpty) completedFields++;
    if (bio.isNotEmpty &&
        bio != 'Just another chat app user enjoying conversations!') {
      completedFields++;
    }
    if (phoneNumber.isNotEmpty) completedFields++;
    if (dateOfBirth.isNotEmpty) completedFields++;
    if (location.isNotEmpty) completedFields++;
    if (profession.isNotEmpty) completedFields++;
    if (interests.isNotEmpty) completedFields++;
    if (photoURL.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  // Check if user has completed their profile
  bool get hasCompletedProfile {
    return profileCompletionPercentage >=
        75.0; // 75% completion considered complete
  }

  // Get display name or fallback to email
  String get displayNameOrEmail {
    return displayName.isNotEmpty ? displayName : email.split('@').first;
  }

  // Check if user is a friend
  bool isFriend(String userUid) {
    return friends.contains(userUid);
  }

  // Check if user is blocked
  bool isBlocked(String userUid) {
    return blockedUsers.contains(userUid);
  }

  // Get formatted interests string
  String get formattedInterests {
    if (interests.isEmpty) return 'No interests added';
    if (interests.length <= 3) return interests.join(', ');
    return '${interests.take(3).join(', ')} and ${interests.length - 3} more';
  }

  // Get user status emoji based on activity
  String get statusEmoji {
    if (isOnline) return '🟢';
    if (isRecentlyActive) return '🟡';
    return '⚫';
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, status: $status, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }
}
