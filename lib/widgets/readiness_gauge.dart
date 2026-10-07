import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/village.dart';

class ReadinessGauge extends StatelessWidget {
  final Village village;
  final bool showBreakdown;

  const ReadinessGauge({
    Key? key,
    required this.village,
    this.showBreakdown = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int score = village.readinessIndex;

    Color gaugeColor = AppColors.usefulGreen;
    if (score < 50) {
      gaugeColor = AppColors.notUsefulRed;
    } else if (score < 75) {
      gaugeColor = AppColors.partlyUsefulYellow;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular Gauge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gaugeColor, width: 4.5),
                  color: gaugeColor.withOpacity(0.08),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: gaugeColor,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Village Livelihood Readiness',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score >= 75
                          ? 'High potential for enterprise takeoff. Water and forest base are strong.'
                          : 'Moderate readiness. Needs market connectivity and desilting support.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showBreakdown) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            _buildScoreRow('Water Availability', village.waterScore, AppColors.mapWater),
            _buildScoreRow('Land Potential', village.landScore, AppColors.mapGrazing),
            _buildScoreRow('Forest Resources', village.forestScore, AppColors.usefulGreen),
            _buildScoreRow('Local Skills', village.skillsScore, const Color(0xFF8B5CF6)),
            _buildScoreRow('Market Access', village.marketScore, AppColors.secondaryOrange),
            _buildScoreRow('Infrastructure', village.infrastructureScore, const Color(0xFF0284C7)),
            _buildScoreRow('Sustainability', village.sustainabilityScore, const Color(0xFF059669)),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, int value, Color barColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100.0,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 25,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
