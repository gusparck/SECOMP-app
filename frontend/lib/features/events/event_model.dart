enum EventType {
  palestra,
  workshop,
  minicurso,
  mesaRedonda,
  outros;

  String get label {
    switch (this) {
      case EventType.palestra:
        return 'Palestra';
      case EventType.workshop:
        return 'Workshop';
      case EventType.minicurso:
        return 'Minicurso';
      case EventType.mesaRedonda:
        return 'Mesa Redonda';
      case EventType.outros:
        return 'Outros';
    }
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final String speaker;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCapacity;
  final int currentParticipants;
  final bool isUserSubscribed; // Mocked field for current user status

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.speaker,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.currentParticipants,
    this.isUserSubscribed = false,
  });

  String get timeRange {
    final start =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    final end =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
    return "$start - $end";
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    String? speaker,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? maxCapacity,
    int? currentParticipants,
    bool? isUserSubscribed,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      speaker: speaker ?? this.speaker,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isUserSubscribed: isUserSubscribed ?? this.isUserSubscribed,
    );
  }
}
