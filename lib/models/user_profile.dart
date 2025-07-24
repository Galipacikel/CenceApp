class UserProfile {
  final String id;
  final String name;
  final String surname;
  final String title;
  final String? email;
  final String? phone;
  final String? department;
  final String? profileImagePath;

  UserProfile({
    required this.id,
    required this.name,
    required this.surname,
    required this.title,
    this.email,
    this.phone,
    this.department,
    this.profileImagePath,
  });

  // Tam ad getter'ı
  String get fullName => '$name $surname';

  // Kısa ad getter'ı (sadece ad)
  String get shortName => name;

  UserProfile copyWith({
    String? id,
    String? name,
    String? surname,
    String? title,
    String? email,
    String? phone,
    String? department,
    String? profileImagePath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'title': title,
      'email': email,
      'phone': phone,
      'department': department,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      title: json['title'] ?? '',
      email: json['email'],
      phone: json['phone'],
      department: json['department'],
      profileImagePath: json['profileImagePath'],
    );
  }
} 