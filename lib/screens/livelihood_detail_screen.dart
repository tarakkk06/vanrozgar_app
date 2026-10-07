import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/livelihood_idea.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trust_label_badge.dart';
import 'gram_sabha_screen.dart';
import 'what_if_simulator_screen.dart';

class LivelihoodDetailScreen extends StatelessWidget {
  final LivelihoodIdea idea;

  const LivelihoodDetailScreen({Key? key, required this.idea}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(idea.title, style: const TextStyle(fontSize: 15)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          idea.categoryDisplay,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.usefulGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Demand: ${idea.marketDemandRating}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.usefulGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    idea.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  Text(
                    idea.marathiTitle,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    idea.basicIdea,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Financial Snapshot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Economics & Financial Potential', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildFinancialRow('Estimated Annual Revenue', idea.annualRevenueRange, AppColors.primaryDark),
                  _buildFinancialRow('Initial Capital Required', '₹${idea.initialInvestmentLakhs} Lakhs (Supported by Subsidy)', AppColors.secondaryOrange),
                  _buildFinancialRow('Local Employment Generated', '${idea.estimatedEmploymentDays} Person-Days per Year', AppColors.usefulGreen),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Income Sources & Value Addition
            _buildSectionCard(
              title: 'Income Sources / उत्पन्न स्रोत',
              icon: Icons.monetization_on_outlined,
              items: idea.incomeSources,
            ),
            const SizedBox(height: 14),

            // Required Skills
            _buildSectionCard(
              title: 'Required Skills / आवश्यक कौशल्ये',
              icon: Icons.psychology_outlined,
              items: idea.requiredSkillNames,
            ),
            const SizedBox(height: 14),

            // Forest Safety & FRA Compliance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Forest Safety & Legal Gating', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    idea.forestSafetyRule,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMain, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Statutory Base: ${idea.legalBase}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Implementation Steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Implementation Steps / कृती आराखडा', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...idea.implementationSteps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textMain, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // First Year Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('First Year Timeline / १ वर्षाचे नियोजन', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...idea.firstYearTimeline.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              e.key,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMain),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Risks & Mitigation
            _buildSectionCard(
              title: 'Key Risks & Challenges',
              icon: Icons.warning_amber_rounded,
              items: idea.risks,
            ),
            const SizedBox(height: 14),

            // Trust Label
            TrustLabelBadge(trustLabel: idea.trustLabel),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.markIdeaInterest(idea.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GramSabhaScreen()),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Add to Gram Sabha Agenda', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 12.5, color: AppColors.textMain, height: 1.3)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
