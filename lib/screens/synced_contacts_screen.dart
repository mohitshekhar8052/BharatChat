import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import 'realtime_chat_screen.dart';
import '../models/user_model.dart';

class SyncedContactsScreen extends StatefulWidget {
  const SyncedContactsScreen({super.key});

  @override
  State<SyncedContactsScreen> createState() => _SyncedContactsScreenState();
}

class _SyncedContactsScreenState extends State<SyncedContactsScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyRegistered = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<ContactModel> _filterContacts(List<ContactModel> contacts) {
    List<ContactModel> filtered = contacts;

    // Filter by registration status if needed
    if (_showOnlyRegistered) {
      filtered = filtered.where((contact) => contact.isRegistered).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((contact) {
        return contact.displayName.toLowerCase().contains(_searchQuery) ||
            contact.phoneNumber.contains(_searchQuery) ||
            contact.email.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2327),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Synced Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyRegistered ? Icons.people : Icons.people_outline,
              color: _showOnlyRegistered
                  ? const Color(0xFF13A4EC)
                  : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showOnlyRegistered = !_showOnlyRegistered;
              });
            },
            tooltip: _showOnlyRegistered
                ? 'Show All Contacts'
                : 'Show Registered Only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: const TextStyle(color: Color(0xFF9DB0B9)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9DB0B9)),
                filled: true,
                fillColor: const Color(0xFF283339),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chip
          if (_showOnlyRegistered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Chip(
                label: const Text('Registered Users Only'),
                backgroundColor: const Color(0xFF13A4EC),
                labelStyle: const TextStyle(color: Colors.white),
                deleteIcon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
                onDeleted: () {
                  setState(() {
                    _showOnlyRegistered = false;
                  });
                },
              ),
            ),

          // Contacts List
          Expanded(
            child: StreamBuilder<List<ContactModel>>(
              stream: _contactService.getContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF13A4EC),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading contacts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Color(0xFF9DB0B9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allContacts = snapshot.data ?? [];
                final filteredContacts = _filterContacts(allContacts);

                if (filteredContacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.contacts_outlined,
                          size: 64,
                          color: const Color(0xFF9DB0B9),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No contacts found'
                              : 'No contacts synced yet',
                          style: const TextStyle(
                            color: Color(0xFF9DB0B9),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'Tap "Sync Contacts" to import your contacts',
                          style: const TextStyle(
                            color: Color(0xFF9DB0B9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return _buildContactItem(contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(ContactModel contact) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: contact.isRegistered ? () => _startChat(contact) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2327),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 24,
                  backgroundImage: contact.photoUrl?.isNotEmpty == true
                      ? NetworkImage(contact.photoUrl!)
                      : null,
                  backgroundColor: contact.isRegistered
                      ? const Color(0xFF13A4EC)
                      : const Color(0xFF283339),
                  child: contact.photoUrl?.isEmpty != false
                      ? Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Contact Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (contact.isRegistered) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF13A4EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Registered',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (contact.phoneNumber.isNotEmpty)
                        Text(
                          contact.phoneNumber,
                          style: const TextStyle(
                            color: Color(0xFF9DB0B9),
                            fontSize: 14,
                          ),
                        ),
                      if (contact.email.isNotEmpty &&
                          contact.phoneNumber.isNotEmpty)
                        const SizedBox(height: 2),
                      if (contact.email.isNotEmpty)
                        Text(
                          contact.email,
                          style: const TextStyle(
                            color: Color(0xFF9DB0B9),
                            fontSize: 14,
                          ),
                        ),
                      if (contact.isRegistered)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: contact.isOnline
                                      ? Colors.green
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                contact.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color: contact.isOnline
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Action Button
                if (contact.isRegistered)
                  IconButton(
                    onPressed: () => _startChat(contact),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFF13A4EC),
                    ),
                    tooltip: 'Start Chat',
                  )
                else
                  IconButton(
                    onPressed: () => _inviteContact(contact),
                    icon: const Icon(
                      Icons.person_add_outlined,
                      color: Color(0xFF9DB0B9),
                    ),
                    tooltip: 'Invite to App',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startChat(ContactModel contact) {
    if (contact.userId != null) {
      // Create a UserModel from contact for chat
      final user = UserModel(
        uid: contact.userId!,
        email: contact.email,
        displayName: contact.displayName,
        photoURL: contact.photoUrl ?? '',
        isOnline: contact.isOnline,
        lastSeen: contact.lastSeen,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RealtimeChatScreen(contact: user),
        ),
      );
    }
  }

  void _inviteContact(ContactModel contact) {
    // TODO: Implement invite functionality
    // This could open SMS/Email to send an app invitation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite ${contact.displayName} to join the app!'),
        backgroundColor: const Color(0xFF13A4EC),
        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ),
    );
  }
}
