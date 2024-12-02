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
      {int? expertId, int? page, String? search}) async {
    String url = '${Env.baseApiUrl}garages';

    List<String> queryParams = [];

    if (expertId != null) {
      queryParams.add('expertId=$expertId');
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
      return data.map((item) {
        return Garage(
          id: item['id'],
          name: item['name'] ?? '',
          phone: item['phone'] ?? '',
          address: item['address'] ?? '',
          description: item['description'] ?? '',
          expertName: item['expert']?['name'] ?? '',
          expertId: item['expert']?['id'] ?? -1,
          logoUrl: '${Env.baseImageUrl}garages/thumb/logo/${item['logo']}',
          bannerUrl:
              '${Env.baseImageUrl}garages/thumb/banner/${item['banner']}',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Garages');
    }
  }

  final String _baseUrl = Env.baseApiUrl;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> createGarage({
    required BuildContext context,
    required String name,
    required int brandId,
    required String description,
    required String address,
    required String phone,
    required XFile logoImage,
    required XFile bannerImage,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    try {
      var uri =
          Uri.parse('${_baseUrl}garages'); // API URL for creating a garage
      var request = http.MultipartRequest('POST', uri);

      // Add the fields
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['address'] = address;
      request.fields['phone'] = phone;
      request.fields['brand_id'] = brandId.toString();

      // Add the logo image
      request.files.add(await http.MultipartFile.fromPath(
        'logo',
        logoImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Add the banner image
      request.files.add(await http.MultipartFile.fromPath(
        'banner',
        bannerImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        final createdGarage = data['garage'];
        final newGarage = Garage(
          id: createdGarage['id'],
          name: createdGarage['name'] ?? '',
          description: createdGarage['description'] ?? '',
          address: createdGarage['address'] ?? '',
          phone: createdGarage['phone'] ?? '',
          expertId: createdGarage['expert']?['id'] ?? -1,
          expertName: createdGarage['expert']?['name'] ?? '',
          logoUrl:
              '${Env.baseImageUrl}garages/thumb/logo/${createdGarage['logo']}',
          bannerUrl:
              '${Env.baseImageUrl}garages/thumb/banner/${createdGarage['banner']}',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(
              garage: newGarage,
            ),
          ),
        );
        return {'success': true, 'message': responseData};
      } else {
        final responseData = await response.stream.bytesToString();
        return {
          'success': false,
          'message': 'Failed to create garage: $responseData'
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
    XFile? logoImage, // Optional
    XFile? bannerImage, // Optional
  }) async {
    final token = await _storage.read(key: 'auth_token'); // Retrieve auth token

    try {
      var uri = Uri.parse(
          '${_baseUrl}garages/$garageId'); // API URL for updating a garage
      var request = http.MultipartRequest(
          'POST', uri); // Change to PUT request for updating

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

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        final updatedGarage = data['garage'];
        final newGarage = Garage(
          id: updatedGarage['id'],
          name: updatedGarage['name'] ?? '',
          description: updatedGarage['description'] ?? '',
          address: updatedGarage['address'] ?? '',
          phone: updatedGarage['phone'] ?? '',
          expertId: brandId,
          expertName: updatedGarage['expert']?['name'] ?? '',
          logoUrl:
              '${Env.baseImageUrl}garages/thumb/logo/${updatedGarage['logo']}',
          bannerUrl:
              '${Env.baseImageUrl}garages/thumb/banner/${updatedGarage['banner']}',
        );
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(
              garage: newGarage,
            ),
          ),
        );
        return {'success': true, 'message': responseData};
      } else {
        final responseData = await response.stream.bytesToString();
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
    required String description, // Only description is required
    required XFile image, // Image input from the UI
  }) async {
    final token = await _storage.read(key: 'auth_token');

    try {
      var uri = Uri.parse('${_baseUrl}garages_posts');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      request.fields['description'] = description;

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        Navigator.pop(
            context); // Pop the current screen (e.g., loading or form screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminGarageDetailPage(
              garage: garage, // Pass any required parameters to the next page
            ),
          ),
        );

        // Return success response with the message from the API
        return {'success': true, 'message': jsonDecode(responseData)};
      } else {
        final responseData = await response.stream.bytesToString();
        // Return failure response with the error message from the API
        return {
          'success': false,
          'message': 'Failed to create Post: ${jsonDecode(responseData)}'
        };
      }
    } catch (e) {
      print(e);
      return {'success': false, 'message': 'Failed to create Post'};
    }
  }

  Future<Map<String, dynamic>> editPost({
    context,
    required String postId, // ID of the post to be updated
    required Garage garage, // Garage object
    required String description, // Only description is required
    XFile? image, // Image input from the UI (optional)
  }) async {
    final token = await _storage.read(key: 'auth_token'); // Retrieve auth token

    try {
      // API endpoint for updating a post
      var uri = Uri.parse('${_baseUrl}garages_posts/$postId');
      var request = http.MultipartRequest('POST', uri); // Change to PUT request

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['description'] = description;

      // Add image if provided
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ));
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
      var uri = Uri.parse('${_baseUrl}garages_posts/$postId/delete');
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
    String url = '${Env.baseApiUrl}garages_posts';

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
        return GaragePost(
          id: item['id'],
          name: item['name'] ?? '',
          imageUrl: '${Env.baseImageUrl}garageposts/thumb/${item['image']}',
          description: item['description'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Garages Posts');
    }
  }
}
