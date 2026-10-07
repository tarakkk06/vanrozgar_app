import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/land_record_7_12.dart';
import '../models/resource.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gis_map_canvas.dart';
import '../widgets/trust_label_badge.dart';
import 'resource_detail_screen.dart';
import 'resource_verify_screen.dart';

class GisResourceMapScreen extends StatefulWidget {
  const GisResourceMapScreen({Key? key}) : super(key: key);

  @override
  State<GisResourceMapScreen> createState() => _GisResourceMapScreenState();
}

class _GisResourceMapScreenState extends State<GisResourceMapScreen> {
  String _activeFilter = 'all'; // 'all', 'water', 'land', 'forest', 'others'
  ResourceItem? _selectedResource;
  bool _satelliteView = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final village = provider.selectedVillage;
    final resources = provider.resources;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${village.localizedNameByLang(provider.langCode)} Village Map',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              'CFR Area: ${village.cfrAreaHectares} ha • ${village.district}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: Icon(
              _satelliteView ? Icons.map_outlined : Icons.satellite_alt,
            ),
            tooltip:
                _satelliteView ? 'Switch to street map' : 'Switch to satellite',
            onPressed: () => setState(() => _satelliteView = !_satelliteView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh map data',
            onPressed: provider.liveSyncing
                ? null
                : () => provider.refreshLiveVillageData(),
          ),
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Fetch 7/12 land record',
            onPressed: () => _showLandRecord(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Map Layers',
            onPressed: () => _showLayersBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(
              children: [
                if (provider.liveSyncing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    provider.firebaseConfigured
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    size: 16,
                    color: provider.firebaseConfigured
                        ? AppColors.usefulGreen
                        : AppColors.textMuted,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.liveSyncing
                        ? 'Refreshing map and authorized data…'
                        : provider.liveStatus,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All / सर्व', Icons.grid_view),
                  const SizedBox(width: 8),
                  _buildFilterChip('water', 'Water (जल)', Icons.water_drop),
                  const SizedBox(width: 8),
                  _buildFilterChip('forest', 'Forest (वन)', Icons.forest),
                  const SizedBox(width: 8),
                  _buildFilterChip('land', 'Land (जमीन)', Icons.grass),
                  const SizedBox(width: 8),
                  _buildFilterChip('others', 'Others', Icons.more_horiz),
                ],
              ),
            ),
          ),

