import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? photoUrl;
  final String? phone;
  final String? college;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int totalPoints;
  final int coins;
  final List<String> badges;
  final int currentStreak;
  final int longestStreak;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.phone,
    this.college,
    required this.createdAt,
    this.lastLoginAt,
    this.totalPoints = 0,
    this.coins = 0,
    this.badges = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.preferences,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      college: map['college'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      totalPoints: map['totalPoints'] ?? 0,
      coins: map['coins'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      preferences: map['preferences'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'phone': phone,
      'college': college,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'totalPoints': totalPoints,
      'coins': coins,
      'badges': badges,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? photoUrl,
    String? phone,
    String? college,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? totalPoints,
    int? coins,
    List<String>? badges,
    int? currentStreak,
    int? longestStreak,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      college: college ?? this.college,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalPoints: totalPoints ?? this.totalPoints,
      coins: coins ?? this.coins,
      badges: badges ?? this.badges,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      preferences: preferences ?? this.preferences,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';
}

