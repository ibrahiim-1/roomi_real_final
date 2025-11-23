class AppUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // admin

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }

  // Create from Firestore document
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'admin',
    );
  }
}

