import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _searchController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _foundUser;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _foundUser = null;
      _searchQuery = query;
    });

    try {
      // Search by email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        userData['uid'] = querySnapshot.docs.first.id;

        // Check if user is trying to add themselves
        final currentUser = FirebaseAuth.instance.currentUser;
        if (userData['uid'] == currentUser?.uid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You cannot add yourself as a contact'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Check if already a contact
        final contactDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('contacts')
            .doc(userData['uid'])
            .get();

        if (contactDoc.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('This user is already in your contacts'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          setState(() {
            _foundUser = userData;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No user found with email: $query'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addContact() async {
    if (_foundUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final nickname = _nicknameController.text.trim();
      final contactData = {
        'uid': _foundUser!['uid'],
        'name': _foundUser!['name'] ?? 'Unknown',
        'email': _foundUser!['email'],
        'photoURL': _foundUser!['photoURL'],
        'nickname': nickname.isNotEmpty ? nickname : null,
        'addedAt': FieldValue.serverTimestamp(),
        'status': _foundUser!['status'] ?? 'Hey there! I am using this app.',
      };

      // Add to current user's contacts
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('contacts')
          .doc(_foundUser!['uid'])
          .set(contactData);

      // Add current user to the found user's contacts
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final currentUserData = currentUserDoc.data() ?? {};
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_foundUser!['uid'])
          .collection('contacts')
          .doc(currentUser.uid)
          .set({
            'uid': currentUser.uid,
            'name': currentUserData['name'] ?? 'Unknown',
            'email': currentUserData['email'] ?? currentUser.email,
            'photoURL': currentUserData['photoURL'],
            'addedAt': FieldValue.serverTimestamp(),
            'status':
                currentUserData['status'] ?? 'Hey there! I am using this app.',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Contact'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            Text(
              'Search by Email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _searchUser(),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.search),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Search Results
            if (_foundUser != null) ...[
              Text(
                'User Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: _foundUser!['photoURL'] != null
                                ? NetworkImage(_foundUser!['photoURL'])
                                : null,
                            child: _foundUser!['photoURL'] == null
                                ? Icon(Icons.person, size: 30)
                                : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _foundUser!['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _foundUser!['email'] ?? '',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (_foundUser!['status'] != null)
                                  Text(
                                    _foundUser!['status'],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Optional Nickname
                      TextField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: 'Nickname (Optional)',
                          hintText: 'Give this contact a nickname',
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Add Contact Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addContact,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Add Contact',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_searchQuery.isNotEmpty &&
                _foundUser == null &&
                !_isLoading) ...[
              SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No user found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Try searching with a different email',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            if (_searchQuery.isEmpty && _foundUser == null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Add New Contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Search by email to add new contacts',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
