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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Color getStatusColor() {
      if (event.isSubscribed) return Colors.greenAccent;
      if (event.participantsCount >= event.capacity) return Colors.redAccent;
      if (event.participantsCount >= event.capacity * 0.8)
        return Colors.orangeAccent;
      return Colors.transparent;
    }

    final statusColor = getStatusColor();
    final hasStatus = statusColor != Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasStatus ? statusColor.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: hasStatus
                ? statusColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: hasStatus ? 15 : 10,
            spreadRadius: hasStatus ? 2 : 0,
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
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "Evento", // Default label as backend doesn't have type yet
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          event.formattedDate,
                          style: TextStyle(
                            color:
                                textTheme.bodySmall?.color ?? Colors.grey[500],
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
                  style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ) ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person,
                        size: 16,
                        color: textTheme.bodySmall?.color ?? Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.organizerName ?? "Organizador",
                        style: textTheme.bodyMedium?.copyWith(
                              color: textTheme.bodySmall?.color ??
                                  const Color(0xFF64748B),
                            ) ??
                            const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16,
                        color: textTheme.bodySmall?.color ?? Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location ?? "Local não definido",
                        style: textTheme.bodyMedium?.copyWith(
                              color: textTheme.bodySmall?.color ??
                                  const Color(0xFF64748B),
                            ) ??
                            const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.people,
                              size: 14, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            "${event.participantsCount}/${event.capacity}",
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
