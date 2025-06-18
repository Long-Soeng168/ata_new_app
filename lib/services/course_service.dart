import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/course.dart';
import 'package:http/http.dart' as http;

class CourseService {
  static Future<List<Course>> fetchCourses({int page = 1}) async {
    // final url = '${Env.baseApiUrl}courses?page=$page';
    final url = 'https://atech-auto.com/api/courses?page=$page';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body);
      List<dynamic> data = result['data'];
      return data.map((item) {
        return Course(
          id: item['id'],
          name: item['title'] ?? '',
          imageUrl:
              'https://atech-auto.com/assets/images/courses/thumb/${item['image']}',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Courses');
    }
  }

  static Future<Course> fetchCourseById({required int id}) async {
    String url = 'https://atech-auto.com/api/courses/$id';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    final Map<String, dynamic> data = jsonDecode(response.body);

    return Course(
      id: data['id'],
      name: data['title'] ?? '',
      price: data['price']?.toString() ?? '',
      imageUrl:
          'https://atech-auto.com/assets/images/courses/thumb/${data['image']}',
      description: data['description'] ?? '',
      start: data['start'] ?? '',
      end: data['end'] ?? '',
    );
  }
}
