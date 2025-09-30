import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or get existing chat between two users
  Future<String> createOrGetChat(String otherUserId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final chatId = _generateChatId(currentUserId!, otherUserId);

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Create new chat
        final newChat = ChatModel(
          id: chatId,
          participants: [currentUserId!, otherUserId],
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          lastMessageSenderId: '',
          unreadCounts: {currentUserId!: 0, otherUserId: 0},
          createdAt: DateTime.now(),
        );

        await _firestore.collection('chats').doc(chatId).set(newChat.toMap());
      }

      return chatId;
    } catch (e) {
      print('Error creating/getting chat: $e');
      throw Exception('Failed to create chat');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    String type = 'text',
    String? imageUrl,
    String? fileUrl,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: currentUserId!,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
        type: type,
        imageUrl: imageUrl,
        fileUrl: fileUrl,
      );

      // Add message to messages subcollection
      final messageRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Update chat document with last message
      await _updateChatLastMessage(chatId, text, receiverId);

      print('Message sent successfully: ${messageRef.id}');
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  // Get real-time messages stream
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get user's chats stream
  Stream<List<ChatModel>> getUserChatsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    if (currentUserId == null) return;

    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Reset unread count for current user
      batch.update(_firestore.collection('chats').doc(chatId), {
        'unreadCounts.$currentUserId': 0,
      });

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Update chat with last message info
  Future<void> _updateChatLastMessage(
    String chatId,
    String message,
    String receiverId,
  ) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);

      await _firestore.runTransaction((transaction) async {
        final chatDoc = await transaction.get(chatRef);

        if (chatDoc.exists) {
          final data = chatDoc.data()!;
          final unreadCounts = Map<String, int>.from(
            data['unreadCounts'] ?? {},
          );

          // Increment unread count for receiver
          unreadCounts[receiverId] = (unreadCounts[receiverId] ?? 0) + 1;

          transaction.update(chatRef, {
            'lastMessage': message,
            'lastMessageTime': DateTime.now().toIso8601String(),
            'lastMessageSenderId': currentUserId,
            'unreadCounts': unreadCounts,
          });
        }
      });
    } catch (e) {
      print('Error updating chat last message: $e');
    }
  }

  // Generate consistent chat ID for two users
  String _generateChatId(String userId1, String userId2) {
    final participants = [userId1, userId2]..sort();
    return participants.join('_');
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message');
    }
  }

  // Get unread message count for a chat
  Future<int> getUnreadCount(String chatId) async {
    if (currentUserId == null) return 0;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final data = chatDoc.data()!;
        final unreadCounts = Map<String, int>.from(data['unreadCounts'] ?? {});
        return unreadCounts[currentUserId] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
