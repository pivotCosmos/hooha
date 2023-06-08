import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Location _location = Location();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  LatLng? _destination;
  bool _isAlarmTriggered = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    loadSavedDestination();
    _getCurrentLocation(); // 현재 위치 가져오기
  }

  @override
  void dispose() {
    super.dispose();
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Future<void> showNotification() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '고객님께서 지정한 흡연구역입니다!',
      _notificationMessage,
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
        title: Center(child: Text('피하고 싶은 흡연구역이 있나요?')),
        backgroundColor: Color.fromARGB(255, 74, 236, 101),
        elevation: 0,
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: _destination ?? LatLng(37.317439546276, 127.12702648557),
          zoom: 20.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        compassEnabled: true,
        onTap: (LatLng position) {
          setState(() {
            _destination = position;
          });
          saveDestination(position); // 마커를 탭할 때마다 목적지 위치를 저장
        },
        markers: Set<Marker>.from([
          if (_destination != null)
            Marker(
              markerId: MarkerId('destination'),
              position: _destination!,
            ),
        ]),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            onPressed: () {
              if (_destination != null) {
                _showNotificationDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('피하고 싶은 흡연장소를 먼저 지정해 주세요.'),
                  ),
                );
              }
            },
            label: Text('흡연구역 지정'),
            icon: Icon(Icons.place),
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('자신에게 동기부여를 해보세요'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _notificationMessage = value;
              });
            },
            decoration: InputDecoration(hintText: 'ex) 초심을 잊지말자!'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                _startLocationSubscription();
              },
            ),
          ],
        );
      },
    );
  }

  void _startLocationSubscription() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (!_isAlarmTriggered &&
          _isWithinRange(
            currentLocation.latitude!,
            currentLocation.longitude!,
          )) {
        _isAlarmTriggered = true;
        showNotification();
      }
    });
  }

  bool _isWithinRange(double latitude, double longitude) {
    const double range = 100;
    double distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      _destination!.latitude,
      _destination!.longitude,
    );
    return distance <= range;
  }

  Future<void> saveDestination(LatLng position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('destination_latitude', position.latitude);
    await prefs.setDouble('destination_longitude', position.longitude);
  }

  Future<void> loadSavedDestination() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('destination_latitude');
    double? longitude = prefs.getDouble('destination_longitude');
    if (latitude != null && longitude != null) {
      setState(() {
        _destination = LatLng(latitude, longitude);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData currentLocation = await _location.getLocation();
    if (!_isAlarmTriggered &&
        _isWithinRange(currentLocation.latitude!, currentLocation.longitude!)) {
      _isAlarmTriggered = true;
      showNotification();
    }

    setState(() {
      _destination =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
    });
    saveDestination(_destination!);
  }
}
