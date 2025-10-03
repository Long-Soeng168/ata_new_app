import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/video.dart';
import 'package:ata_new_app/models/video_playlist.dart';
import 'package:ata_new_app/pages/trainings/videos/cart/video_order_success_page.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class VideoService {
  static Future<List<Video>> fetchVideos({int? playlistId}) async {
    final FlutterSecureStorage _storage = const FlutterSecureStorage();
    final token = await _storage.read(key: 'auth_token');

    String url = 'https://atech-auto.com/api/videos';
    if (playlistId != null) {
      url += '?playlistId=$playlistId';
    }

    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token', // add token
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      return data.map((item) {
        return Video(
          id: item['id'],
          name: item['title'],
          status: item['status'],
          viewsCount: item['views_count']?.toString() ?? '0',
          isFree: item['is_free'] == 0 ? false : true,
          imageUrl:
              'https://atech-auto.com/assets/images/videos/thumb/${item['image']}',
          videoUrl:
              'https://atech-auto.com/assets/files/videos/${item['video_name']}',
        );
      }).toList();
    } else {
      throw Exception('Failed to load video');
    }
  }

  static Future<Video> fetchVideoById({required int id}) async {
    String url = 'https://atech-auto.com/api/videos/$id';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    final Map<String, dynamic> data = jsonDecode(response.body);

    return Video(
      id: data['id'],
      name: data['title'],
      status: data['status'],
      description: data['description'] ?? '',
      viewsCount: data['views_count']?.toString() ?? '0',
      isFree: data['is_free'] == 0 ? false : true,
      imageUrl:
          'https://atech-auto.com/assets/images/videos/thumb/${data['image']}',
      videoUrl:
          'https://atech-auto.com/assets/files/videos/${data['video_name']}',
    );
  }

  static Future<List<VideoPlaylist>> fetchVideoPlaylists(
      {String? search}) async {
    String url = 'https://atech-auto.com/api/videos_playlists';

    if (search != null) {
      url += '?search=$search';
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      return data.map((item) {
        return VideoPlaylist(
          id: item['id'],
          name: item['name'],
          imageUrl:
              'https://atech-auto.com/assets/images/video_play_lists/thumb/${item['image']}',
          description: item['description'] ?? '',
          price: item['price']?.toString() ?? '',
          videosCount: item['videos_count']?.toString() ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load video playlists');
    }
  }

  static Future<List<dynamic>> fetchUserPlaylists() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    String url = '${Env.baseApiUrl}playlists_user/';
    final uri = Uri.parse(url);

    var request = http.MultipartRequest('GET', uri);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    });

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final List<dynamic> data = jsonDecode(responseData);
        return data;
      } else {
        throw Exception(
            'Failed to load playlists, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> orderPlaylistVideo({
    required BuildContext context,
    required XFile image,
  }) async {
    const String baseUrl = Env.baseApiUrl;
    const FlutterSecureStorage storage = FlutterSecureStorage();

    try {
      // Retrieve the token
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Authentication token not found'};
      }

      // Access cart items and calculate total price
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cartItems = cartProvider.items;
      final totalPrice = cartProvider.totalPrice();

      // Get comma-separated playlist IDs
      String ids = cartItems.map((item) => item.videoPlaylist.id).join(",");
      print("Playlist IDs: $ids");

      // Set up the request URL and headers
      var uri = Uri.parse('${baseUrl}submit_order_video_playlist');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add fields to the request
      request.fields['playlists_id'] = ids;
      request.fields['price'] = totalPrice.toString();

      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'), // Adjust if needed
      ));

      // Send the request and handle the response
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        cartProvider.clearCart();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
        );
        return {'success': true, 'message': jsonDecode(responseData)};
      } else {
        final responseData = await response.stream.bytesToString();
        return {
          'success': false,
          'message': 'Failed to create product: ${jsonDecode(responseData)}'
        };
      }
    } catch (e) {
      print("Error: $e");
      return {'success': false, 'message': 'Failed to create product'};
    }
  }
}
