import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Memory leak due to uncancelled timer
class LeakyTimerWidget extends StatefulWidget {
  @override
  _LeakyTimerWidgetState createState() => _LeakyTimerWidgetState();
}

class _LeakyTimerWidgetState extends State<LeakyTimerWidget> {
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Timer isn't cancelled in dispose()
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  // Missing dispose() method to cancel the timer

  @override
  Widget build(BuildContext context) {
    return Text('Counter: $_counter');
  }
}

// 2. Memory leak due to stream subscription not being closed
class LeakyStreamWidget extends StatefulWidget {
  @override
  _LeakyStreamWidgetState createState() => _LeakyStreamWidgetState();
}

class _LeakyStreamWidgetState extends State<LeakyStreamWidget> {
  StreamController<int> _controller = StreamController<int>();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    // Problem: Stream subscription isn't cancelled in dispose()
    _subscription = _controller.stream.listen((data) {
      setState(() {
        // Do something with data
      });
    });
  }

  // Missing dispose() method to cancel the subscription

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 3. Memory leak in animation controller
class LeakyAnimationWidget extends StatefulWidget {
  @override
  _LeakyAnimationWidgetState createState() => _LeakyAnimationWidgetState();
}

class _LeakyAnimationWidgetState extends State<LeakyAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
    // Problem: Animation controller isn't disposed
  }

  // Missing dispose() method to dispose the animation controller

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 4. Memory leak with static references to context
class LeakyStaticContextWidget extends StatefulWidget {
  @override
  _LeakyStaticContextWidgetState createState() => _LeakyStaticContextWidgetState();
}

class _LeakyStaticContextWidgetState extends State<LeakyStaticContextWidget> {
  // Problem: Static reference to context will persist even when widget is disposed
  static BuildContext? staticContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Leaking the context
    staticContext = context;
    return Container();
  }
}

// 5. Memory leak with event listeners
class LeakyEventListenerWidget extends StatefulWidget {
  @override
  _LeakyEventListenerWidgetState createState() => _LeakyEventListenerWidgetState();
}

class _LeakyEventListenerWidgetState extends State<LeakyEventListenerWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  void _listener() {
    setState(() {
      // Update some state
    });
  }

  @override
  void initState() {
    super.initState();
    // Problem: Adding event listener without removing it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(MyWidgetObserver(_listener));
    });
  }

  // Missing dispose() method to remove the observer

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey);
  }
}

class MyWidgetObserver extends WidgetsBindingObserver {
  final VoidCallback callback;
  
  MyWidgetObserver(this.callback);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    callback();
  }
}

// 6. Memory leak with HTTP client
class LeakyHttpClientWidget extends StatefulWidget {
  @override
  _LeakyHttpClientWidgetState createState() => _LeakyHttpClientWidgetState();
}

class _LeakyHttpClientWidgetState extends State<LeakyHttpClientWidget> {
  http.Client _client = http.Client();
  String _data = '';

  Future<void> _fetchData() async {
    try {
      final response = await _client.get(Uri.parse('https://api.example.com/data'));
      if (mounted) {
        setState(() {
          _data = response.body;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Problem: HTTP client isn't closed
  }

  // Missing dispose() method to close the client

  @override
  Widget build(BuildContext context) {
    return Text(_data);
  }
}

// 7. Memory leak with large data in state
class LeakyLargeDataWidget extends StatefulWidget {
  @override
  _LeakyLargeDataWidgetState createState() => _LeakyLargeDataWidgetState();
}

class _LeakyLargeDataWidgetState extends State<LeakyLargeDataWidget> {
  // Problem: Storing large data in widget state
  List<String> _hugeList = List.generate(10000, (index) => 'Item $index' * 1000);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _hugeList.length,
      itemBuilder: (context, index) => Text(_hugeList[index]),
    );
  }
}

// 8. Memory leak with singleton keeping references
class SingletonManager {
  static final SingletonManager _instance = SingletonManager._internal();
  
  factory SingletonManager() {
    return _instance;
  }
  
  SingletonManager._internal();
  
  // Problem: Keeping strong references to widgets or contexts
  final List<BuildContext> contextReferences = [];
  final Map<String, Widget> widgetReferences = {};
  
  void registerContext(BuildContext context) {
    contextReferences.add(context);
  }
  
  void registerWidget(String key, Widget widget) {
    widgetReferences[key] = widget;
  }
  
  // Missing method to remove references
}

class LeakySingletonWidget extends StatefulWidget {
  @override
  _LeakySingletonWidgetState createState() => _LeakySingletonWidgetState();
}

class _LeakySingletonWidgetState extends State<LeakySingletonWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Leaking the context to singleton
    SingletonManager().registerContext(context);
    // Leaking this widget to singleton
    SingletonManager().registerWidget('myWidget', widget);
    return Container();
  }
}

