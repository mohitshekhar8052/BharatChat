class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final bool isActive;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCounts,
    required this.createdAt,
    this.isActive = true,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  String getChatId(String userId1, String userId2) {
    final participants = [userId1, userId2]..sort();
    return participants.join('_');
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }
}
