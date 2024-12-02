import 'dart:io';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/services/garage_service.dart';

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

  // Controllers for garage fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBrands();
    _nameController.text = widget.garage.name;
    _descriptionController.text = widget.garage.description;
    _addressController.text = widget.garage.address;
    _phoneController.text = widget.garage.phone;
    brandId = widget.garage.expertId;
  }

  Future<void> getBrands() async {
    try {
      // Fetch products outside of setState
      final fetchedBrands = await BrandService.fetchBrands();
      // Update the state
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBrands = false;
        isLoadingBrandsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Brands: $error');
    }
  }

  // Variables for logo and banner images
  XFile? _logoImage;
  XFile? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Function to pick image for logo or banner
  Future<void> _pickImage(bool isLogo) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoImage = pickedFile;
        } else {
          _bannerImage = pickedFile;
        }
      });
    }
  }

  // Function to handle garage creation
  Future<void> _updateGarage() async {
    if (_garageFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Call the garage creation service
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
      );

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Garage created successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields and upload images")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Garage"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _garageFormKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Garage name input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Garage Name",
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Garage Name',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Garage name is required" : null,
              ),
              const SizedBox(height: 12),

              // Phone number input
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Phone Number',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Phone number is required" : null,
              ),
              const SizedBox(height: 12),

              if (!isLoadingBrands)
                DropdownButtonFormField<int>(
                  value: brandId,
                  decoration: InputDecoration(
                    labelText: "Select Brand",
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Colors.grey.shade400, // Border color when enabled
                      ),
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
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                              child: Image.network(
                                brand.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10), // Space between image and text
                            Text(brand.name),
                          ],
                        ),
                      );
                    }),
                    const DropdownMenuItem<int>(
                      value: -1, // Unique value for "Other"
                      child: Row(
                        children: [
                          Icon(Icons.add), // Icon for "Other" option
                          SizedBox(width: 10),
                          Text("Other"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      brandId = value;
                    });
                  },
                  validator: (value) => value == null ? "Select a Brand" : null,
                ),
              const SizedBox(height: 12),

              // Address input
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  hintText: 'Garage Address',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                ),
                maxLines:
                    2, // Set maxLines to allow multiple lines, adjust as needed
                validator: (value) =>
                    value!.isEmpty ? "Enter Garage Address" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: 'Garage Description',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                ),
                maxLines:
                    4, // Set maxLines to allow multiple lines, adjust as needed
                validator: (value) =>
                    value!.isEmpty ? "Enter Shop description" : null,
              ),
              const SizedBox(height: 12),

              // Logo image picker with preview
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Column(
                  children: [
                    const Text("Logo Image", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    _logoImage == null
                        ? const Icon(Icons.image, size: 100, color: Colors.grey)
                        : Image.file(File(_logoImage!.path), height: 100),
                    TextButton(
                      onPressed: () => _pickImage(true),
                      child: Text(
                          _logoImage == null ? "Upload Logo" : "Change Logo"),
                    ),
                  ],
                ),
              ),

              // Banner image picker with preview
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Column(
                  children: [
                    const Text("Banner Image", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    _bannerImage == null
                        ? const Icon(Icons.image, size: 100, color: Colors.grey)
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

              const SizedBox(height: 20),

              // Submit button with loading indicator
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyElevatedButton(
                      onPressed: _updateGarage, title: "Create Garage"),
            ],
          ),
        ),
      ),
    );
  }
}
