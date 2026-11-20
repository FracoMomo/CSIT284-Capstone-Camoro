import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import 'dummy_announcements.dart';

// One shared store keeps both demo roles in sync until Firebase is connected.
class AnnouncementStore extends ChangeNotifier {
  AnnouncementStore({List<Announcement>? initialAnnouncements})
    : _announcements = [...(initialAnnouncements ?? dummyAnnouncements)] {
    _announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _nextId =
        _announcements.fold(0, (id, post) => post.id > id ? post.id : id) + 1;
  }

  final List<Announcement> _announcements;
  final Set<int> _savedIds = {};
  late int _nextId;

  List<Announcement> get announcements => List.unmodifiable(_announcements);
  int get savedCount => _savedIds.length;

  Announcement? find(int id) {
    for (final post in _announcements) {
      if (post.id == id) return post;
    }
    return null;
  }

  bool isSaved(int id) => _savedIds.contains(id);

  void toggleSaved(int id) {
    if (find(id) == null) return;
    if (!_savedIds.remove(id)) _savedIds.add(id);
    notifyListeners();
  }

  void create({
    required String title,
    required String description,
    required AnnouncementAudience audience,
  }) {
    _announcements.insert(
      0,
      Announcement(
        id: _nextId++,
        title: title.trim(),
        description: description.trim(),
        audience: audience,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  bool update({
    required int id,
    required String title,
    required String description,
    required AnnouncementAudience audience,
  }) {
    final index = _announcements.indexWhere((post) => post.id == id);
    if (index == -1) return false;
    _announcements[index] = Announcement(
      id: id,
      title: title.trim(),
      description: description.trim(),
      audience: audience,
      createdAt: _announcements[index].createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  void delete(int id) {
    _announcements.removeWhere((post) => post.id == id);
    _savedIds.remove(id);
    notifyListeners();
  }
}
