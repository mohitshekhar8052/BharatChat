import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'How do I change my profile picture?',
      answer:
          'Go to Profile > tap on your profile picture > select "Change Photo" > choose from camera or gallery.',
    ),
    FAQItem(
      question: 'How do I delete a message?',
      answer:
          'Long press on the message you want to delete > select "Delete" > choose "Delete for me" or "Delete for everyone".',
    ),
    FAQItem(
      question: 'How do I block a contact?',
      answer:
          'Go to the chat with the contact > tap on their name > select "Block Contact".',
    ),
    FAQItem(
      question: 'How do I change notification settings?',
      answer:
          'Go to Settings > Notifications > customize your notification preferences.',
    ),
    FAQItem(
      question: 'How do I backup my chats?',
      answer:
          'Go to Settings > Chats > Chat Backup > tap "Back Up Now" to create a backup.',
    ),
    FAQItem(
      question: 'How do I change my theme?',
      answer:
          'Go to Profile > Appearance > select your preferred theme (Light, Dark, or System).',
    ),
    FAQItem(
      question: 'How do I enable two-step verification?',
      answer:
          'Go to Settings > Privacy > Two-Step Verification > follow the setup instructions.',
    ),
    FAQItem(
      question: 'How do I report a problem?',
      answer:
          'Go to Help Center > Contact Support > describe your issue and submit.',
    ),
  ];

  final List<GuideItem> guides = [
    GuideItem(
      title: 'Getting Started',
      subtitle: 'Learn the basics of using the app',
      icon: Icons.play_circle_outline,
    ),
    GuideItem(
      title: 'Privacy & Security',
      subtitle: 'Keep your account safe and secure',
      icon: Icons.security,
    ),
    GuideItem(
      title: 'Managing Chats',
      subtitle: 'Tips for organizing your conversations',
      icon: Icons.chat,
    ),
    GuideItem(
      title: 'Troubleshooting',
      subtitle: 'Solutions to common problems',
      icon: Icons.build,
    ),
  ];

  HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help Center'), elevation: 0),
      body: ListView(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Quick Actions
          _buildSection('Quick Actions', [
            _buildActionTile(
              context,
              'Contact Support',
              'Get help from our support team',
              Icons.support_agent,
              () => _showContactSupport(context),
            ),
            _buildActionTile(
              context,
              'Report a Bug',
              'Report technical issues',
              Icons.bug_report,
              () => _showReportBug(context),
            ),
            _buildActionTile(
              context,
              'Feature Request',
              'Suggest new features',
              Icons.lightbulb_outline,
              () => _showFeatureRequest(context),
            ),
          ]),

          // User Guides
          _buildSection(
            'User Guides',
            guides.map((guide) => _buildGuideTile(context, guide)).toList(),
          ),

          // FAQ Section
          _buildSection(
            'Frequently Asked Questions',
            faqItems.map((faq) => _buildFAQTile(context, faq)).toList(),
          ),

          // Additional Resources
          _buildSection('Additional Resources', [
            _buildActionTile(
              context,
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              () => _launchURL(context, 'https://example.com/privacy'),
            ),
            _buildActionTile(
              context,
              'Terms of Service',
              'Read our terms of service',
              Icons.description,
              () => _launchURL(context, 'https://example.com/terms'),
            ),
            _buildActionTile(
              context,
              'Community Guidelines',
              'Learn about our community rules',
              Icons.group,
              () => _launchURL(context, 'https://example.com/guidelines'),
            ),
          ]),

          SizedBox(height: 16),
        ],
      ),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildGuideTile(BuildContext context, GuideItem guide) {
    return ListTile(
      leading: Icon(guide.icon),
      title: Text(guide.title),
      subtitle: Text(guide.subtitle),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => _showGuideDetail(context, guide),
    );
  }

  Widget _buildFAQTile(BuildContext context, FAQItem faq) {
    return ExpansionTile(
      title: Text(faq.question),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(faq.answer, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(context: context, builder: (context) => ContactSupportDialog());
  }

  void _showReportBug(BuildContext context) {
    showDialog(context: context, builder: (context) => ReportBugDialog());
  }

  void _showFeatureRequest(BuildContext context) {
    showDialog(context: context, builder: (context) => FeatureRequestDialog());
  }

  void _showGuideDetail(BuildContext context, GuideItem guide) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GuideDetailScreen(guide: guide)),
    );
  }

  void _launchURL(BuildContext context, String url) {
    // Show a dialog with the URL since we don't have url_launcher
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('External Link'),
        content: Text('This would open: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ContactSupportDialog extends StatefulWidget {
  const ContactSupportDialog({super.key});

  @override
  _ContactSupportDialogState createState() => _ContactSupportDialogState();
}

class _ContactSupportDialogState extends State<ContactSupportDialog> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Technical Issue',
    'Account Problem',
    'Privacy Concern',
    'Billing',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Contact Support'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Simulate sending support request
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Support request sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}

class ReportBugDialog extends StatefulWidget {
  const ReportBugDialog({super.key});

  @override
  _ReportBugDialogState createState() => _ReportBugDialogState();
}

class _ReportBugDialogState extends State<ReportBugDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report a Bug'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Bug Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what happened...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _stepsController,
              decoration: InputDecoration(
                labelText: 'Steps to Reproduce',
                hintText: '1. Go to...\n2. Click on...\n3. See error',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bug report submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

class FeatureRequestDialog extends StatefulWidget {
  const FeatureRequestDialog({super.key});

  @override
  _FeatureRequestDialogState createState() => _FeatureRequestDialogState();
}

class _FeatureRequestDialogState extends State<FeatureRequestDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Feature Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Feature Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the feature you\'d like to see...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Feature request submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

class GuideDetailScreen extends StatelessWidget {
  final GuideItem guide;

  const GuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(guide.title), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              guide.icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              guide.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              guide.subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            Text(
              'This guide will help you ${guide.subtitle.toLowerCase()}. '
              'Follow the steps below to get started.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Guide content coming soon!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class GuideItem {
  final String title;
  final String subtitle;
  final IconData icon;

  GuideItem({required this.title, required this.subtitle, required this.icon});
}
