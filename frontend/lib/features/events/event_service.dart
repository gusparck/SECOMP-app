import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_service.dart';
import 'event_model.dart';
import '../../shared/models/user_model.dart';

class EventService {
  // Use 10.0.2.2 for Android Emulator, or local IP for physical device
  static const String _baseUrl = 'http://192.168.1.41:3000/api/events';

  final AuthService _authService = AuthService();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  Future<List<EventModel>> getEvents({
    int page = 1,
    int limit = 10,
    String? search,
    bool myEvents = false, // Subscribed events
    bool myCreations = false, // Created events
    bool teamEvents = false, // Team member events
  }) async {
    final token = await _getToken();
    String query = '?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) {
      query += '&search=$search';
    }
    if (myEvents) {
      query += '&user=me';
    }
    if (myCreations) {
      query += '&organizer=me';
    }
    if (teamEvents) {
      query += '&speaker=me';
    }

    final response = await http.get(
      Uri.parse('$_baseUrl$query'),
      headers: token != null
          ? {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            }
          : null,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List eventsJson = data['data'];
      return eventsJson.map((json) => EventModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  Future<List<EventModel>> getUserEvents() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('$_baseUrl?user=me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List eventsJson = data['data'];
      return eventsJson.map((json) => EventModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar suas inscrições');
    }
  }

  Future<List<EventModel>> getCreatedEvents() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('$_baseUrl?organizer=me'), // Fetch created events
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List events = data['data'];
      return events.map((e) => EventModel.fromJson(e)).toList();
    } else {
      throw Exception('Falha ao carregar seus eventos criados');
    }
  }

  Future<List<EventModel>> getTeamEvents() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('$_baseUrl?speaker=me'), // Fetch team events
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List events = data['data'];
      return events.map((e) => EventModel.fromJson(e)).toList();
    } else {
      throw Exception('Falha ao carregar eventos da equipe');
    }
  }

  Future<EventModel> getEventById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar detalhes do evento');
    }
  }

  Future<EventModel> createEvent(EventModel event) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': event.title,
        'description': event.description,
        'date': event.date.toIso8601String(),
        'location': event.location,
        'capacity': event.capacity,
        'organizerId': event
            .organizerId, // Usually handled by backend from token, but validated in schema
      }),
    );

    if (response.statusCode == 201) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Falha ao criar evento');
    }
  }

  Future<void> subscribe(String eventId) async {
    final token = await _getToken();
    final user = await _authService.getUser();

    if (token == null || user == null)
      throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eventId': eventId,
        'userId': user.id,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Falha na inscrição');
    }
  }

  Future<void> addSpeaker(String eventId, String registration) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$_baseUrl/$eventId/speakers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'registration': registration}),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Falha ao adicionar integrante');
    }
  }

  Future<Map<String, dynamic>> checkIn(String eventId, String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$_baseUrl/$eventId/checkin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Falha ao realizar check-in');
    }
  }
}
