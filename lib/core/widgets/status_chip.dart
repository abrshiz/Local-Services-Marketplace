import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localservicemarket/core/theme/app_theme.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
