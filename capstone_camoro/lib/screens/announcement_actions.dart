import 'package:flutter/material.dart';

import '../data/announcement_store.dart';
import '../models/announcement.dart';
import 'announcement_editor_screen.dart';

Future<bool> openAnnouncementEditor(
  BuildContext context,
  AnnouncementStore store, {
  Announcement? announcement,
}) async {
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) =>
          AnnouncementEditorScreen(store: store, announcement: announcement),
    ),
  );
  if (!context.mounted || saved != true) return false;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          announcement == null
              ? 'Announcement published.'
              : 'Announcement updated.',
        ),
      ),
    );
  return true;
}

Future<bool> deleteAnnouncement(
  BuildContext context,
  AnnouncementStore store,
  Announcement announcement,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete announcement?'),
      content: Text(
        '“${announcement.title}” will be removed from the board and saved announcements.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (!context.mounted || confirmed != true) return false;
  store.delete(announcement.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Announcement deleted.')));
  return true;
}
