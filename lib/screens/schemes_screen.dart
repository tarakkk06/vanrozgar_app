import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scheme.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class SchemesScreen extends StatefulWidget {
  final String? filterIdeaId;

  const SchemesScreen({Key? key, this.filterIdeaId}) : super(key: key);

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final allSchemes = provider.schemes;

    List<Scheme> filtered = allSchemes.where((s) {
      if (widget.filterIdeaId != null && !s.linkedIdeaIds.contains(widget.filterIdeaId)) {
        return false;
      }
      return true;
    }).toList();

    List<Scheme> govtSchemes = filtered.where((s) => s.type == SchemeType.government).toList();
    List<Scheme> ngoSchemes = filtered.where((s) => s.type == SchemeType.ngo).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Government & NGO Schemes', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondaryOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: 'Government Schemes (${govtSchemes.length})'),
            Tab(text: 'NGO Partner Schemes (${ngoSchemes.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSchemesList(govtSchemes),
          _buildSchemesList(ngoSchemes),
        ],
      ),
    );
  }

  Widget _buildSchemesList(List<Scheme> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No schemes found for the selected filter.', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildSchemeCard(context, item);
      },
    );
  }

  Widget _buildSchemeCard(BuildContext context, Scheme item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.type == SchemeType.government ? AppColors.primaryLight : AppColors.usefulGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.type == SchemeType.government ? 'Central / State Govt' : 'NGO Pilot Grant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.type == SchemeType.government ? AppColors.primaryDark : AppColors.usefulGreen,
                  ),
                ),
              ),
              Text(
                item.lastCheckedDate.split('(')[0].trim(),
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          Text(
            item.marathiTitle,
            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'Authority: ${item.authorityOrNgo}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMain, height: 1.35),
          ),
          const SizedBox(height: 12),

          // Subsidy Highlight Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppColors.secondaryOrange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.subsidyOrSupport,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Contact Details & Process
          Row(
            children: [
              const Icon(Icons.person_pin, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Contact: ${item.contactPerson}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Eligibility: ${item.eligibleBeneficiaries}',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${item.officialPortalUrl}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Portal Link ↗', style: TextStyle(fontSize: 11, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
