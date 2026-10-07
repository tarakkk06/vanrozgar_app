import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maharashtra_districts.dart';
import '../models/village.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'main_navigation_shell.dart';

class ChooseVillageScreen extends StatefulWidget {
  const ChooseVillageScreen({Key? key}) : super(key: key);

  @override
  State<ChooseVillageScreen> createState() => _ChooseVillageScreenState();
}

class _ChooseVillageScreenState extends State<ChooseVillageScreen> {
  String _selectedDistrict = 'Nagpur';
  String _selectedTaluka = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final villages = provider.villages;
    final accessibleDistrictNames =
        villages.map((village) => village.district).toSet();
    final scopedDistricts = MaharashtraDataCatalog.districts
        .where((item) => accessibleDistrictNames.contains(item.name))
        .toList();
    final districts = scopedDistricts.isEmpty
        ? MaharashtraDataCatalog.districts
        : scopedDistricts;
    final activeDistrict =
        districts.any((item) => item.name == _selectedDistrict)
            ? _selectedDistrict
            : districts.first.name;
    final district = MaharashtraDataCatalog.byName(activeDistrict)!;
    final talukas = ['All', ...district.talukas];

    List<Village> filtered = villages.where((v) {
      if (v.district != activeDistrict) return false;
      if (_selectedTaluka != 'All' && v.taluka != _selectedTaluka) return false;
      if (_searchQuery.isNotEmpty) {
        String q = _searchQuery.toLowerCase();
        return v.name.toLowerCase().contains(q) ||
            v.marathiName.contains(q) ||
            v.taluka.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose Village / गाव निवडा',
            style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // District & Taluka Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'District / जिल्हा',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: activeDistrict,
                                dropdownColor: AppColors.primaryDark,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                isExpanded: true,
                                items: districts.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.name,
                                    child: Text(
                                        '${item.name} (${item.marathiName})'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedDistrict = value;
                                    _selectedTaluka = 'All';
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Taluka / तालुका',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTaluka,
                                dropdownColor: AppColors.primaryDark,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                                isExpanded: true,
                                items: talukas.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t,
                                    child: Text(t),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedTaluka = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Village Search TextField
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search village by name / गावाचे नाव शोधा',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.12),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Results / Village Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.isEmpty ? 1 : filtered.length,
              itemBuilder: (context, index) {
                if (filtered.isEmpty) {
                  final hasAccess = provider.currentUser?.isAdmin == true ||
                      (provider.currentUser?.allowedDistricts.isNotEmpty ??
                          false) ||
                      (provider.currentUser?.allowedVillageIds.isNotEmpty ??
                          false);
                  return Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      hasAccess
                          ? 'No village catalog entries for this district yet. '
                              'Connect an authoritative village dataset to populate it.'
                          : 'Your account has no assigned village or district access yet. '
                              'Ask your administrator to provision your profile.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final v = filtered[index];
                return _buildVillageCard(context, provider, v);
              },
            ),
          ),

          // Bottom Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: const Text(
              'Prototype statewide catalog • Entries and statistics are sample data, '
              'not an official CFR/village register.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVillageCard(
      BuildContext context, AppStateProvider provider, Village v) {
    Color badgeBg;
    Color badgeColor;
    String badgeText;

    switch (v.recognitionStatus) {
      case RecognitionStatus.cfrRecognised:
        badgeBg = AppColors.usefulGreenBg;
        badgeColor = AppColors.usefulGreen;
        badgeText = 'CFR Recognised (मान्यताप्राप्त)';
        break;
      case RecognitionStatus.potentialCfr:
        badgeBg = AppColors.partlyUsefulYellowBg;
        badgeColor = AppColors.partlyUsefulYellow;
        badgeText = 'Potential CFR (संभाव्य)';
        break;
      case RecognitionStatus.notMatched:
        badgeBg = AppColors.notUsefulRedBg;
        badgeColor = AppColors.notUsefulRed;
        badgeText = 'Not Matched';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          provider.selectVillage(v.id);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${v.localizedNameByLang(provider.langCode)} (${v.name})',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Taluka: ${v.taluka}, District: ${v.district}',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('CFR Forest Area', '${v.cfrAreaHectares} ha',
                      Icons.forest),
                  _buildStatItem(
                      'Households', '${v.householdCount}', Icons.home),
                  _buildStatItem(
                      'Readiness', '${v.readinessIndex}/100', Icons.speed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
          ],
        ),
      ],
    );
  }
}
