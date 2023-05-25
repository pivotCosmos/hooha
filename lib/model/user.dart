class User {
  final String name;
  final String age;
  final String gender;
  final String smoking_year;
  final String end_date;

  const User({
    required this.name,
    required this.age,
    required this.gender,
    required this.smoking_year,
    required this.end_date,
  });
  User copyWith({
    String? name,
    String? age,
    String? gender,
    String? smoking_year,
    String? end_date,
  }) =>
      User(
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        smoking_year: smoking_year ?? this.smoking_year,
        end_date: end_date ?? this.end_date,
      );

  static User fromJson(Map<String, dynamic> json) => User(
        name: json['name'],
        age: json['age'],
        gender: json['gender'],
        smoking_year: json['smoking_year'],
        end_date: json['end_date'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'smoking_year': smoking_year,
        'end_date': end_date,
      };
}
