import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/readiness_gauge.dart';

class ReadinessIndexScreen extends StatelessWidget {
  const ReadinessIndexScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final village = provider.selectedVillage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Village Livelihood Readiness Index', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Readiness Gauge Card with Full 7-Sub-indices Breakdown
            ReadinessGauge(village: village, showBreakdown: true),
            const SizedBox(height: 16),

            // Biggest Constraint & Bottleneck Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.notUsefulRedBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.notUsefulRed.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning, color: AppColors.notUsefulRed, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Primary Bottleneck: Market Connectivity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.notUsefulRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Village is located 14 km from nearest mandi over a semi-paved road. Without an on-site primary processing unit or collective aggregation hub, raw produce suffers a 30-40% price drop.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMain, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Action Recommended: Establish Gram Sabha Van Dhan processing centre to package commodities before dispatch.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Strategic Development Pillars Card
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
                  const Text('Strategic Recommendations', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildStrategyItem(
                    icon: Icons.water_drop,
                    color: AppColors.mapWater,
                    title: '1. Desilt Check Dam before June',
                    desc: 'Restoring weir storage adds 3 months of supplemental water for winter nursery and fisheries.',
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildStrategyItem(
                    icon: Icons.precision_manufacturing,
                    color: AppColors.usefulGreen,
                    title: '2. Setup Bamboo Treatment Dip Tank',
                    desc: 'Enables 10 local artisans to sell finished furniture at 4.2x raw culm value.',
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _buildStrategyItem(
                    icon: Icons.grass,
                    color: AppColors.mapGrazing,
                    title: '3. Construct Fodder Silage Depot',
                    desc: 'Harvest 60 tonnes of monsoon grass for lean summer dairy & goat feed.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
