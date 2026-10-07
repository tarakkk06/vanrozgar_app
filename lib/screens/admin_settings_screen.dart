import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late double _wM;
  late double _wK;
  late double _wP;
  late double _wE;
  late double _wG;

  @override
  void initState() {
    super.initState();
    final engine = Provider.of<AppStateProvider>(context, listen: false).engine;
    _wM = engine.weightM;
    _wK = engine.weightK;
    _wP = engine.weightP;
    _wE = engine.weightE;
    _wG = engine.weightG;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin & Formula Customizer',
            style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formula Tuning Card
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
                      Icon(Icons.tune, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Fit Score Weight Coefficients',
                          style: TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Formula: F = wM×M + wK×K + wP×P + wE×E + wG×G\nAdjust weights based on expert forest committee recommendations:',
                    style:
                        TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  _buildWeightSlider('Resource Quality Weight (wM)', _wM,
                      (v) => setState(() => _wM = v)),
                  _buildWeightSlider('Market Access Weight (wK)', _wK,
                      (v) => setState(() => _wK = v)),
                  _buildWeightSlider('Village Skills Weight (wP)', _wP,
                      (v) => setState(() => _wP = v)),
                  _buildWeightSlider('Ease of Start Weight (wE)', _wE,
                      (v) => setState(() => _wE = v)),
                  _buildWeightSlider('Green / Ecological Fit Weight (wG)', _wG,
                      (v) => setState(() => _wG = v)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final engine = provider.engine;
                        engine.weightM = _wM;
                        engine.weightK = _wK;
                        engine.weightP = _wP;
                        engine.weightE = _wE;
                        engine.weightG = _wG;
                        provider.notifyListeners();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Formula weights updated! Livelihood ranking recomputed.'),
                            backgroundColor: AppColors.usefulGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: const Text('Apply Weights to Engine'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // FRA Legal Gates Inspector
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
                      Icon(Icons.gavel,
                          color: AppColors.secondaryOrange, size: 20),
                      SizedBox(width: 8),
                      Text('Active FRA Legal Gates (Non-Negotiable)',
                          style: TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGateItem('Gate 1: FRA Section 4(4)',
                      'Strictly prohibits sale, lease, or alienation of forest land.'),
                  _buildGateItem('Gate 2: FRA Section 3(1)(l)',
                      'Strictly bans commercial hunting, trapping, or poaching.'),
                  _buildGateItem('Gate 3: FRA Section 5',
                      'Prohibits commercial tree felling, harm to wildlife or sacred groves.'),
                  _buildGateItem('Gate 4: Environmental Conversion Gate',
                      'Requires utilizing existing village/indoor space; zero forest clearance allowed.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Configured services and their current sync state.
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
                  const Text('Service Connections',
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildSyncRow(
                    'Firebase Authentication & Firestore',
                    provider.firebaseConfigured
                        ? 'Phone sign-in and realtime sync configured'
                        : 'Not configured; see Firebase setup in README',
                    provider.firebaseConfigured ? 'Configured' : 'Offline',
                    provider.firebaseConfigured,
                  ),
                  _buildSyncRow(
                    'Authorized 7/12 API',
                    provider.landRecordsConfigured
                        ? 'Authorized endpoint configured'
                        : 'Not configured; 7/12 data unavailable',
                    provider.landRecordsConfigured
                        ? 'Configured'
                        : 'Unavailable',
                    provider.landRecordsConfigured,
                  ),
                  _buildSyncRow(
                    'Map and nearby features',
                    provider.liveStatus,
                    provider.lastLiveSync == null
                        ? 'Not refreshed'
                        : provider.lastLiveSync!.toLocal().toString(),
                    provider.lastLiveSync != null,
                  ),
                  _buildSyncRow(
                    'Maharashtra village catalog',
                    'Prototype entries only; not an official village/CFR register',
                    'Sample data',
                    false,
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

  Widget _buildWeightSlider(
      String label, double val, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textMain)),
              Text('${(val * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ],
          ),
          Slider(
            value: val,
            min: 0.05,
            max: 0.60,
            divisions: 11,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGateItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle,
              color: AppColors.usefulGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.bold)),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncRow(
      String source, String details, String date, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(status ? Icons.cloud_done : Icons.cloud_off,
              color: status ? AppColors.usefulGreen : AppColors.notUsefulRed,
              size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(details,
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(date,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}
