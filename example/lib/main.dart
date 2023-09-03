import 'package:flutter/services.dart';
import 'package:flutter_drawer_menu/drawer_menu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawer menu Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Drawer menu Demo'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _controller = DrawerMenuController();
  int _selectedContent = 0;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerMenu(
      controller: _controller,
      menu: _buildMenu(),
      body: _buildBody(),
    );
  }

  Widget _buildMenu() {
    final listView = ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Content $index"),
            ),
            onTap: () {
              _controller.close();
              setState(() {
                _selectedContent = index;
              });
            },
          );
        }
    );

    Widget menu = Container(
      color: Colors.white,
      child: SafeArea(
        child: listView,
      ),
    );

    // Applying status bar and navigation bar theme settings.
    // If you want to configure a transparent navigation bar for Android
    // the same way as in the example, you need to call the following once (e.g., in initState):
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // and set the fields of SystemUiOverlayStyle:
    // systemNavigationBarColor: Colors.transparent,
    // systemNavigationBarContrastEnforced: false,
    menu = AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Android part.
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
        // iOS part.
        // When Android setup dark iOS light one. Hmm.
        statusBarBrightness: Brightness.light,
      ),
      child: menu,
    );

    return menu;
  }

  Widget _buildBody() {
    // The menu button subscribes to changes in the menu mode (tablet|phone).
    Widget leadingWidget = ValueListenableBuilder<bool>(
        valueListenable: _controller.isTabletModeNotifier,
        builder: (context, value, _) {
          if(value) {
            return const SizedBox();
          }
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _controller.open();
            },
          );
        }
    );

    /// PageView part
    Widget pageView = Container(
      color: Colors.black12,
      height: 150,
      child: PageView.builder(
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => Center(
          child: Text(
            "Nested PageView\nPage $index",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    /// Content part
    Widget content = Expanded(
      child: Container(
        color: Colors.black.withOpacity(0.05),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Content $_selectedContent"),
              // scrollPosition subscription (0-1)
              ValueListenableBuilder<double>(
                  valueListenable: _controller.scrollPositionNotifier,
                  builder: (context, value, _) {
                    return Text(value.toStringAsFixed(2));
                  }
              ),
              // isOpen subscription
              ValueListenableBuilder<bool>(
                  valueListenable: _controller.isOpenNotifier,
                  builder: (context, value, _) {
                    return Text(value ? "open": "closed");
                  }
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: leadingWidget,
      ),
      body: Column(
        children: [
          pageView,
          content
        ],
      ),
    );
  }
}