// 9. Memory leak with image cache
class LeakyImageCacheWidget extends StatefulWidget {
  @override
  _LeakyImageCacheWidgetState createState() => _LeakyImageCacheWidgetState();
}

class _LeakyImageCacheWidgetState extends State<LeakyImageCacheWidget> {
  @override
  void initState() {
    super.initState();
    // Problem: Setting image cache size too large
    PaintingBinding.instance.imageCache.maximumSize = 10000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 * 1024 * 1024; // 1000 MB
  }

  @override
  Widget build(BuildContext context) {
    return Image.network('https://example.com/large_image.jpg');
  }
}

// 10. Memory leak with closures
class LeakyClosureWidget extends StatefulWidget {
  @override
  _LeakyClosureWidgetState createState() => _LeakyClosureWidgetState();
}

class _LeakyClosureWidgetState extends State<LeakyClosureWidget> {
  late VoidCallback _callback;
  final List<String> _data = List.generate(10000, (i) => 'Item $i' * 100);

  @override
  void initState() {
    super.initState();
    // Problem: Creating a closure that captures this instance
    _callback = () {
      // This closure captures the entire state object including _data
      print(_data.length);
    };
    
    // Storing the callback somewhere it won't be released
    GlobalCallbackHolder.instance.registerCallback(_callback);
  }

  // Missing code to unregister the callback

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GlobalCallbackHolder {
  static final GlobalCallbackHolder instance = GlobalCallbackHolder._();
  
  GlobalCallbackHolder._();
  
  final List<VoidCallback> callbacks = [];
  
  void registerCallback(VoidCallback callback) {
    callbacks.add(callback);
  }
}

// 11. Memory leak with notifications
class LeakyNotificationWidget extends StatefulWidget {
  @override
  _LeakyNotificationWidgetState createState() => _LeakyNotificationWidgetState();
}

class _LeakyNotificationWidgetState extends State<LeakyNotificationWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Problem: NotificationListener without proper cleanup
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Captured context in callback
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text('Scrolled!')),
        );
        return true;
      },
      child: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
    );
  }
}

// 12. Memory leak with focus nodes
class LeakyFocusNodeWidget extends StatefulWidget {
  @override
  _LeakyFocusNodeWidgetState createState() => _LeakyFocusNodeWidgetState();
}

class _LeakyFocusNodeWidgetState extends State<LeakyFocusNodeWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        // Update based on focus
      });
    });
  }

  // Missing dispose() method to dispose the focus node

  @override
  Widget build(BuildContext context) {
    return TextField(focusNode: _focusNode);
  }
}

// 13. Memory leak with async operations
class LeakyAsyncWidget extends StatefulWidget {
  @override
  _LeakyAsyncWidgetState createState() => _LeakyAsyncWidgetState();
}

class _LeakyAsyncWidgetState extends State<LeakyAsyncWidget> {
  List<String> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Problem: Not checking if widget is still mounted after async operation
    await Future.delayed(Duration(seconds: 2));
    // No mounted check, might set state after widget is disposed
    setState(() {
      _data = List.generate(1000, (i) => 'Item $i');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) => Text(_data[index]),
    );
  }
}

// 14. Memory leak with InheritedWidget references
class LeakyInheritedWidget extends InheritedWidget {
  final List<String> largeData;

  LeakyInheritedWidget({
    required Widget child,
    required this.largeData,
  }) : super(child: child);

  @override
  bool updateShouldNotify(LeakyInheritedWidget oldWidget) {
    return largeData != oldWidget.largeData;
  }

