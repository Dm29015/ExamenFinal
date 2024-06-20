import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/peajeModel.dart';

const String api = "http://localhost:5146/api/peaje";
const String apiExterna = "https://www.datos.gov.co/resource/7gj8-j6i3.json";

// GET: Listar Peajees
Future<List<Peaje>> fetchRegistrosPeajes() async {
  try {
    final response = await http.get(Uri.parse(api));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((peaje) => Peaje.fromJson(peaje)).toList();
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error en la carga de la API: $e');
  }
}

// POST: Registrar nuevo Peaje
Future<void> registrarPeaje(Map peaje) async {
  try {
    final response = await http.post(
      Uri.parse(api),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(peaje),
    );
    if (response.statusCode != 201) {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error en la carga de la API: $e');
  }
}

// PUT: Actualizar registro de peaje
Future<void> actualizarPeaje(int id, Map peaje) async {
  try {
    final response = await http.put(
      Uri.parse('$api/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(peaje),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      (response.statusCode);
      throw Exception('Error en la solicitud HTTP: $Error');
    }
  } catch (e) {
    throw Exception('Error en la carga de la API: $e');
  }
}

// GET: Obtener nombres de peajes desde la API externa
Future<List<String>> fetchNombresPeajes() async {
  try {
    final response = await http.get(Uri.parse(apiExterna));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<String> nombresPeajes =
          jsonResponse.map<String>((peaje) => peaje['peaje']).toList();
      return nombresPeajes;
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error en la carga de la API externa: $e');
  }
}

// GET: Obtener valor del peaje basado en el nombre y la categoría
Future<String> fetchValorPeaje(
    String nombrePeaje, String categoriaTarifa) async {
  try {
    final response = await http.get(Uri.parse(apiExterna));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      var peaje = jsonResponse.firstWhere(
          (peaje) =>
              peaje['peaje'] == nombrePeaje &&
              peaje['idcategoriatarifa'] == categoriaTarifa,
          orElse: () => null);
      if (peaje != null) {
        return peaje['valor'].toString();
      } else {
        throw Exception('Peaje no encontrado para los valores dados');
      }
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error en la carga de la API: $e');
  }
}

// DELETE: Eliminar registro de peaje
Future<void> eliminarPeaje(int id) async {
  try {
    final response =
        await http.delete(Uri.parse('$api/$id'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode != 201 && response.statusCode != 204) {
      throw Exception('Error al eliminar peaje: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al eliminar peaje: $e');
  }
}
