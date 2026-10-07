import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resource.dart';
import '../models/trust_label.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class ResourceVerifyScreen extends StatefulWidget {
  final ResourceItem resource;

  const ResourceVerifyScreen({Key? key, required this.resource}) : super(key: key);

  @override
  State<ResourceVerifyScreen> createState() => _ResourceVerifyScreenState();
}

class _ResourceVerifyScreenState extends State<ResourceVerifyScreen> {
  late double _a;
  late double _c;
  late double _s;
  late double _r;
  late CheckStatus _status;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _verifierNameController = TextEditingController(text: 'Suresh Patil (FRC Secretary)');
  final TextEditingController _notesController = TextEditingController();
  bool _photoTaken = true;

  @override
  void initState() {
    super.initState();
    _a = widget.resource.availabilityA;
    _c = widget.resource.conditionC;
    _s = widget.resource.seasonalityS;
    _r = widget.resource.reachR;
    _status = CheckStatus.confirmed;
    _reasonController.text = widget.resource.plainReason;
    _notesController.text = 'Ground inspection verified during FRC meeting. Check dam needs desilting before monsoon.';
  }

  double get _calculatedScore {
    double score = (0.35 * _a) + (0.25 * _c) + (0.25 * _s) + (0.15 * _r);
    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Resource Ground Verification', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Vision Detection Card (Camera/Photo Preview with tags)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 190,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F281E), Color(0xFF1E4D38)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.greenAccent, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'GPS: ${widget.resource.latitude.toStringAsFixed(4)}° N, ${widget.resource.longitude.toStringAsFixed(4)}° E (Auto)',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'AI Vision Active',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Detected AI Tags Box
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Detected Features (Edge Model):',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textMain),
                        ),
                        const SizedBox(height: 8),
                        _buildAiTagRow(Icons.check_circle_outline, 'Detected Feature: Check Dam / Nala Bundh'),
                        _buildAiTagRow(Icons.water, 'Water Level: Approx. 60% Capacity'),
                        _buildAiTagRow(Icons.build_outlined, 'Condition: Partially Damaged / Silted Weir Wall'),
                        _buildAiTagRow(Icons.satellite_outlined, 'Match with MRSAC Map: YES (92% Confidence)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Calculated Score Preview
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_calculatedScore',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recalculated Utility Score',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _calculatedScore >= 0.7
                              ? 'Label: Useful (उपयुक्त)'
                              : (_calculatedScore >= 0.4 ? 'Label: Partly Useful (अंशतः उपयुक्त)' : 'Label: Not Useful (अनुपयुक्त)'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _calculatedScore >= 0.7
                                ? AppColors.usefulGreen
                                : (_calculatedScore >= 0.4 ? AppColors.partlyUsefulYellow : AppColors.notUsefulRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4 Formula Input Sliders
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
                  const Text('Ground Check Parameters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSlider(
                    '1. Availability in Main Season (A)',
                    _a,
                    (val) => setState(() => _a = val),
                    '${(_a * 100).round()}%',
                  ),
                  _buildSlider(
                    '2. Physical Condition (C)',
                    _c,
                    (val) => setState(() => _c = val),
                    _c >= 0.7 ? 'Good' : (_c >= 0.4 ? 'Moderate' : 'Poor'),
                  ),
                  _buildSlider(
                    '3. Months of Use / Seasonality (S)',
                    _s,
                    (val) => setState(() => _s = val),
                    '${(_s * 12).round()} months',
                  ),
                  _buildSlider(
                    '4. Reach & Accessibility (R)',
                    _r,
                    (val) => setState(() => _r = val),
                    '${(_r * 100).round()}% Easy',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Selector (Confirmed / Changed / Rejected)
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
                  const Text('Verification Verdict', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildVerdictChip('Confirmed', CheckStatus.confirmed, AppColors.usefulGreen),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVerdictChip('Changed', CheckStatus.changed, AppColors.infoBlue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVerdictChip('Wrong Data', CheckStatus.rejected, AppColors.notUsefulRed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Plain Reason / कारण',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _verifierNameController,
                    decoration: const InputDecoration(
                      labelText: 'Verified By (Name / FRC Designation)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Audit Log Notes / नोंद',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.verifyResourceGroundCheck(
                    resourceId: widget.resource.id,
                    newA: _a,
                    newC: _c,
                    newS: _s,
                    newR: _r,
                    reason: _reasonController.text,
                    verifiedBy: _verifierNameController.text,
                    note: _notesController.text,
                    status: _status,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resource verified successfully! Score updated on map & ledger.'),
                      backgroundColor: AppColors.usefulGreen,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Submit Verification / नोंद सेव्ह करा', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTagRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textMain))),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double val, Function(double) onChanged, String display) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(display, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: val,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictChip(String label, CheckStatus s, Color color) {
    bool isSelected = _status == s;
    return InkWell(
      onTap: () => setState(() => _status = s),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
