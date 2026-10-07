import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/resource.dart';
import '../models/village.dart';
import '../services/geo_api_service.dart';
import '../theme/app_theme.dart';

class GisMapCanvas extends StatefulWidget {
  final Village village;
  final List<ResourceItem> resources;
  final List<OsmMapFeature> mapFeatures;
  final String activeFilter;
  final bool satelliteView;
  final Function(ResourceItem) onResourceSelected;

  const GisMapCanvas({
    Key? key,
    required this.village,
    required this.resources,
    required this.mapFeatures,
    required this.activeFilter,
    required this.satelliteView,
    required this.onResourceSelected,
  }) : super(key: key);

  @override
  State<GisMapCanvas> createState() => _GisMapCanvasState();
}

class _GisMapCanvasState extends State<GisMapCanvas> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant GisMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.village.id != widget.village.id ||
        oldWidget.village.latitude != widget.village.latitude ||
        oldWidget.village.longitude != widget.village.longitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            LatLng(widget.village.latitude, widget.village.longitude),
            13,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = widget.resources.where(_matchesFilter).toList();
    final center = LatLng(widget.village.latitude, widget.village.longitude);
    final markers = <Marker>[
      Marker(
        point: center,
        width: 42,
        height: 48,
        child: const Icon(
          Icons.location_on,
          color: AppColors.secondaryOrange,
          size: 42,
        ),
      ),
      ...resources.map(
        (resource) => Marker(
          point: LatLng(resource.latitude, resource.longitude),
          width: 42,
          height: 42,
          child: Tooltip(
            message: '${resource.name} • sample catalog location',
            child: InkWell(
              onTap: () => widget.onResourceSelected(resource),
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                backgroundColor: _colorFor(resource.type),
                child: Icon(
                  _iconFor(resource.type),
                  size: 19,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      ...widget.mapFeatures.map(
        (feature) => Marker(
          point: LatLng(feature.latitude, feature.longitude),
          width: 32,
          height: 32,
          child: Tooltip(
            message: '${feature.name} • OpenStreetMap',
            child: Icon(
              feature.kind == 'water' ? Icons.water_drop : Icons.forest,
              size: 24,
              color: feature.kind == 'water' ? Colors.lightBlue : Colors.green,
            ),
          ),
        ),
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              minZoom: 4,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: widget.satelliteView
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.vanrozgar_app',
                maxNativeZoom: 19,
              ),
              MarkerLayer(markers: markers),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                attributions: [
                  TextSourceAttribution(
                    widget.satelliteView
                        ? 'Imagery © Esri, Maxar, Earthstar Geographics'
                        : '© OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 10,
            top: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                child: Text(
                  widget.satelliteView ? 'Satellite imagery' : 'Street map',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Column(
              children: [
                _mapControl(Icons.add, () => _zoom(1)),
                const SizedBox(height: 6),
                _mapControl(Icons.remove, () => _zoom(-1)),
                const SizedBox(height: 6),
                _mapControl(
                  Icons.center_focus_strong,
                  () => _mapController.move(center, 13),
                ),
              ],
            ),
          ),
          if (widget.resources.isNotEmpty)
            Positioned(
              left: 10,
              bottom: 26,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    'Resource pins use sample catalog coordinates',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesFilter(ResourceItem resource) {
    switch (widget.activeFilter) {
      case 'water':
        return {
          ResourceType.checkDam,
          ResourceType.pond,
          ResourceType.well,
          ResourceType.canal,
        }.contains(resource.type);
      case 'forest':
        return {
          ResourceType.forestCompartment,
          ResourceType.bambooStand,
          ResourceType.medicinalPatch,
          ResourceType.sacredGrove,
        }.contains(resource.type);
      case 'land':
        return {
          ResourceType.grazingLand,
          ResourceType.agricultureParcel,
        }.contains(resource.type);
      case 'others':
        return true;
      default:
        return true;
    }
  }

  void _zoom(double delta) {
    final camera = _mapController.camera;
    _mapController.move(
      camera.center,
      (camera.zoom + delta).clamp(4, 19).toDouble(),
    );
  }

  Widget _mapControl(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 19, color: AppColors.primaryDark),
        ),
      ),
    );
  }

  Color _colorFor(ResourceType type) {
    switch (type) {
      case ResourceType.checkDam:
      case ResourceType.pond:
      case ResourceType.well:
      case ResourceType.canal:
        return AppColors.mapWater;
      case ResourceType.forestCompartment:
      case ResourceType.bambooStand:
      case ResourceType.medicinalPatch:
        return AppColors.usefulGreen;
      case ResourceType.grazingLand:
        return AppColors.mapGrazing;
      case ResourceType.sacredGrove:
        return AppColors.secondaryOrange;
      case ResourceType.agricultureParcel:
        return Colors.amber.shade700;
    }
  }

  IconData _iconFor(ResourceType type) {
    switch (type) {
      case ResourceType.checkDam:
      case ResourceType.pond:
        return Icons.water_drop;
      case ResourceType.well:
      case ResourceType.canal:
        return Icons.waves;
      case ResourceType.forestCompartment:
      case ResourceType.bambooStand:
        return Icons.park;
      case ResourceType.medicinalPatch:
        return Icons.spa;
      case ResourceType.grazingLand:
        return Icons.grass;
      case ResourceType.sacredGrove:
        return Icons.temple_buddhist;
      case ResourceType.agricultureParcel:
        return Icons.agriculture;
    }
  }
}
