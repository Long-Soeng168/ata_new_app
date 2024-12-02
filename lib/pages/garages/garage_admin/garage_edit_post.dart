// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/garage_post.dart';
import 'package:ata_new_app/pages/garages/garage_admin/admin_garage_detail_page.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GarageEditPost extends StatefulWidget {
  const GarageEditPost(
      {super.key, required this.garage, required this.garagePost});
  final Garage garage;
  final GaragePost garagePost;

  @override
  _GarageEditPostState createState() => _GarageEditPostState();
}

class _GarageEditPostState extends State<GarageEditPost> {
  final _garageService = GarageService();
  final _postFormKey = GlobalKey<FormState>();

  // Controllers for post fields
  final _descriptionController = TextEditingController();

  String oldImageUrl = '';

  // Variable for the post image
  XFile? _postImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _postImage = pickedFile;
      });
    }
  }

  // Function to handle updating the post
  Future<void> _updatePost() async {
    if (_postFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Call the update post service
      final response = await _garageService.editPost(
        context: context,
        garage: widget.garage,
        postId: widget.garagePost.id.toString(),
        description: _descriptionController.text, // Pass updated description
        image: _postImage != null ? _postImage : null,
      );

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (response['success']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Post updated successfully")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please complete the description")));
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.garagePost.description;
    oldImageUrl = widget.garagePost.imageUrl;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void deletePostHandler() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return; // User canceled the action.

    final garageService =
        GarageService(); // Replace with the appropriate service for posts.
    final result = await garageService.deletePost(
      context: context,
      postId: widget.garagePost.id.toString(), // Assuming you have a post ID
      garage: widget.garage, // Pass the relevant garage object
    );

    if (result['success']) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminGarageDetailPage(
            garage: widget.garage, // Pass the relevant garage details
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Post"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: deletePostHandler,
            icon: Icon(
              Icons.delete,
              size: 32,
              color: Colors.red.shade300,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _postFormKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  color: _postImage == null
                      ? Colors.grey.shade200
                      : Colors.transparent,
                  child: _postImage != null
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(
                            File(_postImage!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : (oldImageUrl.isNotEmpty
                          ? AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                oldImageUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : AspectRatio(
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
                                ),
                              ),
                            )),
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
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter post description" : null,
              ),
              SizedBox(height: 12),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : MyElevatedButton(
                      onPressed: _updatePost,
                      title: 'Update Post',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
