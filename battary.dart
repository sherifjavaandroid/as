import 'dart:async';
import 'dart:math';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// 1. Continuous GPS tracking without throttling
class BatteryDrainingGPSWidget extends StatefulWidget {
  @override
  _BatteryDrainingGPSWidgetState createState() => _BatteryDrainingGPSWidgetState();
}

class _BatteryDrainingGPSWidgetState extends State<BatteryDrainingGPSWidget> {
  StreamSubscription<Position>? _positionStreamSubscription;
  String _locationData = "Waiting for location";

  @override
  void initState() {
    super.initState();
    // Problem: High accuracy GPS with no distanceFilter and very frequent updates
    // This will drain battery quickly as it continuously uses GPS
    _startLocationTracking();
  }

  void _startLocationTracking() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Highest accuracy - uses more battery
      distanceFilter: 0, // Update on any movement - inefficient
      timeLimit: null, // No time limit between updates
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _locationData = 'LAT: ${position.latitude}, LNG: ${position.longitude}';
      });
      
      // Problem: No actual need for the data, just collecting constantly
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_locationData);
  }
}

// 2. Continuous network polling
class BatteryDrainingNetworkWidget extends StatefulWidget {
  @override
  _BatteryDrainingNetworkWidgetState createState() => _BatteryDrainingNetworkWidgetState();
}

class _BatteryDrainingNetworkWidgetState extends State<BatteryDrainingNetworkWidget> {
  Timer? _timer;
  String _apiData = "No data";

  @override
  void initState() {
    super.initState();
    // Problem: Polling a network resource extremely frequently (every second)
    // This drains battery due to constant network activity and radio usage
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _fetchDataFromApi();
    });
  }

  Future<void> _fetchDataFromApi() async {
    try {
      // Constant HTTP requests drain battery
      final response = await http.get(Uri.parse('https://api.example.com/data'));
      if (mounted) {
        setState(() {
          _apiData = response.body;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_apiData);
  }
}

// 3. Intensive computation on main thread
class BatteryDrainingComputationWidget extends StatefulWidget {
  @override
  _BatteryDrainingComputationWidgetState createState() => _BatteryDrainingComputationWidgetState();
}

class _BatteryDrainingComputationWidgetState extends State<BatteryDrainingComputationWidget> {
  Timer? _timer;
  String _result = "No result";

  @override
  void initState() {
    super.initState();
    // Problem: Running intensive calculations repeatedly on main thread
    // This keeps CPU busy and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _performHeavyCalculation();
    });
  }

  void _performHeavyCalculation() {
    // Simulating a heavy calculation that blocks the main thread
    double result = 0;
    for (int i = 0; i < 10000000; i++) {
      result += sin(i.toDouble()) * cos(i.toDouble());
    }
    
    setState(() {
      _result = "Result: $result";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_result);
  }
}

// 4. Excessive sensor usage
class BatteryDrainingSensorsWidget extends StatefulWidget {
  @override
  _BatteryDrainingSensorsWidgetState createState() => _BatteryDrainingSensorsWidgetState();
}

class _BatteryDrainingSensorsWidgetState extends State<BatteryDrainingSensorsWidget> {
  List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  String _accelerometerData = "Waiting for data";
  String _gyroscopeData = "Waiting for data";
  String _magnetometerData = "Waiting for data";

  @override
  void initState() {
    super.initState();
    // Problem: Subscribing to all sensors at highest update frequency
    // This keeps sensors active constantly, draining battery
    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _accelerometerData = 'X: ${event.x}, Y: ${event.y}, Z: ${event.z}';
        });
      })
    );

    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          _gyroscopeData = 'X: ${event.x}, Y: ${event.y}, Z: ${event.z}';
        });
      })
    );

    _streamSubscriptions.add(
      magnetometerEvents.listen((MagnetometerEvent event) {
        setState(() {
          _magnetometerData = 'X: ${event.x}, Y: ${event.y}, Z: ${event.z}';
        });
      })
    );
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_accelerometerData),
        Text(_gyroscopeData),
        Text(_magnetometerData),
      ],
    );
  }
}

// 5. Camera constantly running
class BatteryDrainingCameraWidget extends StatefulWidget {
  @override
  _BatteryDrainingCameraWidgetState createState() => _BatteryDrainingCameraWidgetState();
}

class _BatteryDrainingCameraWidgetState extends State<BatteryDrainingCameraWidget> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Problem: Using highest resolution and keeping the camera on constantly
    // Camera is one of the biggest battery drains
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.max, // Highest resolution - more battery usage
      enableAudio: true, // Audio recording also drains battery
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    
    // Start continuous video recording but don't save it anywhere
    // Just keeping camera active
    await _controller!.startImageStream((image) {
      // Process every single frame - very battery intensive
      // But not actually using the data for anything important
    });

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_controller!);
  }
}

