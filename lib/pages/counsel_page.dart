import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';
import 'package:hooha/services/firebase_analytics.dart' as analytics;

///OpenAI API settings
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
const String MODEL_ID = 'gpt-3.5-turbo';

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

  /// 선택지 버튼을 클릭하면 이어질 각각의 챗봇 메시지 이름들(디폴트: _intro)
  List<String> _nextMessageNames = ['_intro'];

  // 디폴트 세팅들
  final _defaultMessage = '안녕하세요! 후하와 대화를 시작해 볼까요?';
  final _defaultOptions = ['좋아요!'];

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
      Timer(const Duration(milliseconds: 500), () {
        _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent); // Scroll to the bottom
      });
    });
  }

  // 챗봇 응답 띄우기

  // Firestore 인스턴스 가져오기
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Firestore에서 챗봇 메시지 가져오기
  /// return msgTxt, options
  Future<Map<String, String>> _getChatbotMsg(String msgNo) async {
    String collectionName = 'chatbot_msg'; // 컬렉션 이름
    String documentId = msgNo; // 문서 ID

    try {
      // Firestore에서 문서 가져오기
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        // 문서가 존재할 경우 필드 값 가져오기
        String msgTxt = documentSnapshot.get('msg_txt');
        String formattedMsgTxt =
            msgTxt.replaceAll(r'\n', '\n'); // "\\n"을 "\n"으로 변경
        String options = documentSnapshot.get('options');

        return {
          'msgTxt': formattedMsgTxt, // msgTxt에서 formattedMsgTxt로 변경 줄바꿈을 위해
          'options': options,
        }; // 가져온 값 반환
      } else {
        return {
          'msgTxt': '문서가 존재하지 않습니다.',
          'options': '',
        };
      }
    } catch (e) {
      // 에러가 발생했을 경우 파이어베이스에 로그 남기기
      analytics.AnalyticsService.logErrorOccurred(
          'Firestore에서 데이터를 가져오는 중 오류가 발생했습니다: $e');
      return {
        'msgTxt': '오류가 발생했습니다.',
        'options': '',
      };
    }
  }

  /// Firestore에서 선택지 텍스트, 다음 메시지 이름 가져오기
  /// return nextMsg, optionTxt
  Future<Map<String, String>> _getOptionMsgAndNextMsgNo(String msgName) async {
    String collectionName = 'options'; // 컬렉션 이름
    String documentId = msgName; // 문서 ID

    try {
      // Firestore에서 문서 가져오기
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        // 문서가 존재할 경우 필드 값 가져오기
        String nextMsg = documentSnapshot.get('next_msg');
        String optionTxt = documentSnapshot.get('option_txt');

        return {
          'nextMsg': nextMsg,
          'optionTxt': optionTxt,
        }; // 가져온 값 반환
      } else {
        return {
          'nextMsg': '문서가 존재하지 않습니다.',
          'options': '',
        };
      }
    } catch (e) {
      // 에러가 발생했을 경우 파이어베이스에 로그 남기기
      analytics.AnalyticsService.logErrorOccurred(
          'Firestore에서 데이터를 가져오는 중 오류가 발생했습니다: $e');
      return {
        'nextMsg': '오류가 발생했습니다.',
        'optionTxt': '',
      };
    }
  }

  /// OpenAI API에서 답변 가져오기
  /// message: API에 보낼 프롬프트
  Future<String> _getAIResponse(String message) async {
    const message = 'I love you and thank you';
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat//completions'),
      headers: {
        'Authorization': 'Bearer $OPENAI_API_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message}
        ],
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
  /// option: 사용자가 클릭한 선택지 버튼 텍스트.
  /// index: 사용자가 클릭한 버튼 인덱스
  void _showHoohaMsgAndUserOptions(int buttonIndex) async {
    print("Start of _showHoohaMsgAndUserOptions");
    analytics.AnalyticsService.analytics.setAnalyticsCollectionEnabled(true);
    // 직전 선택지에 딸려있었던 메시지들 확인하기
    //print("_previousNextMessageNames=$_nextMessageNames");

    // 직전에 클릭한 메시지 인덱스 확인하기
    //print("clickedButtonIndex=$buttonIndex");

    // 사용자가 클릭한 선택지 텍스트를 버블로 띄워주기
    String clickedButtonTxt = _options[buttonIndex];
    _addMessage(clickedButtonTxt);
    //print("clickedButtonTxt=$clickedButtonTxt");

    // 사용자가 클릭한 선택지에 연결된 메시지 이름 가져오기
    String nextMsgName = _nextMessageNames[buttonIndex];
    //print("nextMsgName=$nextMsgName");
    String previousNextMessageNamesString = _nextMessageNames.join(', ');
    // 직전 선택지에서 현재 메시지로 오기까지에 대한 로깅
    analytics.AnalyticsService.logChatbotMsgSentEvent(
        previousNextMessageNamesString,
        buttonIndex,
        clickedButtonTxt,
        nextMsgName);

    // 시나리오 혹은 프롬프트로 분기 나누기

    // 챗봇 메시지 가져오기 (1.시나리오 2.프롬프트)
    Map<String, String> msgData = await _getChatbotMsg(nextMsgName);
    String? msgTxt = msgData['msgTxt'];

    String? msgTxtHead = msgTxt?.substring(0, 6);

    // 가져온 챗봇 메시지 시작부에 prompt 표시가 있는지 판단
    print("msgTxtHead=$msgTxtHead");

    String prompt = "prompt";
    if (msgTxtHead! == prompt) {
      // 1. 프롬프트인 경우 API 호출, AI 응답을 받아와서 _messages에 저장
      _getAIResponse(clickedButtonTxt).then((aiResponse) {
        _addMessage(aiResponse);
        //print("aiResponse=$aiResponse");
        analytics.AnalyticsService.logGetAiResponseEvent(aiResponse);
      }).catchError((error) {
        _addMessage('Error: ${error.toString()}');
        analytics.AnalyticsService.logErrorOccurred(
            "aiResponseError=${error.toString()}");
      });
    } else {
      // 2. 시나리오인 경우 DB에서 가져와서 _messages에 저장
      _addMessage(msgTxt!);
      //print("using nextMsgNo(=$nextMsgName), msgTxt=$msgTxt");
    }

    // 챗봇 메시지에 딸린 선택지 옵션들 담기
    String? options = msgData['options'];
    List<String>? optionList = options?.split(' ');
    print("options=$options");

    // 선택지 텍스트, 다음 메시지 이름 담을 준비
    List<String> optTxtList = [];
    List<String> nextMsgNameList = [];

    // 선택지 반복문 돌리기
    for (var opt in optionList!) {
      // 선택지 텍스트, 다음 메시지 이름 가져오기
      Map<String, String> optMap = await _getOptionMsgAndNextMsgNo(opt);
      print("optMap=$optMap");

      // 선택지 텍스트 담기
      String? txt = optMap['optionTxt'];
      optTxtList.add(txt!);

      // 선택지와 연결된 다음 메시지 이름 담기
      String? nextMsgNo = optMap['nextMsg'];
      nextMsgNameList.add(nextMsgNo!);
    }

    // 선택지 버튼 텍스트 업데이트
    setButtonOptions(optTxtList, nextMsgNameList);
    print("End of _showHoohaMsgAndUserOptions");

    String nextMsgNamesString = nextMsgNameList.join(', ');
    // 이 다음 챗봇 메시지를 띄워주기 위한 로깅
    analytics.AnalyticsService.logChatbotMsgPreparingEvent(
        msgTxtHead, msgTxt!, options!, nextMsgNamesString);
  }

  /// 사용자에게 제공할 선택지와 선택지별 다음 메시지 이름들 세팅
  void setButtonOptions(List<String>? options, List<String>? nextMsgNums) {
    setState(() {
      /// 선택지 텍스트 세팅
      _options = options!;

      /// 선택지에 연결된 다음 메시지 이름들 세팅
      _nextMessageNames = nextMsgNums!;
      print("_nextMessageNames=$_nextMessageNames");
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
              styleMe: styleMe,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: createOptionButtons(context),
          ),
        ],
      ),
    );
  }

  /// 사용자에게 제공할 선택지 버튼 생성
  /// 버튼 너비가 길거나 여러 개일 경우 층층이 생성
  Widget createOptionButtons(context) {
    final isChatbotMessage = _messages.length % 2 == 0;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      children: [
        for (int i = 0; i < _options.length; i++)
          ElevatedButton(
            // 챗봇 응답 기다리는 동안 선택지 버튼 비활성화
            onPressed: isChatbotMessage
                ? null
                : () => _showHoohaMsgAndUserOptions(i), // 버튼 인덱스 전달
            child: Text(_options[i]),
          ),
      ],
    );
  }
}

/// 대화 내용을 담아 채팅창에 띄워줄 버블 리스트뷰
/// 버블 아래에 현재 시간도 함께 띄워줌
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
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isChatbotMessage = index % 2 == 0;

        // 현재 시간 가져오기
        String currentTime = DateFormat('h:mm a').format(DateTime.now());
        // print("currentTime=$currentTime\n DateTime.now()=$DateTime.now()");

        return Column(
          children: [
            // 챗봇 메시지
            Bubble(
              style: isChatbotMessage ? styleChatbot : styleMe,
              child: Text(
                message,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
            // 메시지 전송 시간
            Padding(
                padding: isChatbotMessage
                    ? const EdgeInsets.only(top: 8.0, left: 20.0)
                    : const EdgeInsets.only(top: 8.0, right: 20.0),
                child: Align(
                  alignment: isChatbotMessage
                      ? Alignment.topLeft
                      : Alignment.bottomRight,
                  child: Text(
                    currentTime,
                    style: const TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                )),
          ],
        );
      },
    );
  }
}
