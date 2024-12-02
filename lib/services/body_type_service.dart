import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/body_type.dart';
import 'package:http/http.dart' as http;

class BodyTypeService {
  static Future<List<BodyType>> fetchBodyTypes() async {
    const url = '${Env.baseApiUrl}body_types?';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<BodyType> categories = data.map((item) {
        return BodyType(
          id: item['id'],
          name: item['name'] ?? '',
          nameKh: item['name_kh'] ?? '',
          imageUrl: '${Env.baseImageUrl}body_types/${item['image']}',
        );
      }).toList();
       
      return categories;

    } else {
      throw Exception('Failed to load Body Type');
    }
  }

}
