import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bubble/bubble.dart';

///OpenAI API settings
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
const String MODEL_ID = 'text-davinci-003';

///Counsel Module
class GetCounsel extends StatelessWidget {
  const GetCounsel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HOOHA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CounselPage(title: 'OpenAI Chatbot'),
    );
  }
}

class CounselPage extends StatefulWidget {
  const CounselPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CounselPageState createState() => _CounselPageState();
}

class _CounselPageState extends State<CounselPage> {
  final _messages = <String>[];
  List<String> _responseOptions = [];
  final _defaultMessage = 'Welcome';
  final _selectButtonMessage = 'Select a button';
  final _defaultOptions = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  final ScrollController _scrollController = ScrollController();

  /// bubble settings : styleSomebody - chatbot , styleMe - user
  static const styleChatbot = BubbleStyle(
    nip: BubbleNip.leftCenter,
    color: Colors.white,
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(
      top: 10,
      right: 50,
      left: 10,
    ),
    alignment: Alignment.topLeft,
  );

  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color.fromARGB(255, 209, 230, 255),
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(
      top: 10,
      left: 50,
      right: 10,
    ),
    alignment: Alignment.topRight,
  );

  _CounselPageState() {
    _messages.add(_defaultMessage); // Add the default welcome message
    _responseOptions = List.from(_defaultOptions); // Set default button options
  }

  void _addMessage(String message) {
    setState(() {
      _messages.add(message);
      _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent); // Scroll to the bottom
    });
  }

  /// OpenAI API에서 답변 가져오기
  Future<String> _getAIResponse(String message) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/$MODEL_ID/completions'),
      headers: {
        'Authorization': 'Bearer $OPENAI_API_KEY',
        'Content-Type': 'application/json',
        "model": "text-davinci-003"
      },
      body: jsonEncode({
        'prompt': message,
        'max_tokens': 1000,
        'temperature': 0.5,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['text'].toString();
    } else {
      throw Exception('Failed to generate text');
    }
  }

  void _selectResponse(String response) {
    _addMessage(response);

    // Call the API for the next chatbot response
    _getAIResponse(response).then((aiResponse) {
      _addMessage(aiResponse);

      // Reset button options to default after selecting a response
      setState(() {
        _responseOptions = List.from(_defaultOptions);
      });
    }).catchError((error) {
      _addMessage('Error: ${error.toString()}');
    });
  }

  /// 사용자에게 제공할 선택지 버튼에 텍스트 세팅
  void setButtonOptions(List<String>? options) {
    setState(() {
      _responseOptions = options!;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MessageBubbleListView(
                scrollController: _scrollController,
                messages: _messages,
                styleChatbot: styleChatbot,
                styleMe: styleMe),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SelectButtonMessageContainer(
                    selectButtonMessage: _selectButtonMessage),
                Builder(
                  builder: createResponseOptionButtons,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자에게 제공할 선택지 버튼 생성
  Widget createResponseOptionButtons(context) {
    final isChatbotMessage = _messages.length % 2 == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < _responseOptions.length; i++)
          ElevatedButton(
            //deactivate buttons while waiting for the AI response.
            onPressed: isChatbotMessage
                ? null
                : () => _selectResponse(_responseOptions[i]),
            child: Text(_responseOptions[i]),
          ),
      ],
    );
  }
}

/// 버튼 상단에 띄워줄 안내 메시지
class SelectButtonMessageContainer extends StatelessWidget {
  const SelectButtonMessageContainer({
    super.key,
    required String selectButtonMessage,
  }) : _selectButtonMessage = selectButtonMessage;

  final String _selectButtonMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Text(
        _selectButtonMessage,
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}

/// 대화 내용을 담아 채팅창에 띄워줄 버블 리스트뷰
class MessageBubbleListView extends StatelessWidget {
  const MessageBubbleListView({
    super.key,
    required ScrollController scrollController,
    required List<String> messages,
    required this.styleChatbot,
    required this.styleMe,
  })  : _scrollController = scrollController,
        _messages = messages;

  final ScrollController _scrollController;
  final List<String> _messages;
  final BubbleStyle styleChatbot;
  final BubbleStyle styleMe;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController, // Assign the ScrollController
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isChatbotMessage = index % 2 == 0;

        return Bubble(
          style: isChatbotMessage ? styleChatbot : styleMe,
          child: Text(
            message,
            style: const TextStyle(fontSize: 18.0),
          ),
        );
      },
    );
  }
}
