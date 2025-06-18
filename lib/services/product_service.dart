import 'dart:convert';

import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/pages/shops/shop_admin/admin_shop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProductService {
  static Future<List<Product>> fetchProducts(
      {int? categoryId,
      int? bodyTypeId,
      int? brandId,
      int? shopId,
      int? brandModelId,
      int? page,
      String? search}) async {
    String url = 'https://atech-auto.com/api/products';

    List<String> queryParams = [];

    if (categoryId != null) {
      queryParams.add('categoryId=$categoryId');
    }
    if (bodyTypeId != null) {
      queryParams.add('bodyTypeId=$bodyTypeId');
    }
    if (brandId != null) {
      queryParams.add('brandId=$brandId');
    }
    if (shopId != null) {
      queryParams.add('shopId=$shopId');
    }
    if (brandModelId != null) {
      queryParams.add('brandModelId=$brandModelId');
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

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      return data.map((item) {
        return Product(
          id: item['id'] ?? 0,
          name: item['name'] ?? '',
          shopId: item['shop_id'] ?? 0,
          price: item['price']?.toString() ?? '',
          imageUrl:
              'https://atech-auto.com/assets/images/items/thumb/${item['image']}',
          isInstock: item['is_instock'] == 0 ? false : true,
        );
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> fetchRelatedProducts({required int id}) async {
    String url = 'https://atech-auto.com/api/related_products/$id';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      return data.map((item) {
        return Product(
          id: item['id'] ?? 0,
          name: item['name'] ?? '',
          shopId: item['shop_id'] ?? 0,
          price: item['price']?.toString() ?? '',
          imageUrl:
              'https://atech-auto.com/assets/images/items/thumb/${item['image']}',
          isInstock: item['is_instock'] == 0 ? false : true,
        );
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Product> fetchProductById({required int id}) async {
    String url = 'https://atech-auto.com/api/products/$id';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    final Map<String, dynamic> data = jsonDecode(response.body);

    List<dynamic> imagesObjects = data['images'];
    List<String> imagesUrls = imagesObjects.map((item) {
      return 'https://atech-auto.com/assets/images/items/thumb/${item['image']}';
    }).toList();

    String formatCreatedAt = '';
    if (data['created_at'] != null) {
      String createdAt = data['created_at'];
      DateTime parsedDate = DateTime.parse(createdAt);
      formatCreatedAt = DateFormat('yyyy-MMM-dd').format(parsedDate);
    }

    // print(data);
    return Product(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      price: data['price']?.toString() ?? '',
      imageUrl:
          'https://atech-auto.com/assets/images/items/thumb/${data['image']}',
      imagesUrls: imagesUrls,
      isInstock: data['is_instock'] == 0 ? false : true,
      description: data['description'] ?? '',
      bodyTypeId: data['body_type']?['id'] ?? -1,
      bodyTypeName: data['body_type']?['name'] ?? '',
      categoryId: data['category']?['id'] ?? -1,
      shopId: data['shop_id'] ?? 0,
      categoryName: data['category']?['name'] ?? '',
      brandId: data['brand']?['id'] ?? -1,
      brandName: data['brand']?['name'] ?? '',
      modelId: data['brand_model']?['id'] ?? -1,
      modelName: data['brand_model']?['name'] ?? '',
      createdAt: formatCreatedAt,
    );
  }

  final String _baseUrl = Env.baseApiUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createProduct({
    context,
    shop,
    required String name,
    required String price,
    required String description,
    required int categoryId,
    required int brandId,
    required int brandModelId,
    required int bodyTypeId,
    required XFile image,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    try {
      var uri = Uri.parse(
          'https://atech-auto.com/api/products'); // API URL for creating a product
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['name'] = name;
      request.fields['price'] = price;
      request.fields['description'] = description;
      request.fields['categoryId'] = categoryId.toString();
      request.fields['bodyTypeId'] = bodyTypeId.toString();
      request.fields['brandId'] = brandId.toString();
      request.fields['brandModelId'] = brandModelId.toString();

      // Add the product image
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Ensure this key matches your API's expected field name for the product image
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AdminShopPage(
                    shop: shop,
                  )),
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
      print(e);
      return {'success': false, 'message': 'Failed to create product'};
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    context,
    shop,
    required Product product,
    required String name,
    required String price,
    required String description,
    required int categoryId,
    required int brandId,
    required int brandModelId,
    required int bodyTypeId,
    required XFile? image,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    try {
      var uri = Uri.parse(
          'https://atech-auto.com/api/update_products/${product.id}'); // API URL for creating a product
      var request = http.MultipartRequest('POST', uri);
      print(uri);

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['name'] = name;
      request.fields['price'] = price;
      request.fields['description'] = description;
      request.fields['categoryId'] = categoryId.toString();
      request.fields['bodyTypeId'] = bodyTypeId.toString();
      request.fields['brandId'] = brandId.toString();
      request.fields['brandModelId'] = brandModelId.toString();

      // Add the product image
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Ensure this key matches your API's expected field name for the product image
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
              builder: (context) => AdminShopPage(
                    shop: shop,
                  )),
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
      print(e);
      return {'success': false, 'message': 'Failed to create product'};
    }
  }

  Future<Map<String, dynamic>> deleteProduct({
    required BuildContext context,
    required int productId,
  }) async {
    final token =
        await _storage.read(key: 'auth_token'); // Retrieve the auth token

    try {
      var uri = Uri.parse(
          'https://atech-auto.com/api/products/$productId/delete'); // API URL for deleting a product
      var request = http.Request('GET', uri);

      // Add headers
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return {'success': true, 'message': jsonDecode(responseData)};
      } else {
        final responseData = await response.stream.bytesToString();
        return {
          'success': false,
          'message': 'Failed to delete product: ${jsonDecode(responseData)}',
        };
      }
    } catch (e) {
      print(e);
      return {'success': false, 'message': 'Failed to delete product'};
    }
  }
}