// 6. Multiple background tasks and isolates
class BatteryDrainingBackgroundTasksWidget extends StatefulWidget {
  @override
  _BatteryDrainingBackgroundTasksWidgetState createState() => _BatteryDrainingBackgroundTasksWidgetState();
}

class _BatteryDrainingBackgroundTasksWidgetState extends State<BatteryDrainingBackgroundTasksWidget> {
  List<Isolate> _isolates = [];

  @override
  void initState() {
    super.initState();
    // Problem: Creating multiple isolates for background work
    // This keeps multiple CPU cores busy and drains battery
    _startMultipleBackgroundTasks();
  }

  Future<void> _startMultipleBackgroundTasks() async {
    // Start 4 isolates that just do busy work
    for (int i = 0; i < 4; i++) {
      final receivePort = ReceivePort();
      Isolate isolate = await Isolate.spawn(_isolateFunction, receivePort.sendPort);
      _isolates.add(isolate);
    }
  }

  static void _isolateFunction(SendPort sendPort) {
    // Continuous work that never ends
    while (true) {
      // Busy work that consumes CPU
      List<double> calculations = [];
      for (int i = 0; i < 1000000; i++) {
        calculations.add(sqrt(i.toDouble()));
      }
    }
  }

  @override
  void dispose() {
    for (final isolate in _isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('${_isolates.length} background tasks running');
  }
}

// 7. Excessive file I/O operations
class BatteryDrainingFileIOWidget extends StatefulWidget {
  @override
  _BatteryDrainingFileIOWidgetState createState() => _BatteryDrainingFileIOWidgetState();
}

class _BatteryDrainingFileIOWidgetState extends State<BatteryDrainingFileIOWidget> {
  Timer? _timer;
  int _filesWritten = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Constant file writing operations
    // This keeps flash memory busy and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _writeRandomFileToStorage();
    });
  }

  Future<void> _writeRandomFileToStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/file_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      // Generate large random data
      final random = Random();
      final buffer = StringBuffer();
      for (int i = 0; i < 10000; i++) {
        buffer.write('${random.nextDouble()},');
      }
      
      // Write to storage
      await file.writeAsString(buffer.toString());
      
      setState(() {
        _filesWritten++;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Files written: $_filesWritten');
  }
}

// 8. Continuous Bluetooth scanning
class BatteryDrainingBluetoothWidget extends StatefulWidget {
  @override
  _BatteryDrainingBluetoothWidgetState createState() => _BatteryDrainingBluetoothWidgetState();
}

class _BatteryDrainingBluetoothWidgetState extends State<BatteryDrainingBluetoothWidget> {
  // Note: You would need flutter_blue or similar package for actual implementation
  Timer? _timer;
  int _scanCount = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Continuous Bluetooth scanning
    // This keeps Bluetooth radio active and drains battery
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      // Simulating constant BT scanning
      setState(() {
        _scanCount++;
      });
      // In real code, you would do:
      // FlutterBlue.instance.startScan(timeout: Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Bluetooth scans: $_scanCount');
  }
}

// 9. Excessive screen updates and animations
class BatteryDrainingAnimationWidget extends StatefulWidget {
  @override
  _BatteryDrainingAnimationWidgetState createState() => _BatteryDrainingAnimationWidgetState();
}

class _BatteryDrainingAnimationWidgetState extends State<BatteryDrainingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Problem: Constant high-speed animations
    // This forces frequent screen refreshes and GPU usage
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Creating 100 animated widgets that all update constantly
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              color: Color.fromRGBO(
                Random().nextInt(255),
                Random().nextInt(255),
                Random().nextInt(255),
                _controller.value,
              ),
            );
          },
        );
      },
    );
  }
}

// 10. Wake locks preventing sleep
class BatteryDrainingWakeLockWidget extends StatefulWidget {
  @override
  _BatteryDrainingWakeLockWidgetState createState() => _BatteryDrainingWakeLockWidgetState();
}

class _BatteryDrainingWakeLockWidgetState extends State<BatteryDrainingWakeLockWidget> {
  @override
  void initState() {
    super.initState();
    // Problem: Keeping the screen on indefinitely
    // This prevents device from sleeping and drains battery
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    
    // In actual implementation, you would use wakelock package:
    // Wakelock.enable();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    // Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Screen will stay on indefinitely');
  }
}

