class AppUser {
  final String uid;
  final String? email;
  final String? fullName;
  final String? role; // legacy
  final bool? isAdminFlag; // yeni boolean alan
  final DateTime? createdAt;
  final String? username;
  final String? usernameLowercase;

  AppUser({
    required this.uid,
    this.email,
    this.fullName,
    this.role,
    this.isAdminFlag,
    this.createdAt,
    this.username,
    this.usernameLowercase,
  });

  // Backward compatible getterlar
  bool get isAdmin => isAdminFlag ?? (role == 'admin');
  bool get isTechnician => !isAdmin;

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] as String?,
      fullName: (data['full_name'] ?? data['fullName']) as String?,
      role: data['role'] as String?,
      isAdminFlag: (data['is_admin'] is bool
              ? data['is_admin'] as bool
              : (data['isAdmin'] is bool
                  ? data['isAdmin'] as bool
                  : (data['admin'] is bool ? data['admin'] as bool : null))),
      createdAt: (data['created_at'] != null)
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
      username: data['username'] as String?,
      usernameLowercase: data['username_lowercase'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'full_name': fullName,
      'role': role, // legacy alanı koru (okuma için)
      'is_admin': isAdminFlag, // yeni alan
      'created_at': createdAt?.toIso8601String(),
      'username': username,
      'username_lowercase': usernameLowercase,
    }..removeWhere((key, value) => value == null);
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    bool? isAdminFlag,
    DateTime? createdAt,
    String? username,
    String? usernameLowercase,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isAdminFlag: isAdminFlag ?? this.isAdminFlag,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      usernameLowercase: usernameLowercase ?? this.usernameLowercase,
    );
  }
}
