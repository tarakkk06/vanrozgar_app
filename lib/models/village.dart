import 'trust_label.dart';

enum RecognitionStatus {
  cfrRecognised,
  potentialCfr,
  notMatched,
}

class VillageProfile {
  String nearestMarketTown;
  double distanceToMarketKm;
  String roadType; // Paved, Semi-paved, Kutcha
  String nearestProcessingPoint;
  List<String> localSkills;
  bool isShgActive;
  int activeShgCount;

  VillageProfile({
    this.nearestMarketTown = 'Ramtek',
    this.distanceToMarketKm = 14.0,
    this.roadType = 'Semi-paved / All-weather',
    this.nearestProcessingPoint = 'Nagpur Agro Cluster (45 km)',
    List<String>? localSkills,
    this.isShgActive = true,
    this.activeShgCount = 4,
  }) : localSkills = localSkills ??
            [
              'Bamboo Weaving',
              'Animal Husbandry',
              'Honey Harvesting',
              'Fisheries Management',
              'Leaf Plate Making'
            ];

  double get marketAccessScore {
    // K calculation: 1.0 is highest access (close town, paved road)
    double distanceFactor = (30.0 - distanceToMarketKm).clamp(0.0, 30.0) / 30.0;
    double roadFactor = roadType.contains('Paved') ? 1.0 : (roadType.contains('Semi') ? 0.7 : 0.4);
    return (0.6 * distanceFactor + 0.4 * roadFactor).clamp(0.1, 1.0);
  }

  double get skillsScore {
    // P calculation: based on count of skills and SHG participation
    double skillFactor = (localSkills.length / 6.0).clamp(0.2, 1.0);
    double shgFactor = isShgActive ? 0.9 : 0.4;
    return (0.6 * skillFactor + 0.4 * shgFactor).clamp(0.1, 1.0);
  }
}

class Village {
  final String id;
  final String name;
  final String marathiName;
  final String hindiName;
  final String taluka;
  final String district;
  final double cfrAreaHectares;
  final String approvalDate;
  final RecognitionStatus recognitionStatus;
  final int householdCount;
  final int totalPopulation;
  final double latitude;
  final double longitude;
  final List<String> surveyNumbers;
  final VillageProfile profile;
  final TrustLabel trustLabel;

  // Livelihood readiness sub-indices (0 - 100)
  final int waterScore;
  final int landScore;
  final int forestScore;
  final int skillsScore;
  final int marketScore;
  final int infrastructureScore;
  final int sustainabilityScore;

  Village({
    required this.id,
    required this.name,
    required this.marathiName,
    required this.hindiName,
    required this.taluka,
    this.district = 'Nagpur',
    required this.cfrAreaHectares,
    required this.approvalDate,
    required this.recognitionStatus,
    required this.householdCount,
    required this.totalPopulation,
    required this.latitude,
    required this.longitude,
    required this.surveyNumbers,
    required this.profile,
    required this.trustLabel,
    this.waterScore = 82,
    this.landScore = 74,
    this.forestScore = 89,
    this.skillsScore = 68,
    this.marketScore = 61,
    this.infrastructureScore = 72,
    this.sustainabilityScore = 85,
  });

  int get readinessIndex {
    return ((waterScore +
                landScore +
                forestScore +
                skillsScore +
                marketScore +
                infrastructureScore +
                sustainabilityScore) /
            7)
        .round();
  }

  String localizedNameByLang(String langCode) {
    if (langCode == 'mr') return marathiName;
    if (langCode == 'hi') return hindiName;
    return name;
  }
}
