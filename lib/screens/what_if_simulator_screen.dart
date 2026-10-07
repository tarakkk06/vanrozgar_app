import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resource.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'gram_sabha_screen.dart';

class WhatIfSimulatorScreen extends StatefulWidget {
  const WhatIfSimulatorScreen({super.key});

  @override
  State<WhatIfSimulatorScreen> createState() => _WhatIfSimulatorScreenState();
}

class _WhatIfSimulatorScreenState extends State<WhatIfSimulatorScreen> {
  String? _selectedResourceId;
  double _investmentLakhs = 2.0;
  double _waterAllocationSplit = 0.60; // 60% fisheries, 40% irrigation
  int _householdCount = 15;
  String _selectedOption =
      'integrated'; // 'fish_only', 'irrigation_only', 'integrated'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final resources = provider.resources;
    final selectedResourceExists =
        resources.any((resource) => resource.id == _selectedResourceId);
    final ponds = resources
        .where((resource) => resource.type == ResourceType.pond)
        .toList();
    final selectedResourceId = selectedResourceExists
        ? _selectedResourceId
        : ponds.isNotEmpty
            ? ponds.first.id
            : resources.isNotEmpty
                ? resources.first.id
                : null;

    // Simulation computations
    double estRevenueLakhs;
    int estLaborDays;
    int fitScore;
    String recommendationTag;

    if (_selectedOption == 'fish_only') {
      estRevenueLakhs =
          1.8 + (_investmentLakhs * 0.45) + (_householdCount * 0.05);
      estLaborDays = (140 + (_householdCount * 4)).clamp(100, 300);
      fitScore = (68 + (_waterAllocationSplit * 10)).clamp(60, 85).round();
      recommendationTag = 'Medium Return (Single Use)';
    } else if (_selectedOption == 'irrigation_only') {
      estRevenueLakhs =
          1.4 + (_investmentLakhs * 0.35) + (_householdCount * 0.04);
      estLaborDays = (120 + (_householdCount * 3)).clamp(90, 240);
      fitScore =
          (62 + ((1.0 - _waterAllocationSplit) * 12)).clamp(55, 78).round();
      recommendationTag = 'Seasonal Only (4 Months)';
    } else {
      // Integrated Fish + Irrigation + Desilting
      estRevenueLakhs =
          2.6 + (_investmentLakhs * 0.65) + (_householdCount * 0.08);
      estLaborDays = (220 + (_householdCount * 6)).clamp(180, 480);
      fitScore = 92;
      recommendationTag = 'Optimal Synergy (Recommended)';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Livelihood What-If Simulator',
            style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Selector Dropdown Card
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
                  const Text('Select Resource to Simulate',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedResourceId,
                    hint: Text(
                      resources.isEmpty
                          ? 'No resources available'
                          : 'Select a resource',
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: resources.map((r) {
                      return DropdownMenuItem<String>(
                        value: r.id,
                        child: Text(
                            '${r.name} (${r.typeDisplay.split(' ')[0]})',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: resources.isEmpty
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() => _selectedResourceId = val);
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3 Scenario Option Cards
            const Text('What-If Scenario Options',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Option A: Fish Farming
            _buildScenarioCard(
              id: 'fish_only',
              title: 'Option A: Pure Fish Farming',
              revenue: '₹2.5 Lakhs / yr',
              labor: 'High Employment (160 days)',
              score: 72,
              color: AppColors.mapWater,
            ),
            const SizedBox(height: 8),

            // Option B: Irrigation
            _buildScenarioCard(
              id: 'irrigation_only',
              title: 'Option B: Pure Rabi Irrigation',
              revenue: '₹1.9 Lakhs / yr',
              labor: 'Medium Employment (120 days)',
              score: 65,
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 8),

            // Option C: Integrated
            _buildScenarioCard(
              id: 'integrated',
              title: 'Option C: Fish + Irrigation + Desilting',
              revenue: '₹3.1L - ₹4.5L / yr',
              labor: 'Very High Employment (280 days)',
              score: 92,
              isRecommended: true,
              color: AppColors.usefulGreen,
            ),
            const SizedBox(height: 16),

            // Interactive Scenario Adjuster Sliders
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
                  const Row(
                    children: [
                      Icon(Icons.tune, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Dynamic Scenario Sliders',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Slider 1: Capital Investment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Capital Investment:',
                          style: TextStyle(fontSize: 12)),
                      Text('₹${_investmentLakhs.toStringAsFixed(1)} Lakhs',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _investmentLakhs,
                    min: 0.5,
                    max: 5.0,
                    divisions: 18,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _investmentLakhs = val),
                  ),

                  // Slider 2: Water Allocation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Water Allocation (Fish vs Agri):',
                          style: TextStyle(fontSize: 12)),
                      Text(
                          '${(_waterAllocationSplit * 100).round()}% / ${(100 - _waterAllocationSplit * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _waterAllocationSplit,
                    min: 0.2,
                    max: 0.8,
                    divisions: 12,
                    activeColor: AppColors.mapWater,
                    onChanged: (val) =>
                        setState(() => _waterAllocationSplit = val),
                  ),

                  // Slider 3: Household Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Participating SHG Households:',
                          style: TextStyle(fontSize: 12)),
                      Text('$_householdCount families',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _householdCount.toDouble(),
                    min: 5,
                    max: 40,
                    divisions: 35,
                    activeColor: AppColors.secondaryOrange,
                    onChanged: (val) =>
                        setState(() => _householdCount = val.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Simulation Outcome Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D765C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Simulated Annual Impact',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          recommendationTag,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImpactMetric(
                          'Net Revenue',
                          '₹${estRevenueLakhs.toStringAsFixed(2)}L',
                          Icons.currency_rupee),
                      _buildImpactMetric('Person-Days', '$estLaborDays days',
                          Icons.work_history),
                      _buildImpactMetric(
                          'Fit Score', '$fitScore%', Icons.auto_awesome),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Scenario locked into Gram Sabha proposal agenda.'),
                          backgroundColor: AppColors.usefulGreen,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const GramSabhaScreen()),
                      );
                    },
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('Adopt Scenario in GS Plan',
                        style: TextStyle(fontSize: 12)),
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

  Widget _buildScenarioCard({
    required String id,
    required String title,
    required String revenue,
    required String labor,
    required int score,
    required Color color,
    bool isRecommended = false,
  }) {
    bool isSelected = _selectedOption == id;

    return InkWell(
      onTap: () => setState(() => _selectedOption = id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.secondaryOrange : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.secondaryOrange.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? AppColors.secondaryOrange
                      : AppColors.textLight,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textMain,
                    ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.usefulGreenBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Recommended',
                        style: TextStyle(
                            color: AppColors.usefulGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(revenue,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(labor,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                  Text('Fit: $score%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }
}
