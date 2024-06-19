import 'package:http/http.dart' as http;
import 'dart:convert';
import 'peaje.dart';

class PeajeApi {
  final String baseUrl;

  PeajeApi({required this.baseUrl});

  Future<List<Peaje>> getPeajes() async {
    final response = await http.get(Uri.parse('$baseUrl/peajes'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((peaje) => Peaje.fromJson(peaje)).toList();
    } else {
      throw Exception('Failed to load peajes');
    }
  }

  Future<Peaje> createPeaje(Peaje peaje) async {
    final response = await http.post(
      Uri.parse('$baseUrl/peajes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(peaje.toJson()),
    );

    if (response.statusCode == 201) {
      return Peaje.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create peaje');
    }
  }

  Future<void> updatePeaje(Peaje peaje) async {
    final response = await http.put(
      Uri.parse('$baseUrl/peajes/${peaje.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(peaje.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update peaje');
    }
  }

  Future<void> deletePeaje(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/peajes/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete peaje');
    }
  }
}
