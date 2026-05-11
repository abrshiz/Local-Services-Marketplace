import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class BookingTimeSlotsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timeSlots;
  final String? selectedSlotId;
  final Function(String) onSlotSelected;

  const BookingTimeSlotsWidget({
    super.key,
    required this.timeSlots,
    required this.selectedSlotId,
    required this.onSlotSelected,
  });

  Map<String, List<Map<String, dynamic>>> _groupByPeriod() {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };
    for (final slot in timeSlots) {
      final period = slot['period'] as String;
      grouped[period]?.add(slot);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _groupByPeriod();
    final availableCount = timeSlots
        .where((s) => s['isAvailable'] as bool)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Time Slots',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$availableCount slots open',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...grouped.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PeriodHeader(period: entry.key),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((slot) {
                    return _TimeSlotChip(
                      slot: slot,
                      isSelected: selectedSlotId == slot['slotId'],
                      onTap: (slot['isAvailable'] as bool)
                          ? () => onSlotSelected(slot['slotId'] as String)
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],
            );
          }),
          // Legend
          Row(
            children: [
              _LegendItem(color: AppTheme.primary, label: 'Selected'),
              const SizedBox(width: 16),
              _LegendItem(
                color: AppTheme.surfaceVariantLight,
                label: 'Available',
                textColor: AppTheme.textSecondary,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: AppTheme.outlineLight,
                label: 'Booked',
                textColor: AppTheme.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodHeader extends StatelessWidget {
  final String period;
  const _PeriodHeader({required this.period});

  IconData _getIcon() {
    switch (period) {
      case 'Morning':
        return Icons.wb_sunny_outlined;
      case 'Afternoon':
        return Icons.wb_cloudy_outlined;
      case 'Evening':
        return Icons.nights_stay_outlined;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(_getIcon(), size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          period,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final Map<String, dynamic> slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = slot['isAvailable'] as bool;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : isAvailable
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : isAvailable
                ? theme.colorScheme.outlineVariant
                : theme.colorScheme.outlineVariant.withAlpha(128),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(64),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          slot['startTime'] as String,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isAvailable
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant.withAlpha(102),
            decoration: !isAvailable ? TextDecoration.lineThrough : null,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? textColor;

  const _LegendItem({required this.color, required this.label, this.textColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: textColor ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
