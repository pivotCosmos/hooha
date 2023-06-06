import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

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
  String _notificationMessage = ''; // 알림 메시지 저장 변수

  @override
  void initState() {
    super.initState();
    initializeNotifications();
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
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'You have reached the destination!',
      _notificationMessage, // 사용자가 입력한 알림 메시지를 사용
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.317439546276, 127.12702648557),
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
                _showNotificationDialog(); // 알림 메시지 설정 다이얼로그 표시
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please set a destination first.'),
                  ),
                );
              }
            },
            label: Text('Set Destination'),
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
          title: Text('Set Notification Message'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _notificationMessage = value; // 입력한 알림 메시지를 저장
              });
            },
            decoration: InputDecoration(hintText: 'Enter notification message'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
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
    const double range = 100; // 100 meters
    double distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      _destination!.latitude,
      _destination!.longitude,
    );
    return distance <= range;
  }
}
