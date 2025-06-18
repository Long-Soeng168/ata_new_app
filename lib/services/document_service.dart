import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/document.dart';
import 'package:http/http.dart' as http;

class DocumentService {
  static Future<Document> fetchDocuments({String path = 'Documents'}) async {
    final url = 'https://atech-auto.com/api/file-explorer/folder/$path';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> foldersObject = data['folders'];
      List<dynamic> filesObject = data['files'];
      
      List<String> folders =
          foldersObject.map((item) => item.toString()).toList();
      List<String> files = filesObject.map((item) => item.toString()).toList();

      return Document(folders: folders, files: files);
    } else {
      throw Exception('Failed to load Documents');
    }
  }
}
