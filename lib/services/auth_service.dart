import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  final String _baseUrl = Env.baseApiUrl; // Replace with your Laravel API URL
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('https://atech-auto.com/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];

      // Save token to secure storage
      await _storage.write(key: 'auth_token', value: token);

      return {
        'success': true,
        'user': data['user'],
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    }
  }

  // Register function
  Future<Map<String, dynamic>> register(
      String name, String phone, String email, String password) async {
    final url = Uri.parse(
        'https://atech-auto.com/api/register'); // Replace with your registration endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];

      // Save token to secure storage
      await _storage.write(key: 'auth_token', value: token);

      return {
        'success': true,
        'user': data['user'],
      };
    } else {
      final data = json.decode(response.body);
      String errorMessage = 'Registration failed. Please try again.';

      // Check if 'errors' exists and contains any field with errors
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        // Get the first key from the errors map
        String firstKey = data['errors'].keys.first;

        // Get the first error message from that key
        String firstError = data['errors'][firstKey][0];

        // print(firstError);
        errorMessage = firstError;
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Get saved token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Fetch user info
  Future<Map<String, dynamic>> getUserInfo() async {
    final token = await getToken();
    final url = Uri.parse('https://atech-auto.com/api/user');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // final user = User(
      //   id: data['id'],
      //   name: data['user']['name'] ?? '',
      //   email: data['user']['email'] ?? '',
      //   phone: data['user']['phone'] ?? '',
      //   image:
      //       'https://atech-auto.com/assets/images/users/thumb/${data['user']['image']}',
      // );
      // print(user);

      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'message': 'Failed to fetch user info'};
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required BuildContext context,
    required int userId,
    required String name,
    required String email,
    required String phone,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    XFile? imageFile,
  }) async {
    final token = await getToken();

    try {
      var uri = Uri.parse('https://atech-auto.com/api/update_users/$userId');
      var request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add required fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      // Password fields if provided
      if (currentPassword != null && currentPassword.isNotEmpty) {
        request.fields['current_password'] = currentPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        request.fields['password'] = newPassword;
        request.fields['password_confirmation'] = confirmPassword ?? '';
      }

      // Image upload if provided
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        return {'success': true, 'data': data};
      } else {
        final responseData = await response.stream.bytesToString();
        return {
          'success': false,
          'message': 'Failed to update user: $responseData'
        };
      }
    } catch (e) {
      print(e);
      return {
        'success': false,
        'message': 'Error occurred while updating user'
      };
    }
  }

  Future<Map<String, dynamic>> deleteAccount({
    required int userId,
    required String password,
  }) async {
    final token = await getToken();

    try {
      var uri = Uri.parse('https://atech-auto.com/api/delete_users/$userId');

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      request.fields['password'] = password;

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return {'success': true, 'message': data['message']};
      } else {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete account',
        };
      }
    } catch (e) {
      print(e);
      return {
        'success': false,
        'message': 'An error occurred while deleting the account',
      };
    }
  }

  // Fetch user Shop
  Future<Map<String, dynamic>> getUserShop() async {
    final token = await getToken();
    final url = Uri.parse('https://atech-auto.com/api/user_shop');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final shop = Shop(
        id: data['id'],
        name: data['name'] ?? '',
        description: data['short_description'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        logoUrl:
            'https://atech-auto.com/assets/images/shops/thumb/${data['logo']}',
        bannerUrl:
            'https://atech-auto.com/assets/images/shops/thumb/${data['banner']}',
      );

      return {'success': true, 'shop': shop};
    } else {
      return {'success': false, 'message': 'Failed to fetch user shop'};
    }
  }

  Future<Map<String, dynamic>> getUserGarage() async {
    final token = await getToken();
    final url = Uri.parse('https://atech-auto.com/api/user_garage');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['brand_id']);
      final garage = Garage(
        id: data['id'],
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        latitude: data['latitude'] ?? 0,
        longitude: data['longitude'] ?? 0,
        description: data['short_description'] ?? '',
        phone: data['phone'] ?? '',
        expertName: data['expert']?['name'] ?? '',
        expertId: data['expert']?['id'] ?? -1,
        logoUrl:
            'https://atech-auto.com/assets/images/garages/thumb/${data['logo']}',
        bannerUrl:
            'https://atech-auto.com/assets/images/garages/thumb/${data['banner']}',
      );

      return {'success': true, 'garage': garage};
    } else {
      return {'success': false, 'message': 'Failed to fetch user Garage'};
    }
  }

  // Logout function
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
