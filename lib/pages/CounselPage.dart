import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../notification.dart';

const apiKey = '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';
const apiUrl = 'https://api.openai.com/v1/completions';

class CounselPage extends StatelessWidget {
  const CounselPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    FlutterLocalNotification.init();
    Future.delayed(const Duration(seconds: 3),
        FlutterLocalNotification.requestNotificationPermission());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _controller,
          ),
          TextButton(
              onPressed: () {
                String prompt = _controller.text;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ResultPage(prompt)));
              },
              child: const Text("Get Result")),
          TextButton(
              onPressed: () => FlutterLocalNotification.showNotification2(),
              child: const Text("알림 보내기"))
        ],
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final String prompt;
  const ResultPage(this.prompt, {super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result from GPT"),
      ),
      body: FutureBuilder<String>(
        future: generateText(widget.prompt),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text('${snapshot.data}');
          }
        },
      ),
    );
  }
}

Future<String> generateText(String prompt) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      'prompt': prompt,
      'max_tokens': 1000,
      'temperature': 0,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0
    }),
  );

  Map<String, dynamic> newresponse =
      jsonDecode(utf8.decode(response.bodyBytes));

  return newresponse['choices'][0]['text'];
}
