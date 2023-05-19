import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore: non_constant_identifier_names
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
// ignore: constant_identifier_names
const String MODEL_ID = 'text-davinci-003';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAI Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'OpenAI Chatbot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  final _messages = <String>[];

  void _addMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  Future<String> _getAIResponse(String message) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/$MODEL_ID/completions'),

      // Uri.parse('https://api.openai.com/v1/completions'),
      // Uri.parse('https://api.openai.com/v1/engines/'),

      headers: {
        'Authorization': 'Bearer $OPENAI_API_KEY',
        'Content-Type': 'application/json',
        "model": "text-davinci-003"
      },
      body: jsonEncode({
        'prompt': message,
        'max_tokens': 1000,
        'temperature': 0.5,
        // 'n': 1,
        // 'stream': false,
        // 'stop': 'n',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      // ignore: avoid_print
      print(data);
      return data['choices'][0]['text'].toString();
    } else {
      throw Exception('Failed to generate text');
    }
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    _textController.clear();

    if (message.isNotEmpty) {
      _addMessage(message);

      try {
        final aiResponse = await _getAIResponse(message);
        _addMessage(aiResponse);
      } catch (e) {
        _addMessage('Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter message',
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
