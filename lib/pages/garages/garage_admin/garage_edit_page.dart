import 'dart:io';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarageEditPage extends StatefulWidget {
  const GarageEditPage({super.key, required this.garage});
  final Garage garage;

  @override
  _GarageEditPageState createState() => _GarageEditPageState();
}

class _GarageEditPageState extends State<GarageEditPage> {
  final _garageService = GarageService();
  final _garageFormKey = GlobalKey<FormState>();

  List<Brand> brands = [];
  bool isLoadingBrands = true;
  bool isLoadingBrandsError = false;
  int? brandId;

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Logo & banner
  XFile? _logoImage;
  XFile? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  // Map location
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  final CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(11.5564, 104.9282), zoom: 12);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedLocation = LatLng(
          widget.garage.latitude ?? 11.5564,
          widget.garage.longitude ?? 104.9282,
        );
      });
    });

    getBrands();
    _nameController.text = widget.garage.name;
    _descriptionController.text = widget.garage.description;
    _addressController.text = widget.garage.address;
    _phoneController.text = widget.garage.phone;
    brandId = widget.garage.expertId;
  }

  Future<void> getBrands() async {
    try {
      final fetchedBrands = await BrandService.fetchBrands();
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } catch (error) {
      setState(() {
        isLoadingBrands = false;
        isLoadingBrandsError = true;
      });
      print('Failed to load Brands: $error');
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final fileSize = await pickedFile.length(); // in bytes
    if (fileSize > 2 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${pickedFile.name} is too large. Maximum allowed size is 2 MB.",
          ),
        ),
      );
      return;
    }

    setState(() {
      if (isLogo) {
        _logoImage = pickedFile;
      } else {
        _bannerImage = pickedFile;
      }
    });
  }

  Future<void> _updateGarage() async {
    if (_garageFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final response = await _garageService.updateGarage(
        garageId: widget.garage.id.toString(),
        context: context,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        brandId: brandId ?? -1,
        description: _descriptionController.text,
        logoImage: _logoImage,
        bannerImage: _bannerImage,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
      );

      setState(() => _isLoading = false);

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Garage updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please complete all fields and upload images")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Garage"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _garageFormKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Garage name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Garage Name",
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Garage Name',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Garage name is required" : null,
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Phone Number',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Phone number is required" : null,
              ),
              const SizedBox(height: 12),

              // Brand dropdown
              if (!isLoadingBrands)
                DropdownButtonFormField<int>(
                  value: brandId,
                  decoration: InputDecoration(
                    labelText: "Select Brand",
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    ...brands.map((brand) {
                      return DropdownMenuItem<int>(
                        value: brand.id,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Image.network(
                                brand.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(brand.name),
                          ],
                        ),
                      );
                    }),
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text("Other"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => brandId = value),
                  validator: (value) => value == null ? "Select a Brand" : null,
                ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  hintText: 'Garage Address',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                maxLines: 2,
                validator: (value) =>
                    value!.isEmpty ? "Enter Garage Address" : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: 'Garage Description',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter Shop description" : null,
              ),
              const SizedBox(height: 12),

              // Logo
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Column(
                  children: [
                    const Text("Logo Image", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    _logoImage == null
                        ? (_logoImage == null && widget.garage.logoUrl != null
                            ? Image.network(widget.garage.logoUrl!, height: 100)
                            : const Icon(Icons.image,
                                size: 100, color: Colors.grey))
                        : Image.file(File(_logoImage!.path), height: 100),
                    TextButton(
                      onPressed: () => _pickImage(true),
                      child: Text(
                          _logoImage == null ? "Upload Logo" : "Change Logo"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Banner
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Column(
                  children: [
                    const Text("Banner Image", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    _bannerImage == null
                        ? (widget.garage.bannerUrl != null
                            ? Image.network(widget.garage.bannerUrl!,
                                height: 100)
                            : const Icon(Icons.image,
                                size: 100, color: Colors.grey))
                        : Image.file(File(_bannerImage!.path), height: 100),
                    TextButton(
                      onPressed: () => _pickImage(false),
                      child: Text(_bannerImage == null
                          ? "Upload Banner"
                          : "Change Banner"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Map picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Garage Location",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _selectedLocation != null
                      ? SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation!,
                              zoom: 12,
                            ),
                            onMapCreated: (controller) =>
                                _mapController = controller,
                            markers: {
                              Marker(
                                markerId: const MarkerId('garage_marker'),
                                position: _selectedLocation!,
                                draggable: true,
                                onDragEnd: (latLng) {
                                  setState(() => _selectedLocation = latLng);
                                },
                              ),
                            },
                            onTap: (latLng) =>
                                setState(() => _selectedLocation = latLng),
                            zoomControlsEnabled: true,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                          ),
                        )
                      : const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                    'Lng: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyElevatedButton(
                      onPressed: _updateGarage, title: "Update Garage"),
            ],
          ),
        ),
      ),
    );
  }
}
