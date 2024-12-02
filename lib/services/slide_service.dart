import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/slide.dart';
import 'package:http/http.dart' as http;

class SlideService {
  static Future<List<String>> fetchSlides({String position = ''}) async {
    final url = '${Env.baseApiUrl}slides?position=$position';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Slide> slideObject = data.map((item) {
        return Slide(
          id: item['id'],
          name: item['name'] ?? '',
          image: item['image'] ?? '',
        );
      }).toList();
      
      List<String> slideList = slideObject.map((e) {
        return '${Env.baseImageUrl}slides/thumb/${e.image}';
      }).toList();

      return slideList;

    } else {
      throw Exception('Failed to load slide');
    }
  }

}
