import 'package:flutter/material.dart';
import 'create_story_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  // Sample data for stories
  final List<Map<String, dynamic>> stories = [
    {
      'name': 'You',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB308wpAry_53k6TAh0GqbWONnK3qGw8H5LngrckjPDcVrbeYzW9dIk2Uo6iLxtBeQq90kOg3D6IySoeslTHR_KNm0nEkEVbwfwehHoT_YVct5Qw1DpoaT06WLH6EkaGo7Xs0nc1af8fm3zmQ8m1s0ZqxQhz2I1wA9eknRcapcgF7qj8JzCkzYIMVOwb_HK8-S4bZ9R2BiHJ-voMlFPvD3KpTq0A9pR4ogO4h8McF40z6Qz4dtkVt5XhEVp8HDcpT_JCq6W2_UjXBk',
      'isActive': true,
      'hasStory': true,
      'time': '2 min ago',
      'views': 0,
    },
    {
      'name': 'Mohit',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBAkK7ADq8U-6Nf7_zsvT3mhiwchCh0DyOT8PviwhOR0lTHmqb524BS0GYetUnJ6F_CpseSlGGb84q6BEa_B3hn9q-MFXeRz7qZ-9wxQ1h9lJEUmY1lof3EfoXrHcdQ-LCbywTe0Kk7IfzqPhltzCrsYr2zZq2thtXiJQJ4SfzPiUPvpSijsI-8eZefzMt6s3hKua9q1AsvEZnR6xAFl_BKifMrRSJCIIxodKLYv37QbDhLdNr9yYmDzW_xaFi9OFKWaHpji4T5vLw',
      'isActive': false,
      'hasStory': true,
      'time': '5 min ago',
      'views': 12,
    },
    {
      'name': 'Ashraf',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCVBJj2XTpIQQqCJBsP2fmhzu-mdKZl5hZxCKB39azkjeKmqkLMcfw573qYMtIKgyu4GJzAzTy7pI_0GItTWLobUc5ZWw9xgC7PfIkvZegzUw51WVpFhLFKmNcp4sens3ZFqt5iOI__lSmuoojKOhJFi3BXJxvQFpGJIBBni8gD3D3WbcWBQk6TqBfAcgVdNcrmy88_F10qZLmDBBSoQA8GHU7N318hk1s97i6OlEV_O0m1tx79FZXAJUZWt6dRF6kNs9nPeVkKjsvHw',
      'isActive': false,
      'hasStory': true,
      'time': '1 hour ago',
      'views': 45,
    },
    {
      'name': 'Lodu Sharma',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDKfHC_TBizcNUxWZp2MR_k7x56wbu4bOApfiN9bPHVnyTrLMcSZFPFZm_Y9w40OAjKruqHyXWqrU6pLhwxO-K_rWazVeMfhI_aU9GFCi2K3IKt6KuSRWi1aontyd4j1wjfPQaLE7gYk2m8Yl10fN4thyRJVM_jhWZZtH9hr2DRdMbdqf9hoNinl5yxMnJX37UDxL7QJfjX5SUWphAWrMsCW598iNFdhln7XZFjiwZPh2cHQJrHcEMCUIixQOk_vHKoGIweiBuGXb0',
      'isActive': false,
      'hasStory': false,
      'time': null,
      'views': 0,
    },
    {
      'name': 'Vishajit',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAdzawrru3uJ8kMYJpQ8hQx63De1v3slHmTF8C3EcrDgIOexG5hSfgwfQXJ5n2u8XJO7KfyAXiHPFgg4bwqQ9FtslfLnhspX8u9suEMCN2F0AOVFry053KaepgzQD1PkMwi2ye2R3MLLobeeZia2bVsPLsO-UyUyHo2XpnvcWL1Xoyv1Be82J6jt34-E5KQfstSzm6ExtorXlzKzxtP8W1W_nzbwGadI7kROCfohE69dOMUIeKUlb1_rq515l0diS3PgYEqqYnxZEg',
      'isActive': false,
      'hasStory': false,
      'time': null,
      'views': 0,
    },
    {
      'name': 'Mulkit',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAa3zp2FTTADz9-M5hEKpllYmDCGtJtS_bzDvOOQ99VdBjHvbxszCMOe2iZOPLvByuBXA4fyXbcTIMIJ_-x67gIBNedTw5GW5w1ttmZ9bZY66Iv4jKt-RSv5j-mIV_Nfwb7Ar-E7vT9sjeUffTZfJEOeWuFyqM52ytZZdX-cNSM4c2qrMC3G0Ccwm85mwSKR90DTzQj9bZC6BbG-kjqQHrJsKC6MpWHwN23Msdwp4j145r6BudLbROq2bVjRfbyjS5Jm6LHe3yfI5M',
      'isActive': false,
      'hasStory': false,
      'time': null,
      'views': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2327),
        elevation: 0,
        title: const Text(
          'Stories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateStoryScreen()),
              );
              // Refresh stories if a new story was created
              if (result == true) {
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // My Story Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Story',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMyStoryItem(),
              ],
            ),
          ),

          const Divider(color: Color(0xFF283339), height: 1),

          // Recent Stories Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recent Stories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: stories
                        .where((story) => story['name'] != 'You')
                        .length,
                    itemBuilder: (context, index) {
                      final filteredStories = stories
                          .where((story) => story['name'] != 'You')
                          .toList();
                      final story = filteredStories[index];
                      return _buildStoryListItem(story);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStoryItem() {
    final myStory = stories.firstWhere((story) => story['name'] == 'You');
    return GestureDetector(
      onTap: () {
        if (myStory['hasStory']) {
          _viewStory(myStory);
        } else {
          _createStory();
        }
      },
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: myStory['hasStory']
                        ? const Color(0xFF13A4EC)
                        : Colors.grey.shade600,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    myStory['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
              ),
              if (!myStory['hasStory'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF13A4EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Story',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myStory['hasStory']
                      ? 'Tap to view your story'
                      : 'Tap to add story',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryListItem(Map<String, dynamic> story) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _viewStory(story),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: story['hasStory']
                      ? const Color(0xFF13A4EC)
                      : Colors.grey.shade600,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  story['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (story['hasStory'] && story['time'] != null)
                    Text(
                      story['time'],
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            if (story['hasStory'] && story['views'] > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${story['views']} views',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _viewStory(Map<String, dynamic> story) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${story['name']}\'s story'),
        backgroundColor: const Color(0xFF13A4EC),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _createStory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateStoryScreen()),
    );
    // Refresh stories if a new story was created
    if (result == true) {
      setState(() {});
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2327),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  'Story Privacy',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Story privacy settings coming soon!'),
                      backgroundColor: Color(0xFF13A4EC),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive, color: Colors.white),
                title: const Text(
                  'Story Archive',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Story archive coming soon!'),
                      backgroundColor: Color(0xFF13A4EC),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
