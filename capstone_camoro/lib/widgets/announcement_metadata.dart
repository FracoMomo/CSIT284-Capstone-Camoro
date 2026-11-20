import 'package:flutter/material.dart';

import '../models/announcement.dart';

class AnnouncementMetadata extends StatelessWidget {
  const AnnouncementMetadata({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          announcement.audience.label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.primary),
        ),
        Text(
          MaterialLocalizations.of(
            context,
          ).formatMediumDate(announcement.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (announcement.updatedAt != null)
          Text('Edited', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
