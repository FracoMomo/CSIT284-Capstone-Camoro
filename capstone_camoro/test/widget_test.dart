import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_camoro/main.dart';
import 'package:capstone_camoro/models/announcement.dart';

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
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
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
    'student starts on For everyone and can browse and search departments',
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
      await tester.enterText(find.byType(TextField), 'workstation');
      await tester.pumpAndSettle();
      expect(
        find.text('Computer Lab 2 Closed for Maintenance'),
        findsOneWidget,
      );
      await tester.tap(find.text('Saved').last);
      await tester.pumpAndSettle();
      expect(find.text('Nothing saved yet'), findsOneWidget);
      await tester.tap(find.text('Board').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Computer Lab 2 Closed for Maintenance'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'workstation',
      );
      await tester.enterText(find.byType(TextField), 'does not exist');
      await tester.pumpAndSettle();
      expect(find.text('No announcements found'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(find.text('11 announcements · Newest first'), findsOneWidget);
    },
  );

  testWidgets('admin changes reach students and deleted posts leave Saved', (
    tester,
  ) async {
    await phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await logIn(tester, 'admin');
    await tester.tap(find.text('New announcement'));
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
    await tester.tap(find.byTooltip('Announcement actions'));
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
    await tester.tap(find.text('Manage').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Updated campus announcement',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Announcement actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(Card, 'Updated campus announcement'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Announcement actions'));
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
    'publishing a department post opens Manage and preserves the student default',
    (tester) async {
      await phoneSize(tester);
      await tester.pumpWidget(const MyApp());
      await logIn(tester, 'admin');
      await tester.tap(find.text('New announcement'));
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
      expect(find.text('Manage announcements'), findsOneWidget);
      expect(find.text('New CCS update'), findsOneWidget);
      expect(find.text('All announcements').first, findsOneWidget);
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
    await tester.tap(find.text('New announcement'));
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
    await tester.tap(find.text('New announcement'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('announcement-body')));
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
