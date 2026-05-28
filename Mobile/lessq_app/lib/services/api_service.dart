import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/print_ticket.dart';
import '../models/queue_status.dart';

class ApiService {
  // USB (real device): keep 'localhost' + run: adb reverse tcp:5078 tcp:5078
  // Emulator:          use 'http://10.0.2.2:5078'
  // WiFi (real device): use your PC's LAN IP, e.g. 'http://192.168.1.x:5078'
  static const String baseUrl = 'http://localhost:5078';

  static Future<PrintTicket> createTicket({
    required File file,
    required int copies,
    required bool duplex,
    required String colorMode,
    String? pageRange,
  }) async {
    final uri = Uri.parse('$baseUrl/api/tickets');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['copies'] = copies.toString();
    request.fields['duplex'] = duplex.toString();
    request.fields['colorMode'] = colorMode;
    if (pageRange != null && pageRange.isNotEmpty) {
      request.fields['pageRange'] = pageRange;
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return PrintTicket.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al crear el ticket: ${response.statusCode}');
  }

  static Future<PrintTicket> getTicket(String id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/tickets/$id'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return PrintTicket.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Ticket no encontrado');
  }

  static Future<QueueStatus> getQueueStatus() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/queue'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return QueueStatus.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al obtener el estado de la cola');
  }
}
