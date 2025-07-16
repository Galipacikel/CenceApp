class UserProfile {
  String name;
  String surname;
  String title;
  String? profileImagePath;

  UserProfile({
    required this.name,
    required this.surname,
    required this.title,
    this.profileImagePath,
  });

  UserProfile copyWith({
    String? name,
    String? surname,
    String? title,
    String? profileImagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      title: title ?? this.title,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
} 