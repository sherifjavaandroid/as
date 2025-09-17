// memory_vulnerabilities.dart - مثال على مشاكل إدارة الذاكرة وحقن البيانات
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// مشكلة أمنية: استخدام FFI بطريقة غير آمنة
class UnsafeMemoryManager {
  late Pointer<Uint8> _buffer;
  late Pointer<Char> _stringBuffer;
  int _bufferSize = 1024;
  
  void initializeBuffers() {
    // تخصيص ذاكرة بدون تهيئة آمنة
    _buffer = malloc.allocate<Uint8>(_bufferSize);
    _stringBuffer = malloc.allocate<Char>(256);
    print('Buffers initialized: ${_buffer.address}, ${_stringBuffer.address}');
  }
  
  // مشكلة أمنية: Buffer Overflow
  void unsafeCopyData(List<int> data) {
    print('Copying ${data.length} bytes to buffer of size $_bufferSize');
    
    // لا توجد حماية من تجاوز حدود المصفوفة
    for (int i = 0; i < data.length; i++) {
      if (i >= _bufferSize) {
        print('⚠️ Buffer overflow detected at index $i');
        // المتابعة رغم تجاوز الحدود - خطر أمني!
      }
      _buffer[i] = data[i];
    }
    
    print('Data copied successfully');
  }
  
  // مشكلة أمنية: عدم فحص طول النص المدخل
  void unsafeStringCopy(String input) {
    List<int> bytes = utf8.encode(input);
    print('Copying string of ${bytes.length} bytes');
    
    // نسخ بدون فحص الطول - يمكن أن يسبب buffer overflow
    for (int i = 0; i < bytes.length; i++) {
      _stringBuffer[i] = bytes[i];
    }
    _stringBuffer[bytes.length] = 0; // null terminator
    
    print('String copied to memory');
  }
  
  // مشكلة أمنية: قراءة من ذاكرة غير محمية
  List<int> readUnsafeMemory(int offset, int length) {
    List<int> result = [];
    print('Reading $length bytes from offset $offset');
    
    // لا توجد حماية من قراءة خارج حدود الذاكرة المخصصة
    for (int i = 0; i < length; i++) {
      try {
        result.add(_buffer[offset + i]);
      } catch (e) {
        print('Memory access violation at offset ${offset + i}');
        result.add(0);
      }
    }
    
    return result;
  }
  
  // عدم تحرير الذاكرة - memory leak
  void dispose() {
    print('Warning: Memory not properly released - potential memory leak');
    // malloc.free(_buffer); // معلق عمداً لإظهار memory leak
    // malloc.free(_stringBuffer);
  }
}

// مشكلة أمنية: Injection في معالجة البيانات
class DataProcessor {
  Map<String, dynamic> _memoryCache = {};
  List<Function> _callbacks = [];
  
  // مشكلة أمنية: Code Injection عبر eval-like functionality
  dynamic processUserInput(String userInput, String operation) {
    print('Processing user input: $userInput with operation: $operation');
    
    try {
      // محاكاة تنفيذ كود المستخدم - خطر أمني كبير
      switch (operation) {
        case 'store':
          return storeInMemory(userInput);
        case 'calculate':
          return performCalculation(userInput);
        case 'execute':
          return executeUserCode(userInput); // خطر!
        case 'callback':
          return registerCallback(userInput); // خطر!
        default:
          return 'Unknown operation';
      }
    } catch (e) {
      print('Error processing input: $e');
      return null;
    }
  }
  
  // مشكلة أمنية: تنفيذ كود المستخدم بدون تصفية
  String executeUserCode(String code) {
    print('⚠️ Executing potentially dangerous user code: $code');
    
    // محاكاة تنفيذ كود JavaScript-like
    if (code.contains('alert(') || code.contains('console.log(')) {
      return 'Simulated: $code executed';
    } else if (code.contains('delete ') || code.contains('rm ')) {
      return 'Simulated: Dangerous deletion command blocked';
    } else if (code.contains('system(') || code.contains('exec(')) {
      return 'Simulated: System command executed - SECURITY BREACH!';
    }
    
    return 'Code execution completed';
  }
  
  // مشكلة أمنية: تسجيل callbacks خطيرة
  String registerCallback(String callbackCode) {
    print('Registering callback: $callbackCode');
    
    // إضافة callback بدون تصفية - يمكن استغلالها
    _callbacks.add(() {
      print('Executing callback: $callbackCode');
      return executeUserCode(callbackCode);
    });
    
    return 'Callback registered';
  }
  
  // تنفيذ جميع الـ callbacks - خطر أمني
  void executeAllCallbacks() {
    print('Executing ${_callbacks.length} registered callbacks');
    for (Function callback in _callbacks) {
      try {
        callback();
      } catch (e) {
        print('Callback execution failed: $e');
      }
    }
  }
  
  // مشكلة أمنية: تخزين بيانات في الذاكرة بدون تشفير
  String storeInMemory(String data) {
    String key = 'data_${DateTime.now().millisecondsSinceEpoch}';
    _memoryCache[key] = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'size': data.length,
      'raw_bytes': utf8.encode(data)
    };
    
