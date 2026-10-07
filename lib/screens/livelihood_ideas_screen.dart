import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/livelihood_idea.dart';
import '../providers/app_state_provider.dart';
import '../services/livelihood_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/trust_label_badge.dart';
import 'livelihood_detail_screen.dart';
import 'village_profile_dialog.dart';
import 'gram_sabha_screen.dart';
import 'what_if_simulator_screen.dart';

class LivelihoodIdeasScreen extends StatefulWidget {
  const LivelihoodIdeasScreen({Key? key}) : super(key: key);

  @override
  State<LivelihoodIdeasScreen> createState() => _LivelihoodIdeasScreenState();
}

class _LivelihoodIdeasScreenState extends State<LivelihoodIdeasScreen> {
  String _activeCategoryFilter = 'top5'; // 'top5', 'all', 'animal', 'forest', 'fisheries', 'craft', 'eco'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final village = provider.selectedVillage;
    final top5 = provider.top5Ideas;
    final all22 = provider.allIdeas;

    List<LivelihoodRankResult> displayList;

    if (_activeCategoryFilter == 'top5') {
      displayList = top5;
    } else {
      // Evaluate all 22 against current village
      var allEvaluated = provider.engine.evaluateAndRankIdeas(
        allIdeas: all22,
        villageResources: provider.resources,
        profile: village.profile,
      );

      if (_activeCategoryFilter == 'animal') {
        displayList = allEvaluated
            .where((r) => r.idea.category == IdeaCategory.animalHusbandry)
            .toList();
      } else if (_activeCategoryFilter == 'forest') {
        displayList = allEvaluated
            .where((r) =>
                r.idea.category == IdeaCategory.forestProduceProcessing ||
                r.idea.category == IdeaCategory.agroforestryNursery ||
                r.idea.category == IdeaCategory.controlledBioEnterprise)
            .toList();
      } else if (_activeCategoryFilter == 'craft') {
        displayList = allEvaluated
            .where((r) => r.idea.category == IdeaCategory.artisanCraft)
            .toList();
      } else if (_activeCategoryFilter == 'fisheries') {
        displayList = allEvaluated
            .where((r) => r.idea.category == IdeaCategory.fisheries)
            .toList();
      } else if (_activeCategoryFilter == 'eco') {
        displayList = allEvaluated
            .where((r) =>
                r.idea.category == IdeaCategory.ecoTourism ||
                r.idea.category == IdeaCategory.conservationWork)
            .toList();
      } else {
        displayList = allEvaluated;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Livelihood Intelligence (22 Ideas)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('${village.localizedNameByLang(provider.langCode)} • Formula F = 0.35M + 0.20K + 0.15P + 0.15E + 0.15G',
                style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Why not other ideas?',
            onPressed: () => _showWhyNotOthersDialog(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Village Profile Summary Banner Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Access: ${(village.profile.marketAccessScore * 100).round()}% • Skills: ${(village.profile.skillsScore * 100).round()}%',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Town: ${village.profile.nearestMarketTown} (${village.profile.distanceToMarketKm.round()} km) • SHGs: ${village.profile.activeShgCount}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const VillageProfileDialog(),
                    );
                  },
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Category Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('top5', 'Top 5 Ranked', Icons.stars),
                  const SizedBox(width: 6),
                  _buildCategoryChip('all', 'All 22 Library', Icons.view_list),
                  const SizedBox(width: 6),
                  _buildCategoryChip('forest', 'Forest & Bio', Icons.forest),
                  const SizedBox(width: 6),
                  _buildCategoryChip('craft', 'Bamboo & Craft', Icons.precision_manufacturing),
                  const SizedBox(width: 6),
                  _buildCategoryChip('animal', 'Goats & Dairy', Icons.pets),
                  const SizedBox(width: 6),
                  _buildCategoryChip('fisheries', 'Fisheries', Icons.water),
                  const SizedBox(width: 6),
                  _buildCategoryChip('eco', 'Eco & Services', Icons.tour),
                ],
              ),
            ),
          ),

          // Ideas List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final rankItem = displayList[index];
                return _buildIdeaCard(context, provider, rankItem, index + 1);
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showWhyNotOthersDialog(context, provider),
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text('Why not others?', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GramSabhaScreen()),
                      );
                    },
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Make GS Summary', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label, IconData icon) {
    bool isSelected = _activeCategoryFilter == key;
    return ChoiceChip(
      avatar: Icon(icon, size: 13, color: isSelected ? Colors.white : AppColors.textMuted),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeCategoryFilter = key),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textMain,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildIdeaCard(
    BuildContext context,
    AppStateProvider provider,
    LivelihoodRankResult item,
    int displayIndex,
  ) {
    final idea = item.idea;
    bool isGated = !item.passesGates;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isGated ? AppColors.notUsefulRed.withOpacity(0.4) : AppColors.border,
          width: isGated ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Rank Badge, Title, Fit Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isGated ? AppColors.notUsefulRedBg : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$displayIndex',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isGated ? AppColors.notUsefulRed : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idea.title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        idea.marathiTitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGated ? AppColors.notUsefulRedBg : AppColors.usefulGreenBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isGated ? AppColors.notUsefulRed : AppColors.usefulGreen,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isGated ? 'Gated Out' : 'Fit: ${item.fitScore}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isGated ? AppColors.notUsefulRed : AppColors.usefulGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // One-Line Reason
            Text(
              item.oneLineReason,
              style: TextStyle(
                fontSize: 12.5,
                color: isGated ? AppColors.notUsefulRed : AppColors.textMain,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),

            // Economics & Metrics Row
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Est. Annual Revenue', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text(idea.annualRevenueRange,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Initial Investment', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text('₹${idea.initialInvestmentLakhs} Lakhs',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Labor Days', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text('${idea.estimatedEmploymentDays} days',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Matched Resources & Legal Base
            Row(
              children: [
                const Icon(Icons.gavel, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    idea.legalBase,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons: Open Plan & Mark Interest
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LivelihoodDetailScreen(idea: idea),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Open Plan / आराखडा पहा', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    provider.markIdeaInterest(idea.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Marked interest in ${idea.title}! Total: ${idea.markedInterestCount}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 14),
                  label: Text('Interest (${idea.markedInterestCount})', style: const TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWhyNotOthersDialog(BuildContext context, AppStateProvider provider) {
    final gatedList = provider.gatedAndHeldBackIdeas;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                children: [
                  const Text(
                    'Why Not Other Ideas? (Legal Gates & Ranking)',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'VanRozgar applies 4 strict FRA legal gates to filter out illegal proposals, then ranks the remaining ideas by fit score:',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ...gatedList.map((item) {
                    bool isIllegal = !item.passesGates;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isIllegal ? AppColors.notUsefulRedBg : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isIllegal ? AppColors.notUsefulRed.withOpacity(0.4) : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isIllegal ? Icons.block : Icons.low_priority,
                                color: isIllegal ? AppColors.notUsefulRed : AppColors.textMuted,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.idea.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: isIllegal ? AppColors.notUsefulRed : AppColors.textMain,
                                  ),
                                ),
                              ),
                              Text(
                                isIllegal ? 'LEGAL GATE REJECTION' : 'Rank Score: ${item.fitScore}%',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isIllegal ? AppColors.notUsefulRed : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.oneLineReason,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMain),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
