import '../models/livelihood_idea.dart';
import '../models/resource.dart';
import '../models/village.dart';

class LivelihoodRankResult {
  final LivelihoodIdea idea;
  final double fitScore;
  final String oneLineReason;
  final List<ResourceItem> matchedResources;
  final bool passesGates;
  final String? gateFailureReason;

  LivelihoodRankResult({
    required this.idea,
    required this.fitScore,
    required this.oneLineReason,
    required this.matchedResources,
    required this.passesGates,
    this.gateFailureReason,
  });
}

class LivelihoodEngine {
  // Custom weights adjustable from Admin panel
  double weightM = 0.35; // Resource availability
  double weightK = 0.20; // Market access
  double weightP = 0.15; // Local skills & SHG
  double weightE = 0.15; // Ease of start
  double weightG = 0.15; // Green / Ecological fit

  List<LivelihoodRankResult> evaluateAndRankIdeas({
    required List<LivelihoodIdea> allIdeas,
    required List<ResourceItem> villageResources,
    required VillageProfile profile,
  }) {
    List<LivelihoodRankResult> results = [];

    for (var idea in allIdeas) {
      // 1. Check Legal Gates First
      if (!idea.passesAllGates) {
        results.add(LivelihoodRankResult(
          idea: idea,
          fitScore: 0.0,
          oneLineReason: idea.gateRejectionReason ?? 'Violates FRA legal provisions.',
          matchedResources: [],
          passesGates: false,
          gateFailureReason: idea.gateRejectionReason,
        ));
        continue;
      }

      // 2. Find matching resources
      List<ResourceItem> matched = villageResources.where((r) {
        return idea.requiredResourceTypes.contains(r.type) &&
            r.utilityLabel != ResourceUtilityLabel.notUseful;
      }).toList();

      // 3. Compute Resource Score M
      double mScore = 0.40;
      if (matched.isNotEmpty) {
        double sum = 0;
        for (var r in matched) {
          sum += r.utilityScore;
        }
        mScore = sum / matched.length;
      }

      // 4. Compute Weighted Score F
      double kScore = profile.marketAccessScore;
      double pScore = profile.skillsScore;
      double eScore = idea.easeOfStartE;
      double gScore = idea.greenFitG;

      double f = (weightM * mScore) +
          (weightK * kScore) +
          (weightP * pScore) +
          (weightE * eScore) +
          (weightG * gScore);
      double finalScore = double.parse((f.clamp(0.1, 1.0) * 100).toStringAsFixed(1));

      // 5. Generate contextual one-line reason
      String reason = _generateContextualReason(idea, matched, profile, finalScore);

      results.add(LivelihoodRankResult(
        idea: idea,
        fitScore: finalScore,
        oneLineReason: reason,
        matchedResources: matched,
        passesGates: true,
      ));
    }

    // Sort valid ideas descending by score, invalid ideas at the end
    results.sort((a, b) {
      if (!a.passesGates && b.passesGates) return 1;
      if (a.passesGates && !b.passesGates) return -1;
      return b.fitScore.compareTo(a.fitScore);
    });

    return results;
  }

  List<LivelihoodRankResult> getTop5Ideas({
    required List<LivelihoodIdea> allIdeas,
    required List<ResourceItem> villageResources,
    required VillageProfile profile,
  }) {
    List<LivelihoodRankResult> ranked = evaluateAndRankIdeas(
      allIdeas: allIdeas,
      villageResources: villageResources,
      profile: profile,
    );
    return ranked.where((r) => r.passesGates).take(5).toList();
  }

  List<LivelihoodRankResult> getGatedAndHeldBackIdeas({
    required List<LivelihoodIdea> allIdeas,
    required List<ResourceItem> villageResources,
    required VillageProfile profile,
  }) {
    List<LivelihoodRankResult> ranked = evaluateAndRankIdeas(
      allIdeas: allIdeas,
      villageResources: villageResources,
      profile: profile,
    );
    // Returns gated ideas plus ideas ranked 6th and below
    List<LivelihoodRankResult> output = [];
    output.addAll(ranked.where((r) => !r.passesGates));
    List<LivelihoodRankResult> passed = ranked.where((r) => r.passesGates).toList();
    if (passed.length > 5) {
      output.addAll(passed.sublist(5));
    }
    return output;
  }

  String _generateContextualReason(
    LivelihoodIdea idea,
    List<ResourceItem> matched,
    VillageProfile profile,
    double score,
  ) {
    if (idea.id == 'idea_bamboo_processing') {
      return 'High culm density in CFR forest + active weaving skills + growing urban furniture demand.';
    } else if (idea.id == 'idea_fisheries') {
      return 'Perennial pond water available for 10 months; composite carp provides fast cash returns.';
    } else if (idea.id == 'idea_goat_rearing') {
      return 'Secured grazing entitlement in CFR order + 5 active SHG groups for collective rearing.';
    } else if (idea.id == 'idea_honey_beekeeping') {
      return 'Rich flowering deciduous forest; zero land conversion needed with high retail pricing.';
    } else if (idea.id == 'idea_medicinal_plants') {
      return 'Abundant wild Mahua & herbal belt; supported by 100% TRIFED Van Dhan grant.';
    } else if (idea.id == 'idea_watershed_works') {
      return 'Check dam needs desilting; 100% MGNREGA wage funding creates 450 person-days of labor.';
    } else if (idea.id == 'idea_mushroom') {
      return 'Zero forest land requirement; indoor village space with quick 25-day cash cycles.';
    }
    return 'Strong resource alignment (${matched.length} local assets) with favorable local skills.';
  }
}
