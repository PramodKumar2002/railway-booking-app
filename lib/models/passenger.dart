class Passenger {
  Passenger({
    this.name = '',
    this.age = '',
    this.gender = 'Male',
    this.berthPreference = 'No Preference',
  });

  String name;
  String age;
  String gender;
  String berthPreference;

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'age': age.trim(),
        'gender': gender,
        'berthPreference': berthPreference,
      };

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        name: json['name']?.toString() ?? '',
        age: json['age']?.toString() ?? '',
        gender: json['gender']?.toString() ?? 'Male',
        berthPreference: json['berthPreference']?.toString() ?? 'No Preference',
      );

  Passenger clone() => Passenger(
        name: name,
        age: age,
        gender: gender,
        berthPreference: berthPreference,
      );
}
