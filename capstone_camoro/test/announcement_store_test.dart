import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_camoro/data/announcement_store.dart';
import 'package:capstone_camoro/models/announcement.dart';

void main() {
  testWidgets(
    'scheduled posts publish at their due time and notify the board',
    (tester) async {
      var now = DateTime(2026, 11, 21, 9);
      final store = AnnouncementStore(initialAnnouncements: [], now: () => now);
      addTearDown(store.dispose);
      var notifications = 0;
      store.addListener(() => notifications++);
      final due = now.add(const Duration(minutes: 5));
      final post = store.create(
        title: 'Later',
        description: 'Scheduled text',
        audience: AnnouncementAudience.ccs,
        scheduledFor: due,
      );
      expect(store.publishedAnnouncements, isEmpty);
      expect(store.scheduledAnnouncements.single.id, post.id);
      store.toggleSaved(post.id);
      expect(store.savedCount, 0);
      now = now.add(const Duration(minutes: 4));
      await tester.pump(const Duration(minutes: 4));
      expect(store.publishedAnnouncements, isEmpty);
      now = due;
      await tester.pump(const Duration(minutes: 1));
      expect(store.scheduledAnnouncements, isEmpty);
      expect(store.publishedAnnouncements.single.publishedAt, due);
      expect(
        store.publishedAnnouncements.single.createdAt,
        DateTime(2026, 11, 21, 9),
      );
      expect(notifications, 2);
    },
  );

  testWidgets(
    'rescheduling, publishing now and deleting cancel pending publication',
    (tester) async {
      var now = DateTime(2026, 11, 21, 9);
      final store = AnnouncementStore(initialAnnouncements: [], now: () => now);
      addTearDown(store.dispose);
      final post = store.create(
        title: 'Later',
        description: 'Text',
        audience: AnnouncementAudience.everyone,
        scheduledFor: now.add(const Duration(minutes: 5)),
      );
      store.update(
        id: post.id,
        title: 'Rescheduled',
        description: 'Text',
        audience: post.audience,
        scheduledFor: now.add(const Duration(minutes: 10)),
      );
      now = now.add(const Duration(minutes: 5));
      await tester.pump(const Duration(minutes: 5));
      expect(store.publishedAnnouncements, isEmpty);
      store.update(
        id: post.id,
        title: 'Publish now',
        description: 'Text',
        audience: post.audience,
      );
      expect(store.publishedAnnouncements.single.publishedAt, now);
      final second = store.create(
        title: 'Delete me',
        description: 'Text',
        audience: post.audience,
        scheduledFor: now.add(const Duration(minutes: 1)),
      );
      store.delete(second.id);
      now = now.add(const Duration(hours: 1));
      await tester.pump(const Duration(hours: 1));
      expect(store.announcements.length, 1);
      expect(store.scheduledAnnouncements, isEmpty);
    },
  );

  test('past schedules are rejected', () {
    final now = DateTime(2026, 11, 21, 9);
    final store = AnnouncementStore(initialAnnouncements: [], now: () => now);
    addTearDown(store.dispose);
    expect(
      () => store.create(
        title: 'Past',
        description: 'Text',
        audience: AnnouncementAudience.everyone,
        scheduledFor: now,
      ),
      throwsArgumentError,
    );
    expect(store.announcements, isEmpty);
  });

  test('edits preserve identity, creation date, order, and bookmarks', () {
    final store = AnnouncementStore(
      initialAnnouncements: [
        Announcement(
          id: 4,
          title: 'Original',
          description: 'Original body',
          audience: AnnouncementAudience.everyone,
          createdAt: DateTime(2026, 11, 1),
        ),
      ],
    );
    addTearDown(store.dispose);
    store.toggleSaved(4);
    store.create(
      title: '  New title  ',
      description: '  New body  ',
      audience: AnnouncementAudience.ccs,
    );
    final post = store.announcements.first;
    expect(post.id, 5);
    expect(post.title, 'New title');
    expect(post.description, 'New body');
    expect(
      store.update(
        id: 4,
        title: 'Edited title',
        description: 'Edited body',
        audience: AnnouncementAudience.cea,
      ),
      isTrue,
    );
    expect(store.find(4)!.createdAt, DateTime(2026, 11, 1));
    expect(store.find(4)!.updatedAt, isNotNull);
    expect(store.find(4)!.audience, AnnouncementAudience.cea);
    expect(store.isSaved(4), isTrue);
    expect(store.announcements.first.id, 5);
  });

  test('deleted announcements cannot leave bookmarks or reuse IDs', () {
    final store = AnnouncementStore(initialAnnouncements: []);
    addTearDown(store.dispose);
    store.create(
      title: 'First',
      description: 'Text',
      audience: AnnouncementAudience.everyone,
    );
    final id = store.announcements.single.id;
    store.toggleSaved(id);
    store.delete(id);
    expect(store.savedCount, 0);
    expect(store.find(id), isNull);
    store.toggleSaved(id);
    expect(store.savedCount, 0);
    expect(
      store.update(
        id: id,
        title: 'Missing',
        description: 'Text',
        audience: AnnouncementAudience.everyone,
      ),
      isFalse,
    );
    store.create(
      title: 'Second',
      description: 'Text',
      audience: AnnouncementAudience.everyone,
    );
    expect(store.announcements.single.id, greaterThan(id));
  });
}
