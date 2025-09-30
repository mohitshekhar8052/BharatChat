import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'chat_conversation_screen.dart';
import 'realtime_chat_list_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for chat list
  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Mohit',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBAkK7ADq8U-6Nf7_zsvT3mhiwchCh0DyOT8PviwhOR0lTHmqb524BS0GYetUnJ6F_CpseSlGGb84q6BEa_B3hn9q-MFXeRz7qZ-9wxQ1h9lJEUmY1lof3EfoXrHcdQ-LCbywTe0Kk7IfzqPhltzCrsYr2zZq2thtXiJQJ4SfzPiUPvpSijsI-8eZefzMt6s3hKua9q1AsvEZnR6xAFl_BKifMrRSJCIIxodKLYv37QbDhLdNr9yYmDzW_xaFi9OFKWaHpji4T5vLw',
      'lastMessage': 'Hey! How are you doing?',
      'time': '10:42 AM',
      'unreadCount': 3,
      'isOnline': true,
    },
    {
      'name': 'Ashraf',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCBqAVtb0CQzDdkuAHPRu-fPd1gSlsuJN7-krYgNwhgjmIS51hwP35zZuiTS8DOh9hNn-kwx8aMUd7qIvHAVtztvBDk-77A4aJ99g3Av5rSyFDTCJYdkig_GtSdRp4mV3ZYYi9fdSCPX1CsVmcutwy4FXdw0ktjXOlYzS04hAdt5Yob1ha4rNBu4U__3RpJdWd1Gt7fHq7KCnJ_udI-fp8pWVmJeUEy2EDy3k1Kr0HddJ1cosybQg3yzGf4BbJhyq3prvdN9_3LNEo',
      'lastMessage': "Let's meet at the cafe tomorrow",
      'time': 'Yesterday',
      'unreadCount': 1,
      'isOnline': false,
    },
    {
      'name': 'Lodu Sharma',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCVBJj2XTpIQQqCJBsP2fmhzu-mdKZl5hZxCKB39azkjeKmqkLMcfw573qYMtIKgyu4GJzAzTy7pI_0GItTWLobUc5ZWw9xgC7PfIkvZegzUw51WVpFhLFKmNcp4sens3ZFqt5iOI__lSmuoojKOhJFi3BXJxvQFpGJIBBni8gD3WbcWBQk6TqBfAcgVdNcrmy88_F10qZLmDBBSoQA8GHU7N318hk1s97i6OlEV_O0m1tx79FZXAJUZWt6dRF6kNs9nPeVkKjsvHw',
      'lastMessage': 'Bro, where are you? 😂',
      'time': 'Monday',
      'unreadCount': 0,
      'isOnline': true,
    },
    {
      'name': 'Vishajit',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAdzawrru3uJ8kMYJpQ8hQx63De1v3slHmTF8C3EcrDgIOexG5hSfgwfQXJ5n2u8XJO7KfyAXiHPFgg4bwqQ9FtslfLnhspX8u9suEMCN2F0AOVFry053KaepgzQD1PkMwi2ye2R3MLLobeeZia2bVsPLsO-UyUyHo2XpnvcWL1Xoyv1Be82J6jt34-E5KQfstSzm6ExtorXlzKzxtP8W1W_nzbwGadI7kROCfohE69dOMUIeKUlb1_rq515l0diS3PgYEqqYnxZEg',
      'lastMessage': "Working on the project deadline",
      'time': 'Sunday',
      'unreadCount': 0,
      'isOnline': false,
    },
    {
      'name': 'Mulkit',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAa3zp2FTTADz9-M5hEKpllYmDCGtJtS_bzDvOOQ99VdBjHvbxszCMOe2iZOPLvByuBXA4fyXbcTIMIJ_-x67gIBNedTw5GW5w1ttmZ9bZY66Iv4jKt-RSv5j-mIV_Nfwb7Ar-E7vT9sjeUffTZfJEOeWuFyqM52ytZZdX-cNSM4c2qrMC3G0Ccwm85mwSKR90DTzQj9bZC6BbG-kjqQHrJsKC6MpWHwN23Msdwp4j145r6BudLbROq2bVjRfbyjS5Jm6LHe3yfI5M',
      'lastMessage': "Good morning! Ready for today?",
      'time': '05/12/2023',
      'unreadCount': 2,
      'isOnline': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF111618).withOpacity(0.8),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title and add button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chats',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF13A4EC),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF13A4EC).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2327),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Chat list
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chat = chats[index];
                    return _buildChatItem(chat);
                  }, childCount: chats.length),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RealtimeChatListScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF13A4EC),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {
        // Navigate to chat conversation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              contact: UserModel(
                uid: 'dummy_uid',
                email: 'dummy@email.com',
                displayName: chat['name'],
                photoURL: chat['image'],
                isOnline: chat['isOnline'],
              ),
            ),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Profile picture with online indicator
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      chat['image'],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                  if (chat['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: const Color(0xFF111618),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Chat details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          chat['time'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat['lastMessage'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat['unreadCount'] > 0)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF13A4EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                chat['unreadCount'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
