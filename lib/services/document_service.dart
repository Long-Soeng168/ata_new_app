import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/document.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DocumentService {
  static Future<Document> fetchDocuments({String path = 'Documents'}) async {
    final FlutterSecureStorage _storage = const FlutterSecureStorage();

    final token = await _storage.read(key: 'auth_token'); // get the token
    final url = 'https://atech-auto.com/api/file-explorer/folder/$path';
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token', // add token
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> foldersObject = data['folders'];
      List<dynamic> filesObject = data['files'];

      List<String> folders =
          foldersObject.map((item) => item.toString()).toList();
      List<String> files = filesObject.map((item) => item.toString()).toList();

      return Document(
        folders: folders,
        files: files,
        status: data['status'] ?? 'unknown',
      );
    } else {
      throw Exception('Failed to load Documents');
    }
  }
}
