import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  /// 챗봇이 사용자에게 보내는 메시지
  final _messages = <String>[];

  /// 사용자에게 주어지는 선택지
  List<String> _options = [];

  /// 선택지 버튼을 클릭하면 이어지는 다음 챗봇 메시지 번호
  List<int> _nextMessagesNums = [];

  // 디폴트 세팅들
  final _defaultMessage = 'Welcome';
  final _selectButtonMessage = 'Select a button';
  final _defaultOptions = ['금연 정보 얻기', '상담 받기', 'Option 3', 'Option 4'];

  /// 자동으로 스크롤이 내려가게 하기 위한 스크롤컨트롤러
  final ScrollController _scrollController = ScrollController();

  /// 챗봇 말풍선 스타일
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

  /// 사용자 말풍선 스타일
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

  // 디폴트 메시지, 버튼 세팅
  _CounselPageState() {
    _messages.add(_defaultMessage); // Add the default welcome message
    _options = List.from(_defaultOptions); // Set default button options
  }

  // _messages에 새로운 메시지 담기
  void _addMessage(String message) {
    setState(() {
      _messages.add(message);
      _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent); // Scroll to the bottom
    });
  }

  // 챗봇 응답 띄우기

  // Firestore 인스턴스 가져오기
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Firestore에서 챗봇 메시지 가져오기
  Future<String> _getChatbotMsg(int msgNo) async {
    String collectionName = 'chatbot_msg'; // 컬렉션 이름
    String documentId = msgNo.toString(); // 문서 ID

    try {
      // Firestore에서 문서 가져오기
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        // 문서가 존재할 경우 필드 값 가져오기
        String msgTxt = documentSnapshot.get('msg_txt');
        String options = documentSnapshot.get('options');

        return '$msgTxt, $options'; // 가져온 값 반환
      } else {
        return '문서가 존재하지 않습니다.';
      }
    } catch (e) {
      print('Firestore에서 데이터를 가져오는 중 오류가 발생했습니다: $e');
      return '오류가 발생했습니다.';
    }
  }

  /// OpenAI API에서 답변 가져오기
  /// message: API에 보낼 프롬프트
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

  /// 챗봇 메시지와 선택지 버튼 띄우기
  /// option: 선택지 버튼 텍스트
  void _showHoohaMsgAndUserOptions(String option) async {
    // 시나리오 혹은 프롬프트로 분기 나누기

    // 1. 시나리오인 경우 DB에서 가져와서 _messages에 저장
    String msg = await _getChatbotMsg(0);
    _addMessage(msg);

    // 2. 프롬프트인 경우 API 호출, AI 응답을 받아와서 _messages에 저장
    _getAIResponse(option).then((aiResponse) {
      _addMessage(aiResponse);
    }).catchError((error) {
      _addMessage('Error: ${error.toString()}');
    });

    // 선택지 버튼 텍스트 업데이트
    setButtonOptions(_defaultOptions);
    // setState(() {
    //   _options = List.from(_defaultOptions);
    // });
  }

  /// 사용자에게 제공할 선택지&다음 메시지 번호 세팅
  void setButtonOptions(List<String>? options) {
    setState(() {
      /// 선택지 텍스트 세팅
      _options = options!;

      /// 선택지에 연결된 다음 메시지 번호 세팅
      _nextMessagesNums = [0, 1, 2, 3];
    });
  }

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
                  builder: createOptionButtons,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자에게 제공할 선택지 버튼 생성
  Widget createOptionButtons(context) {
    final isChatbotMessage = _messages.length % 2 == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < _options.length; i++)
          ElevatedButton(
            // 챗봇 응답 기다리는 동안 선택지 버튼 비활성화
            onPressed: isChatbotMessage
                ? null
                : () => _showHoohaMsgAndUserOptions(_options[i]),
            child: Text(_options[i]),
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
