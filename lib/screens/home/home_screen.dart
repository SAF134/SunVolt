import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_station_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  // Bandung center (matches station)
  static final _initialCenter = LatLng(-6.96919, 107.62849);
  static const _initialZoom = 15.0;

  // Station data
  final List<_StationData> _stations = [
    _StationData(
      id: 'station_1',
      name: 'Stasiun SunVolt',
      position: LatLng(-6.969190449877452, 107.62849044096225),
      distance: '0m',
      slots: 2,
      tags: ['Utama'],
    ),
  ];

  int _selectedStationIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedStation = _stations[_selectedStationIndex];

    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap via flutter_map (Leaflet)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              maxZoom: 18,
              minZoom: 5,
              onTap: (_, p) {},
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.sunvolt.app',
                maxZoom: 19,
              ),
              // Station markers
              MarkerLayer(
                markers: _stations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final station = entry.value;
                  final isSelected = index == _selectedStationIndex;

                  return Marker(
                    point: station.position,
                    width: isSelected ? 56 : 44,
                    height: isSelected ? 56 : 44,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedStationIndex = index);
                        _mapController.move(station.position, 15);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isSelected
                                      ? AppColors.primaryContainer
                                      : AppColors.secondary)
                                  .withValues(alpha: 0.4),
                              blurRadius: isSelected ? 16 : 8,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: Icon(
                          Icons.bolt,
                          size: isSelected ? 28 : 20,
                          color: isSelected
                              ? AppColors.onPrimaryContainer
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top App Bar
          const SunVoltAppBar(),

          // My Location button
          Positioned(
            top: 110,
            right: 24,
            child: GestureDetector(
              onTap: () {
                _mapController.move(_initialCenter, _initialZoom);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFFEAB308),
                  size: 24,
                ),
              ),
            ),
          ),


          // Bottom station info card
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: SunVoltStationCard(
              name: selectedStation.name,
              address: 'Jl. Telekomunikasi No.1, Sukapura, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat',
              slots: selectedStation.slots,
              tags: selectedStation.tags,
              onSelect: () => Navigator.pushNamed(context, '/station-detail'),
            ),
          ),
        ],
      ),
    );
  }


}

class _StationData {
  final String id;
  final String name;
  final LatLng position;
  final String distance;
  final int slots;
  final List<String> tags;

  _StationData({
    required this.id,
    required this.name,
    required this.position,
    required this.distance,
    required this.slots,
    required this.tags,
  });
}
