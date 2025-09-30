import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  String _lastSeenVisibility = 'Everyone';
  String _profilePhotoVisibility = 'Everyone';
  String _statusVisibility = 'Everyone';
  bool _readReceiptsEnabled = true;
  bool _onlineStatusVisible = true;
  bool _typingIndicatorsEnabled = true;
  bool _liveLocationSharingEnabled = false;
  bool _contactsSyncEnabled = true;
  bool _dataAnalyticsEnabled = false;

  final List<String> _visibilityOptions = ['Everyone', 'Contacts', 'Nobody'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSeenVisibility =
          prefs.getString('last_seen_visibility') ?? 'Everyone';
      _profilePhotoVisibility =
          prefs.getString('profile_photo_visibility') ?? 'Everyone';
      _statusVisibility = prefs.getString('status_visibility') ?? 'Everyone';
      _readReceiptsEnabled = prefs.getBool('read_receipts_enabled') ?? true;
      _onlineStatusVisible = prefs.getBool('online_status_visible') ?? true;
      _typingIndicatorsEnabled =
          prefs.getBool('typing_indicators_enabled') ?? true;
      _liveLocationSharingEnabled =
          prefs.getBool('live_location_sharing_enabled') ?? false;
      _contactsSyncEnabled = prefs.getBool('contacts_sync_enabled') ?? true;
      _dataAnalyticsEnabled = prefs.getBool('data_analytics_enabled') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  Widget _buildVisibilityTile({
    required String title,
    required String subtitle,
    required String currentValue,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: currentValue,
        items: _visibilityOptions.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        SizedBox(height: 16),
      ],
    );
  }

  void _showBlockedContactsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlockedContactsScreen()),
    );
  }

  void _showTwoStepVerificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TwoStepVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy Settings'), elevation: 0),
      body: ListView(
        children: [
          _buildSection('Who can see my personal info', [
            _buildVisibilityTile(
              title: 'Last Seen',
              subtitle: 'Who can see when I was last online',
              currentValue: _lastSeenVisibility,
              icon: Icons.access_time,
              onChanged: (value) {
                setState(() {
                  _lastSeenVisibility = value;
                });
                _saveSetting('last_seen_visibility', value);
              },
            ),
            _buildVisibilityTile(
              title: 'Profile Photo',
              subtitle: 'Who can see my profile photo',
              currentValue: _profilePhotoVisibility,
              icon: Icons.account_circle,
              onChanged: (value) {
                setState(() {
                  _profilePhotoVisibility = value;
                });
                _saveSetting('profile_photo_visibility', value);
              },
            ),
            _buildVisibilityTile(
              title: 'Status',
              subtitle: 'Who can see my status updates',
              currentValue: _statusVisibility,
              icon: Icons.circle,
              onChanged: (value) {
                setState(() {
                  _statusVisibility = value;
                });
                _saveSetting('status_visibility', value);
              },
            ),
          ]),

          _buildSection('Activity', [
            _buildSwitchTile(
              title: 'Read Receipts',
              subtitle: 'Show when I\'ve read messages',
              value: _readReceiptsEnabled,
              icon: Icons.done_all,
              onChanged: (value) {
                setState(() {
                  _readReceiptsEnabled = value;
                });
                _saveSetting('read_receipts_enabled', value);
              },
            ),
            _buildSwitchTile(
              title: 'Online Status',
              subtitle: 'Show when I\'m online',
              value: _onlineStatusVisible,
              icon: Icons.circle,
              onChanged: (value) {
                setState(() {
                  _onlineStatusVisible = value;
                });
                _saveSetting('online_status_visible', value);
              },
            ),
            _buildSwitchTile(
              title: 'Typing Indicators',
              subtitle: 'Show when I\'m typing',
              value: _typingIndicatorsEnabled,
              icon: Icons.keyboard,
              onChanged: (value) {
                setState(() {
                  _typingIndicatorsEnabled = value;
                });
                _saveSetting('typing_indicators_enabled', value);
              },
            ),
          ]),

          _buildSection('Location', [
            _buildSwitchTile(
              title: 'Live Location Sharing',
              subtitle: 'Allow sharing live location in chats',
              value: _liveLocationSharingEnabled,
              icon: Icons.location_on,
              onChanged: (value) {
                setState(() {
                  _liveLocationSharingEnabled = value;
                });
                _saveSetting('live_location_sharing_enabled', value);
              },
            ),
          ]),

          _buildSection('Contacts', [
            _buildSwitchTile(
              title: 'Sync Contacts',
              subtitle: 'Sync contacts with the app',
              value: _contactsSyncEnabled,
              icon: Icons.contacts,
              onChanged: (value) {
                setState(() {
                  _contactsSyncEnabled = value;
                });
                _saveSetting('contacts_sync_enabled', value);
              },
            ),
          ]),

          _buildSection('Data and Analytics', [
            _buildSwitchTile(
              title: 'Usage Analytics',
              subtitle: 'Help improve the app by sharing usage data',
              value: _dataAnalyticsEnabled,
              icon: Icons.analytics,
              onChanged: (value) {
                setState(() {
                  _dataAnalyticsEnabled = value;
                });
                _saveSetting('data_analytics_enabled', value);
              },
            ),
          ]),

          _buildSection('Security', [
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Blocked Contacts'),
              subtitle: Text('Manage blocked users'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _showBlockedContactsScreen,
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Two-Step Verification'),
              subtitle: Text('Add extra security to your account'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _showTwoStepVerificationScreen,
            ),
          ]),

          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class BlockedContactsScreen extends StatelessWidget {
  const BlockedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blocked Contacts'), elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Blocked Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You haven\'t blocked anyone yet',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({super.key});

  @override
  _TwoStepVerificationScreenState createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  bool _isTwoStepEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadTwoStepStatus();
  }

  Future<void> _loadTwoStepStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTwoStepEnabled =
          prefs.getBool('two_step_verification_enabled') ?? false;
    });
  }

  Future<void> _toggleTwoStepVerification() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTwoStepEnabled = !_isTwoStepEnabled;
    });
    await prefs.setBool('two_step_verification_enabled', _isTwoStepEnabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTwoStepEnabled
              ? 'Two-step verification enabled'
              : 'Two-step verification disabled',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Two-Step Verification'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Two-Step Verification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'For added security, enable two-step verification, which will require a PIN when registering your phone number with the app again.',
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Enable Two-Step Verification'),
                      value: _isTwoStepEnabled,
                      onChanged: (value) => _toggleTwoStepVerification(),
                    ),
                  ],
                ),
              ),
            ),
            if (_isTwoStepEnabled) ...[
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Step Verification is ON',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your account is protected with two-step verification.',
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Change PIN'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Change PIN feature coming soon'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Change Email'),
                        subtitle: Text('Update recovery email'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Change email feature coming soon'),
                            ),
                          );
                        },
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
