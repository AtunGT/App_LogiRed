import 'package:flutter/material.dart';
import '../utils/directions.dart';

IconData maneuverIcon(String? m) {
  switch (m) {
    case 'turn-left':
    case 'turn-sharp-left':
    case 'ramp-left':
      return Icons.turn_left;
    case 'turn-slight-left':
      return Icons.turn_slight_left;
    case 'turn-right':
    case 'turn-sharp-right':
    case 'ramp-right':
      return Icons.turn_right;
    case 'turn-slight-right':
      return Icons.turn_slight_right;
    case 'uturn-left':
      return Icons.u_turn_left;
    case 'uturn-right':
      return Icons.u_turn_right;
    case 'roundabout-left':
      return Icons.roundabout_left;
    case 'roundabout-right':
      return Icons.roundabout_right;
    case 'fork-left':
      return Icons.fork_left;
    case 'fork-right':
      return Icons.fork_right;
    case 'merge':
      return Icons.merge_type;
    default:
      return Icons.straight;
  }
}

class TurnBanner extends StatelessWidget {
  final NavStep step;
  final String distanceText;
  final ColorScheme colorScheme;
  const TurnBanner(
      {super.key,
      required this.step,
      required this.distanceText,
      required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(maneuverIcon(step.maneuver), color: cs.onPrimary, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (distanceText.isNotEmpty)
                  Text(distanceText,
                      style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.1)),
                Text(step.instruction,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: cs.onPrimary.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
