import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/dummy_announcements.dart';

enum _BoardFilter { all, bookmarked }

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _bookmarkedIds = ValueNotifier<Set<int>>({});
  Object _filter = _BoardFilter.all;

  @override
  void dispose() {
    _bookmarkedIds.dispose();
    super.dispose();
  }

  void _toggleBookmark(int id) {
    final updatedIds = {..._bookmarkedIds.value};
    if (!updatedIds.remove(id)) updatedIds.add(id);
    _bookmarkedIds.value = updatedIds;
  }

  void _openAnnouncement(Announcement announcement) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AnnouncementDetails(
          announcement: announcement,
          bookmarkedIds: _bookmarkedIds,
          onToggleBookmark: () => _toggleBookmark(announcement.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Filter announcements',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Object>(
                    value: _filter,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: _BoardFilter.all,
                        child: Text('All announcements'),
                      ),
                      for (final audience in AnnouncementAudience.values)
                        DropdownMenuItem(
                          value: audience,
                          child: Text(audience.label),
                        ),
                      const DropdownMenuItem(
                        value: _BoardFilter.bookmarked,
                        child: Text('Bookmarked'),
                      ),
                    ],
                    onChanged: (filter) {
                      if (filter != null) setState(() => _filter = filter);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Set<int>>(
                valueListenable: _bookmarkedIds,
                builder: (context, bookmarkedIds, child) {
                  final announcements = switch (_filter) {
                    _BoardFilter.bookmarked =>
                      dummyAnnouncements
                          .where((post) => bookmarkedIds.contains(post.id))
                          .toList(),
                    AnnouncementAudience audience =>
                      dummyAnnouncements
                          .where((post) => post.audience == audience)
                          .toList(),
                    _ => dummyAnnouncements,
                  };

                  if (announcements.isEmpty) {
                    return Center(
                      child: Text(
                        _filter == _BoardFilter.bookmarked
                            ? 'No bookmarked announcements yet.'
                            : 'No announcements in this category.',
                      ),
                    );
                  }

                  return ListView.builder(
                    key: ValueKey(_filter),
                    padding: const EdgeInsets.all(12),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return _AnnouncementCard(
                        announcement: announcement,
                        isBookmarked: bookmarkedIds.contains(announcement.id),
                        onOpen: () => _openAnnouncement(announcement),
                        onToggleBookmark: () =>
                            _toggleBookmark(announcement.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.isBookmarked,
    required this.onOpen,
    required this.onToggleBookmark,
  });

  final Announcement announcement;
  final bool isBookmarked;
  final VoidCallback onOpen;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  _BookmarkButton(
                    isBookmarked: isBookmarked,
                    onPressed: onToggleBookmark,
                  ),
                ],
              ),
              Text(announcement.audience.label, style: textTheme.labelMedium),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  announcement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementDetails extends StatelessWidget {
  const _AnnouncementDetails({
    required this.announcement,
    required this.bookmarkedIds,
    required this.onToggleBookmark,
  });

  final Announcement announcement;
  final ValueListenable<Set<int>> bookmarkedIds;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
        actions: [
          ValueListenableBuilder<Set<int>>(
            valueListenable: bookmarkedIds,
            builder: (context, ids, child) => _BookmarkButton(
              isBookmarked: ids.contains(announcement.id),
              onPressed: onToggleBookmark,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(announcement.title, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(announcement.audience.fullName, style: textTheme.labelLarge),
              const SizedBox(height: 16),
              Text(announcement.description, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.isBookmarked, required this.onPressed});

  final bool isBookmarked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      isSelected: isBookmarked,
      icon: const Icon(Icons.bookmark_border),
      selectedIcon: const Icon(Icons.bookmark),
      tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark announcement',
      onPressed: onPressed,
    );
  }
}
