import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import 'event_model.dart';
import 'event_service.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        event.type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          event.timeRange,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          event.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // White Sheet
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Speaker Section
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  event.speaker.substring(0, 1),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Palestrante',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    event.speaker,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 48),

                          // Description
                          const Text(
                            'Sobre o evento',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF475569),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Participants Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoStat(
                                  'Vagas',
                                  '${event.maxCapacity}',
                                  Icons.people_outline,
                                ),
                                Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey.shade200),
                                _buildInfoStat(
                                  'Disponíveis',
                                  '${event.maxCapacity - event.currentParticipants}',
                                  Icons.event_seat,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 32),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ListenableBuilder(
            listenable: EventService(),
            builder: (context, _) {
              // Get latest event state
              final currentEvent = EventService()
                  .events
                  .firstWhere((e) => e.id == event.id, orElse: () => event);

              final isSubscribed = currentEvent.isUserSubscribed;

              return FloatingActionButton.extended(
                onPressed: () {
                  EventService().toggleSubscription(event.id);
                },
                backgroundColor:
                    isSubscribed ? Colors.redAccent : Colors.indigo,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                label: Text(
                  isSubscribed ? 'Cancelar Inscrição' : 'Inscrever-se',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: Icon(
                  isSubscribed ? Icons.close : Icons.check,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildInfoStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo.shade300, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
