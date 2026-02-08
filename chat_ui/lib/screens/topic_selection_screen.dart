import 'package:flutter/material.dart';
import '../main.dart';
import 'chat_screen.dart';
import 'history_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  _TopicSelectionScreenState createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  String? _hoveredTopic;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Text('Select a Topic', style: TextStyle(fontSize: 18)),
          centerTitle: true,
          actions: [
            Switch(
              value: isDarkMode,
              onChanged: (value) {
                ChatApp.of(context)?.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 24,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            ListTile(
              title: const Text('Law'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen(topic: 'Law')),
                );
              },
            ),
            ListTile(
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen(topic: 'History')),
                );
              },
            ),
            ListTile(
              title: const Text('Rizal Life'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen(topic: 'Rizal Life')),
                );
              },
            ),
            ListTile(
              title: const Text('Science'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen(topic: 'Science')),
                );
              },
            ),
            ListTile(
              title: const Text('Movies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen(topic: 'Movies')),
                );
              },
            ),
            ListTile(
              title: const Text('Sports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen(topic: 'Sports')),
                );
              },
            ),
            ListTile(
              title: const Text('Music'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen(topic: 'Music')),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // You can change this value
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: <Widget>[
              _buildTopicListItem(context, 'Law', Icons.gavel),
              const SizedBox(height: 10.0),
              _buildTopicListItem(context, 'History', Icons.history_edu),
              const SizedBox(height: 10.0),
              _buildTopicListItem(context, 'Rizal Life', Icons.person_search),
              const SizedBox(height: 10.0),
              _buildTopicListItem(context, 'Science', Icons.science),
              const SizedBox(height: 10.0),
              _buildTopicListItem(context, 'Movies', Icons.movie),
              const SizedBox(height: 10.0),
              _buildTopicListItem(context, 'Sports', Icons.sports_baseball),
              const SizedBox(height: 10.0),
              _buildTopicListItem(context, 'Music', Icons.music_note),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicListItem(BuildContext context, String topic, IconData icon) {
    final theme = Theme.of(context);
    final isHovering = _hoveredTopic == topic;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTopic = topic),
      onExit: (_) => setState(() => _hoveredTopic = null),
      child: Card(
        elevation: isHovering ? 10.0 : 4.0, // This will move/lift when hovered
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          hoverColor: theme.hoverColor,
          contentPadding: const EdgeInsets.all(20.0),
          leading: Icon(icon, size: 40.0, color: theme.colorScheme.primary),
          title: Text(
            topic,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen(topic: topic)),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
