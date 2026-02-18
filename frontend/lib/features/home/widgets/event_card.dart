import 'package:flutter/material.dart';
import '../../events/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  Color _getTypeColor() {
    switch (event.type) {
      case EventType.workshop:
        return Colors.orangeAccent;
      case EventType.palestra:
        return Colors.indigoAccent;
      case EventType.minicurso:
        return Colors.purpleAccent;
      case EventType.mesaRedonda:
        return Colors.redAccent;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        event.type.label,
                        style: TextStyle(
                          color: _getTypeColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (event.isUserSubscribed)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                        Text(
                          event.timeRange,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B), // Slate 800
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event.speaker,
                      style: const TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: const TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
