import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String type; // e.g., 'Palestra', 'Workshop'
  final String time;
  final String speaker;
  final String location;

  const EventCard({
    super.key,
    required this.title,
    required this.type,
    required this.time,
    required this.speaker,
    required this.location,
  });

  Color _getTypeColor() {
    switch (type.toLowerCase()) {
      case 'workshop':
        return Colors.orangeAccent;
      case 'palestra':
        return Colors.indigoAccent;
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
          onTap: () {}, // Detail view could go here
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
                        type,
                        style: TextStyle(
                          color: _getTypeColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
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
                      speaker,
                      style: const TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      location,
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
