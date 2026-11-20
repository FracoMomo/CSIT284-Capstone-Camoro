import 'package:flutter/material.dart';

import '../data/announcement_store.dart';
import '../models/announcement.dart';
import 'announcement_editor_screen.dart';

List<PopupMenuEntry<String>> announcementMenuItems(Announcement announcement) =>
    [
      if (announcement.isArchived)
        const PopupMenuItem(value: 'restore', child: Text('Restore'))
      else ...[
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'archive', child: Text('Archive')),
      ],
      const PopupMenuItem(value: 'delete', child: Text('Delete')),
    ];

Future<bool> changeAnnouncementArchive(
  BuildContext context,
  AnnouncementStore store,
  Announcement announcement,
) async {
  final restoring = announcement.isArchived;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        restoring ? 'Restore announcement?' : 'Archive announcement?',
      ),
      content: Text(
        restoring
            ? '“${announcement.title}” will be published and visible to students now.'
            : announcement.isScheduled
            ? '“${announcement.title}” will move to Archive and its scheduled publication will be canceled.'
            : '“${announcement.title}” will move to Archive and be hidden from students.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(restoring ? 'Restore and publish' : 'Archive'),
        ),
      ],
    ),
  );
  if (!context.mounted || confirmed != true) return false;
  final changed = restoring
      ? store.restore(announcement.id)
      : store.archive(announcement.id);
  if (!changed) return false;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          restoring ? 'Announcement restored.' : 'Announcement archived.',
        ),
      ),
    );
  return true;
}

Future<Announcement?> openAnnouncementEditor(
  BuildContext context,
  AnnouncementStore store, {
  Announcement? announcement,
}) async {
  final saved = await Navigator.of(context).push<Announcement>(
    MaterialPageRoute(
      builder: (context) =>
          AnnouncementEditorScreen(store: store, announcement: announcement),
    ),
  );
  if (!context.mounted || saved == null) return null;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          saved.isScheduled
              ? 'Announcement scheduled.'
              : announcement == null || announcement.isScheduled
              ? 'Announcement published.'
              : 'Announcement updated.',
        ),
      ),
    );
  return saved;
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
