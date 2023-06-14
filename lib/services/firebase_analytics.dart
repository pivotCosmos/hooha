import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  /// 사용자 선택지 버튼 클릭 시 로깅
  static Future<void> logOptionButtonClickedEvent(
      String clicked_option_msg) async {
    await analytics.logEvent(
      name: 'option_button_clicked',
      parameters: {'clicked_option_msg': clicked_option_msg},
    );
  }

  /// 피드백 버튼 클릭 시 로깅
  static Future<void> logSatisfiedFeedbackEvent(String feedbackDetail) async {
    await analytics.logEvent(
      name: "feedback",
      parameters: {'feedback_detail': feedbackDetail},
    );
  }

  /// 직전 선택지 하나를 클릭해서 현재 챗봇 메시지로 오기까지에 대한 로깅
  /// 1. 직전 선택지에 딸려있었던 메시지들
  /// 2. 직전에 클릭한 메시지 인덱스
  /// 3. 사용자가 클릭한 선택지 텍스트
  /// 4. 사용자가 클릭한 선택지에 연결된 메시지 이름
  static Future<void> logChatbotMsgSentEvent(
    String previousNextMessageNames,
    int clickedButtonIndex,
    String clickedButtonTxt,
    String nextMsgName,
  ) async {
    await analytics.logEvent(
      name: 'chatbot_msg_sent',
      parameters: {
        'previousNextMessageNames': previousNextMessageNames,
        'clickedButtonIndex': clickedButtonIndex,
        'clickedButtonTxt': clickedButtonTxt,
        'nextMsgName': nextMsgName,
      },
    );
  }

  /// AI 응답 로깅
  static Future<void> logGetAiResponseEvent(String aiResponse) async {
    await analytics.logEvent(
      name: 'chatbot_msg_sent',
      parameters: {
        'aiResponse': aiResponse,
      },
    );
  }

  /// 이 다음 챗봇 메시지를 띄워주기 위한 로깅
  /// 1. 가져온 챗봇 메시지 시작부에 prompt가 있는지 판단
  /// 2. DB에서 가져온 메시지 텍스트(시나리오 혹은 프롬프트)
  /// 3. 챗봇 메시지에 딸린 선택지 옵션들
  /// 4. 선택지별 선택지 텍스트와 연결된 다음 메시지 이름
  static Future<void> logChatbotMsgPreparingEvent(
    String msgTxtHead,
    String msgTxt,
    String options,
    String nextMsgNameList,
  ) async {
    await analytics.logEvent(
      name: 'chatbot_msg_sent',
      parameters: {
        'msgTxtHead': msgTxtHead,
        'msgTxt': msgTxt,
        'connectedOptions': options,
        'nextMsgNameList': nextMsgNameList,
      },
    );
  }

  /// 에러 발생 시 로깅
  static Future<void> logErrorOccurred(String error_msg) async {
    await analytics.logEvent(
      name: 'error_occurred',
      parameters: {'error_message': error_msg},
    );
  }
}
