import 'package:flutter/material.dart';
import 'chat_list_screen.dart';
import 'call_screens.dart';
import '../models/user_model.dart';

class ChatConversationScreen extends StatefulWidget {
  final UserModel contact;

  const ChatConversationScreen({super.key, required this.contact});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  // Sample messages data
  List<Map<String, dynamic>> messages = [
    {
      'text': "Hey there! How's it going?",
      'time': '10:30 AM',
      'isMe': false,
      'avatar':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuApxnWdLUTdTHjr-6-RgWHh5G60bOSUD9I6KLhx0iKH88saVvN1HPxwlfE3Uctf8eO16IJ3siZCuYdrR7UldPg_aKVWX7zS5GLHo6XwS8kB5kzpM8dcoHv-Luv3Jg3KUiLp2taiC7oDxgHzvM4H-Mq2KH8vM9_Gd6q29YS6fJ2QPJeNZrUajW7APqXMYrSl9HxPGfDMk7eF5L9HGQvTQj5Jeb3IKdNyrJLqugVETEF6roYNN6ApvLD5yhDVqjBT7wr_ODJdKaEDbB8',
    },
    {
      'text': "Hi Alex! I'm doing great, thanks! How about you?",
      'time': '10:31 AM',
      'isMe': true,
      'avatar': '',
    },
    {
      'text':
          "I'm doing well too, just finished a workout. What are you up to?",
      'time': '10:32 AM',
      'isMe': false,
      'avatar':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBhCOSnhwlE1LR9plCsOuhHhs2-R7hFw5HL5j7ELtUbQGOH0ZGcJcCR-qBkcZ4i_2f9uMu6Ok6wUY3U3bfgotkj3ZRH04NbVBxy0tgtNU0TuUDtK0RuyBDnML418WFJHlbTgZuPGQmwWfM40ONsQAtPFJQ0TJb1KJHvlYErA40ow5ZCkPOctkhgIjgUTpG6ZvNxD64XI5vEAQSr6j3_WTxI8eSf2t8hNH2bL9HXUMlvvWn4T3rNGlAnE2trySvKi5T5nvUF48JvVCE',
    },
    {
      'text':
          "Just relaxing at home, catching up on some reading. Anything exciting happening on your end?",
      'time': '10:33 AM',
      'isMe': true,
      'avatar': '',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'text': _messageController.text.trim(),
        'time': _getCurrentTime(),
        'isMe': true,
        'avatar': '',
      });
    });

    _messageController.clear();
    _scrollToBottom();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${now.minute.toString().padLeft(2, '0')} $period';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF21262D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B949E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.videocam, color: Color(0xFF8B949E)),
                  title: const Text(
                    'Video Call',
                    style: TextStyle(color: Color(0xFFE6EDF3)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          contactName: widget.contact.displayName,
                          contactImage: widget.contact.photoURL,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.call, color: Color(0xFF8B949E)),
                  title: const Text(
                    'Voice Call',
                    style: TextStyle(color: Color(0xFFE6EDF3)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoiceCallScreen(
                          contactName: widget.contact.displayName,
                          contactImage: widget.contact.photoURL,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF8B949E)),
                  title: const Text(
                    'Contact Info',
                    style: TextStyle(color: Color(0xFFE6EDF3)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact info feature coming soon!'),
                        backgroundColor: Color(0xFF13A4EC),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF21262D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B949E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF8B949E)),
                  title: const Text(
                    'Profile Settings',
                    style: TextStyle(color: Color(0xFFE6EDF3)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile settings coming soon!'),
                        backgroundColor: Color(0xFF13A4EC),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF8B949E)),
                  title: const Text(
                    'App Settings',
                    style: TextStyle(color: Color(0xFFE6EDF3)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App settings coming soon!'),
                        backgroundColor: Color(0xFF13A4EC),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF21262D),
          title: const Text(
            'Logout',
            style: TextStyle(color: Color(0xFFE6EDF3)),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Color(0xFF8B949E)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8B949E)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117).withOpacity(0.8),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF21262D), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF8B949E),
                        size: 24,
                      ),
                    ),

                    // Profile info (centered)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 24), // Offset for back button
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  widget.contact.photoURL,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade800,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (widget.contact.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF0D1117),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Text(
                                widget.contact.displayName,
                                style: const TextStyle(
                                  color: Color(0xFFE6EDF3),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.contact.isOnline ? 'Online' : 'Offline',
                                style: const TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Menu button
                    GestureDetector(
                      onTap: _showChatOptions,
                      child: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF8B949E),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(messages[index]);
              },
            ),
          ),

          // Message input and bottom navigation
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117).withOpacity(0.8),
              border: const Border(
                top: BorderSide(color: Color(0xFF21262D), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Message input
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Text input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: const TextStyle(
                                    color: Color(0xFFE6EDF3),
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF8B949E),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              // Photo/attachment button
                              IconButton(
                                onPressed: () {
                                  // Handle photo attachment
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Photo attachment feature'),
                                      backgroundColor: Color(0xFF13A4EC),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_photo_alternate,
                                  color: Color(0xFF8B949E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Send button
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF13A4EC),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom navigation
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF21262D), width: 1),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBottomNavItem(
                            icon: Icons.chat,
                            label: 'Chats',
                            isSelected: _selectedTabIndex == 0,
                            onTap: () {
                              setState(() => _selectedTabIndex = 0);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatListScreen(),
                                ),
                              );
                            },
                          ),
                          _buildBottomNavItem(
                            icon: Icons.group,
                            label: 'Contacts',
                            isSelected: _selectedTabIndex == 1,
                            onTap: () {
                              setState(() => _selectedTabIndex = 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contacts feature coming soon!',
                                  ),
                                  backgroundColor: Color(0xFF13A4EC),
                                ),
                              );
                            },
                          ),
                          _buildBottomNavItem(
                            icon: Icons.person,
                            label: 'Profile',
                            isSelected: _selectedTabIndex == 2,
                            onTap: () {
                              setState(() => _selectedTabIndex = 2);
                              _showProfileOptions();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isMe = message['isMe'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Avatar for received messages
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                message['avatar'],
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isMe
                          ? [const Color(0xFF13A4EC), const Color(0xFF0B8AC4)]
                          : [const Color(0xFF21262D), const Color(0xFF2A2F37)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 8),
                      bottomRight: Radius.circular(isMe ? 8 : 16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    message['text'],
                    style: const TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['time'],
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF13A4EC)
                : const Color(0xFF8B949E),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF13A4EC)
                  : const Color(0xFF8B949E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
