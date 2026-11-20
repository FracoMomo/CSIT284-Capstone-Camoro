import 'package:flutter/material.dart';

import '../data/announcement_store.dart';
import '../models/announcement.dart';
import '../models/user_role.dart';
import '../widgets/announcement_metadata.dart';
import 'announcement_actions.dart';
import 'announcement_details_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({
    super.key,
    required this.store,
    required this.role,
    required this.onLogout,
  });

  final AnnouncementStore store;
  final UserRole role;
  final VoidCallback onLogout;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _boardKey = GlobalKey<_AnnouncementFeedState>();
  int _tab = 0;
  bool get _isAdmin => widget.role == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    final labels = ['Board', _isAdmin ? 'Create' : 'Saved', 'Account'];
    final icons = [
      Icons.campaign_outlined,
      _isAdmin ? Icons.add_circle_outline : Icons.bookmark_border,
      Icons.person_outline,
    ];
    final selectedIcons = [
      Icons.campaign,
      _isAdmin ? Icons.add_circle : Icons.bookmark,
      Icons.person,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              ['School announcements', 'Saved announcements', 'Account'][_tab],
            ),
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (wide) ...[
                  NavigationRail(
                    selectedIndex: _tab,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: _selectTab,
                    destinations: [
                      for (var i = 0; i < labels.length; i++)
                        NavigationRailDestination(
                          icon: Icon(icons[i]),
                          selectedIcon: Icon(selectedIcons[i]),
                          label: Text(labels[i]),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                ],
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      _AnnouncementFeed(
                        key: _boardKey,
                        store: widget.store,
                        isAdmin: _isAdmin,
                      ),
                      if (_isAdmin)
                        const SizedBox.shrink()
                      else
                        _AnnouncementFeed(
                          key: const ValueKey('saved'),
                          store: widget.store,
                          isAdmin: false,
                          savedOnly: true,
                        ),
                      _AccountScreen(
                        role: widget.role,
                        onLogout: widget.onLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: _selectTab,
                  destinations: [
                    for (var i = 0; i < labels.length; i++)
                      NavigationDestination(
                        icon: Icon(icons[i]),
                        selectedIcon: Icon(selectedIcons[i]),
                        label: labels[i],
                      ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _selectTab(int index) async {
    FocusScope.of(context).unfocus();
    if (_isAdmin && index == 1) {
      final saved = await openAnnouncementEditor(context, widget.store);
      if (!mounted || saved == null) return;
      setState(() => _tab = 0);
      _boardKey.currentState?.showAnnouncement(saved);
      return;
    }
    setState(() => _tab = index);
  }
}

enum _AudienceFilter { all }

class _AnnouncementFeed extends StatefulWidget {
  const _AnnouncementFeed({
    super.key,
    required this.store,
    required this.isAdmin,
    this.savedOnly = false,
  });

  final AnnouncementStore store;
  final bool isAdmin;
  final bool savedOnly;

  @override
  State<_AnnouncementFeed> createState() => _AnnouncementFeedState();
}

class _AnnouncementFeedState extends State<_AnnouncementFeed> {
  final _scroll = ScrollController();
  late Object _audience;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _audience = widget.savedOnly
        ? _AudienceFilter.all
        : AnnouncementAudience.everyone;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void showAnnouncement(Announcement announcement) {
    setState(() {
      _audience = announcement.audience;
      _scheduled = announcement.isScheduled;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, child) {
        final source = widget.isAdmin && _scheduled
            ? widget.store.scheduledAnnouncements
            : widget.store.publishedAnnouncements;
        final posts = source
            .where(
              (post) =>
                  (!widget.savedOnly || widget.store.isSaved(post.id)) &&
                  (_audience == _AudienceFilter.all ||
                      post.audience == _audience),
            )
            .toList();
        final noSavedPosts = widget.savedOnly && widget.store.savedCount == 0;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.separated(
              controller: _scroll,
              key: PageStorageKey(
                widget.savedOnly ? 'saved-feed' : 'board-feed',
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: posts.isEmpty ? 2 : posts.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.savedOnly
                            ? 'Keep useful updates close.'
                            : 'Updates from across your campus.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      if (widget.isAdmin) ...[
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('Published'),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('Scheduled'),
                            ),
                          ],
                          selected: {_scheduled},
                          onSelectionChanged: (values) => setState(() {
                            _scheduled = values.single;
                            if (_scheduled) _audience = _AudienceFilter.all;
                          }),
                        ),
                        const SizedBox(height: 20),
                      ],
                      DropdownButtonFormField<Object>(
                        initialValue: _audience,
                        key: ValueKey(_audience),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Audience',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: _AudienceFilter.all,
                            child: Text('All announcements'),
                          ),
                          for (final audience in AnnouncementAudience.values)
                            DropdownMenuItem(
                              value: audience,
                              child: Text(audience.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _audience = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${posts.length} ${posts.length == 1 ? 'announcement' : 'announcements'} · ${_scheduled ? 'Next scheduled first' : 'Newest first'}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                }
                if (posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          noSavedPosts
                              ? Icons.bookmark_border
                              : _scheduled
                              ? Icons.schedule
                              : Icons.campaign_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          noSavedPosts
                              ? 'Nothing saved yet'
                              : _scheduled
                              ? 'No scheduled announcements'
                              : 'No announcements here yet',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          noSavedPosts
                              ? 'Tap the bookmark on an announcement to find it here.'
                              : _scheduled
                              ? 'Use Create to schedule a post, or choose another audience.'
                              : 'Try another audience or check back later.',
                          textAlign: TextAlign.center,
                        ),
                        if (!noSavedPosts &&
                            _audience != _AudienceFilter.all) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                setState(() => _audience = _AudienceFilter.all),
                            child: const Text('Show all audiences'),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return _AnnouncementCard(
                  announcement: posts[index - 1],
                  store: widget.store,
                  isAdmin: widget.isAdmin,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.store,
    required this.isAdmin,
  });

  final Announcement announcement;
  final AnnouncementStore store;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailsScreen(
              store: store,
              announcementId: announcement.id,
              isAdmin: isAdmin,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnnouncementMetadata(announcement: announcement),
                  ),
                  if (isAdmin)
                    PopupMenuButton<String>(
                      tooltip: 'Announcement actions',
                      onSelected: (value) {
                        if (value == 'edit') {
                          openAnnouncementEditor(
                            context,
                            store,
                            announcement: announcement,
                          );
                        } else {
                          deleteAnnouncement(context, store, announcement);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    )
                  else
                    IconButton(
                      tooltip: store.isSaved(announcement.id)
                          ? 'Remove bookmark'
                          : 'Bookmark announcement',
                      isSelected: store.isSaved(announcement.id),
                      icon: const Icon(Icons.bookmark_border),
                      selectedIcon: const Icon(Icons.bookmark),
                      onPressed: () {
                        final wasSaved = store.isSaved(announcement.id);
                        store.toggleSaved(announcement.id);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                wasSaved
                                    ? 'Removed from saved announcements.'
                                    : 'Announcement saved.',
                              ),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () =>
                                    store.toggleSaved(announcement.id),
                              ),
                            ),
                          );
                      },
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      announcement.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Read announcement',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountScreen extends StatelessWidget {
  const _AccountScreen({required this.role, required this.onLogout});

  final UserRole role;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 32,
                child: Icon(Icons.person_outline, size: 32),
              ),
            ),
            const SizedBox(height: 20),
            Text('${role.label} account', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              role == UserRole.admin
                  ? 'Manage text announcements for your school and its departments.'
                  : 'Browse campus updates and save announcements to read again.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Role'),
              subtitle: Text(role.label),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text('Demo mode'),
              subtitle: Text(
                'Changes and bookmarks stay while the app is open. Restarting the app resets the sample data.',
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  onLogout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
