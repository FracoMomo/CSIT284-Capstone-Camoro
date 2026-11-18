import 'package:flutter/material.dart';

import '../data/dummy_announcements.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: SafeArea(
        child: ListView.separated(
          itemCount: dummyAnnouncements.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final announcement = dummyAnnouncements[index];
            return ListTile(
              title: Text(announcement.title),
              subtitle: Text(announcement.description),
            );
          },
        ),
      ),
    );
  }
}