// 11. Excessive image decoding/rendering
class BatteryDrainingImageProcessingWidget extends StatefulWidget {
  @override
  _BatteryDrainingImageProcessingWidgetState createState() => _BatteryDrainingImageProcessingWidgetState();
}

class _BatteryDrainingImageProcessingWidgetState extends State<BatteryDrainingImageProcessingWidget> {
  Timer? _timer;
  int _imagesProcessed = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Constantly processing images in memory
    // This is CPU intensive and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      setState(() {
        _imagesProcessed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading high-res images repeatedly
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        // Forcing the creation of new image widgets constantly
        // Each requiring full decode and render pipeline
        return Image.network(
          'https://picsum.photos/seed/${_imagesProcessed + index}/500/500',
          cacheHeight: 1000, // Excessive resolution
          cacheWidth: 1000,
        );
      },
    );
  }
}

// 12. Excessive shader compilations with complex UI
class BatteryDrainingComplexUIWidget extends StatefulWidget {
  @override
  _BatteryDrainingComplexUIWidgetState createState() => _BatteryDrainingComplexUIWidgetState();
}

class _BatteryDrainingComplexUIWidgetState extends State<BatteryDrainingComplexUIWidget> {
  Timer? _timer;
  int _rebuildCount = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Constantly rebuilding very complex UI
    // This forces shader recompilations and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 16), (_) { // 60 FPS updates
      setState(() {
        _rebuildCount++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(100, (index) {
        return Positioned(
          left: 100 * sin((_rebuildCount + index) / 10),
          top: 100 * cos((_rebuildCount + index) / 10),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 0.7),
                  Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        );
      }),
    );
  }
}

// 13. Inefficient list rendering with excessive rebuilds
class BatteryDrainingListWidget extends StatefulWidget {
  @override
  _BatteryDrainingListWidgetState createState() => _BatteryDrainingListWidgetState();
}

class _BatteryDrainingListWidgetState extends State<BatteryDrainingListWidget> {
  final _scrollController = ScrollController();
  Timer? _timer;
  List<int> _items = List.generate(10000, (index) => index);

  @override
  void initState() {
    super.initState();
    // Problem: Constantly rebuilding the entire list
    // This causes excessive CPU usage and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() {
        // Rebuilding the entire list just to update one item
        _items = List.generate(10000, (index) => index + Random().nextInt(10));
      });
      
      // Also forcing scroll jumps which cause additional rendering work
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(Random().nextDouble() * 10000);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Not using ListView.builder, forcing all 10000 items to be created at once
    return ListView(
      controller: _scrollController,
      children: _items.map((item) {
        return ListTile(
          title: Text('Item $item'),
          // Creating a new widget for each item on each rebuild
          subtitle: Container(
            height: 50,
            color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 0.3),
          ),
        );
      }).toList(),
    );
  }
}

// 14. Audio playing in background
class BatteryDrainingAudioWidget extends StatefulWidget {
  @override
  _BatteryDrainingAudioWidgetState createState() => _BatteryDrainingAudioWidgetState();
}

class _BatteryDrainingAudioWidgetState extends State<BatteryDrainingAudioWidget> {
  // Note: You would need audioplayers or similar package for actual implementation
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // Problem: Playing audio continuously in background
    // This keeps audio hardware active and drains battery
    _playAudio();
  }

  void _playAudio() {
    // In real code this would be:
    // AudioPlayer().play('url_to_audio.mp3', isLocal: false);
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    // In real code this would be:
    // AudioPlayer().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Audio playing: $_isPlaying');
  }
}

// 15. Heavy database operations on main thread
class BatteryDrainingDatabaseWidget extends StatefulWidget {
  @override
  _BatteryDrainingDatabaseWidgetState createState() => _BatteryDrainingDatabaseWidgetState();
}

