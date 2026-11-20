import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import 'dummy_announcements.dart';

// One shared store keeps both demo roles in sync until Firebase is connected.
class AnnouncementStore extends ChangeNotifier {
  AnnouncementStore({
    List<Announcement>? initialAnnouncements,
    DateTime Function()? now,
  }) : _announcements = [...(initialAnnouncements ?? dummyAnnouncements)],
       _now = now ?? DateTime.now {
    _nextId =
        _announcements.fold(0, (id, post) => post.id > id ? post.id : id) + 1;
    _publishDue();
    _scheduleNextPublication();
  }

  final List<Announcement> _announcements;
  final Set<int> _savedIds = {};
  final DateTime Function() _now;
  Timer? _publicationTimer;
  late int _nextId;

  List<Announcement> get announcements {
    final sorted = [..._announcements]
      ..sort((a, b) => b.displayDate.compareTo(a.displayDate));
    return List.unmodifiable(sorted);
  }

  List<Announcement> get publishedAnnouncements => announcements
      .where((post) => !post.isScheduled && !post.isArchived)
      .toList();
  List<Announcement> get scheduledAnnouncements =>
      announcements.where((post) => post.isScheduled).toList()
        ..sort((a, b) => a.scheduledFor!.compareTo(b.scheduledFor!));
  List<Announcement> get archivedAnnouncements =>
      announcements.where((post) => post.isArchived).toList()
        ..sort((a, b) => b.archivedAt!.compareTo(a.archivedAt!));
  int get savedCount =>
      publishedAnnouncements.where((post) => isSaved(post.id)).length;

  Announcement? find(int id) {
    for (final post in _announcements) {
      if (post.id == id) return post;
    }
    return null;
  }

  bool isSaved(int id) => _savedIds.contains(id);

  void toggleSaved(int id) {
    final post = find(id);
    if (post == null || post.isScheduled || post.isArchived) return;
    if (!_savedIds.remove(id)) _savedIds.add(id);
    notifyListeners();
  }

  Announcement create({
    required String title,
    required String description,
    required AnnouncementAudience audience,
    DateTime? scheduledFor,
  }) {
    _validateSchedule(scheduledFor);
    final now = _now();
    final post = Announcement(
      id: _nextId++,
      title: title.trim(),
      description: description.trim(),
      audience: audience,
      createdAt: now,
      scheduledFor: scheduledFor,
      publishedAt: scheduledFor == null ? now : null,
    );
    _announcements.add(post);
    _scheduleNextPublication();
    notifyListeners();
    return post;
  }

  bool update({
    required int id,
    required String title,
    required String description,
    required AnnouncementAudience audience,
    DateTime? scheduledFor,
  }) {
    final index = _announcements.indexWhere((post) => post.id == id);
    if (index == -1) return false;
    if (_announcements[index].isArchived) return false;
    _validateSchedule(scheduledFor);
    final previous = _announcements[index];
    _announcements[index] = Announcement(
      id: id,
      title: title.trim(),
      description: description.trim(),
      audience: audience,
      createdAt: previous.createdAt,
      updatedAt: _now(),
      scheduledFor: scheduledFor,
      publishedAt: scheduledFor != null
          ? null
          : previous.isScheduled
          ? _now()
          : previous.publishedAt ?? previous.createdAt,
    );
    if (scheduledFor != null) _savedIds.remove(id);
    _scheduleNextPublication();
    notifyListeners();
    return true;
  }

  void delete(int id) {
    _announcements.removeWhere((post) => post.id == id);
    _savedIds.remove(id);
    _scheduleNextPublication();
    notifyListeners();
  }

  bool archive(int id) => _changeArchiveState(id, archive: true);
  bool restore(int id) => _changeArchiveState(id, archive: false);

  bool _changeArchiveState(int id, {required bool archive}) {
    final index = _announcements.indexWhere((post) => post.id == id);
    if (index == -1) return false;
    final previous = _announcements[index];
    if (previous.isArchived == archive) return false;
    _announcements[index] = Announcement(
      id: previous.id,
      title: previous.title,
      description: previous.description,
      audience: previous.audience,
      createdAt: previous.createdAt,
      updatedAt: previous.updatedAt,
      publishedAt: archive
          ? previous.publishedAt ??
                (previous.isScheduled ? null : previous.createdAt)
          : previous.publishedAt ?? _now(),
      archivedAt: archive ? _now() : null,
    );
    _scheduleNextPublication();
    notifyListeners();
    return true;
  }

  void _validateSchedule(DateTime? scheduledFor) {
    if (scheduledFor != null && !scheduledFor.isAfter(_now())) {
      throw ArgumentError('Choose a future date and time.');
    }
  }

  void _publishDue() {
    final now = _now();
    for (var i = 0; i < _announcements.length; i++) {
      final post = _announcements[i];
      if (post.isArchived ||
          post.scheduledFor == null ||
          post.scheduledFor!.isAfter(now)) {
        continue;
      }
      _announcements[i] = Announcement(
        id: post.id,
        title: post.title,
        description: post.description,
        audience: post.audience,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        publishedAt: post.scheduledFor,
      );
    }
  }

  void _scheduleNextPublication() {
    _publicationTimer?.cancel();
    final pending = scheduledAnnouncements;
    if (pending.isEmpty) return;
    final delay = pending.first.scheduledFor!.difference(_now());
    _publicationTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _publishDue();
      _scheduleNextPublication();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _publicationTimer?.cancel();
    super.dispose();
  }
}
