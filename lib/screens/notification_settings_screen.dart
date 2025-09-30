import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _messagesNotifications = true;
  bool _callsNotifications = true;
  bool _groupNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _ledNotification = true;
  bool _inAppSounds = true;
  bool _inAppVibration = true;
  bool _showPreview = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _messagesNotifications = prefs.getBool('messages_notifications') ?? true;
      _callsNotifications = prefs.getBool('calls_notifications') ?? true;
      _groupNotifications = prefs.getBool('group_notifications') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _ledNotification = prefs.getBool('led_notification') ?? true;
      _inAppSounds = prefs.getBool('in_app_sounds') ?? true;
      _inAppVibration = prefs.getBool('in_app_vibration') ?? true;
      _showPreview = prefs.getBool('show_preview') ?? true;
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
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

  Future<void> _showTimePicker({
    required String title,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time != null) {
      onTimeSelected(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings'), elevation: 0),
      body: ListView(
        children: [
          _buildSection('Message Notifications', [
            _buildSwitchTile(
              title: 'Messages',
              subtitle: 'Receive notifications for new messages',
              value: _messagesNotifications,
              icon: Icons.message,
              onChanged: (value) {
                setState(() {
                  _messagesNotifications = value;
                });
                _saveSetting('messages_notifications', value);
              },
            ),
            _buildSwitchTile(
              title: 'Group Messages',
              subtitle: 'Receive notifications for group messages',
              value: _groupNotifications,
              icon: Icons.group,
              onChanged: (value) {
                setState(() {
                  _groupNotifications = value;
                });
                _saveSetting('group_notifications', value);
              },
            ),
          ]),

          _buildSection('Call Notifications', [
            _buildSwitchTile(
              title: 'Calls',
              subtitle: 'Receive notifications for incoming calls',
              value: _callsNotifications,
              icon: Icons.call,
              onChanged: (value) {
                setState(() {
                  _callsNotifications = value;
                });
                _saveSetting('calls_notifications', value);
              },
            ),
          ]),

          _buildSection('Sound & Vibration', [
            _buildSwitchTile(
              title: 'Sound',
              subtitle: 'Play sound for notifications',
              value: _soundEnabled,
              icon: Icons.volume_up,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
                _saveSetting('sound_enabled', value);
              },
            ),
            _buildSwitchTile(
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _vibrationEnabled,
              icon: Icons.vibration,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
                _saveSetting('vibration_enabled', value);
              },
            ),
            _buildSwitchTile(
              title: 'LED Notification',
              subtitle: 'Blink LED for notifications',
              value: _ledNotification,
              icon: Icons.lightbulb_outline,
              onChanged: (value) {
                setState(() {
                  _ledNotification = value;
                });
                _saveSetting('led_notification', value);
              },
            ),
          ]),

          _buildSection('In-App Notifications', [
            _buildSwitchTile(
              title: 'In-App Sounds',
              subtitle: 'Play sounds when app is open',
              value: _inAppSounds,
              icon: Icons.music_note,
              onChanged: (value) {
                setState(() {
                  _inAppSounds = value;
                });
                _saveSetting('in_app_sounds', value);
              },
            ),
            _buildSwitchTile(
              title: 'In-App Vibration',
              subtitle: 'Vibrate when app is open',
              value: _inAppVibration,
              icon: Icons.vibration,
              onChanged: (value) {
                setState(() {
                  _inAppVibration = value;
                });
                _saveSetting('in_app_vibration', value);
              },
            ),
          ]),

          _buildSection('Privacy', [
            _buildSwitchTile(
              title: 'Show Preview',
              subtitle: 'Show message content in notifications',
              value: _showPreview,
              icon: Icons.preview,
              onChanged: (value) {
                setState(() {
                  _showPreview = value;
                });
                _saveSetting('show_preview', value);
              },
            ),
          ]),

          _buildSection('Quiet Hours', [
            _buildSwitchTile(
              title: 'Enable Quiet Hours',
              subtitle: 'Silence notifications during specific hours',
              value: _quietHoursEnabled,
              icon: Icons.bedtime,
              onChanged: (value) {
                setState(() {
                  _quietHoursEnabled = value;
                });
                _saveSetting('quiet_hours_enabled', value);
              },
            ),
            if (_quietHoursEnabled) ...[
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Start Time'),
                subtitle: Text(_quietStart.format(context)),
                onTap: () => _showTimePicker(
                  title: 'Quiet Hours Start',
                  initialTime: _quietStart,
                  onTimeSelected: (time) {
                    setState(() {
                      _quietStart = time;
                    });
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.access_time_filled),
                title: Text('End Time'),
                subtitle: Text(_quietEnd.format(context)),
                onTap: () => _showTimePicker(
                  title: 'Quiet Hours End',
                  initialTime: _quietEnd,
                  onTimeSelected: (time) {
                    setState(() {
                      _quietEnd = time;
                    });
                  },
                ),
              ),
            ],
          ]),

          SizedBox(height: 16),
        ],
      ),
    );
  }
}
