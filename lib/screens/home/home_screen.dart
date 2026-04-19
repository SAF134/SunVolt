import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  bool _showCard = true; // Show by default or toggle? Let's keep it true initially if there's a selected station.
  
  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  String? _calculatedDistance;

  @override
  void initState() {
    super.initState();
    // Default calculated distance based on initial hardcoded distance could be set here,
    // but better to fetch actual user location first.
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan lokasi tidak aktif.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak permanen. Silakan atur di pengaturan aplikasi.')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_userLocation!, 15);
      await _calculateDistance(_userLocation!, _stations[_selectedStationIndex].position);
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _calculateDistance(LatLng origin, LatLng destination) async {
    try {
      // Using OSRM public API for driving distance (suitable for motorcycle estimate)
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=false');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final distanceMeters = data['routes'][0]['distance'];
          
          if (distanceMeters != null) {
            setState(() {
              if (distanceMeters < 1000) {
                _calculatedDistance = '${distanceMeters.toStringAsFixed(0)} m';
              } else {
                _calculatedDistance = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
              }
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating distance with OSRM: $e');
    }

    // Fallback to straight line distance if API fails
    final distance = const Distance().as(
      LengthUnit.Meter,
      origin,
      destination,
    );
    // Multiply by ~1.3 to roughly estimate road distance from straight line
    final estimatedRoadDistance = distance * 1.3;
    setState(() {
      if (estimatedRoadDistance < 1000) {
        _calculatedDistance = '${estimatedRoadDistance.toStringAsFixed(0)} m';
      } else {
        _calculatedDistance = '${(estimatedRoadDistance / 1000).toStringAsFixed(1)} km';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _StationData? selectedStation;
    if (_showCard) {
      selectedStation = _stations[_selectedStationIndex];
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const SunVoltAppBar(),
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
              // User Location Marker
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        setState(() {
                          _selectedStationIndex = index;
                          _showCard = true;
                        });
                        _mapController.move(station.position, 15);
                        if (_userLocation != null) {
                          _calculateDistance(_userLocation!, station.position);
                        }
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



          // My Location button
          Positioned(
            top: 134,
            right: 24,
            child: GestureDetector(
              onTap: _isLoadingLocation ? null : _getUserLocation,
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
                child: _isLoadingLocation 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Icon(
                        Icons.my_location,
                        color: Color(0xFFEAB308),
                        size: 20,
                      ),
              ),
            ),
          ),


          // Bottom station info card
          if (selectedStation != null)
            Positioned(
              bottom: 135,
              left: 24,
              right: 24,
              child: SunVoltStationCard(
                name: selectedStation.name,
                address:
                    'Jl. Telekomunikasi No.1, Sukapura, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat',
                slots: selectedStation.slots,
                tags: selectedStation.tags,
                distanceString: _calculatedDistance,
                onSelect: () => Navigator.pushNamed(context, '/station-detail'),
                onClose: () => setState(() => _showCard = false),
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
