import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Inefficient List Building - Creating a huge list without ListView.builder
class InefficientListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Creating 1000 widgets at once instead of using ListView.builder
    // This loads all widgets in memory at once instead of lazily loading them
    final List<Widget> allItems = List.generate(1000, (index) {
      return ListTile(
        title: Text('Item $index'),
        subtitle: Text('Description for item $index'),
        leading: Icon(Icons.star),
        trailing: Icon(Icons.arrow_forward_ios),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text('Inefficient List')),
      // Loading all 1000 widgets at once, causing jank when scrolling
      body: SingleChildScrollView(
        child: Column(children: allItems),
      ),
    );
  }
}

// 2. Unnecessary Widget Rebuilds - Not using const constructors
class UnnecessaryRebuildsWidget extends StatefulWidget {
  @override
  _UnnecessaryRebuildsWidgetState createState() => _UnnecessaryRebuildsWidgetState();
}

class _UnnecessaryRebuildsWidgetState extends State<UnnecessaryRebuildsWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Rebuilding entire UnnecessaryRebuildsWidget');
    // Performance Problem: Not using const constructors for static widgets
    // This causes Flutter to rebuild widgets that don't need to change
    return Scaffold(
      appBar: AppBar(
        // Should be const AppBar(title: const Text('Unnecessary Rebuilds')),
        title: Text('Unnecessary Rebuilds'),
      ),
      body: Center(
        // Entire tree rebuilds when only _counter changes
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Should be const Text('You have pushed the button this many times:')
            Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              // Should be style: const TextStyle(fontSize: 24),
              style: TextStyle(fontSize: 24),
            ),
            // These don't change and should be const
            Icon(Icons.add),
            FlutterLogo(size: 100),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(20),
              color: Colors.blue,
              child: Text('Static widget'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

// 3. Heavy Computation on UI Thread
class UIThreadBlockingWidget extends StatefulWidget {
  @override
  _UIThreadBlockingWidgetState createState() => _UIThreadBlockingWidgetState();
}

class _UIThreadBlockingWidgetState extends State<UIThreadBlockingWidget> {
  String _result = 'No calculation yet';

  void _performHeavyCalculation() {
    // Performance Problem: Running heavy computations on the UI thread
    // This blocks the UI and causes the app to freeze temporarily
    setState(() {
      _result = 'Calculating...';
    });
    
    // Expensive calculation that should be done in a separate isolate
    int fibonacci(int n) {
      if (n <= 1) return n;
      return fibonacci(n - 1) + fibonacci(n - 2);
    }
    
    // This will block the UI for several seconds
    final result = fibonacci(45);
    
    setState(() {
      _result = 'Result: $result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UI Thread Blocking')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performHeavyCalculation,
              child: Text('Perform Heavy Calculation'),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Excessive Network Requests without Caching
class ExcessiveNetworkWidget extends StatefulWidget {
  @override
  _ExcessiveNetworkWidgetState createState() => _ExcessiveNetworkWidgetState();
}

class _ExcessiveNetworkWidgetState extends State<ExcessiveNetworkWidget> {
  List<String> _data = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Performance Problem: No caching, fetching data repeatedly
    // Each time the user navigates or refreshes, data is fetched again
    setState(() {
      _isLoading = true;
    });

    try {
      // Makes a new request every time instead of caching results
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      
      if (response.statusCode == 200) {
        final List<dynamic> parsedData = json.decode(response.body);
        setState(() {
          _data = parsedData.map((item) => item['title'].toString()).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excessive Network Requests')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData, // Fetches new data on every refresh
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(_data[index]));
                },
              ),
            ),
    );
  }
}

// 5. Inefficient Image Loading
class InefficientImageLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Loading full-sized images without resizing
    // This consumes excessive memory and can cause OOM errors
    return Scaffold(
      appBar: AppBar(title: Text('Inefficient Image Loading')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          return Image.network(
            'https://picsum.photos/id/${index + 1}/2000/2000',
            // No width or height specified, loading full 2000x2000 images
            // No cacheWidth or cacheHeight specified
            // No placeholder or error handling
            // No memory cache management
          );
        },
      ),
    );
  }
}

// 6. Stateful Widget Abuse - Using stateful widgets unnecessarily
class StatefulWidgetAbuseExample extends StatefulWidget {
  @override
  _StatefulWidgetAbuseExampleState createState() => _StatefulWidgetAbuseExampleState();
}

