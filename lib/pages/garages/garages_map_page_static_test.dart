import 'dart:math';
import 'package:ata_new_app/models/garage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class GaragesMapPage extends StatefulWidget {
  const GaragesMapPage({super.key});

  @override
  State<GaragesMapPage> createState() => _GaragesMapPageState();
}

class _GaragesMapPageState extends State<GaragesMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  LatLng _currentCenter = const LatLng(11.5564, 104.9282);
  double _currentZoom = 14;

  bool _isLoading = true; // show loading

  final List<Garage> garages = List.generate(100, (index) {
    final random = Random();
    final cityLatitudes = [
      11.56,
      13.36,
      13.10,
      10.61,
      10.64,
      10.99,
      13.36,
      11.56
    ];
    final cityLongitudes = [
      104.92,
      103.85,
      103.20,
      104.18,
      103.51,
      104.78,
      103.85,
      104.92
    ];
    final cities = [
      'Phnom Penh',
      'Siem Reap',
      'Battambang',
      'Kampot',
      'Sihanoukville',
      'Takeo',
      'Siem Reap Riverside',
      'Wat Phnom'
    ];
    final cityIndex = index % cities.length;

    return Garage(
      bannerUrl:
          'https://atech-auto.com/assets/images/shops/1746864386_Screenshot%202025-05-10%20at%203.06.22%20in%20the%20afternoon.webp',
      description: '',
      expertId: index,
      expertName: '',
      logoUrl: 'https://atech-auto.com/assets/images/shops/1746864535_ai.webp',
      phone: '',
      id: index + 1,
      name: 'Garage ${index + 1}',
      address: 'Street ${(100 + index)} ${cities[cityIndex]}',
      latitude: cityLatitudes[cityIndex] + (random.nextDouble() - 0.5) * 0.1,
      longitude: cityLongitudes[cityIndex] + (random.nextDouble() - 0.5) * 0.1,
    );
  });

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestLocationPermission();
    _setMarkers(garages);
    // await _getCurrentLocation();
    setState(() => _isLoading = false); // done loading
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
        CameraPosition(target: currentLatLng, zoom: 14)));
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) await Permission.location.request();
  }

  void _setMarkers(List<Garage> list) {
    final newMarkers = <Marker>{};
    for (var garage in list) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(garage.name),
          position: LatLng(garage.latitude ?? 0.0, garage.longitude ?? 0.0),
          // infoWindow: InfoWindow(title: garage.name, snippet: garage.address),
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
      isScrollControlled: true, // Allows the sheet to be full-height
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  garage.bannerUrl,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // Logo and Name
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
              // Garage Details
              Text(
                'Address: ${garage.address}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Phone: ${garage.phone}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Add more details here...
              const SizedBox(height: 16),
              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  // Handle button tap, e.g., navigate to the garage's full profile page
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('View Full Profile'),
              ),
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentCenter, zoom: _currentZoom),
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: _currentMapType,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: (position) {
              _currentCenter = position.target;
              _currentZoom = position.zoom;
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 100,
            right: 8,
            child: FloatingActionButton.small(
              heroTag: 'btn-my-location',
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
