import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/pages/garages/garage_detail_page.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GaragesMapPage extends StatefulWidget {
  const GaragesMapPage({super.key});

  @override
  State<GaragesMapPage> createState() => _GaragesMapPageState();
}

class _GaragesMapPageState extends State<GaragesMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  LatLng _currentCenter = const LatLng(11.5564, 104.9282); // Default Phnom Penh
  double _currentZoom = 11;

  bool _isLoading = true;
  List<Garage> garages = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestLocationPermission();
    await _fetchGarages();
    await _getCurrentLocation(); // optional auto-focus on user
    setState(() => _isLoading = false);
  }

  Future<void> _fetchGarages() async {
    try {
      final fetchedGarages = await GarageService.fetchAllGarages(page: 1);
      garages = fetchedGarages;
      _setMarkers(garages);
    } catch (e) {
      debugPrint("Failed to fetch garages: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load garages")),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentCenter = currentLatLng;
      _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });

    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLatLng, zoom: 14),
    ));
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) await Permission.location.request();
  }

  void _setMarkers(List<Garage> list) async {
    final newMarkers = <Marker>{};
    final BitmapDescriptor customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'lib/assets/icons/garage-pin2.png', // your asset
    );

    for (var garage in list) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(garage.id.toString()),
          position: LatLng(garage.latitude ?? 0.0, garage.longitude ?? 0.0),
          icon: customIcon,
          onTap: () => _showGarageDetailsSheet(garage),
        ),
      );
    }

    setState(() {
      _markers
        ..clear()
        ..addAll(newMarkers);
    });
  }

  void _onMapTypeChanged(MapType? selectedType) {
    if (selectedType != null) setState(() => _currentMapType = selectedType);
  }

  void _showGarageDetailsSheet(Garage garage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  garage.bannerUrl,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      garage.logoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      garage.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Address: ${garage.address}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Phone: ${garage.phone}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final url =
                          'https://www.google.com/maps?q=${garage.latitude},${garage.longitude}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text(
                      'Open in Google Maps',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final route = MaterialPageRoute(
                        builder: (context) => GarageDetailPage(garage: garage),
                      );
                      Navigator.push(context, route);
                    },
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    label: const Text(
                      'View Garage',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Garages Map',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Map',
            onPressed: () async {
              setState(() => _isLoading = true);
              await _fetchGarages(); // refetch garages
              setState(() => _isLoading = false);

              if (_mapController != null && garages.isNotEmpty) {
                final lat =
                    garages.first.latitude ?? 11.5564; // fallback to Phnom Penh
                final lng = garages.first.longitude ?? 104.9282;
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(lat, lng),
                    _currentZoom,
                  ),
                );
              }
            },
          ),
          PopupMenuButton<MapType>(
            icon: const Icon(Icons.layers),
            onSelected: _onMapTypeChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(value: MapType.normal, child: Text('Normal')),
              PopupMenuItem(value: MapType.satellite, child: Text('Satellite')),
              PopupMenuItem(value: MapType.terrain, child: Text('Terrain')),
              PopupMenuItem(value: MapType.hybrid, child: Text('Hybrid')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _currentCenter, zoom: _currentZoom),
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: _currentMapType,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                if (garages.isNotEmpty) _setMarkers(garages);
              },
              onCameraMove: (position) {
                _currentCenter = position.target;
                _currentZoom = position.zoom;
              },
            ),
    );
  }
}
