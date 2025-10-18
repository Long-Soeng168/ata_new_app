// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/garage_post.dart';
import 'package:ata_new_app/pages/garages/garage_admin/admin_garage_detail_page.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GarageEditPost extends StatefulWidget {
  const GarageEditPost({
    super.key,
    required this.garage,
    required this.garagePost,
  });

  final Garage garage;
  final GaragePost garagePost;

  @override
  _GarageEditPostState createState() => _GarageEditPostState();
}

class _GarageEditPostState extends State<GarageEditPost> {
  final _garageService = GarageService();
  final _postFormKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<String> _oldImages = [];
  List<XFile> _newImages = [];
  int? _deletingImageIndex; // track deleting image
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.garagePost.name;
    if (widget.garagePost.images.isNotEmpty) {
      _oldImages = widget.garagePost.images;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Pick multiple new images
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
      setState(() => _newImages = validImages);
    }
  }

  // Update post
  Future<void> _updatePost() async {
    if (!_postFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please complete the description".tr())));
      return;
    }

    setState(() => _isLoading = true);

    final response = await _garageService.editPost(
      context: context,
      garage: widget.garage,
      postId: widget.garagePost.id.toString(),
      description: _descriptionController.text,
      images: _newImages,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['success']
            ? "Post updated successfully".tr()
            : response['message']),
      ),
    );
  }

  // Delete entire post
  void _deletePostHandler() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'.tr()),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'.tr())),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _garageService.deletePost(
      context: context,
      postId: widget.garagePost.id.toString(),
      garage: widget.garage,
    );

    if (result['success']) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(garage: widget.garage)),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post deleted successfully'.tr())));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  // Delete single old image
  void _confirmDeleteOldImage(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Image'.tr()),
        content: Text('Are you sure you want to delete this image?'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'.tr())),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deletingImageIndex = index);

    final imageName = _oldImages[index].split('/').last;
    final result = await GarageService().deleteImage(imageName);

    setState(() => _deletingImageIndex = null);

    if (result['success']) {
      setState(() => _oldImages.removeAt(index));
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));
  }

  Widget _buildImageCard(
      {required Widget child,
      VoidCallback? onDelete,
      bool isDeleting = false}) {
    return Stack(
      children: [
        AspectRatio(aspectRatio: 1, child: child),
        if (isDeleting)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
          )
        else if (onDelete != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Post".tr()),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _deletePostHandler,
            icon: Icon(Icons.delete, size: 32, color: Colors.red.shade300),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _postFormKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Old Images
              if (_oldImages.isNotEmpty) ...[
                Text("Existing Images".tr()),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _oldImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) => _buildImageCard(
                      child:
                          Image.network(_oldImages[index], fit: BoxFit.cover),
                      onDelete: () => _confirmDeleteOldImage(index),
                      isDeleting: _deletingImageIndex == index,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // New Images
              GestureDetector(
                onTap: _pickImages,
                child: _newImages.isEmpty
                    ? Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    color: Colors.grey.shade400, size: 50),
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
                          itemCount: _newImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) => _buildImageCard(
                            child: Image.file(File(_newImages[index].path),
                                fit: BoxFit.cover),
                            onDelete: () =>
                                setState(() => _newImages.removeAt(index)),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter post description".tr() : null,
                decoration: InputDecoration(
                  labelText: "Description".tr(),
                  hintText: 'Post Description'.tr(),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyElevatedButton(
                      onPressed: _updatePost, title: 'Update Post'.tr()),
            ],
          ),
        ),
      ),
    );
  }
}
