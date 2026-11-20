import 'package:flutter/material.dart';

import '../data/announcement_store.dart';
import '../models/announcement.dart';
import '../widgets/announcement_metadata.dart';
import 'announcement_actions.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({
    super.key,
    required this.store,
    required this.announcementId,
    required this.isAdmin,
  });

  final AnnouncementStore store;
  final int announcementId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, child) {
        final announcement = store.find(announcementId);
        if (announcement == null || (!isAdmin && announcement.isScheduled)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Announcement')),
            body: const Center(
              child: Text('This announcement is no longer available.'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Announcement'),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  tooltip: 'Announcement actions',
                  onSelected: (action) async {
                    if (action == 'edit') {
                      openAnnouncementEditor(
                        context,
                        store,
                        announcement: announcement,
                      );
                    } else {
                      final deleted = await deleteAnnouncement(
                        context,
                        store,
                        announcement,
                      );
                      if (deleted && context.mounted) Navigator.pop(context);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                )
              else
                IconButton(
                  tooltip: store.isSaved(announcementId)
                      ? 'Remove bookmark'
                      : 'Bookmark announcement',
                  isSelected: store.isSaved(announcementId),
                  icon: const Icon(Icons.bookmark_border),
                  selectedIcon: const Icon(Icons.bookmark),
                  onPressed: () => store.toggleSaved(announcementId),
                ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnnouncementMetadata(announcement: announcement),
                      const SizedBox(height: 16),
                      SelectableText(
                        announcement.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (announcement.audience !=
                          AnnouncementAudience.everyone) ...[
                        const SizedBox(height: 12),
                        Text(
                          announcement.audience.fullName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      SelectableText(
                        announcement.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
