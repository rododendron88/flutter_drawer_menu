import 'package:flutter/material.dart';
import 'package:flutter_drawer_menu/flutter_drawer_menu.dart';
import 'package:flutter_test/flutter_test.dart';

const _menuKey = ValueKey('menu_container');
const _bodyKey = ValueKey('body_container');

void main() {
  testWidgets('Testing the transition from phone mode to tablet mode and back.',
      (tester) async {
    // Init screen
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(300, 600);

    await tester.pumpWidget(
      const TestApp(),
    );

    // Set tablet screen size and wait
    tester.view.physicalSize = const Size(700, 600);
    await tester.pump(const Duration(seconds: 1));

    // Check menu width (default 300 in tablet mode)
    final menuWidth = tester.getRect(find.byKey(_menuKey)).width;
    expect(300, equals(menuWidth));

    // Set phone screen size and wait
    tester.view.physicalSize = const Size(300, 600);
    await tester.pump(const Duration(seconds: 1));

    // Check body width (== screen width)
    final bodyWidth = tester.getRect(find.byKey(_bodyKey)).width;
    expect(300, equals(bodyWidth));

    // These two avoid the exception 'A Timer is still pending even after the
    // widget tree was disposed.'
    await tester.pumpWidget(const Placeholder());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Testing open|close menu states.', (tester) async {
    // Init screen
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(300, 600);

    await tester.pumpWidget(
      const TestApp(),
    );
    await tester.pump(const Duration(seconds: 1));

    final DrawerMenuState drawerMenuState =
        tester.state(find.byType(DrawerMenu));

    // check initial state
    expect(drawerMenuState.isOpen, equals(false));

    // swipe to right
    await tester.flingFrom(const Offset(100, 100), const Offset(100, 0), 100);
    await tester.pump(const Duration(seconds: 1));
    expect(drawerMenuState.isOpen, equals(true));

    // swipe to left
    await tester.flingFrom(const Offset(100, 100), const Offset(-100, 0), 100);
    await tester.pump(const Duration(seconds: 1));
    expect(drawerMenuState.isOpen, equals(false));

    // These two avoid the exception 'A Timer is still pending even after the
    // widget tree was disposed.'
    await tester.pumpWidget(const Placeholder());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Testing system back handling.', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(300, 600);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DrawerMenu(
                    handleSystemBack: true,
                    menu: Container(key: _menuKey),
                    body: Container(key: _bodyKey),
                  ),
                ));
              },
              child: const Text('Push'),
            );
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // push
    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();

    final DrawerMenuState drawerMenuState =
        tester.state(find.byType(DrawerMenu));

    expect(drawerMenuState.isOpen, equals(false));

    // Try back button while closed
    final dynamic widgetsAppState1 = tester.state(find.byType(WidgetsApp));
    await widgetsAppState1.didPopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DrawerMenu), findsNothing); // route popped

    // Re-pump and push again
    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();

    final DrawerMenuState drawerMenuState2 =
        tester.state(find.byType(DrawerMenu));

    // Open menu
    drawerMenuState2.open(animated: false);
    await tester.pumpAndSettle();
    expect(drawerMenuState2.isOpen, equals(true));

    // Try back button while open
    final dynamic widgetsAppState2 = tester.state(find.byType(WidgetsApp));
    await widgetsAppState2.didPopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(DrawerMenu), findsOneWidget); // route did NOT pop
    expect(drawerMenuState2.isOpen, equals(false)); // menu was closed

    // Pop the route manually to test false parameter
    await widgetsAppState2.didPopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DrawerMenu), findsNothing);

    // Test handleSystemBack: false
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DrawerMenu(
                    handleSystemBack: false,
                    menu: Container(key: _menuKey),
                    body: Container(key: _bodyKey),
                  ),
                ));
              },
              child: const Text('Push'),
            );
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();

    final DrawerMenuState drawerMenuState3 =
        tester.state(find.byType(DrawerMenu));
    drawerMenuState3.open(animated: false);
    await tester.pumpAndSettle();

    final dynamic widgetsAppState3 = tester.state(find.byType(WidgetsApp));
    await widgetsAppState3.didPopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(DrawerMenu), findsNothing); // route popped despite open menu, because handleSystemBack=false

    // avoid pending timer warning
    await tester.pumpWidget(const Placeholder());
    await tester.pump(const Duration(seconds: 1));
  });
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawer = DrawerMenu(
      menu: Container(key: _menuKey),
      body: Container(key: _bodyKey),
    );
    return MaterialApp(
      home: drawer,
    );
  }
}
