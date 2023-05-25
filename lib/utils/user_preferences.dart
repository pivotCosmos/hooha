import 'dart:convert';
import 'package:flutter_application_1/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUser = 'user';
  static User myUser = User(
    name: '이진동',
    age: '30',
    gender: '남자',
    smoking_year: '18',
    end_date: '2023-01-02',
  );

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static User getUser() {
    final json = _preferences.getString(_keyUser);
    return json == null ? myUser : User.fromJson(jsonDecode(json));
  }

  static Future<void> setUser(User user) async {
    final json = jsonEncode(user.toJson());
    await _preferences.setString(_keyUser, json);
  }

  static Future<void> updateUser(User updatedUser) async {
    final currentUser = getUser();
    final newUser = currentUser.copyWith(
      name: updatedUser.name ?? currentUser.name,
      age: updatedUser.age ?? currentUser.age,
      gender: updatedUser.gender ?? currentUser.gender,
      smoking_year: updatedUser.smoking_year ?? currentUser.smoking_year,
      end_date: updatedUser.end_date ?? currentUser.end_date,
    );
    await setUser(newUser);
  }
}
