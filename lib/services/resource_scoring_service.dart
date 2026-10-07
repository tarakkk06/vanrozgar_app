import '../models/resource.dart';

class ResourceScoringService {
  // Weights: U = 0.35 A + 0.25 C + 0.25 S + 0.15 R
  static const double weightA = 0.35;
  static const double weightC = 0.25;
  static const double weightS = 0.25;
  static const double weightR = 0.15;

  double calculateUtilityScore({
    required double availabilityA,
    required double conditionC,
    required double seasonalityS,
    required double reachR,
  }) {
    double score = (weightA * availabilityA) +
        (weightC * conditionC) +
        (weightS * seasonalityS) +
        (weightR * reachR);
    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(2));
  }

  ResourceUtilityLabel getLabelForScore(double score) {
    if (score >= 0.70) return ResourceUtilityLabel.useful;
    if (score >= 0.40) return ResourceUtilityLabel.partlyUseful;
    return ResourceUtilityLabel.notUseful;
  }

  Map<ResourceUtilityLabel, int> countSummary(List<ResourceItem> resources) {
    int useful = 0;
    int partly = 0;
    int notUseful = 0;

    for (var r in resources) {
      switch (r.utilityLabel) {
        case ResourceUtilityLabel.useful:
          useful++;
          break;
        case ResourceUtilityLabel.partlyUseful:
          partly++;
          break;
        case ResourceUtilityLabel.notUseful:
          notUseful++;
          break;
      }
    }

    return {
      ResourceUtilityLabel.useful: useful,
      ResourceUtilityLabel.partlyUseful: partly,
      ResourceUtilityLabel.notUseful: notUseful,
    };
  }
}
