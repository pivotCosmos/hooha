import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';
import 'package:hooha/services/firebase_analytics.dart' as analytics;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:loading_indicator/loading_indicator.dart';

///OpenAI API settings
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
const String MODEL_ID = 'text-davinci-003';

/// Loading Indicator colors
const List<Color> indicatorColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

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
  /// 로딩중인지 판단하는 상태값
  bool isLoading = false;

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
    borderColor: Color.fromARGB(255, 243, 137, 51),
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
    color: Color.fromARGB(255, 255, 234, 166),
    borderColor: Color.fromARGB(255, 243, 137, 51),
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

  // 채팅창 스크롤 내리기
  void autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
      );
    });
  }

  // _messages에 새로운 메시지 담기
  void _addMessage(String message) {
    setState(() {
      _messages.add(message);
    });
    // 메시지 담은 후에 스크롤 내리기
    autoScroll();
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
      analytics.AnalyticsService.logErrorOccurred('Firestore: $e');
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
      analytics.AnalyticsService.logErrorOccurred('Firestore: $e');
      return {
        'nextMsg': '오류가 발생했습니다.',
        'optionTxt': '',
      };
    }
  }

  /// Firestore에서 사용자 정보 가져오기
  /// return name, job
  Future<Map<String, String>> _getUserInfo(String userId) async {
    String collectionName = 'users'; // 컬렉션 이름
    String documentId = userId; // 문서 ID

    try {
      // Firestore에서 문서 가져오기
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        // 문서가 존재할 경우 필드 값 가져오기
        String name = documentSnapshot.get('name');
        String job = documentSnapshot.get('job');

        return {
          'name': name,
          'job': job,
        }; // 가져온 값 반환
      } else {
        return {
          'msgTxt': '문서가 존재하지 않습니다.',
          'options': '',
        };
      }
    } catch (e) {
      // 에러가 발생했을 경우 파이어베이스에 로그 남기기
      analytics.AnalyticsService.logErrorOccurred('Firestore: $e');
      return {
        'msgTxt': '오류가 발생했습니다.',
        'options': '',
      };
    }
  }

  /// OpenAI API에서 답변 가져오기
  /// message: API에 보낼 프롬프트
  Future<String> _getAIResponse(String message) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $OPENAI_API_KEY',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'model': "gpt-3.5-turbo", // 사용할 AI 모델
        'messages': [
          {
            'role': "user", // 메시지 역할을 user로 설정
            'content': '$message' // 사용자가 입력한 메시지
          },
          {'role': "assistant", 'content': 'you are the best'}
        ],
        'temperature': 0.8, // 모델의 출력 다양성
        'max_tokens': 1024, // 응답받을 메시지 최대 토큰(단어) 수 설정
        'top_p': 1, // 토큰 샘플링 확률을 설정
        'frequency_penalty': 0.5, // 일반적으로 나오지 않는 단어를 억제하는 정도
        'presence_penalty': 0.5, // 동일한 단어나 구문이 반복되는 것을 억제하는 정도
      }),
    );

    // AI 답변 맨앞 불필요한 공백 제거
    String trimAIResponse(String text) {
      if (text.startsWith('\n')) {
        return text.trimLeft();
      } else {
        return text;
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String responseText = data['choices'][0]['message']['content'].toString();
      String cleanedResponseText = trimAIResponse(responseText);
      print("cleanedResponseText=$cleanedResponseText");
      return cleanedResponseText;
    } else {
      throw Exception('Failed to generate text');
      // 요청 실패 처리
    }
  }

  void main() async {
    try {
      final result = await _getAIResponse('Hello');
      print('결과: $result');
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  /// 챗봇 메시지와 선택지 버튼 띄우기
  /// option: 사용자가 클릭한 선택지 버튼 텍스트.
  /// index: 사용자가 클릭한 버튼 인덱스
  void _showHoohaMsgAndUserOptions(int buttonIndex) async {
    final kakao.User user =
        await kakao.UserApi.instance.me(); //현재 로그인된 카카오 유저의 정보를 가져옴
    final userDocRef = //파이어스토어의 users 객체의 userid 문서의 정보 저장
        FirebaseFirestore.instance.collection('users').doc(user.id.toString());

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

    // 만약 직전에 클릭한 선택지가 feedback이라면 firebase analytics 로깅
    if (clickedButtonTxt.length >= 8) {
      String buttonTextHead = clickedButtonTxt.substring(0, 8);
      String buttonTextBody = clickedButtonTxt.substring(8);
      if (buttonTextHead == 'feedback') {
        analytics.AnalyticsService.logSatisfiedFeedbackEvent(buttonTextBody);
      }
    }

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

    // 가져온 챗봇 메시지 시작부에 prompt 표시가 있는지 판단
    String? msgTxtHead = msgTxt?.substring(0, 6);
    print("msgTxtHead=$msgTxtHead");

    String prompt = "prompt";
    if (msgTxtHead! == prompt) {
      // 1. 프롬프트인 경우 API 호출, AI 응답을 받아와서 _messages에 저장

      // AI 응답을 기다리는 로딩 시작
      setState(() {
        isLoading = true;
      });

      // "prompt" 표시 부분을 잘라내고 프롬프트 담기
      msgTxt = msgTxt?.substring(6);

      // 회원 아이디로 회원정보 가져오기
      // 필요한 회원정보: 회원 유형, 회원 아이디
      Map<String, String> userData = await _getUserInfo('${user.id}');
      String? name = userData['name'];
      String? job = userData['job'];

      // 프롬프트 앞에 맞춤상담에 필요한 회원 정보 붙이기
      String completePrompt = "$job이라는 직업의 $name님" + msgTxt!;
      print("completePrompt=$completePrompt");

      _getAIResponse(completePrompt).then((aiResponse) {
        _addMessage(aiResponse);
        //print("aiResponse=$aiResponse");
        analytics.AnalyticsService.logGetAiResponseEvent(aiResponse);
      }).catchError((error) {
        _addMessage('Error: ${error.toString()}');
        analytics.AnalyticsService.logErrorOccurred(
            "aiResponseError=${error.toString()}");
      }).whenComplete(() {
        setState(() {
          // AI 응답을 가져왔으면 로딩 종료
          isLoading = false;
        });
      });
    } else {
      // 2. 시나리오인 경우 DB에서 가져와서 _messages에 저장
      // 시간차를 두고 버블이 생성되도록 _message에 넣기 전에 타이머 걸기
      Timer(const Duration(milliseconds: 300), () {
        _addMessage(msgTxt!);
      });
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

      // 선택지 텍스트 앞부분에 "feedback"이 있으면 잘라서 나머지만 담기
      if (txt!.length >= 8) {
        String optionHead = txt.substring(0, 8);
        if (optionHead == "feedback") {
          String optionBody = txt.substring(8);
          txt = optionBody;
        }
      }

      // 선택지 리스트에 선택지 담기
      optTxtList.add(txt);

      // 선택지와 연결된 다음 메시지 이름 담기
      String? nextMsgNo = optMap['nextMsg'];
      nextMsgNameList.add(nextMsgNo!);
    }

    // 선택지 버튼 텍스트 업데이트
    setButtonOptions(optTxtList, nextMsgNameList);
    print("End of _showHoohaMsgAndUserOptions");

    // 버튼 갱신 후 채팅창 스크롤 내리기
    autoScroll();

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
      body: Stack(
        children: [
          Column(
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
                child: Builder(
                  builder: createOptionButtons,
                ),
              ),
            ],
          ),
          if (isLoading) // 로딩 중이라면 인디케이터를 표시
            Container(
              color: Colors.black54,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: LoadingIndicator(
                    colors: indicatorColors,
                    indicatorType: Indicator.pacman,
                  ),
                ),
              ),
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
