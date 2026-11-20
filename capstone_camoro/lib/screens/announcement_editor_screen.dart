import 'package:flutter/material.dart';

import '../data/announcement_store.dart';
import '../models/announcement.dart';

class AnnouncementEditorScreen extends StatefulWidget {
  const AnnouncementEditorScreen({
    super.key,
    required this.store,
    this.announcement,
  });

  final AnnouncementStore store;
  final Announcement? announcement;

  @override
  State<AnnouncementEditorScreen> createState() =>
      _AnnouncementEditorScreenState();
}

class _AnnouncementEditorScreenState extends State<AnnouncementEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late AnnouncementAudience _audience;
  late bool _schedule;
  DateTime? _scheduledFor;
  bool _allowPop = false;

  bool get _editing => widget.announcement != null;
  bool get _hasChanges =>
      _title.text != (widget.announcement?.title ?? '') ||
      _description.text != (widget.announcement?.description ?? '') ||
      _audience !=
          (widget.announcement?.audience ?? AnnouncementAudience.everyone) ||
      _schedule != (widget.announcement?.isScheduled ?? false) ||
      (_schedule && _scheduledFor != widget.announcement?.scheduledFor);

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.announcement?.title ?? '');
    _description = TextEditingController(
      text: widget.announcement?.description ?? '',
    );
    _audience = widget.announcement?.audience ?? AnnouncementAudience.everyone;
    _schedule = widget.announcement?.isScheduled ?? false;
    _scheduledFor = widget.announcement?.scheduledFor;
    _title.addListener(_changed);
    _description.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    if (_allowPop) return;
    final discard =
        !_hasChanges ||
        await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text('Your changes have not been saved.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep editing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Discard'),
                  ),
                ],
              ),
            ) ==
            true;
    if (!mounted || !discard) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _save() {
    if (_allowPop) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Announcement? saved;
    if (_editing) {
      final updated = widget.store.update(
        id: widget.announcement!.id,
        title: _title.text,
        description: _description.text,
        audience: _audience,
        scheduledFor: _schedule ? _scheduledFor : null,
      );
      if (!updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This announcement no longer exists.')),
        );
        return;
      }
      saved = widget.store.find(widget.announcement!.id);
    } else {
      saved = widget.store.create(
        title: _title.text,
        description: _description.text,
        audience: _audience,
        scheduledFor: _schedule ? _scheduledFor : null,
      );
    }
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, saved);
    });
  }

  Future<void> _pickSchedule() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _scheduledFor != null && _scheduledFor!.isAfter(now)
        ? _scheduledFor!
        : now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateUtils.dateOnly(now),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted || time == null) return;
    setState(
      () => _scheduledFor = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop || !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing ? 'Edit announcement' : 'New announcement'),
          leading: BackButton(onPressed: _leave),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _editing
                            ? 'Update the details below.'
                            : 'Share an update with your school.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const ValueKey('announcement-title'),
                        controller: _title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 120,
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter a title.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<AnnouncementAudience>(
                        initialValue: _audience,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Audience',
                        ),
                        items: [
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
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const ValueKey('announcement-body'),
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Announcement',
                          hintText: 'Write your announcement here…',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        minLines: 8,
                        maxLines: 16,
                        maxLength: 5000,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter the announcement text.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (!_editing || widget.announcement!.isScheduled) ...[
                        Text(
                          'Publication',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('Publish now'),
                            ),
                            ButtonSegment(value: true, label: Text('Schedule')),
                          ],
                          selected: {_schedule},
                          onSelectionChanged: (values) =>
                              setState(() => _schedule = values.single),
                        ),
                        const SizedBox(height: 16),
                        if (_schedule) ...[
                          FormField<DateTime>(
                            key: const ValueKey('schedule-date'),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (_) {
                              if (_scheduledFor == null) {
                                return 'Choose a date and time.';
                              }
                              if (!_scheduledFor!.isAfter(DateTime.now())) {
                                return 'Choose a future date and time.';
                              }
                              return null;
                            },
                            builder: (field) {
                              final localizations = MaterialLocalizations.of(
                                context,
                              );
                              final date = _scheduledFor;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      await _pickSchedule();
                                      if (mounted) {
                                        field.didChange(_scheduledFor);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.calendar_month_outlined,
                                    ),
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        date == null
                                            ? 'Choose date and time'
                                            : '${localizations.formatMediumDate(date)}, ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}',
                                      ),
                                    ),
                                  ),
                                  if (field.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        field.errorText!,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Uses this device’s local time.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                      Text(
                        _schedule
                            ? 'Hidden from students until the scheduled time. In demo mode, keep the app open for it to publish.'
                            : 'Visible to students as soon as you ${_editing ? 'save' : 'publish'}.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _save,
                        icon: Icon(
                          _schedule
                              ? Icons.schedule
                              : _editing
                              ? Icons.check
                              : Icons.send_outlined,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _schedule
                                ? (_editing
                                      ? 'Save schedule'
                                      : 'Schedule announcement')
                                : _editing
                                ? 'Save changes'
                                : 'Publish announcement',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
