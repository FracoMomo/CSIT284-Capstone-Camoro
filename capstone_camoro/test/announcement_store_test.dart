import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_camoro/data/announcement_store.dart';
import 'package:capstone_camoro/models/announcement.dart';

void main() {
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
