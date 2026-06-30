import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_station_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
      tags: ['Utama'],
    ),
  ];

  int _selectedStationIndex = 0;
  bool _showCard = true;
  
  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  String? _calculatedDistance;

  // ── Route Polyline Data ──
  List<LatLng> _routePoints = [];
  double? _routeDistanceMeters;
  double? _routeDurationSeconds;

  late AnimationController _routePanelController;
  late Animation<double> _routePanelAnimation;

  @override
  void initState() {
    super.initState();
    _routePanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _routePanelAnimation = CurvedAnimation(
      parent: _routePanelController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _routePanelController.dispose();
    super.dispose();
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
      await _fetchRouteAndDistance(_userLocation!, _stations[_selectedStationIndex].position);
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

  /// Fetch route from OSRM with full geometry for polyline drawing
  Future<void> _fetchRouteAndDistance(LatLng origin, LatLng destination) async {

    try {
      // Request full geometry from OSRM
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distanceMeters = (route['distance'] as num).toDouble();
          final durationSeconds = (route['duration'] as num).toDouble();
          
          // Parse GeoJSON coordinates into LatLng list
          final geometry = route['geometry'];
          final List<dynamic> coords = geometry['coordinates'];
          final points = coords.map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();

          if (mounted) {
            setState(() {
              _routePoints = points;
              _routeDistanceMeters = distanceMeters;
              _routeDurationSeconds = durationSeconds;
              
              if (distanceMeters < 1000) {
                _calculatedDistance = '${distanceMeters.toStringAsFixed(0)} m';
              } else {
                _calculatedDistance = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
              }
            });

            // Fit map to show entire route
            _fitMapToRoute(origin, destination);

            // Animate route panel in
            _routePanelController.forward();
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching route from OSRM: $e');
    }

    // Fallback to straight line distance if API fails
    final distance = const Distance().as(LengthUnit.Meter, origin, destination);
    final estimatedRoadDistance = distance * 1.3;
    if (mounted) {
      setState(() {
        _routePoints = [origin, destination];
        _routeDistanceMeters = estimatedRoadDistance;
        _routeDurationSeconds = null;

        if (estimatedRoadDistance < 1000) {
          _calculatedDistance = '${estimatedRoadDistance.toStringAsFixed(0)} m';
        } else {
          _calculatedDistance = '${(estimatedRoadDistance / 1000).toStringAsFixed(1)} km';
        }
      });
      _routePanelController.forward();
    }

  }

  void _fitMapToRoute(LatLng origin, LatLng destination) {
    final bounds = LatLngBounds.fromPoints([origin, destination]);
    
    // Add padding so markers are not at screen edge
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(60, 360, 60, 140),
      ),
    );
  }

  void _clearRoute() {
    _routePanelController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _routePoints = [];
          _routeDistanceMeters = null;
          _routeDurationSeconds = null;
        });
      }
    });
  }

  void _showStationCard(int index) {
    if (mounted) {
      setState(() {
        _selectedStationIndex = index;
        _showCard = true;
      });
    }
  }

  void _hideStationCard() {
    if (mounted) {
      setState(() {
        _showCard = false;
      });
    }
  }

  void _centerMapOnStation() {
    _showStationCard(0);
    _mapController.move(_stations[0].position, 15);
    if (_userLocation != null) {
      _fetchRouteAndDistance(_userLocation!, _stations[0].position);
    }
  }

  String _formatDuration(double totalSeconds) {
    final minutes = (totalSeconds / 60).round();
    if (minutes < 60) {
      return '$minutes menit';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours jam $remainingMinutes menit';
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

              // ── Route Polyline Layer ──
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    // Shadow polyline (adds depth)
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 8.0,
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    // Main gradient-style polyline
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      gradientColors: const [
                        AppColors.primary, // Gold yellow
                        AppColors.greenLight, // Green
                      ],
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
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
                        _showStationCard(index);
                        _mapController.move(station.position, 15);
                        if (_userLocation != null) {
                          _fetchRouteAndDistance(_userLocation!, station.position);
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



          // Location buttons overlay (User & Station) - Positioned at bottom right, above bottom nav
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            bottom: (_showCard ? 330 : 100) + MediaQuery.paddingOf(context).bottom,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clear Route button (visible only when route is active)
                if (_routePoints.isNotEmpty) ...[
                  GestureDetector(
                    onTap: _clearRoute,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // SunVolt Station Location button
                GestureDetector(
                  onTap: _centerMapOnStation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.ev_station,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // My Location button
                GestureDetector(
                  onTap: _isLoadingLocation ? null : _getUserLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
                            color: AppColors.yellowAccent,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Sheet (Station Details)
          if (selectedStation != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 80 + MediaQuery.paddingOf(context).bottom,
              child: SunVoltStationBottomSheet(
                name: selectedStation.name,
                address:
                    'Jl. Telekomunikasi No.1, Sukapura, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat',
                tags: selectedStation.tags,
                distanceString: _calculatedDistance,
                onSelect: () => Navigator.pushNamed(context, '/station-detail'),
                onClose: _hideStationCard,
              ),
            ),

          // ── Stacked Cards Info (Route Card) - Positioned at top middle, below header
          Positioned(
            top: 76 + MediaQuery.paddingOf(context).top,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_routeDistanceMeters != null) ...[
                  AnimatedBuilder(
                    animation: _routePanelAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -20 * (1 - _routePanelAnimation.value)),
                        child: Opacity(
                          opacity: _routePanelAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.7),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  // Glowing gradient navigation icon
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.primary, AppColors.greenLight],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.greenLight.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.navigation_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Metrics Column (Distance & Duration side-by-side)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'RUTE NAVIGASI',
                                          style: GoogleFonts.manrope(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            // Distance Value
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: _calculatedDistance?.replaceAll(' km', '') ?? '-',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.onSurface,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' km',
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Vertical divider line
                                            Container(
                                              height: 16,
                                              width: 1.5,
                                              color: AppColors.outlineVariant.withValues(alpha: 0.3),
                                            ),
                                            const SizedBox(width: 12),
                                            // Duration Chip
                                            if (_routeDurationSeconds != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.greenLight.withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.schedule_rounded,
                                                      size: 13,
                                                      color: AppColors.secondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatDuration(_routeDurationSeconds!),
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: const Color(0xFF16A34A),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Circular glassmorphic close button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _clearRoute,
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.onSurface.withValues(alpha: 0.04),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.onSurface.withValues(alpha: 0.06),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Very subtle top-bordered disclaimer section
                              Container(
                                height: 1,
                                color: AppColors.outlineVariant.withValues(alpha: 0.15),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 11,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Rute & durasi merupakan estimasi perkiraan perjalanan.',
                                      style: GoogleFonts.manrope(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
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
  final List<String> tags;

  _StationData({
    required this.id,
    required this.name,
    required this.position,
    required this.distance,
    required this.tags,
  });
}
