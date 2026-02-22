import 'package:intl/intl.dart';
import '../../shared/models/user_model.dart';

class EventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? location;
  final int capacity;
  final String organizerId;
  final String? organizerName;
  final int participantsCount;
  final List<UserModel>? participants; // Full list for details/admin
  final List<UserModel>? speakers;
  final bool isSubscribed;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.location,
    required this.capacity,
    required this.organizerId,
    this.organizerName,
    this.participantsCount = 0,
    this.participants,
    this.speakers,
    this.isSubscribed = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      capacity: json['capacity'],
      organizerId: json['organizerId'],
      organizerName: json['organizer']?['name'],
      participantsCount: json['_count']?['participants'] ?? 0,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => UserModel.fromJson(p['user']))
              .toList()
          : null,
      speakers: json['speakers'] != null
          ? (json['speakers'] as List)
              .map((p) => UserModel.fromJson(p['user']))
              .toList()
          : null,
      isSubscribed: json['isSubscribed'] ?? false,
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
