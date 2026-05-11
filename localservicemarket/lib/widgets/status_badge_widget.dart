import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BadgeStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  paid,
  failed,
  refunded,
  verified,
  active,
  inactive,
}

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final bool compact;

  const StatusBadgeWidget({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (status) {
      case BadgeStatus.pending:
        return _BadgeConfig(
          label: 'PENDING',
          backgroundColor: const Color(0xFFFFF8E1),
          borderColor: const Color(0xFFFFCC02),
          dotColor: const Color(0xFFFF8F00),
          textColor: const Color(0xFF6D4C00),
        );
      case BadgeStatus.confirmed:
        return _BadgeConfig(
          label: 'CONFIRMED',
          backgroundColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
          dotColor: const Color(0xFF1565C0),
          textColor: const Color(0xFF0D2B6B),
        );
      case BadgeStatus.completed:
        return _BadgeConfig(
          label: 'COMPLETED',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          dotColor: const Color(0xFF2E7D32),
          textColor: const Color(0xFF1B5E20),
        );
      case BadgeStatus.cancelled:
        return _BadgeConfig(
          label: 'CANCELLED',
          backgroundColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
          dotColor: const Color(0xFFC62828),
          textColor: const Color(0xFF7F0000),
        );
      case BadgeStatus.paid:
        return _BadgeConfig(
          label: 'PAID',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          dotColor: const Color(0xFF2E7D32),
          textColor: const Color(0xFF1B5E20),
        );
      case BadgeStatus.failed:
        return _BadgeConfig(
          label: 'FAILED',
          backgroundColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
          dotColor: const Color(0xFFC62828),
          textColor: const Color(0xFF7F0000),
        );
      case BadgeStatus.refunded:
        return _BadgeConfig(
          label: 'REFUNDED',
          backgroundColor: const Color(0xFFF3E5F5),
          borderColor: const Color(0xFFCE93D8),
          dotColor: const Color(0xFF7B1FA2),
          textColor: const Color(0xFF4A0072),
        );
      case BadgeStatus.verified:
        return _BadgeConfig(
          label: 'VERIFIED',
          backgroundColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
          dotColor: const Color(0xFF1565C0),
          textColor: const Color(0xFF0D2B6B),
        );
      case BadgeStatus.active:
        return _BadgeConfig(
          label: 'ACTIVE',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          dotColor: const Color(0xFF2E7D32),
          textColor: const Color(0xFF1B5E20),
        );
      case BadgeStatus.inactive:
        return _BadgeConfig(
          label: 'INACTIVE',
          backgroundColor: const Color(0xFFF5F5F5),
          borderColor: const Color(0xFFBDBDBD),
          dotColor: const Color(0xFF757575),
          textColor: const Color(0xFF424242),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color dotColor;
  final Color textColor;

  _BadgeConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.dotColor,
    required this.textColor,
  });
}
