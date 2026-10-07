import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resource.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trust_label_badge.dart';
import 'resource_verify_screen.dart';

class ResourceDetailScreen extends StatelessWidget {
  final ResourceItem resource;

  const ResourceDetailScreen({Key? key, required this.resource}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    Color labelColor = _getUtilityColor(resource.utilityLabel);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resource Detail / AI Analysis', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Header Card with simulated satellite/photo container
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D765C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                          SizedBox(width: 4),
                          Text('AI Analyzed', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          resource.typeDisplay,
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Score & Label Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${resource.utilityScore}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: labelColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              resource.utilityLabelText,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: labelColor),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${resource.utilityLabelMarathi})',
                              style: TextStyle(fontSize: 12, color: labelColor.withOpacity(0.8)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Formula: U = 0.35A + 0.25C + 0.25S + 0.15R',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Fact Sheet Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Key Parameters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildFactRow('Location', '${resource.latitude.toStringAsFixed(4)}° N, ${resource.longitude.toStringAsFixed(4)}° E'),
                  _buildFactRow('Area / Size', '${resource.areaHa} ha'),
                  _buildFactRow('Condition', resource.conditionC >= 0.7 ? 'Good' : (resource.conditionC >= 0.4 ? 'Needs Desilting / Repair' : 'Poor')),
                  _buildFactRow('Water Availability', '${(resource.seasonalityS * 12).round()} months (approx.)'),
                  _buildFactRow('Nearby Land', resource.nearbyLandUse),
                  _buildFactRow('Survey / 7/12', resource.surveyNumber ?? 'CFR Title Holding'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4 Formula Sliders Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Scoring Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildFactorProgress('Availability in Main Season (A: 35%)', resource.availabilityA),
                  _buildFactorProgress('Physical Condition (C: 25%)', resource.conditionC),
                  _buildFactorProgress('Seasonality Months/12 (S: 25%)', resource.seasonalityS),
                  _buildFactorProgress('Physical Reach & Access (R: 15%)', resource.reachR),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AI Assessment Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('AI Ground Assessment', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resource.aiAssessment,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: resource.aiTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Trust Label Card
            TrustLabelBadge(trustLabel: resource.trustLabel),
            const SizedBox(height: 20),

            // Action: Verify on Ground
            if (provider.isCommittee) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResourceVerifyScreen(resource: resource),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Verify on Ground / क्षेत्रीय पडताळणी'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFactRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMain)),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorProgress(String title, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              Text((val * 100).toStringAsFixed(0) + '%', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUtilityColor(ResourceUtilityLabel label) {
    switch (label) {
      case ResourceUtilityLabel.useful:
        return AppColors.usefulGreen;
      case ResourceUtilityLabel.partlyUseful:
        return AppColors.partlyUsefulYellow;
      case ResourceUtilityLabel.notUseful:
        return AppColors.notUsefulRed;
    }
  }
}