class _StatefulWidgetAbuseExampleState extends State<StatefulWidgetAbuseExample> {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Using StatefulWidget for static content
    // This is unnecessary and adds overhead
    return Scaffold(
      appBar: AppBar(title: Text('Stateful Widget Abuse')),
      body: ListView(
        children: List.generate(
          100,
          (index) => UnnecessaryStatefulWidget(index: index),
        ),
      ),
    );
  }
}

// This should be a StatelessWidget since it doesn't manage any state
class UnnecessaryStatefulWidget extends StatefulWidget {
  final int index;
  
  UnnecessaryStatefulWidget({required this.index});
  
  @override
  _UnnecessaryStatefulWidgetState createState() => _UnnecessaryStatefulWidgetState();
}

class _UnnecessaryStatefulWidgetState extends State<UnnecessaryStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    print('Building UnnecessaryStatefulWidget ${widget.index}');
    // This widget doesn't need state, it should be StatelessWidget
    return ListTile(
      title: Text('Item ${widget.index}'),
      subtitle: Text('This is a static item'),
    );
  }
}

// 7. Nested ListView - Performance killer
class NestedListViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Nesting ListViews creates scrolling conflicts
    // and breaks virtualization benefits
    return Scaffold(
      appBar: AppBar(title: Text('Nested ListView Problem')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, outerIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Section $outerIndex', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              // Nested ListView - very bad for performance!
              Container(
                height: 200,
                child: ListView.builder(
                  // No physics specified to prevent scrolling conflicts
                  itemCount: 50,
                  itemBuilder: (context, innerIndex) {
                    return ListTile(
                      title: Text('Item $innerIndex in section $outerIndex'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 8. Excessive setState Calls
class ExcessiveSetStateWidget extends StatefulWidget {
  @override
  _ExcessiveSetStateWidgetState createState() => _ExcessiveSetStateWidgetState();
}

class _ExcessiveSetStateWidgetState extends State<ExcessiveSetStateWidget> {
  List<int> _counters = List.generate(100, (index) => 0);
  
  @override
  Widget build(BuildContext context) {
    print('Rebuilding entire ExcessiveSetStateWidget');
    
    return Scaffold(
      appBar: AppBar(title: Text('Excessive setState')),
      body: ListView.builder(
        itemCount: _counters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Counter $index: ${_counters[index]}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Performance Problem: Using setState for a single counter
                    // This rebuilds the entire widget tree for just one counter change
                    setState(() {
                      _counters[index]++;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 9. Animated Widget without RepaintBoundary
class MissingRepaintBoundaryWidget extends StatefulWidget {
  @override
  _MissingRepaintBoundaryWidgetState createState() => _MissingRepaintBoundaryWidgetState();
}

class _MissingRepaintBoundaryWidgetState extends State<MissingRepaintBoundaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
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
    // Performance Problem: No RepaintBoundary around animated content
    // Causes entire screen to repaint on every animation frame
    return Scaffold(
      appBar: AppBar(title: Text('Missing RepaintBoundary')),
      body: Column(
        children: [
          // Static content that gets repainted unnecessarily
          Expanded(
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Static item $index'));
              },
            ),
          ),
          // Animated content without RepaintBoundary
          // Should be wrapped with RepaintBoundary widget
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: 100,
                color: Color.fromRGBO(
                  (255 * _controller.value).toInt(),
                  (255 * (1 - _controller.value)).toInt(),
                  150,
                  1,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Animated content',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 10. Rebuilding Expensive Widgets
class ExpensiveWidgetRebuildWidget extends StatefulWidget {
  @override
  _ExpensiveWidgetRebuildWidgetState createState() => _ExpensiveWidgetRebuildWidgetState();
}

class _ExpensiveWidgetRebuildWidgetState extends State<ExpensiveWidgetRebuildWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    print('Building ExpensiveWidgetRebuildWidget');
    
    return Scaffold(
      appBar: AppBar(title: Text('Expensive Widget Rebuilding')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Counter: $_counter'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _counter++;
              });
            },
            child: Text('Increment Counter'),
          ),
          // Performance Problem: Rebuilding expensive custom painted widget
          // Should use a RepaintBoundary and/or memoization
          Expanded(
            child: ExpensiveCustomPaintWidget(),
          ),
        ],
      ),
    );
  }
}

class ExpensiveCustomPaintWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building ExpensiveCustomPaintWidget');
    
    // This widget gets rebuilt whenever parent rebuilds
    return CustomPaint(
      painter: ExpensivePainter(),
      size: Size.infinite,
    );
  }
}

class ExpensivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print('Repainting ExpensivePainter');
    
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Drawing 1000 circles - expensive operation
    for (int i = 0; i < 1000; i++) {
      final radius = 10.0 + i * 0.1;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint..color = Color.fromRGBO(
          (255 * sin(i * 0.01)).abs().toInt(),
          (255 * cos(i * 0.01)).abs().toInt(),
          (255 * sin(i * 0.02)).abs().toInt(),
          1,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Always returning true, causing it to repaint every time
    return true;
  }
}

// 11. Excessive use of Opacity widget
class ExcessiveOpacityWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Overusing Opacity widgets which force offscreen rendering
    return Scaffold(
      appBar: AppBar(title: Text('Excessive Opacity')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          // Every item uses Opacity, which is expensive
          return Opacity(
            opacity: 0.9, // Should use const if opacity doesn't change
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: Colors.blue[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nested opacity is even worse
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      'Item $index',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Another nested opacity
                  Opacity(
                    opacity: 0.7,
                    child: Text('This is the description for item $index that has excessive opacity'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 12. Excessive Future Building
class ExcessiveFutureBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Creating new Future inside build method
    return Scaffold(
      appBar: AppBar(title: Text('Excessive FutureBuilder')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return FutureBuilder<String>(
            // Creating a new Future on every build - bad practice
            // Should create future once and store it in state or variable
            future: _fetchDataForItem(index),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text('Loading item $index...'),
                  leading: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text('Error loading item $index'),
                  subtitle: Text(snapshot.error.toString()),
                );
              } else {
                return ListTile(
                  title: Text(snapshot.data ?? 'No data'),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<String> _fetchDataForItem(int index) async {
    // Simulating network request
    await Future.delayed(Duration(milliseconds: 500));
    return 'Data for item $index';
  }
}

// 13. Excessive Stream Subscription
class ExcessiveStreamSubscriptionWidget extends StatefulWidget {
  @override
  _ExcessiveStreamSubscriptionWidgetState createState() => _ExcessiveStreamSubscriptionWidgetState();
}

class _ExcessiveStreamSubscriptionWidgetState extends State<ExcessiveStreamSubscriptionWidget> {
  final _streamControllers = <StreamController<int>>[];
  final _data = List.generate(100, (index) => 0);

  @override
  void initState() {
    super.initState();
    // Performance Problem: Creating too many streams
    // Should use a single stream or more efficient state management
    for (int i = 0; i < 100; i++) {
      final controller = StreamController<int>.broadcast();
      _streamControllers.add(controller);
      
      // Each stream emits values periodically
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (controller.isClosed) {
          timer.cancel();
        } else {
          controller.add(Random().nextInt(100));
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _streamControllers) {
      controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excessive Stream Subscription')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return StreamBuilder<int>(
            // One StreamBuilder per list item - very inefficient
            stream: _streamControllers[index].stream,
            builder: (context, snapshot) {
              final value = snapshot.data ?? 0;
              return ListTile(
                title: Text('Item $index: $value'),
              );
            },
          );
        },
      ),
    );
  }
}

// 14. Inefficient TextStyle Creation
class InefficientTextStyleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Creating new TextStyle instances on every build
    return Scaffold(
      appBar: AppBar(title: Text('Inefficient TextStyle')),
      body: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) {
          // Creating a new TextStyle for every item instead of reusing
          // Should define these styles as static constants or theme styles
          return ListTile(
            title: Text(
              'Item $index',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            subtitle: Text(
              'Description for item $index with inefficient styling',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.2,
              ),
            ),
          );
        },
      ),
    );
  }
}

// 15. Excessive Widget Tree Depth
class ExcessiveWidgetTreeDepthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Creating unnecessarily deep widget trees
    return Scaffold(
      appBar: AppBar(title: Text('Excessive Widget Tree Depth')),
      body: _buildDeepNestingWidget(30), // Excessive nesting depth
    );
  }

  Widget _buildDeepNestingWidget(int depth) {
    if (depth <= 0) {
      return Text('Reached bottom of nesting');
    }
    
    // Excessive nesting of widgets with no real purpose
    return Container(
      margin: EdgeInsets.all(2),
      padding: EdgeInsets.all(2),
      color: depth % 2 == 0 ? Colors.grey[200] : Colors.white,
      child: Column(
        children: [
          Text('Level $depth'),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: _buildDeepNestingWidget(depth - 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 16. Inefficient Key Usage
class InefficientKeyUsageWidget extends StatefulWidget {
  @override
  _InefficientKeyUsageWidgetState createState() => _InefficientKeyUsageWidgetState();
}

class _InefficientKeyUsageWidgetState extends State<InefficientKeyUsageWidget> {
  List<String> _items = List.generate(100, (index) => 'Item $index');

  void _shuffleItems() {
    setState(() {
      _items.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inefficient Key Usage')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _shuffleItems,
            child: Text('Shuffle Items'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                // Performance Problem: No keys provided for list items
                // This forces Flutter to rebuild widgets instead of reusing them
                return StatefulListItem(
                  title: _items[index],
                  // Missing key: key: ValueKey(_items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatefulListItem extends StatefulWidget {
  final String title;
  
  StatefulListItem({required this.title});
  
  @override
  _StatefulListItemState createState() => _StatefulListItemState();
}

class _StatefulListItemState extends State<StatefulListItem> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    print('Building StatefulListItem: ${widget.title}');
    return ExpansionTile(
      title: Text(widget.title),
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('Expanded content for ${widget.title}'),
        ),
      ],
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
    );
  }
}

// 17. Expensive Build Methods
class ExpensiveBuildMethodWidget extends StatefulWidget {
  @override
  _ExpensiveBuildMethodWidgetState createState() => _ExpensiveBuildMethodWidgetState();
}

class _ExpensiveBuildMethodWidgetState extends State<ExpensiveBuildMethodWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    // Performance Problem: Doing expensive work in the build method
    print('Building ExpensiveBuildMethodWidget');
    
    // Expensive computation performed during build
    // This should be done outside the build method
    final expensiveResult = _performExpensiveComputation();
    
    return Scaffold(
      appBar: AppBar(title: Text('Expensive Build Method')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: $_counter'),
            Text('Expensive Result: $expensiveResult'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }

  String _performExpensiveComputation() {
    // Simulating expensive string concatenation and computation
    print('Running expensive computation');
    String result = '';
    for (int i = 0; i < 10000; i++) {
      result += 'x';
      double calculation = sin(i.toDouble()) * cos(i.toDouble());
      result = result.substring(0, result.length - 1) + calculation.toString().substring(0, 1);
    }
    return result.substring(0, 20);
  }
}

// 18. MediaQuery Overuse
class MediaQueryOveruseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Accessing MediaQuery.of(context) repeatedly
    return Scaffold(
      appBar: AppBar(title: Text('MediaQuery Overuse')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          // Should store MediaQuery.of(context) in a variable once
          return Container(
            // Every item queries MediaQuery separately
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.1,
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.01,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
            ),
            child: Text(
              'Item $index',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
            ),
          );
        },
      ),
    );
  }
}

// 19. Inefficient GlobalKey Usage
class InefficientGlobalKeyWidget extends StatefulWidget {
  @override
  _InefficientGlobalKeyWidgetState createState() => _InefficientGlobalKeyWidgetState();
}

class _InefficientGlobalKeyWidgetState extends State<InefficientGlobalKeyWidget> {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Creating too many GlobalKeys
    return Scaffold(
      appBar: AppBar(title: Text('Inefficient GlobalKey Usage')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          // Creating a new GlobalKey for every item - very inefficient
          // GlobalKeys should be reused when possible
          final globalKey = GlobalKey();
          
          return Container(
            key: globalKey,
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(16),
            color: Colors.teal[100],
            child: Text('Item $index with its own GlobalKey'),
          );
        },
      ),
    );
  }
}

// 20. Inefficient Asset Loading
class InefficientAssetLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Performance Problem: Loading same assets repeatedly
    return Scaffold(
      appBar: AppBar(title: Text('Inefficient Asset Loading')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            // Loading the same asset for every list item instead of reusing
            // This causes repeated asset resolution and decoding
            leading: Image.asset(
              'assets/icon.png',
              width: 40,
              height: 40,
            ),
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}