import 'trust_label.dart';

enum ResourceType {
  checkDam,
  pond,
  well,
  canal,
  forestCompartment,
  grazingLand,
  medicinalPatch,
  bambooStand,
  agricultureParcel,
  sacredGrove,
}

enum ResourceUtilityLabel {
  useful,
  partlyUseful,
  notUseful,
}

class ResourceItem {
  final String id;
  final String villageId;
  final String name;
  final String marathiName;
  final ResourceType type;
  final double latitude;
  final double longitude;
  final double areaHa;
  final bool isInsideCfr;
  final bool isInsideVillage;
  final bool isNear; // within 3km
  final String locationDescription;
  final String nearbyLandUse;

  // Scoring factors (0.0 to 1.0)
  double availabilityA; // Main season availability
  double conditionC; // Physical infrastructure / ecosystem condition
  double seasonalityS; // Months active / 12
  double reachR; // Ease of physical access & distance

  String plainReason;
  String aiAssessment;
  TrustLabel trustLabel;
  String photoUrl;
  List<String> aiTags;
  String? surveyNumber;
  String? holder712Name;
  bool isSensitiveSacred;
  DateTime? lastVerifiedAt;

  ResourceItem({
    required this.id,
    required this.villageId,
    required this.name,
    required this.marathiName,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.areaHa,
    this.isInsideCfr = true,
    this.isInsideVillage = true,
    this.isNear = true,
    required this.locationDescription,
    required this.nearbyLandUse,
    required this.availabilityA,
    required this.conditionC,
    required this.seasonalityS,
    required this.reachR,
    required this.plainReason,
    required this.aiAssessment,
    required this.trustLabel,
    this.photoUrl = 'assets/images/checkdam_sample.jpg',
    this.aiTags = const ['Water Body', 'Check Dam', 'Water Level: 60%'],
    this.surveyNumber,
    this.holder712Name,
    this.isSensitiveSacred = false,
    this.lastVerifiedAt,
  });

  // U = 0.35 A + 0.25 C + 0.25 S + 0.15 R
  double get utilityScore {
    double score = (0.35 * availabilityA) +
        (0.25 * conditionC) +
        (0.25 * seasonalityS) +
        (0.15 * reachR);
    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(2));
  }

  ResourceUtilityLabel get utilityLabel {
    double s = utilityScore;
    if (s >= 0.70) return ResourceUtilityLabel.useful;
    if (s >= 0.40) return ResourceUtilityLabel.partlyUseful;
    return ResourceUtilityLabel.notUseful;
  }

  String get utilityLabelText {
    switch (utilityLabel) {
      case ResourceUtilityLabel.useful:
        return 'Useful';
      case ResourceUtilityLabel.partlyUseful:
        return 'Partly Useful';
      case ResourceUtilityLabel.notUseful:
        return 'Not Useful';
    }
  }

  String get utilityLabelMarathi {
    switch (utilityLabel) {
      case ResourceUtilityLabel.useful:
        return 'उपयुक्त';
      case ResourceUtilityLabel.partlyUseful:
        return 'अंशतः उपयुक्त';
      case ResourceUtilityLabel.notUseful:
        return 'अनुपयुक्त';
    }
  }

  String get typeDisplay {
    switch (type) {
      case ResourceType.checkDam:
        return 'Check Dam (बंधारा)';
      case ResourceType.pond:
        return 'Pond / Water Body (तलाव)';
      case ResourceType.well:
        return 'Community Well (विहीर)';
      case ResourceType.canal:
        return 'Canal (कालवा)';
      case ResourceType.forestCompartment:
        return 'CFR Forest (सामुदायिक वन)';
      case ResourceType.grazingLand:
        return 'Grazing Land (चराई क्षेत्र)';
      case ResourceType.medicinalPatch:
        return 'Medicinal Flora (वनौषधी क्षेत्र)';
      case ResourceType.bambooStand:
        return 'Bamboo Stand (बांबू क्षेत्र)';
      case ResourceType.agricultureParcel:
        return 'Agricultural Land (शेती जमीन)';
      case ResourceType.sacredGrove:
        return 'Sacred Grove / Deorai (देवराई)';
    }
  }

  void updateFieldCheck({
    required double newA,
    required double newC,
    required double newS,
    required double newR,
    required String newReason,
    required String verifiedBy,
    required String verificationNote,
    required CheckStatus status,
  }) {
    availabilityA = newA;
    conditionC = newC;
    seasonalityS = newS;
    reachR = newR;
    plainReason = newReason;
    lastVerifiedAt = DateTime.now();
    trustLabel = trustLabel.copyWith(
      checkStatus: status,
      confidence: ConfidenceLevel.high,
      verifiedBy: verifiedBy,
      verificationNote: verificationNote,
      sourceDate: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
  }
}
