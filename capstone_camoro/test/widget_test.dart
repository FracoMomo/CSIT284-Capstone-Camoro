import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_camoro/main.dart';
import 'package:capstone_camoro/models/announcement.dart';
import 'package:capstone_camoro/models/user_role.dart';
import 'package:capstone_camoro/data/announcement_store.dart';
import 'package:capstone_camoro/screens/announcements_screen.dart';
import 'package:capstone_camoro/screens/announcement_details_screen.dart';

Future<void> logIn(WidgetTester tester, String role) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Username'), role);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    '${role}123',
  );
  await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log in'));
  await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
  await tester.pumpAndSettle();
}

Future<void> logOut(WidgetTester tester) async {
  await tester.tap(find.text('Account').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Log out'));
  await tester.pumpAndSettle();
}

Future<void> phoneSize(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> chooseTomorrow(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Choose date and time'));
  await tester.tap(find.text('Choose date and time'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final localizations = MaterialLocalizations.of(
    tester.element(find.byType(DatePickerDialog)),
  );
  await tester.enterText(
    find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byType(TextField),
    ),
    localizations.formatCompactDate(tomorrow),
  );
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('scheduled creation is admin-only and can be published early', (
    tester,
  ) async {
    await phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await logIn(tester, 'admin');
    expect(find.text('Create'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.text('Manage'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('announcement-title')),
      'Scheduled campus notice',
    );
    await tester.enterText(
      find.byKey(const ValueKey('announcement-body')),
      'A future update.',
    );
    await tester.ensureVisible(find.text('Schedule'));
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Schedule announcement'));
    await tester.tap(find.text('Schedule announcement'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a date and time.'), findsOneWidget);
    await chooseTomorrow(tester);
    await tester.ensureVisible(find.text('Schedule announcement'));
    await tester.tap(find.text('Schedule announcement'));
    await tester.pumpAndSettle();
    expect(find.text('Scheduled campus notice'), findsOneWidget);
    expect(find.text('1 announcement · Next scheduled first'), findsOneWidget);
    await logOut(tester);
    await logIn(tester, 'student');
    expect(find.text('Scheduled campus notice'), findsNothing);
    expect(find.text('Scheduled'), findsNothing);
    await logOut(tester);
    await logIn(tester, 'admin');
    await tester.tap(find.text('Scheduled'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scheduled campus notice'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Announcement actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Publish now'));
    await tester.tap(find.text('Publish now'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Scheduled:'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await logOut(tester);
    await logIn(tester, 'student');
    expect(find.text('Scheduled campus notice'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'student board refreshes at publication and blocks scheduled details',
    (tester) async {
      await phoneSize(tester);
      var now = DateTime(2026, 11, 21, 9);
      final store = AnnouncementStore(initialAnnouncements: [], now: () => now);
      final post = store.create(
        title: 'Timed publication',
        description: 'Future text',
        audience: AnnouncementAudience.everyone,
        scheduledFor: now.add(const Duration(minutes: 1)),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: AnnouncementDetailsScreen(
            store: store,
            announcementId: post.id,
            isAdmin: false,
          ),
        ),
      );
      expect(find.text('Future text'), findsNothing);
      expect(
        find.text('This announcement is no longer available.'),
        findsOneWidget,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: AnnouncementsScreen(
            store: store,
            role: UserRole.student,
            onLogout: () {},
          ),
        ),
      );
      expect(find.text('Timed publication'), findsNothing);
      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();
      expect(find.text('Timed publication'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    },
  );

  testWidgets('login validates credentials and can reveal the password', (
    tester,
  ) async {
    await phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'student',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrong',
    );
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect username or password.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'student123',
    );
    await tester.pump();
    expect(find.text('Incorrect username or password.'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'student starts on For everyone, browses departments, and has no search',
    (tester) async {
      await phoneSize(tester);
      await tester.pumpWidget(const MyApp());
      await logIn(tester, 'student');
      expect(find.text('For everyone').first, findsOneWidget);
      expect(find.text('4 announcements · Newest first'), findsOneWidget);
      expect(find.text('New announcement'), findsNothing);
      await tester.tap(find.byType(DropdownButtonFormField<Object>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CCS').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Computer Lab 2 Closed for Maintenance'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Saved').last);
      await tester.pumpAndSettle();
      expect(find.text('Nothing saved yet'), findsOneWidget);
      await tester.tap(find.text('Board').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Computer Lab 2 Closed for Maintenance'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets('admin changes reach students and deleted posts leave Saved', (
    tester,
  ) async {
    await phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await logIn(tester, 'admin');
    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Publish announcement'));
    await tester.tap(find.text('Publish announcement'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a title.'), findsOneWidget);
    expect(find.text('Enter the announcement text.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('announcement-title')),
      'Campus test update',
    );
    await tester.enterText(
      find.byKey(const ValueKey('announcement-body')),
      'First announcement body.',
    );
    await tester.ensureVisible(find.text('Publish announcement'));
    await tester.tap(find.text('Publish announcement'));
    await tester.pumpAndSettle();
    expect(find.text('Campus test update'), findsOneWidget);
    await tester.tap(find.text('Campus test update'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Announcement actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('announcement-title')),
      'Updated campus announcement',
    );
    await tester.enterText(
      find.byKey(const ValueKey('announcement-body')),
      'Updated announcement body.',
    );
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Updated campus announcement'), findsOneWidget);
    expect(find.text('Updated announcement body.'), findsOneWidget);
    expect(find.text('Edited'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await logOut(tester);
    await logIn(tester, 'student');
    expect(find.text('Updated campus announcement'), findsOneWidget);
    await tester.tap(find.byTooltip('Bookmark announcement').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Updated campus announcement'), findsOneWidget);
    await logOut(tester);
    await logIn(tester, 'admin');
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byTooltip('Announcement actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(Card, 'Updated campus announcement'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Announcement actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(Card, 'Updated campus announcement'),
      findsNothing,
    );
    await logOut(tester);
    await logIn(tester, 'student');
    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'publishing a department post shows it on Board and preserves the student default',
    (tester) async {
      await phoneSize(tester);
      await tester.pumpWidget(const MyApp());
      await logIn(tester, 'admin');
      await tester.tap(find.text('Create').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('announcement-title')),
        'New CCS update',
      );
      await tester.enterText(
        find.byKey(const ValueKey('announcement-body')),
        'Computer studies notice.',
      );
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<AnnouncementAudience>),
      );
      await tester.tap(
        find.byType(DropdownButtonFormField<AnnouncementAudience>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('CCS').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Publish announcement'));
      await tester.tap(find.text('Publish announcement'));
      await tester.pumpAndSettle();
      expect(find.text('School announcements'), findsOneWidget);
      expect(find.text('New CCS update'), findsOneWidget);
      expect(find.text('CCS').first, findsOneWidget);
      await logOut(tester);
      await logIn(tester, 'student');
      expect(find.text('New CCS update'), findsNothing);
      expect(find.text('4 announcements · Newest first'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<Object>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CCS').last);
      await tester.pumpAndSettle();
      expect(find.text('New CCS update'), findsOneWidget);
    },
  );

  testWidgets('back navigation protects unsaved announcements', (tester) async {
    await phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await logIn(tester, 'admin');
    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('announcement-title')),
      'Unsaved title',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Unsaved title'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Unsaved title'), findsNothing);
    expect(find.text('School announcements'), findsOneWidget);
  });

  testWidgets('phone, large text, keyboard and desktop layouts stay usable', (
    tester,
  ) async {
    await phoneSize(tester, size: const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    await logIn(tester, 'admin');
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('announcement-body')));
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
