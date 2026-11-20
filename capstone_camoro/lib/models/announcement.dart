enum AnnouncementAudience {
  everyone('For everyone', 'For everyone'),
  cea('CEA', 'College of Engineering and Architecture'),
  cmba('CMBA', 'College of Management, Business & Accountancy'),
  caseCollege('CASE', 'College of Arts, Sciences, & Education'),
  cnahs('CNAHS', 'College of Nursing & Allied Health Sciences'),
  ccs('CCS', 'College of Computer Studies'),
  ccj('CCJ', 'College of Criminal Justice'),
  basicEducation('Basic Education', 'Basic Education (SHS and under)');

  const AnnouncementAudience(this.label, this.fullName);

  final String label;
  final String fullName;
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.audience,
    required this.createdAt,
    this.updatedAt,
    this.scheduledFor,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String description;
  final AnnouncementAudience audience;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? scheduledFor;
  final DateTime? publishedAt;

  bool get isScheduled => scheduledFor != null;
  DateTime get displayDate => scheduledFor ?? publishedAt ?? createdAt;
}
