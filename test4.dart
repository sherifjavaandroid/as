// web_app.dart - مثال على Cross-Site Scripting (XSS)
import 'dart:io';
import 'dart:convert';

class WebServer {
  HttpServer? server;
  
  Future<void> startServer() async {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    print('Server running on http://localhost:8080');
    
    await for (HttpRequest request in server!) {
      await handleRequest(request);
    }
  }
  
  Future<void> handleRequest(HttpRequest request) async {
    if (request.uri.path == '/profile') {
      await handleProfile(request);
    } else if (request.uri.path == '/comment') {
      await handleComment(request);
    } else {
      await sendHomePage(request);
    }
  }
  
  Future<void> handleProfile(HttpRequest request) async {
    // مشكلة أمنية: عدم تصفية المدخلات من المستخدم
    String userName = request.uri.queryParameters['name'] ?? 'Guest';
    
    // خطر XSS: إدراج مباشر للمحتوى بدون تصفية
    String html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>User Profile</title>
    </head>
    <body>
        <h1>Welcome $userName!</h1>
        <p>Your profile information:</p>
        <div id="userContent">$userName</div>
        
        <script>
            // هذا الكود عرضة لـ XSS
            document.getElementById('userContent').innerHTML = '$userName';
        </script>
    </body>
    </html>
    ''';
    
    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }
  
  Future<void> handleComment(HttpRequest request) async {
    if (request.method == 'POST') {
      String body = await utf8.decoder.bind(request).join();
      Map<String, String> params = Uri.splitQueryString(body);
      
      String comment = params['comment'] ?? '';
      
      // مشكلة أمنية: حفظ التعليقات بدون تصفية
      await saveComment(comment);
      
      String html = '''
      <!DOCTYPE html>
      <html>
      <body>
          <h2>Comment Posted:</h2>
          <div>$comment</div>
          <p><a href="/">Back to Home</a></p>
      </body>
      </html>
      ''';
      
      request.response.headers.contentType = ContentType.html;
      request.response.write(html);
      await request.response.close();
    }
  }
  
  Future<void> saveComment(String comment) async {
    // حفظ التعليق بدون أي تصفية أو تشفير
    File commentsFile = File('comments.txt');
    await commentsFile.writeAsString('$comment\n', mode: FileMode.append);
  }
  
  Future<void> sendHomePage(HttpRequest request) async {
    String html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Vulnerable Web App</title>
    </head>
    <body>
        <h1>Welcome to Vulnerable Web App</h1>
        
        <h3>Test XSS:</h3>
        <form action="/profile" method="GET">
            <input type="text" name="name" placeholder="Enter your name">
            <button type="submit">View Profile</button>
        </form>
        
        <h3>Post Comment:</h3>
        <form action="/comment" method="POST">
            <textarea name="comment" placeholder="Enter comment"></textarea>
            <button type="submit">Post Comment</button>
        </form>
        
        <p>Try entering: &lt;script&gt;alert('XSS')&lt;/script&gt;</p>
    </body>
    </html>
    ''';
    
    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }
}

void main() async {
  WebServer webServer = WebServer();
  await webServer.startServer();
}