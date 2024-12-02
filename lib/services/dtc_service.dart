import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/dtc.dart';
import 'package:http/http.dart' as http;

class DtcService {
  static Future<Dtc> fetchDtcById({required String dtcCode}) async {
    String url = '${Env.baseApiUrl}dtcs/$dtcCode';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    final Map<String, dynamic> data = jsonDecode(response.body);

    return Dtc(
      dtcCode: data['dtc_code'] ?? '',
      descriptionKh: data['description_kh'] ?? '',
      descriptionEn: data['description_en'] ?? '',
    );
  }
}
