import 'dart:convert';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/payment.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static Future<Payment> fetchPayment() async {
    final url = '${Env.baseApiUrl}payment';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      Payment payment = Payment(
        id: data['id'] ?? 0, // Default to 0 if id is missing
        name: data['name'] ?? '',
        image: data['image'] != null
            ? '${Env.baseImageUrl}payments/${data['image']}'
            : '', // Set empty string if image is missing
        url: data['url'] ?? '',
      );
      return payment;
    } else {
      throw Exception('Failed to load Payment: ${response.statusCode}');
    }
  }
}
