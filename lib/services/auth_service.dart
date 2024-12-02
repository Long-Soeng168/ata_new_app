import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String _baseUrl = Env.baseApiUrl; // Replace with your Laravel API URL
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${_baseUrl}login');
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
        '${_baseUrl}register'); // Replace with your registration endpoint
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
    final url = Uri.parse('${_baseUrl}user');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'user': data};
    } else {
      return {'success': false, 'message': 'Failed to fetch user info'};
    }
  }

  // Fetch user Shop
  Future<Map<String, dynamic>> getUserShop() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}user_shop');

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
        description: data['description'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        logoUrl: '${Env.baseImageUrl}shops/logo/thumb/${data['logo']}',
        bannerUrl: '${Env.baseImageUrl}shops/banner/thumb/${data['banner']}',
      );

      return {'success': true, 'shop': shop};
    } else {
      return {'success': false, 'message': 'Failed to fetch user shop'};
    }
  }

  Future<Map<String, dynamic>> getUserGarage() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}user_garage');

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
        description: data['description'] ?? '',
        phone: data['phone'] ?? '',
        expertName: data['expert']?['name'] ?? '',
        expertId: data['brand_id'] ?? -1,
        logoUrl: '${Env.baseImageUrl}garages/thumb/logo/${data['logo']}',
        bannerUrl: '${Env.baseImageUrl}garages/thumb/banner/${data['banner']}',
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
