class AppUser {
  final String phone;
  final String displayName;
  final String role; // villager | committee | admin
  final List<String> allowedDistricts; // empty = all Maharashtra
  final List<String>
      allowedVillageIds; // empty = all villages in allowed districts
  final DateTime loggedInAt;

  const AppUser({
    required this.phone,
    required this.displayName,
    required this.role,
    this.allowedDistricts = const [],
    this.allowedVillageIds = const [],
    required this.loggedInAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isCommittee => role == 'committee' || role == 'admin';
  bool get hasStatewideAccess => isAdmin;

  bool canAccessDistrict(String district) {
    if (hasStatewideAccess) return true;
    return allowedDistricts
        .any((d) => d.toLowerCase() == district.toLowerCase());
  }

  bool canAccessVillage(String villageId, String district) {
    if (isAdmin) return true;
    if (allowedVillageIds.isNotEmpty) {
      return allowedVillageIds.contains(villageId) &&
          (allowedDistricts.isEmpty || canAccessDistrict(district));
    }
    return canAccessDistrict(district);
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'displayName': displayName,
        'role': role,
        'allowedDistricts': allowedDistricts,
        'allowedVillageIds': allowedVillageIds,
        'loggedInAt': loggedInAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      phone: json['phone'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      allowedDistricts: List<String>.from(json['allowedDistricts'] ?? const []),
      allowedVillageIds:
          List<String>.from(json['allowedVillageIds'] ?? const []),
      loggedInAt: DateTime.tryParse(json['loggedInAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
