import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/contact_service.dart';
import '../models/user_model.dart';
import 'chat_conversation_screen.dart';
import 'add_contact_screen.dart';
import 'synced_contacts_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ContactService _contactService = ContactService();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeContactSync();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getStatusText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else if (user.lastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen!);

      if (difference.inMinutes < 60) {
        return 'Last seen ${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return 'Last seen ${difference.inHours}h ago';
      } else {
        return 'Last seen ${difference.inDays}d ago';
      }
    }
    return 'Last seen recently';
  }

  // Initialize contact sync on screen load
  Future<void> _initializeContactSync() async {
    await _contactService.initializeContactSync();
  }

  // Sync contacts with user confirmation
  Future<void> _syncContacts() async {
    final hasPermission = await _contactService.hasContactPermission();

    if (!hasPermission) {
      final shouldRequest = await _showPermissionDialog();
      if (!shouldRequest) return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      await _contactService.syncContactsWithDatabase();
      await _contactService.findRegisteredContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts synced successfully!'),
            backgroundColor: Color(0xFF13A4EC),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  // Show permission dialog
  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C2327),
            title: const Text(
              'Contact Permission',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'To help you find friends who are already using the app, we need access to your contacts. Your contacts will be securely stored and used only for this purpose.',
              style: TextStyle(color: Color(0xFF9DB0B9)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Deny', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Allow',
                  style: TextStyle(color: Color(0xFF13A4EC)),
                ),
              ),
            ],
          ),
        ) ??
        false;
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
              child: Column(
                children: [
                  // Title bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Synced Contacts Button
                        Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF283339),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SyncedContactsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.contacts_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'View Synced Contacts',
                          ),
                        ),
                        const Text(
                          'Contacts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.015,
                          ),
                        ),
                        MouseRegion(
                          onEnter: (_) => _animationController.forward(),
                          onExit: (_) => _animationController.reverse(),
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Transform.rotate(
                                  angle: (_scaleAnimation.value - 1) * 0.1,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF13A4EC),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddContactScreen(),
                                          ),
                                        );
                                        // Refresh the contacts list if a contact was added
                                        if (result == true) {
                                          setState(() {});
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
                        color: const Color(0xFF283339),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search contacts',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 24,
                          ),
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
          // Contacts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading contacts',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF13A4EC)),
                  );
                }

                final users =
                    snapshot.data?.docs
                        .map(
                          (doc) => UserModel.fromMap(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .where(
                          (user) =>
                              _searchQuery.isEmpty ||
                              user.displayName.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              user.email.toLowerCase().contains(_searchQuery),
                        )
                        .toList() ??
                    [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No contacts yet'
                              : 'No contacts found',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Start by adding some contacts!'
                              : 'Try a different search term',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ContactCard(
                      user: user,
                      statusText: _getStatusText(user),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatConversationScreen(contact: user),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSyncing ? null : _syncContacts,
        backgroundColor: const Color(0xFF13A4EC),
        foregroundColor: Colors.white,
        icon: _isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.sync),
        label: Text(_isSyncing ? 'Syncing...' : 'Sync Contacts'),
      ),
    );
  }
}

class ContactCard extends StatefulWidget {
  final UserModel user;
  final String statusText;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.user,
    required this.statusText,
    required this.onTap,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotationAnimation.value),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2327),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Profile picture with online indicator
                        SizedBox(
                          height: 56,
                          width: 56,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF13A4EC),
                                backgroundImage: widget.user.photoURL.isNotEmpty
                                    ? NetworkImage(widget.user.photoURL)
                                    : null,
                                child: widget.user.photoURL.isEmpty
                                    ? Text(
                                        widget.user.displayName.isNotEmpty
                                            ? widget.user.displayName[0]
                                                  .toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              if (widget.user.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1C2327),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.displayName.isNotEmpty
                                    ? widget.user.displayName
                                    : 'Unknown User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.statusText,
                                style: TextStyle(
                                  color: widget.user.isOnline
                                      ? Colors.green[400]
                                      : Colors.grey[400],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
