import 'resource.dart';
import 'village.dart';
import 'trust_label.dart';

enum IdeaCategory {
  animalHusbandry,
  fisheries,
  forestProduceProcessing,
  artisanCraft,
  agroforestryNursery,
  ecoTourism,
  conservationWork,
  controlledBioEnterprise,
}

class LivelihoodIdea {
  final String id;
  final String title;
  final String marathiTitle;
  final String hindiTitle;
  final IdeaCategory category;
  final String basicIdea;
  final List<ResourceType> requiredResourceTypes;
  final List<String> requiredSkillNames;
  final double easeOfStartE; // E (0.0 to 1.0)
  final double greenFitG; // G (0.0 to 1.0)
  final String marketDemandRating; // High, Medium-High, Medium
  final String annualRevenueRange;
  final double initialInvestmentLakhs;
  final int estimatedEmploymentDays;
  final List<String> incomeSources;
  final List<String> advantages;
  final List<String> risks;
  final String forestSafetyRule;
  final String legalBase;
  final List<String> matchedSchemeIds;
  final List<String> implementationSteps;
  final Map<String, String> firstYearTimeline;
  final TrustLabel trustLabel;

  // Gate evaluation flags
  final bool violatesSec4_4; // Land sale / lease
  final bool violatesSec3_1_l; // Hunting / trapping
  final violatesSec5; // Timber felling / wildlife harm
  final bool requiresForestConversion; // Illegal land clearing

  // Community interest count
  int markedInterestCount;

  LivelihoodIdea({
    required this.id,
    required this.title,
    required this.marathiTitle,
    required this.hindiTitle,
    required this.category,
    required this.basicIdea,
    required this.requiredResourceTypes,
    required this.requiredSkillNames,
    required this.easeOfStartE,
    required this.greenFitG,
    required this.marketDemandRating,
    required this.annualRevenueRange,
    required this.initialInvestmentLakhs,
    required this.estimatedEmploymentDays,
    required this.incomeSources,
    required this.advantages,
    required this.risks,
    required this.forestSafetyRule,
    required this.legalBase,
    required this.matchedSchemeIds,
    required this.implementationSteps,
    required this.firstYearTimeline,
    required this.trustLabel,
    this.violatesSec4_4 = false,
    this.violatesSec3_1_l = false,
    this.violatesSec5 = false,
    this.requiresForestConversion = false,
    this.markedInterestCount = 14,
  });

  // Check if idea passes all legal gates
  bool get passesAllGates {
    return !violatesSec4_4 &&
        !violatesSec3_1_l &&
        !violatesSec5 &&
        !requiresForestConversion;
  }

  String? get gateRejectionReason {
    if (violatesSec4_4) return 'Violates FRA Sec 4(4): Requires selling or leasing forest land.';
    if (violatesSec3_1_l) return 'Violates FRA Sec 3(1)(l): Involves hunting or unauthorized extraction.';
    if (violatesSec5) return 'Violates FRA Sec 5: Damages biodiversity, timber felling or sacred sites.';
    if (requiresForestConversion) return 'Environmental Gate: Requires clearing natural forest land.';
    return null;
  }

  // Calculate Fit Score F = 0.35 M + 0.20 K + 0.15 P + 0.15 E + 0.15 G
  double calculateFitScore({
    required List<ResourceItem> villageResources,
    required VillageProfile profile,
  }) {
    // 1. Calculate M (Average score of matching available resources)
    List<ResourceItem> matched = villageResources.where((r) {
      return requiredResourceTypes.contains(r.type) &&
          r.utilityLabel != ResourceUtilityLabel.notUseful;
    }).toList();

    double M = 0.40; // baseline if no specific resource
    if (matched.isNotEmpty) {
      double total = 0;
      for (var r in matched) {
        total += r.utilityScore;
      }
      M = total / matched.length;
    }

    // 2. K: Market access score
    double K = profile.marketAccessScore;

    // 3. P: Skills & SHG score
    double P = profile.skillsScore;

    // 4. Weighted formula
    double F = (0.35 * M) + (0.20 * K) + (0.15 * P) + (0.15 * easeOfStartE) + (0.15 * greenFitG);
    return double.parse((F.clamp(0.1, 1.0) * 100).toStringAsFixed(1));
  }

  String get categoryDisplay {
    switch (category) {
      case IdeaCategory.animalHusbandry:
        return 'Animal Husbandry (पशुपालन)';
      case IdeaCategory.fisheries:
        return 'Fisheries (मत्स्यपालन)';
      case IdeaCategory.forestProduceProcessing:
        return 'MFP & Value Addition (वनोपज प्रक्रिया)';
      case IdeaCategory.artisanCraft:
        return 'Artisan & Handicrafts (हस्तकला / बांबू)';
      case IdeaCategory.agroforestryNursery:
        return 'Nursery & Agroforestry (रोपवाटिका)';
      case IdeaCategory.ecoTourism:
        return 'Eco-Tourism & Guiding (पर्यावरण पर्यटन)';
      case IdeaCategory.conservationWork:
        return 'Forest & Watershed Restoration (वन संवर्धन)';
      case IdeaCategory.controlledBioEnterprise:
        return 'Bio-Enterprise (रेशीम / अळंबी उत्पादन)';
    }
  }
}