class _BatteryDrainingDatabaseWidgetState extends State<BatteryDrainingDatabaseWidget> {
  Timer? _timer;
  int _operationsCount = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Constant heavy database operations
    // This keeps CPU busy and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _performDatabaseOperation();
    });
  }

  void _performDatabaseOperation() {
    // Simulating heavy database work on main thread
    final data = List.generate(10000, (i) => {'id': i, 'value': 'data_$i'});
    
    // Heavy sorting/filtering
    final filtered = data.where((item) => item['id']! % 3 == 0).toList();
    filtered.sort((a, b) => (b['id']! as int).compareTo(a['id']! as int));
    
    setState(() {
      _operationsCount++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Database operations: $_operationsCount');
  }
}

// 16. Inefficient state management causing cascading rebuilds
class BatteryDrainingStateManagementWidget extends StatefulWidget {
  @override
  _BatteryDrainingStateManagementWidgetState createState() => _BatteryDrainingStateManagementWidgetState();
}

class _BatteryDrainingStateManagementWidgetState extends State<BatteryDrainingStateManagementWidget> {
  Timer? _timer;
  int _updateCount = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Frequent state updates causing cascading rebuilds
    // This forces CPU to recalculate layouts and drains battery
    _timer = Timer.periodic(Duration(milliseconds: 16), (_) { // 60 FPS
      setState(() {
        _updateCount++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Each state change rebuilds 100 child widgets
    return Column(
      children: List.generate(100, (index) {
        return InefficientChildWidget(updateCount: _updateCount);
      }),
    );
  }
}

class InefficientChildWidget extends StatefulWidget {
  final int updateCount;
  
  const InefficientChildWidget({Key? key, required this.updateCount}) : super(key: key);

  @override
  _InefficientChildWidgetState createState() => _InefficientChildWidgetState();
}

class _InefficientChildWidgetState extends State<InefficientChildWidget> {
  @override
  Widget build(BuildContext context) {
    // Each rebuild does expensive calculations
    double result = 0;
    for (int i = 0; i < 10000; i++) {
      result += sin(i.toDouble() + widget.updateCount);
    }
    
    return Container(
      height: 10,
      color: Color.fromRGBO(
        (widget.updateCount * 5) % 255,
        (widget.updateCount * 7) % 255,
        (widget.updateCount * 11) % 255,
        1,
      ),
    );
  }
}

// 17. Excessive use of opacity and blending
class BatteryDrainingBlendingWidget extends StatefulWidget {
  @override
  _BatteryDrainingBlendingWidgetState createState() => _BatteryDrainingBlendingWidgetState();
}

class _BatteryDrainingBlendingWidgetState extends State<BatteryDrainingBlendingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Problem: Constant animation with heavy GPU blending
    // This forces GPU to work hard and drains battery
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            return Opacity(
              opacity: (sin(_controller.value * pi * 2 + index) + 1) / 2,
              child: Positioned(
                left: 100 * cos(_controller.value * pi * 2 + index),
                top: 100 * sin(_controller.value * pi * 2 + index),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.5),
                        Colors.blue.withOpacity(0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// 18. Dark mode not implemented
class BatteryDrainingBrightUIWidget extends StatefulWidget {
  @override
  _BatteryDrainingBrightUIWidgetState createState() => _BatteryDrainingBrightUIWidgetState();
}

class _BatteryDrainingBrightUIWidgetState extends State<BatteryDrainingBrightUIWidget> {
  @override
  Widget build(BuildContext context) {
    // Problem: Always using bright white background
    // This uses more power on OLED displays
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  'Very bright UI element',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                // More bright white space
                Container(
                  height: 100,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 19. WebView with heavy JavaScript
class BatteryDrainingWebViewWidget extends StatefulWidget {
  @override
  _BatteryDrainingWebViewWidgetState createState() => _BatteryDrainingWebViewWidgetState();
}

class _BatteryDrainingWebViewWidgetState extends State<BatteryDrainingWebViewWidget> {
  @override
  Widget build(BuildContext context) {
    // Note: You would need webview_flutter package for actual implementation
    
    // Problem: Loading heavy websites with animations and JavaScript
    // This keeps JavaScript engine and rendering engine busy
    return Container(
      // In real code this would be:
      // WebView(
      //   initialUrl: 'https://heavy-animation-site.com',
      //   javascriptMode: JavascriptMode.unrestricted,
      // )
      child: Text('WebView with heavy JavaScript running'),
    );
  }
}

// 20. Multiple simultaneous HTTP downloads
class BatteryDrainingDownloadsWidget extends StatefulWidget {
  @override
  _BatteryDrainingDownloadsWidgetState createState() => _BatteryDrainingDownloadsWidgetState();
}

class _BatteryDrainingDownloadsWidgetState extends State<BatteryDrainingDownloadsWidget> {
  Timer? _timer;
  int _downloadsStarted = 0;

  @override
  void initState() {
    super.initState();
    // Problem: Starting many downloads simultaneously
    // This keeps network radio active and drains battery
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      _startMultipleDownloads();
    });
  }

  Future<void> _startMultipleDownloads() async {
    // Starting 10 simultaneous downloads
    for (int i = 0; i < 10; i++) {
      _downloadLargeFile(i);
    }
    
    setState(() {
      _downloadsStarted += 10;
    });
  }

  Future<void> _downloadLargeFile(int index) async {
    try {
      // Each download is a large file
      final url = 'https://example.com/large_file_${index}.zip';
      await http.get(Uri.parse(url));
      // Not doing anything with the downloaded data
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Downloads started: $_downloadsStarted');
  }
}