import 'dart:io';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ata_new_app/services/shop_service.dart';

class ShopEditPage extends StatefulWidget {
  const ShopEditPage({super.key, required this.shop});
  final Shop shop;

  @override
  _ShopEditPageState createState() => _ShopEditPageState();
}

class _ShopEditPageState extends State<ShopEditPage> {
  final _shopService = ShopService();
  final _shopFormKey = GlobalKey<FormState>();

  // Controllers for shop fields
  final _shopNameController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _shopNameController.text = widget.shop.name;
    _shopDescriptionController.text = widget.shop.description;
    _addressController.text = widget.shop.address;
    _phoneController.text = widget.shop.phone;
  }

  // Variables for logo and banner images
  XFile? _logoImage;
  XFile? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Function to pick image for logo or banner
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

  // Function to handle shop creation
  Future<void> _updateShop() async {
    print('Edit Shop');
    if (_shopFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Call the shop creation service
      final response = await _shopService.updateShop(
        context: context,
        shop: widget.shop,
        name: _shopNameController.text,
        description: _shopDescriptionController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        logoImage: _logoImage,
        bannerImage: _bannerImage,
      );

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Shop Update successfully")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all fields")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Shop"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _shopFormKey,
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              // Shop name input
              TextFormField(
                controller: _shopNameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                  hintText: 'Shop Name',
                ),
                validator: (value) => value!.isEmpty ? "Enter Shop name" : null,
              ),
              const SizedBox(height: 12),

              // Phone number input
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Border color when enabled
                    ),
                  ),
                  hintText: 'Shop Phone',
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter Shop Phone" : null,
              ),
              const SizedBox(height: 12),

              // Address input
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  hintText: 'Shop Address',
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
                    value!.isEmpty ? "Enter Shop Address" : null,
              ),
              const SizedBox(height: 12),

              // Shop description input
              TextFormField(
                controller: _shopDescriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: 'Shop Description',
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

              const SizedBox(height: 16),

              // Logo image picker with preview
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Logo Image",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _logoImage != null
                        ? Image.file(File(_logoImage!.path), height: 100)
                        : (widget.shop.logoUrl.isNotEmpty
                            ? Image.network(widget.shop.logoUrl, height: 100)
                            : Icon(Icons.image,
                                size: 100, color: Colors.grey.shade400)),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Banner Image",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _bannerImage != null
                        ? Image.file(File(_bannerImage!.path), height: 100)
                        : (widget.shop.bannerUrl.isNotEmpty
                            ? Image.network(widget.shop.bannerUrl, height: 100)
                            : Icon(Icons.image,
                                size: 100, color: Colors.grey.shade400)),
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
                      onPressed: _updateShop, title: "Update Shop"),
            ],
          ),
        ),
      ),
    );
  }
}