          // Map Area
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: GisMapCanvas(
                village: village,
                resources: resources,
                mapFeatures: provider.mapFeatures,
                activeFilter: _activeFilter,
                satelliteView: _satelliteView,
                onResourceSelected: (res) {
                  setState(() {
                    _selectedResource = res;
                  });
                },
              ),
            ),
          ),

          // Bottom Resource Preview Card / Selected Resource Inspector
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -3)),
                ],
              ),
              child: _selectedResource == null
                  ? _buildDefaultResourcesList(context, provider, resources)
                  : _buildSelectedResourceInspector(
                      context, provider, _selectedResource!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    bool isSelected = _activeFilter == key;
    return ChoiceChip(
      avatar: Icon(icon,
          size: 14, color: isSelected ? Colors.white : AppColors.textMuted),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeFilter = key),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textMain,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildDefaultResourcesList(BuildContext context,
      AppStateProvider provider, List<ResourceItem> resources) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sample Resources (${resources.length})',
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain),
            ),
            const Text(
              'Catalog pins are approximate',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final r = resources[index];
              return InkWell(
                onTap: () => setState(() => _selectedResource = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildUtilityIcon(r.utilityLabel),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Score: ${r.utilityScore} • ${r.utilityLabelText}',
                              style: TextStyle(
                                fontSize: 11,
                                color: _getUtilityColor(r.utilityLabel),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TrustLabelBadge(
                          trustLabel: r.trustLabel, isCompact: true),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedResourceInspector(
      BuildContext context, AppStateProvider provider, ResourceItem res) {
    Color labelColor = _getUtilityColor(res.utilityLabel);

    return SingleChildScrollView(
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
                      res.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${res.typeDisplay} • Area: ${res.areaHa} ha',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedResource = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: labelColor, width: 1),
                ),
                child: Text(
                  'Score: ${res.utilityScore} • ${res.utilityLabelText}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (res.surveyNumber != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Survey #${res.surveyNumber}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            res.plainReason,
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.textMain, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResourceDetailScreen(resource: res),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label:
                      const Text('AI Analysis', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              if (provider.isCommittee) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResourceVerifyScreen(resource: res),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fact_check, size: 16),
                    label: const Text('Verify on Ground',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityIcon(ResourceUtilityLabel label) {
    Color c = _getUtilityColor(label);
    IconData icon = label == ResourceUtilityLabel.useful
        ? Icons.check_circle
        : (label == ResourceUtilityLabel.partlyUseful
            ? Icons.info
            : Icons.cancel);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration:
          BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icon, color: c, size: 16),
    );
  }

  Color _getUtilityColor(ResourceUtilityLabel label) {
    switch (label) {
      case ResourceUtilityLabel.useful:
        return AppColors.usefulGreen;
      case ResourceUtilityLabel.partlyUseful:
        return AppColors.partlyUsefulYellow;
      case ResourceUtilityLabel.notUseful:
        return AppColors.notUsefulRed;
    }
  }

  void _showLayersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Map data layers',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildLayerRow(
                  'Sample resource catalog pins', true, AppColors.usefulGreen),
              _buildLayerRow(
                  'OpenStreetMap nearby features', true, AppColors.mapWater),
              _buildLayerRow('Official CFR/cadastral boundaries', false,
                  const Color(0xFF7C3AED)),
              _buildLayerRow('Official 7/12 overlay', false, Colors.amber),
              const SizedBox(height: 8),
              const Text(
                'Official land boundaries and 7/12 data are not connected. '
                'Do not use sample pins as legal or survey boundaries.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayerRow(String name, bool isVisible, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
          Icon(
            isVisible ? Icons.check : Icons.info_outline,
            size: 16,
            color: isVisible ? AppColors.primary : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Future<void> _showLandRecord(
    BuildContext context,
    AppStateProvider provider,
  ) async {
    final surveys = provider.selectedVillage.surveyNumbers;
    if (surveys.isEmpty) {
      _showLandRecordDialog(
        context,
        message: 'No survey number is available for this sample village.',
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Checking authorized 7/12 service…'),
          ],
        ),
      ),
    );

    LandRecord712? record;
    Object? error;
    try {
      record = await provider.fetch712ForSurvey(surveys.first);
    } catch (caught) {
      error = caught;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (error != null) {
      _showLandRecordDialog(context, message: '7/12 request failed: $error');
      return;
    }
    if (record == null) {
      _showLandRecordDialog(
        context,
        message: provider.landRecordsConfigured
            ? 'The authorized service returned no record for survey ${surveys.first}.'
            : 'No approved 7/12 API is configured. This app will not invent '
                'landholder names, areas, or crop records. Connect an authorized '
                'government/API proxy to enable live retrieval.',
      );
      return;
    }
    _showLandRecordDialog(
      context,
      record: record,
      message: 'Source: ${record.apiSource}',
    );
  }

  void _showLandRecordDialog(
    BuildContext context, {
    required String message,
    LandRecord712? record,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('7/12 Land Record'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              if (record != null) ...[
                const SizedBox(height: 12),
                Text(
                    'Village: ${record.village}, ${record.taluka}, ${record.district}'),
                Text(
                    'Survey/Gat: ${record.surveyGatNumber}/${record.hissaNumber}'),
                Text('Khata: ${record.khataNumber}'),
                Text('Holders: ${record.khatedarNames.join(', ')}'),
                Text('Total area: ${record.totalAreaHa} ha'),
                Text('Cultivable area: ${record.cultivableAreaHa} ha'),
                Text('Land/tenure: ${record.landType} / ${record.tenureType}'),
                Text('Extract date: ${record.extractDate}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
