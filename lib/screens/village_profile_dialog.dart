import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/village.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class VillageProfileDialog extends StatefulWidget {
  const VillageProfileDialog({Key? key}) : super(key: key);

  @override
  State<VillageProfileDialog> createState() => _VillageProfileDialogState();
}

class _VillageProfileDialogState extends State<VillageProfileDialog> {
  late TextEditingController _townController;
  late double _distance;
  late String _roadType;
  late TextEditingController _buyerController;
  late bool _shgActive;
  late int _shgCount;
  late List<String> _selectedSkills;

  final List<String> _availableSkills = [
    'Bamboo Weaving',
    'Animal Husbandry',
    'Honey Harvesting',
    'Fisheries Management',
    'Leaf Plate Making',
    'Forest Patrolling',
    'Herbal Processing',
    'Mushroom Cultivation',
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppStateProvider>(context, listen: false).selectedVillage.profile;
    _townController = TextEditingController(text: profile.nearestMarketTown);
    _distance = profile.distanceToMarketKm;
    _roadType = profile.roadType;
    _buyerController = TextEditingController(text: profile.nearestProcessingPoint);
    _shgActive = profile.isShgActive;
    _shgCount = profile.activeShgCount;
    _selectedSkills = List.from(profile.localSkills);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.assessment, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Village Livelihood Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '6 Quick Questions to compute Market (K) and Skills (P) scores:',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),

            // 1. Market Town
            TextField(
              controller: _townController,
              decoration: const InputDecoration(
                labelText: '1. Nearest Market Town / बाजारपेठ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Distance in KM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('2. Distance to Market:', style: TextStyle(fontSize: 12.5)),
                Text('${_distance.round()} km', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _distance,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _distance = val),
            ),

            // 3. Road Type
            const Text('3. Road Connectivity / रस्ता प्रकार:', style: TextStyle(fontSize: 12.5)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _roadType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Paved Asphalt', child: Text('Paved Asphalt (पक्का डांबरी)')),
                DropdownMenuItem(value: 'Semi-paved / All-weather', child: Text('Semi-paved / All-weather')),
                DropdownMenuItem(value: 'Kutcha road', child: Text('Kutcha / Forest Track (कच्चा रस्ता)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _roadType = val);
              },
            ),
            const SizedBox(height: 12),

            // 4. Processing buyer
            TextField(
              controller: _buyerController,
              decoration: const InputDecoration(
                labelText: '4. Nearest Processing Cluster / खरेदीदार',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            // 5. SHG active
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('5. Active Mahila SHGs / बचत गट:', style: TextStyle(fontSize: 12.5)),
                Switch(
                  value: _shgActive,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _shgActive = v),
                ),
              ],
            ),

            // 6. Skills Checklist
            const Text('6. Village Skill Sets (कौशल्ये):', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableSkills.map((skill) {
                bool hasSkill = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill, style: TextStyle(fontSize: 11, color: hasSkill ? Colors.white : AppColors.textMain)),
                  selected: hasSkill,
                  selectedColor: AppColors.primary,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            VillageProfile newProfile = VillageProfile(
              nearestMarketTown: _townController.text,
              distanceToMarketKm: _distance,
              roadType: _roadType,
              nearestProcessingPoint: _buyerController.text,
              localSkills: _selectedSkills,
              isShgActive: _shgActive,
              activeShgCount: _shgCount,
            );
            provider.updateVillageProfile(newProfile);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Save Profile & Re-Rank'),
        ),
      ],
    );
  }
}
