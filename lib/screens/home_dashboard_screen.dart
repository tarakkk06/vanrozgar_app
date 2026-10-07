import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/village_header_bar.dart';
import '../widgets/readiness_gauge.dart';
import 'choose_village_screen.dart';
import 'schemes_screen.dart';
import 'gram_sabha_screen.dart';
import 'market_intelligence_screen.dart';
import 'seasonal_calendar_screen.dart';
import 'readiness_index_screen.dart';
import 'livelihood_detail_screen.dart';
import 'admin_settings_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final village = provider.selectedVillage;
    final topIdeas = provider.top5Ideas;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: VillageHeaderBar(
              onSearchVillage: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChooseVillageScreen()),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Action Grid (6 Tiles matching prototype)
                _buildQuickActionGrid(context, provider),
                const SizedBox(height: 16),

                // Quick Insights Highlight Card
                _buildQuickInsightCard(context, provider, topIdeas.isNotEmpty ? topIdeas.first : null),
                const SizedBox(height: 16),

                // Readiness Index Preview Card
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReadinessIndexScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: ReadinessGauge(village: village, showBreakdown: false),
                ),
                const SizedBox(height: 16),

                // Top Opportunities Ranked List
                _buildTopOpportunitiesSection(context, provider),
                const SizedBox(height: 16),

                // Live Alerts & Ground Updates
                _buildAlertsSection(),
                const SizedBox(height: 16),

                // Extra Tools Bar (Market Intel, Seasonal Calendar, Admin)
                _buildUtilityGrid(context, provider),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, AppStateProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.map_outlined,
                title: 'Village Map',
                subtitle: '8 MRSAC Layers',
                color: const Color(0xFF0284C7),
                onTap: () => provider.setTabIndex(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.inventory_2_outlined,
                title: 'Resources',
                subtitle: '${provider.resources.length} Assets Logged',
                color: AppColors.usefulGreen,
                onTap: () => provider.setTabIndex(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.lightbulb_outline,
                title: 'Livelihoods',
                subtitle: '22 Idea Library',
                color: AppColors.secondaryOrange,
                onTap: () => provider.setTabIndex(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.auto_graph_outlined,
                title: 'AI Simulator',
                subtitle: 'What-If Scenarios',
                color: const Color(0xFF8B5CF6),
                onTap: () => provider.setTabIndex(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.account_balance_outlined,
                title: 'Schemes',
                subtitle: 'Govt & NGO Funds',
                color: const Color(0xFF059669),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SchemesScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.groups_outlined,
                title: 'Gram Sabha',
                subtitle: 'Quorum & PDF',
                color: const Color(0xFFEA580C),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GramSabhaScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsightCard(BuildContext context, AppStateProvider provider, dynamic topIdea) {
    if (topIdea == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D765C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'AI Quick Insight',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Fit Score: ${topIdea.fitScore}%',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Top Opportunity: ${topIdea.idea.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            topIdea.oneLineReason,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Est. Revenue: ${topIdea.idea.annualRevenueRange}',
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LivelihoodDetailScreen(idea: topIdea.idea),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopOpportunitiesSection(BuildContext context, AppStateProvider provider) {
    final topIdeas = provider.top5Ideas;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Livelihood Opportunities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              InkWell(
                onTap: () => provider.setTabIndex(2),
                child: const Text(
                  'View All 22 →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topIdeas.take(3).map((item) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LivelihoodDetailScreen(idea: item.idea),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        '${topIdeas.indexOf(item) + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.idea.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                          Text(
                            item.idea.annualRevenueRange,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.usefulGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.fitScore}%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.usefulGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
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
          const Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.secondaryOrange, size: 18),
              SizedBox(width: 6),
              Text(
                'Live Alerts & Ground Updates',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAlertItem(
            icon: Icons.warning_amber_rounded,
            color: AppColors.partlyUsefulYellow,
            title: 'Check Dam siltation alert',
            time: '2 hrs ago',
            desc: 'Talavade Nala weir needs desilting before monsoon.',
          ),
          const Divider(height: 16, color: AppColors.border),
          _buildAlertItem(
            icon: Icons.trending_up,
            color: AppColors.usefulGreen,
            title: 'Bamboo craft market demand rising',
            time: '4 hrs ago',
            desc: 'Nagpur & Pune buyers paying ₹55-70 per treated culm.',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityGrid(BuildContext context, AppStateProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketIntelligenceScreen()),
              );
            },
            icon: const Icon(Icons.show_chart, size: 16, color: AppColors.primary),
            label: const Text('Market Intel', style: TextStyle(fontSize: 12, color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeasonalCalendarScreen()),
              );
            },
            icon: const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
            label: const Text('Seasonal Plan', style: TextStyle(fontSize: 12, color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
            icon: const Icon(Icons.tune, size: 16, color: AppColors.primary),
            label: const Text('Admin', style: TextStyle(fontSize: 12, color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
