import 'dart:async';
import 'package:flutter/foundation.dart';
import 'event_model.dart';

class EventService extends ChangeNotifier {
  // Singleton pattern for simple state management
  static final EventService _instance = EventService._internal();

  factory EventService() {
    return _instance;
  }

  EventService._internal();

  final List<EventModel> _events = [
    EventModel(
      id: '1',
      title: 'Inteligência Artificial Generativa',
      description:
          'Explorando o potencial criativo e as aplicações práticas da IA Generativa no desenvolvimento de software e criação de conteúdo.',
      type: EventType.palestra,
      speaker: 'Dra. Ana Silva',
      location: 'Auditório A',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      endTime:
          DateTime.now().add(const Duration(days: 1, hours: 10, minutes: 30)),
      maxCapacity: 100,
      currentParticipants: 85,
      isUserSubscribed: true,
    ),
    EventModel(
      id: '2',
      title: 'Desenvolvimento Mobile com Flutter',
      description:
          'Aprenda a construir aplicativos multiplataforma performáticos e bonitos com o framework do Google.',
      type: EventType.workshop,
      speaker: 'Pedro Alcantara',
      location: 'Lab 3',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      endTime:
          DateTime.now().add(const Duration(days: 1, hours: 12, minutes: 30)),
      maxCapacity: 30,
      currentParticipants: 28,
      isUserSubscribed: false,
    ),
    EventModel(
      id: '3',
      title: 'O Futuro da Cibersegurança',
      description:
          'Tendências, desafios e carreiras em segurança da informação.',
      type: EventType.palestra,
      speaker: 'Carlos Santos',
      location: 'Auditório B',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
      endTime:
          DateTime.now().add(const Duration(days: 1, hours: 15, minutes: 30)),
      maxCapacity: 100,
      currentParticipants: 45,
      isUserSubscribed: false,
    ),
    EventModel(
      id: '4',
      title: 'Blockchain na Prática',
      description:
          'Construindo smart contracts e aplicações descentralizadas (dApps).',
      type: EventType.minicurso,
      speaker: 'Marcos Oliveira',
      location: 'Lab 2',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 16)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
      maxCapacity: 25,
      currentParticipants: 10,
      isUserSubscribed: false,
    ),
  ];

  List<EventModel> get events => List.unmodifiable(_events);

  Future<void> createEvent(EventModel event) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _events.add(event);
    notifyListeners();
  }

  Future<void> toggleSubscription(String eventId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      final newStatus = !event.isUserSubscribed;

      // Update participant count
      final newCount = newStatus
          ? event.currentParticipants + 1
          : event.currentParticipants - 1;

      _events[index] = event.copyWith(
        isUserSubscribed: newStatus,
        currentParticipants: newCount,
      );
      notifyListeners();
    }
  }
}
