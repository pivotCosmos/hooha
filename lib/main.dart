import 'package:flutter/material.dart';
import 'package:hooha/counsel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore: non_constant_identifier_names
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
// ignore: constant_identifier_names
const String MODEL_ID = 'text-davinci-003';

void main() async {
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(const GetCounsel());
}