  // Problem: Static method to access this widget keeps references
  static LeakyInheritedWidget? of(BuildContext context) {
    // Using dependOnInheritedWidgetOfExactType creates a dependency
    return context.dependOnInheritedWidgetOfExactType<LeakyInheritedWidget>();
  }
}

// 15. Memory leak with PageController
class LeakyPageViewWidget extends StatefulWidget {
  @override
  _LeakyPageViewWidgetState createState() => _LeakyPageViewWidgetState();
}

class _LeakyPageViewWidgetState extends State<LeakyPageViewWidget> {
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  // Missing dispose() method to dispose the page controller

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: List.generate(100, (index) => Container(color: Colors.primaries[index % Colors.primaries.length])),
    );
  }
}

// 16. Memory leak with TextEditingController
class LeakyTextFieldWidget extends StatefulWidget {
  @override
  _LeakyTextFieldWidgetState createState() => _LeakyTextFieldWidgetState();
}

class _LeakyTextFieldWidgetState extends State<LeakyTextFieldWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      print(_controller.text);
    });
  }

  // Missing dispose() method to dispose the text controller

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}

// 17. Memory leak with ScrollController
class LeakyScrollControllerWidget extends StatefulWidget {
  @override
  _LeakyScrollControllerWidgetState createState() => _LeakyScrollControllerWidgetState();
}

class _LeakyScrollControllerWidgetState extends State<LeakyScrollControllerWidget> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  // Missing dispose() method to dispose the scroll controller

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: 1000,
      itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
    );
  }
}

// 18. Memory leak with custom painters
class LeakyCustomPainterWidget extends StatefulWidget {
  @override
  _LeakyCustomPainterWidgetState createState() => _LeakyCustomPainterWidgetState();
}

class _LeakyCustomPainterWidgetState extends State<LeakyCustomPainterWidget> {
  // Problem: Large data stored in state and passed to painter
  final List<Offset> _points = List.generate(
    10000, 
    (i) => Offset(i.toDouble(), (i * i).toDouble())
  );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LeakyPainter(_points),
      size: Size(300, 300),
    );
  }
}

class LeakyPainter extends CustomPainter {
  final List<Offset> points;
  
  // Problem: Painter holds reference to large data
  LeakyPainter(this.points);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red..strokeWidth = 1;
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }
  
  @override
  bool shouldRepaint(LeakyPainter oldDelegate) => true;
}

// 19. Memory leak with platform channels
class LeakyPlatformChannelWidget extends StatefulWidget {
  @override
  _LeakyPlatformChannelWidgetState createState() => _LeakyPlatformChannelWidgetState();
}

class _LeakyPlatformChannelWidgetState extends State<LeakyPlatformChannelWidget> {
  static const platform = MethodChannel('com.example.leaky/battery');
  String _batteryLevel = 'Unknown';

  @override
  void initState() {
    super.initState();
    // Problem: Setting up event channel without cleaning up
    EventChannel('com.example.leaky/charging')
        .receiveBroadcastStream()
        .listen((event) {
      if (mounted) {
        setState(() {
          _batteryLevel = '$event%';
        });
      }
    });
  }

  // Missing code to cancel stream subscription

  @override
  Widget build(BuildContext context) {
    return Text('Battery: $_batteryLevel');
  }
}

// 20. Memory leak with bloc pattern
class LeakyBlocWidget extends StatefulWidget {
  @override
  _LeakyBlocWidgetState createState() => _LeakyBlocWidgetState();
}

class _LeakyBlocWidgetState extends State<LeakyBlocWidget> {
  final _bloc = MyLeakyBloc();

  @override
  void initState() {
    super.initState();
    _bloc.streamController.stream.listen((data) {
      setState(() {
        // Update state based on bloc
      });
    });
  }

  // Missing dispose() method to close the bloc

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _bloc.add('event'),
      child: Text('Send Event'),
    );
  }
}

class MyLeakyBloc {
  final streamController = StreamController<String>.broadcast();
  
  void add(String event) {
    streamController.sink.add(event);
  }
  
  // Missing close() method to close the stream controller
}