import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/category.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static Future<List<Category>> fetchCategories() async {
    const url = '${Env.baseApiUrl}categories?';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Category> categories = data.map((item) {
        return Category(
          id: item['id'],
          name: item['name'] ?? '',
          nameKh: item['name_kh'] ?? '',
          imageUrl: '${Env.baseImageUrl}categories/${item['image']}',
        );
      }).toList();
       
      return categories;

    } else {
      throw Exception('Failed to load Categories');
    }
  }

}
