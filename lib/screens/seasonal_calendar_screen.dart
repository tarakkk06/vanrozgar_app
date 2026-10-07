import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeasonalCalendarScreen extends StatelessWidget {
  const SeasonalCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seasonal Livelihood Calendar (हंगामी नियोजन)', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nagpur Agro-Forestry Seasonal Cycle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 4),
            const Text(
              'Synchronize village labor and harvesting cycles across 3 distinct seasons:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),

            // Season 1: Jun - Sep (Monsoon)
            _buildSeasonCard(
              title: 'Jun – Sep (Monsoon / पावसाळा)',
              badgeText: 'Catchment Filling & Planting',
              badgeColor: AppColors.mapWater,
              icon: Icons.water_drop,
              activities: [
                'Agriculture: Kharif Paddy, Soybean, and Tur sowing.',
                'Fishery: Release 5,000 advanced carp fingerlings in community pond.',
                'Nursery: Polybag seedling preparation and afforestation planting.',
                'Grass: High biomass grass harvesting for community fodder bank.',
              ],
            ),
            const SizedBox(height: 12),

            // Season 2: Oct - Jan (Post-Monsoon / हिवाळा)
            _buildSeasonCard(
              title: 'Oct – Jan (Post-Monsoon / हिवाळा)',
              badgeText: 'Processing & Peak Harvest',
              badgeColor: AppColors.usefulGreen,
              icon: Icons.eco,
              activities: [
                'Vegetables & Drip horticulture using well water table.',
                'Minor Forest Produce: Wild herbal collection, solar drying, and sorting.',
                'Bamboo: Harvesting mature 3-year-old culms and boron bath treatment.',
                'Fireline: Clearing 15km forest firebreak lines along CFR boundaries.',
              ],
            ),
            const SizedBox(height: 12),

            // Season 3: Feb - May (Summer / उन्हाळा)
            _buildSeasonCard(
              title: 'Feb – May (Summer / उन्हाळा)',
              badgeText: 'MFP Harvesting & Desilting',
              badgeColor: AppColors.secondaryOrange,
              icon: Icons.wb_sunny,
              activities: [
                'Honey Harvesting: Wild forest honey collection and hygienic bottling.',
                'Tendu Leaves: Bush pruning, phad collection, grading, and e-auction.',
                'Mahua Flowers: Collection, solar dehydration, and packaging.',
                'MGNREGA: Continuous contour trenches (CCT) & check dam desilting before rains.',
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required List<String> activities,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                    Text(badgeText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          ...activities.map((act) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(act, style: const TextStyle(fontSize: 12.5, color: AppColors.textMain, height: 1.3)),
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
