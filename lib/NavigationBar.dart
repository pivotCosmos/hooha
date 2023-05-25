import 'package:flutter/material.dart';

/// Flutter code sample for [NavigationBar] with nested [Navigator] destinations.

void main() {
  runApp(const MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin<Home> {
  static const List<Destination> allDestinations = <Destination>[ //하단바 제작
    Destination(0, 'Home', Icons.home, Colors.blue), //home 아이콘 + 파란색
    Destination(1, 'Calendar', Icons.calendar_month_sharp, Colors.blue), //calendar 아이콘 + 파란색
    Destination(2, 'Counsel', Icons.chat_outlined, Colors.blue), //챗 아이콘 + 파란색
    Destination(3, 'MyPage', Icons.supervised_user_circle_sharp, Colors.blue), //user 아이콘 + 파란색
  ];
  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<GlobalKey> destinationKeys;
  late final List<AnimationController> destinationFaders;
  late final List<Widget> destinationViews;
  int selectedIndex = 0;

  AnimationController buildFaderController() { //애니메이션을 제어하기 위한 컨트롤러 역할
    final AnimationController controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    controller.addStatusListener((AnimationStatus status) {
       //addStatusListener 메서드를 호출하여 애니메이션 컨트롤러의 상태가 변경될 때마다 호출될 콜백 함수를 등록하고 있음.
       // 이 콜백 함수에서는 애니메이션 컨트롤러의 상태가 dismissed(초기 상태)일 때, setState 메서드를 호출하여 애니메이션이 끝난 후,
       // 선택되지 않은 다른 뷰들을 화면에서 숨기고 다시 그려주는 작업을 수행하고 있음.
      if (status == AnimationStatus.dismissed) {
        setState(() {}); // Rebuild unselected destinations offstage.
      }
    });
    return controller;
  }

  @override

  void initState() {  // StatefulWidget의 initState 메소드.
    super.initState();   // initState는 StatefulWidget이 처음 생성될 때, 한 번만 호출되며, 해당 위젯의 초기 상태를 설정할 때 사용됨.
    navigatorKeys = List<GlobalKey<NavigatorState>>.generate( // initState를 사용하여, 
    //현재 선택된 destination의 인덱스를 selectedIndex 변수에 설정하고, 모든 destination에 대한 NavigatorState GlobalKey와 
    //해당 destination에 대한 FadeTransition 및 DestinationView 위젯을 생성하고 초기화
        allDestinations.length, (int index) => GlobalKey()).toList();
    destinationFaders = List<AnimationController>.generate(
        allDestinations.length, (int index) => buildFaderController()).toList();
    destinationFaders[selectedIndex].value = 1.0;
    destinationViews = allDestinations.map((Destination destination) {
      return FadeTransition(
        opacity: destinationFaders[destination.index]
            .drive(CurveTween(curve: Curves.fastOutSlowIn)),
        child: DestinationView(
          destination: destination,
          navigatorKey: navigatorKeys[destination.index],
        ),
      );
    }).toList();
  }

  @override //모든 애니메이션 컨트롤러를 dispose하여 메모리 누수를 방지.
  void dispose() { 
    for (final AnimationController controller in destinationFaders) {
      controller.dispose(); //for문을 사용하여 destinationFaders의 모든 애니메이션 컨트롤러에 대해 dispose() 메소드를 호출.
    }
    super.dispose(); //마지막으로 super.dispose()를 호출하여 슈퍼클래스의 dispose() 메소드를 실행.
  }

  @override
  Widget build(BuildContext context) { //build() 메소드를 정의하는 부분
    return WillPopScope( //WillPopScope 위젯을 사용하여 이전 화면으로 돌아가는 기능을 구현
      onWillPop: () async {
        final NavigatorState navigator =
            navigatorKeys[selectedIndex].currentState!;
        if (!navigator.canPop()) {
          return true;
        } //만약 현재 페이지에서 뒤로 갈 수 있는 경우, navigator.pop()을 호출하여 이전 페이지로 이동하고, 그렇지 않으면 현재 페이지에 머무름
        navigator.pop();
        return false;
      },
      child: Scaffold( // Scaffold 위젯을 사용하여 상단 안전 영역을 제외한 전체 화면을 스택(Stack) 위젯으로 감싸고, 모든 목적지(Destination)를 표시.
        body: SafeArea(
          top: false,
          child: Stack( //Stack 위젯은 여러 개의 위젯을 겹치거나 함께 표시할 때 사용되며, Offstage 위젯을 사용하여 보이지 않는 위젯은 제거됨.
            fit: StackFit.expand,
            children: allDestinations.map((Destination destination) {
              final int index = destination.index;
              final Widget view = destinationViews[index];
              if (index == selectedIndex) {
                destinationFaders[index].forward();
                return Offstage(offstage: false, child: view);
              } else {
                destinationFaders[index].reverse();
                if (destinationFaders[index].isAnimating) {
                  return IgnorePointer(child: view);
                }
                return Offstage(child: view);
              }
            }).toList(),
          ),
        ),
        bottomNavigationBar: NavigationBar( //NavigationBar를 사용하여 하단 탭바를 표시.
        // 선택된 목적지의 인덱스(selectedIndex)를 변경할 때마다 상태를 업데이트하고 화면을 다시 그린다.
        // 모든 목적지를 NavigationDestination 위젯으로 변환하여 구성
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: allDestinations.map((Destination destination) {
            return NavigationDestination( //각각의 NavigationDestination 위젯은 Icon 위젯과 Text 위젯으로 구성되며, 이것은 하단 탭바에 표시됨.
              icon: Icon(destination.icon, color: destination.color),
              label: destination.title,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Destination { //어떤 목적지(destination)를 나타내기 위한 모델 클래스
  const Destination(this.index, this.title, this.icon, this.color); //생성자는  인덱스, 타이틀, 아이콘, 색상으로 구성됨.
  final int index; 
  final String title;
  final IconData icon;
  final MaterialColor color;
}//Destination 클래스를 사용하면, 각 목적지마다 인덱스, 제목, 아이콘, 색상 정보를 저장할 수 있습니다. 
//이 정보를 토대로 NavigationBar와 DestinationView 위젯을 구성하게 됩니다.

class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.destination}); // RootPage는 destination이라는 필수 인자를 받음.

  final Destination destination;

  Widget _buildDialog(BuildContext context) {
    return AlertDialog( //팝업 형태의 다이얼로그를 나타내는 위젯
      title: Text('${destination.title} 알림창'), 
      actions: <Widget>[ //destination.title을 제목으로 갖는 AlertDialog를 생성하고, 확인 버튼을 추가
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) { //Theme.of(context)를 사용하여 현재 context의 Theme을 가져와서 headlineSmall 스타일을 가져옴.
    final TextStyle headlineSmall = Theme.of(context).textTheme.headlineSmall!; //Text 위젯에 적용할 텍스트 스타일을 정의. 폰트 크기, 색상 등의 속성을 정의
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom( //ElevatedButton.styleFrom()을 사용하여 buttonStyle을 만듬.
    //이 스타일은 버튼의 배경색, 텍스트 스타일, 패딩 및 밀도를 설정함.
      backgroundColor: destination.color, //destination.color를 배경색으로 사용하므로 현재 선택된 목적지의 색상으로 버튼 배경색이 설정됨.
      visualDensity: VisualDensity.comfortable,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: headlineSmall,
    ); // 이렇게 정의된 headlineSmall과 buttonStyle은 다음 코드에서 버튼을 만들 때 사용됨.

    return Scaffold( //Scaffold는 앱 화면의 기본 레이아웃 구조를 정의하며, 앱 바, 배경색 및 본문 콘텐츠를 정의하는 방법을 제공.
      appBar: AppBar( //AppBar 위젯을 정의. AppBar는 표시할 타이틀과 색상을 지정할 수 있는 앱 상단 헤더. 이 예제에서는 현재 선택된 목적지의 제목과 색상을 표시.
        title: Text('${destination.title} 페이지 '),
        backgroundColor: destination.color, //페이지의 배경색을 정의
      ),
      backgroundColor: destination.color[50], //destination.color[50]을 사용하여 현재 선택된 목적지의 색상 중 가장 밝은 색상을 사용
      body: Center( // body : 페이지의 본문 내용을 정의하는 Center 위젯과 Column 위젯으로 구성. Center 위젯은 자식 위젯을 화면 중앙에 정렬.
        child: Column( //Column 위젯은 세로 방향으로 여러 위젯을 배열.
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[ //Column 위젯의 children 프로퍼티에는 ElevatedButton 위젯, SizedBox 위젯 및 Builder 위젯이 포함.
            ElevatedButton( //ElevatedButton 위젯은 각 버튼의 스타일 및 동작을 정의.
              style: buttonStyle,
              onPressed: () { //버튼이 클릭되었을 때 호출할 콜백 함수를 정의.
                Navigator.pushNamed(context, '/list'); //지정된 경로 이름으로 새로운 페이지를 라우팅
              },
              child: const Text('Push /list'), //버튼에 포함될 텍스트를 정의
            ),
            const SizedBox(height: 16), //SizedBox 위젯은 각 버튼 사이의 공간을 정의
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {//버튼이 클릭되었을 때 호출할 콜백 함수를 정의.
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: _buildDialog,
                );
              },
              child: const Text('Local Dialog'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {//버튼이 클릭되었을 때 호출할 콜백 함수를 정의.
                showDialog(
                  context: context,
                  useRootNavigator: true,
                  builder: _buildDialog,
                );
              },
              child: const Text('Root Dialog'),
            ),
            const SizedBox(height: 16),
            Builder( //Builder 위젯은 하위 위젯의 context를 빌드할 수 있도록 해줌.
              builder: (BuildContext context) {
                return ElevatedButton(
                  style: buttonStyle, //buttonStyle은 모든 버튼에 대한 공통 스타일을 정의하는 ElevatedButton.styleFrom 함수를 호출하여 만듬.
                  onPressed: () {//버튼이 클릭되었을 때 호출할 콜백 함수를 정의.
                    showBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: Text(
                            '${destination.title} BottomSheet\n'
                            'Tap the back button to dismiss',
                            style: headlineSmall,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Local BottomSheet'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListPage extends StatelessWidget {
  const ListPage({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    const int itemCount = 10;
    final ButtonStyle buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: destination.color,
      fixedSize: const Size.fromHeight(128),
      textStyle: Theme.of(context).textTheme.headlineSmall,
    );
    return Scaffold(
      appBar: AppBar( //상단 바
        title: Text('${destination.title} ListPage - /list'),
        backgroundColor: destination.color, //상단 바 색상 설정
      ),
      backgroundColor: destination.color[50],
      body: SizedBox.expand( //body 속성에는 SizedBox.expand 위젯을 이용하여 ListView.builder 위젯을 전체 화면 크기로 설정.
        child: ListView.builder( //ListView.builder 위젯은 itemCount만큼 아이템을 보여주며, itemBuilder 속성에는 각 아이템을 구성하는 위젯을 작성.
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return Padding( //Padding 위젯은 각 아이템의 상하좌우에 일정한 간격을 두기 위해 사용됨.
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: OutlinedButton( //OutlinedButton 위젯은 각 아이템을 클릭할 수 있는 버튼으로, buttonStyle을 이용하여 스타일을 설정.
                style: buttonStyle.copyWith(
                  backgroundColor: MaterialStatePropertyAll<Color>( //MaterialStatePropertyAll<Color>를 이용하여 배경 색상을 설정.
                    Color.lerp(destination.color[100], Colors.white,
                        index / itemCount)!,
                  ),
                ),
                onPressed: () { //클릭 이벤트가 발생하면 Navigator.pushNamed(context, '/text') 함수를 이용하여 '/text' 페이지로 이동
                  Navigator.pushNamed(context, '/text');
                },
                child: Text('Push /text [$index]'), //child 속성에는 각 버튼의 라벨을 설정
              //라벨의 텍스트는 'Push /text [인덱스]' 형태로 되어 있으며, 인덱스 값은 0부터 9까지 순차적으로 증가.
              ), //
            );
          },
        ),
      ),
    );
  }
}

class TextPage extends StatefulWidget {
  const TextPage({super.key, required this.destination});

  final Destination destination;

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: '텍스트 예시');
  }

  @override
  void dispose() { //textController를 해제
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // 현재 컨텍스트의 테마를 가져와 theme 변수에 할당
    final ThemeData theme = Theme.of(context);
    return Scaffold( //Scaffold를 생성하여 앱 바와 배경색을 설정
      appBar: AppBar(
        title: Text('${widget.destination.title} TextPage - /list/text'),
        backgroundColor: widget.destination.color,
      ),
      backgroundColor: widget.destination.color[50],
      body: Container(
        padding: const EdgeInsets.all(32.0),
        alignment: Alignment.center,
        child: TextField(
          controller: textController,
          style: theme.primaryTextTheme.headlineMedium?.copyWith(
            color: widget.destination.color,
          ),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: widget.destination.color,
                width: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationView extends StatefulWidget {
  const DestinationView({
    super.key,
    required this.destination,
    required this.navigatorKey,
  });

  final Destination destination;
  final Key navigatorKey;

  @override
  State<DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Navigator( //Navigator 위젯을 사용하여 경로에 따라 다른 페이지를 표시하는 역할.
      key: widget.navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case '/': ///' 경로에 대한 페이지: RootPage 위젯을 반환
                return RootPage(destination: widget.destination);
              case '/list': //'/list' 경로에 대한 페이지: ListPage 위젯을 반환
                return ListPage(destination: widget.destination);
              case '/text': //'/text' 경로에 대한 페이지: TextPage 위젯을 반환
                return TextPage(destination: widget.destination);
            }
            assert(false); //assert(false)를 사용하여 예기치 않은 경로에 대한 처리를 확인
            return const SizedBox(); //예외를 발생시키며, const SizedBox() 위젯을 반환하여 빈 위젯을 표시
          },
        );
      },
    );
  }
}
