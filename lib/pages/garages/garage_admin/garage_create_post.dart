// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GarageCreatePost extends StatefulWidget {
  const GarageCreatePost({super.key, required this.garage});
  final Garage garage;

  @override
  _GarageCreatePostState createState() => _GarageCreatePostState();
}

class _GarageCreatePostState extends State<GarageCreatePost> {
  final _garageService = GarageService();
  final _garagePostFormKey = GlobalKey<FormState>();

  // Controllers
  final _descriptionController = TextEditingController();

  // For multiple images
  List<XFile> _postImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Pick multiple images
  // Pick multiple new images (each must be under 2 MB)
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    final List<XFile> validImages = [];
    for (var file in pickedFiles) {
      final fileSize = await file.length(); // in bytes
      if (fileSize <= 2 * 1024 * 1024) {
        validImages.add(file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${file.name} is too large. Maximum allowed size is 2 MB.")),
        );
      }
    }

    if (validImages.isNotEmpty) {
      setState(() => _postImages = validImages);
    }
  }

  // Create post
  Future<void> _createPost() async {
    if (_garagePostFormKey.currentState!.validate() && _postImages.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final response = await _garageService.createPost(
        context: context,
        garage: widget.garage,
        description: _descriptionController.text,
        images: _postImages, // pass list instead of single
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post created successfully".tr())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please complete description and upload images".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post".tr()),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _garagePostFormKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImages,
                child: _postImages.isEmpty
                    ? Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: AspectRatio(
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
                                Text('Tap to pick images'.tr()),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _postImages.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(
                                File(_postImages[index].path),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description".tr(),
                  hintText: 'Post Description'.tr(),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter post description".tr() : null,
              ),
              SizedBox(height: 12),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : MyElevatedButton(
                      onPressed: _createPost,
                      title: 'Create Post'.tr(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
