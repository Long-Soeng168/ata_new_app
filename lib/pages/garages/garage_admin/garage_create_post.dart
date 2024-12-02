// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GarageCreatePost extends StatefulWidget {
  const GarageCreatePost({super.key, required this.garage});
  final Garage garage;

  @override
  _GarageCreatePostState createState() => _GarageCreatePostState();
}

class _GarageCreatePostState extends State<GarageCreatePost> {
  final _productService = GarageService();
  final _productFormKey = GlobalKey<FormState>();

  // Controllers for product fields
  final _descriptionController = TextEditingController();

  // Variable for product image
  XFile? _productImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Function to pick image for the product
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImage = pickedFile;
      });
    }
  }

  // Function to handle product creation
  Future<void> _createProduct() async {
    if (_productFormKey.currentState!.validate() && _productImage != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Call the product creation service
      final response = await _productService.createPost(
        context: context,
        garage: widget.garage,
        description: _descriptionController.text, // Pass description
        image: _productImage!,
      );

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product created successfully")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Please complete the description and upload an image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _productFormKey,
          child: ListView(
            children: [
              // Description input
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  color: _productImage == null
                      ? Colors.grey.shade200
                      : Colors.transparent,
                  child: _productImage == null
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.grey.shade400,
                                size: 50,
                              ),
                              Text('Tap to pick an image'),
                            ],
                          )))
                      : AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(
                            File(_productImage!.path),
                            fit: BoxFit
                                .cover, // You can change BoxFit based on your preference
                          ),
                        ),
                ),
              ),

              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: 'Post Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
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
              SizedBox(
                height: 12,
              ),
              // Loading indicator
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : MyElevatedButton(
                      onPressed: _createProduct,
                      title: 'Create Post',
                    ), 
            ],
          ),
        ),
      ),
    );
  }
}
