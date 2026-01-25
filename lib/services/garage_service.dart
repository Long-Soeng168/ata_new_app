import 'dart:convert';

import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/garage_post.dart';
import 'package:ata_new_app/pages/garages/garage_admin/admin_garage_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class GarageService {
  static Future<List<Garage>> fetchGarages(
      {int? expertId, int? provinceId, int? page, String? search}) async {
    String url = 'https://atech-auto.com/api/garages';

    List<String> queryParams = [];

    if (expertId != null) {
      queryParams.add('expertId=$expertId');
    }
    if (provinceId != null) {
      queryParams.add('provinceId=$provinceId');
    }
    if (page != null) {
      queryParams.add('page=$page');
    }
    if (search != null) {
      queryParams.add('search=$search');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print(url);

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      print(data);
      return data.map((item) {
        return Garage(
          id: item['id'],
          name: item['name'] ?? '',
          latitude: item['latitude'] ?? 0,
          longitude: item['longitude'] ?? 0,
          phone: item['phone'] ?? '',
          address: item['address'] ?? '',
          status: item['status'] ?? '',
          description: item['description'] ?? '',
          expertName: item['expert']?['name'] ?? '',
          expertId: item['expert']?['id'] ?? -1,
          logoUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${item['logo']}',
          bannerUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${item['banner']}',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Garages');
    }
  }

  static Future<List<Garage>> fetchAllGarages(
      {int? expertId, int? provinceId, int? page, String? search}) async {
    String url = 'https://atech-auto.com/api/all-garages';

    List<String> queryParams = [];

    if (expertId != null) {
      queryParams.add('expertId=$expertId');
    }
    if (provinceId != null) {
      queryParams.add('provinceId=$provinceId');
    }
    if (page != null) {
      queryParams.add('page=$page');
    }
    if (search != null) {
      queryParams.add('search=$search');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print(url);

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      print(data);
      return data.map((item) {
        return Garage(
          id: item['id'],
          name: item['name'] ?? '',
          latitude: item['latitude'] ?? 0,
          longitude: item['longitude'] ?? 0,
          phone: item['phone'] ?? '',
          address: item['address'] ?? '',
          status: item['status'] ?? '',
          description: item['description'] ?? '',
          expertName: item['expert']?['name'] ?? '',
          expertId: item['expert']?['id'] ?? -1,
          logoUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${item['logo']}',
          bannerUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${item['banner']}',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Garages');
    }
  }

  final String _baseUrl = Env.baseApiUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createGarage({
    required BuildContext context,
    required String name,
    required int brandId,
    required String description,
    required String address,
    required String phone,
    required XFile logoImage,
    required XFile bannerImage,
    double? latitude,
    double? longitude, // new parameters
  }) async {
    final token = await _storage.read(key: 'auth_token');

    try {
      var uri = Uri.parse('https://atech-auto.com/api/garages');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['address'] = address;
      request.fields['phone'] = phone;
      request.fields['brand_id'] = brandId.toString();

      // Add latitude & longitude if available
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add images
      request.files.add(await http.MultipartFile.fromPath(
        'logo',
        logoImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'banner',
        bannerImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send request
      var response = await request.send();

      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        final createdGarage = data['garage'];
        final newGarage = Garage(
          id: createdGarage['id'],
          name: createdGarage['name'] ?? '',
          status: createdGarage['status'] ?? '',
          description: createdGarage['short_description'] ?? '',
          address: createdGarage['address'] ?? '',
          phone: createdGarage['phone'] ?? '',
          expertId: createdGarage['expert']?['id'] ?? -1,
          expertName: createdGarage['expert']?['name'] ?? '',
          logoUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${createdGarage['logo']}',
          bannerUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${createdGarage['banner']}',
          latitude: createdGarage['latitude'] != null
              ? double.tryParse(createdGarage['latitude'].toString())
              : null,
          longitude: createdGarage['longitude'] != null
              ? double.tryParse(createdGarage['longitude'].toString())
              : null,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(garage: newGarage),
          ),
        );

        return {'success': true, 'message': responseData};
      } else {
        return {
          'success': false,
          'message': 'Failed to create garage: $responseData',
        };
      }
    } catch (e) {
      print(e);
      return {'success': false, 'message': 'Failed to create garage'};
    }
  }

  Future<Map<String, dynamic>> updateGarage({
    required BuildContext context,
    required String garageId, // ID of the garage to be updated
    required String name,
    required String description,
    required String address,
    required String phone,
    required int brandId,
    double? latitude, // new
    double? longitude, // new
    XFile? logoImage, // Optional
    XFile? bannerImage, // Optional
  }) async {
    final token = await _storage.read(key: 'auth_token'); // Retrieve auth token

    try {
      var uri = Uri.parse('https://atech-auto.com/api/garages/$garageId');
      var request = http.MultipartRequest('POST', uri); // Or 'PUT'

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['address'] = address;
      request.fields['phone'] = phone;
      request.fields['brand_id'] = brandId.toString();

      // Add latitude & longitude if provided
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add logo image if provided
      if (logoImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'logo',
          logoImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Add banner image if provided
      if (bannerImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'banner',
          bannerImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Send the request
      var response = await request.send();

      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        final updatedGarage = data['garage'];
        final newGarage = Garage(
          id: updatedGarage['id'],
          name: updatedGarage['name'] ?? '',
          status: updatedGarage['status'] ?? '',
          description: updatedGarage['short_description'] ?? '',
          address: updatedGarage['address'] ?? '',
          phone: updatedGarage['phone'] ?? '',
          expertId: brandId,
          expertName: updatedGarage['expert']?['name'] ?? '',
          logoUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${updatedGarage['logo']}',
          bannerUrl:
              'https://atech-auto.com/assets/images/garages/thumb/${updatedGarage['banner']}',
          latitude: updatedGarage['latitude'] != null
              ? double.tryParse(updatedGarage['latitude'].toString())
              : null,
          longitude: updatedGarage['longitude'] != null
              ? double.tryParse(updatedGarage['longitude'].toString())
              : null,
        );

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(garage: newGarage),
          ),
        );

        return {'success': true, 'message': responseData};
      } else {
        return {
          'success': false,
          'message': 'Failed to update garage: $responseData'
        };
      }
    } catch (e) {
      print(e);
      return {'success': false, 'message': 'Failed to update garage'};
    }
  }

  Future<Map<String, dynamic>> createPost({
    required BuildContext context,
    garage,
    required String description,
    required List<XFile> images,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    try {
      var uri = Uri.parse('https://atech-auto.com/api/garages_posts');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.fields['description'] = description;

      // Main image
      if (images.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          images.first.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Extra images
      if (images.length > 1) {
        for (int i = 1; i < images.length; i++) {
          request.files.add(await http.MultipartFile.fromPath(
            'images[]',
            images[i].path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      dynamic parsed;
      try {
        parsed = jsonDecode(responseData);
      } catch (_) {
        parsed = responseData; // fallback to raw HTML/text
      }

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(garage: garage),
          ),
        );

        return {'success': true, 'message': parsed};
      } else {
        return {
          'success': false,
          'message': 'Failed to create Post',
          'error': parsed, // 👈 you’ll see raw HTML here if it’s not JSON
        };
      }
    } catch (e) {
      print("Exception: $e");
      return {'success': false, 'message': 'Failed to create Post'};
    }
  }

  Future<Map<String, dynamic>> editPost(
      {context,
      required String postId, // ID of the post to be updated
      required Garage garage, // Garage object
      required String description, // Only description is required
      List<XFile>? images // Image input from the UI (optional)
      }) async {
    final token = await _storage.read(key: 'auth_token'); // Retrieve auth token

    try {
      // API endpoint for updating a post
      var uri = Uri.parse('https://atech-auto.com/api/garages_posts/$postId');
      var request = http.MultipartRequest('POST', uri); // Change to PUT request

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['description'] = description;

      // Add images if provided
      if (images != null && images.isNotEmpty) {
        // Attach first image as "image" (main image)
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          images.first.path,
          contentType: MediaType('image', 'jpeg'),
        ));

        // Attach the rest as "images[]" (additional images)
        if (images.length > 1) {
          for (int i = 1; i < images.length; i++) {
            request.files.add(await http.MultipartFile.fromPath(
              'images[]',
              images[i].path,
              contentType: MediaType('image', 'jpeg'),
            ));
          }
        }
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(
              garage: garage, // Pass the updated garage details
            ),
          ),
        );

        // Return success response with the API's response message
        return {'success': true, 'message': jsonDecode(responseData)};
      } else {
        final responseData = await response.stream.bytesToString();

        // Return failure response with the error message from the API
        return {
          'success': false,
          'message': 'Failed to update post: ${jsonDecode(responseData)}'
        };
      }
    } catch (e) {
      print(e);
      return {'success': false, 'message': 'Failed to update post'};
    }
  }

  Future<Map<String, dynamic>> deletePost({
    required BuildContext context,
    required String postId, // ID of the post to delete
    required Garage garage, // Garage object for navigation
  }) async {
    final token = await _storage.read(key: 'auth_token'); // Retrieve auth token

    try {
      // API endpoint for deleting a post
      var uri =
          Uri.parse('https://atech-auto.com/api/garages_posts/$postId/delete');
      print(uri);
      var request = http.Request('get', uri); // Use DELETE request

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();

        // Return success response with the API's response message
        return {'success': true, 'message': jsonDecode(responseData)};
      } else {
        final responseData = await response.stream.bytesToString();

        // Return failure response with the error message from the API
        return {
          'success': false,
          'message': 'Failed to delete post: ${jsonDecode(responseData)}'
        };
      }
    } catch (e) {
      print(e);
      return {'success': false, 'message': 'Failed to delete post'};
    }
  }

  static Future<List<GaragePost>> fetchGaragesPosts(
      {int? garageId, int? page}) async {
    String url = 'https://atech-auto.com/api/garages_posts';

    List<String> queryParams = [];

    if (garageId != null) {
      queryParams.add('garageId=$garageId');
    }
    if (page != null) {
      queryParams.add('page=$page');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];

      return data.map((item) {
        // Get all image URLs
        List<String> imageUrls = [];
        if (item['images'] != null && item['images'].isNotEmpty) {
          imageUrls = (item['images'] as List<dynamic>)
              .map<String>((img) =>
                  'https://atech-auto.com/assets/images/garage_posts/${img['image']}')
              .toList();
        }

        return GaragePost(
          id: item['id'],
          name: item['short_description'] ?? '',
          description: item['long_description'] ?? '',
          imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '', // first image
          images: imageUrls, // all images
        );
      }).toList();
    } else {
      throw Exception('Failed to load Garages Posts');
    }
  }

  Future<Map<String, dynamic>> deleteImage(String imageName) async {
    final token = await _storage.read(key: 'auth_token');
    final encodedName = Uri.encodeComponent(imageName);
    final url = Uri.parse(
        'https://atech-auto.com/api/garages_posts/$encodedName/delete_image');

    try {
      final request = http.Request('GET', url); // API expects GET
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Deleted successfully',
        };
      } else {
        final data = jsonDecode(responseData);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete image',
        };
      }
    } catch (e) {
      print("Delete Image Error: $e");
      return {'success': false, 'message': 'Failed to delete image'};
    }
  }
}
