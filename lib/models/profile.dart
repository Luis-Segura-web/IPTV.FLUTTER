class Profile {
  final String id;
  final String name;
  final String serverUrl;
  final String username;
  final String password;
  final String? logoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;

  Profile({
    required this.id,
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.password,
    this.logoUrl,
    this.isActive = false,
    required this.createdAt,
    this.lastUsed,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      serverUrl: json['serverUrl'],
      username: json['username'],
      password: json['password'],
      logoUrl: json['logoUrl'],
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? serverUrl,
    String? username,
    String? password,
    String? logoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, serverUrl: $serverUrl, isActive: $isActive)';
  }
}