    print('Data stored in memory cache with key: $key');
    return key;
  }
  
  // مشكلة أمنية: عرض محتويات الذاكرة
  void dumpMemoryCache() {
    print('\n=== MEMORY CACHE DUMP ===');
    _memoryCache.forEach((key, value) {
      print('Key: $key');
      print('Data: ${value['data']}');
      print('Raw bytes: ${value['raw_bytes']}');
      print('---');
    });
  }
  
  // مشكلة أمنية: حسابات خطيرة بدون حماية
  dynamic performCalculation(String expression) {
    print('Performing calculation: $expression');
    
    // محاكاة تقييم تعبيرات رياضية - يمكن استغلالها للحقن
    if (expression.contains('..') || expression.contains('//')) {
      return 'Path traversal attempt blocked';
    }
    
    // تقييم خطير للتعبيرات
    try {
      if (expression.contains('+')) {
        List<String> parts = expression.split('+');
        return parts.map((p) => double.tryParse(p.trim()) ?? 0).reduce((a, b) => a + b);
      } else if (expression.contains('*')) {
        List<String> parts = expression.split('*');
        return parts.map((p) => double.tryParse(p.trim()) ?? 1).reduce((a, b) => a * b);
      }
      
      return double.tryParse(expression) ?? 0;
    } catch (e) {
      return 'Calculation error: $e';
    }
  }
}

// مشكلة أمنية: معالج شبكة غير آمن
class NetworkDataHandler {
  static const int MAX_PACKET_SIZE = 1024;
  late Uint8List _packetBuffer;
  
  void initialize() {
    _packetBuffer = Uint8List(MAX_PACKET_SIZE);
    print('Network handler initialized with buffer size: $MAX_PACKET_SIZE');
  }
  
  // مشكلة أمنية: معالجة بيانات الشبكة بدون فحص
  void processNetworkPacket(List<int> packetData) {
    print('Processing packet of size: ${packetData.length}');
    
    if (packetData.length > MAX_PACKET_SIZE) {
      print('⚠️ Packet size exceeds buffer - potential buffer overflow!');
      // المتابعة رغم الخطر
    }
    
    // نسخ البيانات بدون فحص كافي
    for (int i = 0; i < packetData.length && i < MAX_PACKET_SIZE; i++) {
      _packetBuffer[i] = packetData[i];
    }
    
    // معالجة البيانات كنص
    try {
      String packetContent = utf8.decode(_packetBuffer.take(packetData.length).toList());
      print('Packet content: $packetContent');
      
      // تنفيذ أوامر من الشبكة - خطر كبير!
      if (packetContent.startsWith('EXEC:')) {
        String command = packetContent.substring(5);
        print('⚠️ Executing network command: $command');
        executeNetworkCommand(command);
      }
    } catch (e) {
      print('Packet parsing error: $e');
    }
  }
  
  // مشكلة أمنية: تنفيذ أوامر من الشبكة
  void executeNetworkCommand(String command) {
    print('Executing dangerous network command: $command');
    
    // محاكاة تنفيذ أوامر نظام
    if (command.contains('shutdown') || command.contains('reboot')) {
      print('CRITICAL: System shutdown command received!');
    } else if (command.contains('delete') || command.contains('rm')) {
      print('CRITICAL: File deletion command received!');
    } else if (command.contains('format') || command.contains('fdisk')) {
      print('CRITICAL: Disk format command received!');
    }
    
    print('Command execution simulated');
  }
}

void main() {
  print('=== Demonstrating Memory Injection & Buffer Overflow Vulnerabilities ===\n');
  
  // 1. Buffer Overflow Demo
  print('1. Buffer Overflow Demonstration:');
  UnsafeMemoryManager memManager = UnsafeMemoryManager();
  memManager.initializeBuffers();
  
  // محاولة تجاوز حدود المصفوفة
  List<int> oversizedData = List.generate(2048, (index) => index % 256);
  memManager.unsafeCopyData(oversizedData);
  
  // نسخ نص طويل
  String longString = 'A' * 500;
  memManager.unsafeStringCopy(longString);
  
  // قراءة من ذاكرة خطيرة
  List<int> dangerousRead = memManager.readUnsafeMemory(1000, 100);
  print('Read ${dangerousRead.length} bytes from dangerous memory location');
  
  // 2. Code Injection Demo
  print('\n2. Code Injection Demonstration:');
  DataProcessor processor = DataProcessor();
  
  // تنفيذ كود خطير
  processor.processUserInput('alert("XSS Attack!")', 'execute');
  processor.processUserInput('system("rm -rf /")', 'execute');
  processor.processUserInput('console.log(document.cookie)', 'callback');
  
  // تنفيذ callbacks خطيرة
  processor.executeAllCallbacks();
  
  // عرض محتويات الذاكرة
  processor.storeInMemory('Sensitive user data: password123');
  processor.storeInMemory('Credit card: 1234-5678-9012-3456');
  processor.dumpMemoryCache();
  
  // 3. Network Injection Demo
  print('\n3. Network Data Injection:');
  NetworkDataHandler netHandler = NetworkDataHandler();
  netHandler.initialize();
  
  // حزمة عادية
  String normalPacket = 'Hello Server';
  netHandler.processNetworkPacket(utf8.encode(normalPacket));
  
  // حزمة خطيرة تحتوي على أوامر
  String maliciousPacket = 'EXEC:shutdown -h now';
  netHandler.processNetworkPacket(utf8.encode(maliciousPacket));
  
  // حزمة كبيرة جداً
  String oversizedPacket = 'X' * 2048;
  netHandler.processNetworkPacket(utf8.encode(oversizedPacket));
  
  print('\n=== Memory & Injection Vulnerabilities Demonstrated ===');
  print('❌ Buffer overflow conditions');
  print('❌ Unsafe memory access');
  print('❌ Memory leaks');
  print('❌ Code injection vulnerabilities');
  print('❌ Unsafe network data processing');
  print('❌ Command execution from untrusted sources');
  
  // عدم تحرير الذاكرة
  memManager.dispose();
}