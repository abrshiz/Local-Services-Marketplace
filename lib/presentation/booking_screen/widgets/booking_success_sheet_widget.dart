import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';
import './booking_summary_row_widget.dart';

class BookingSuccessSheetWidget extends StatelessWidget {
  final String serviceName;
  final String providerName;
  final DateTime selectedDate;
  final Map<String, dynamic> selectedSlot;
  final VoidCallback onGoHome;

  const BookingSuccessSheetWidget({
    super.key,
    required this.serviceName,
    required this.providerName,
    required this.selectedDate,
    required this.selectedSlot,
    required this.onGoHome,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[date.weekday - 1];
    return '$weekday, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.successContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: AppTheme.success, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            'Booking Requested!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking is pending confirmation from $providerName. You\'ll be notified once they respond.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                BookingSummaryRowWidget(
                  icon: Icons.cleaning_services_rounded,
                  label: 'Service',
                  value: serviceName,
                ),
                const SizedBox(height: 10),
                BookingSummaryRowWidget(
                  icon: Icons.person_rounded,
                  label: 'Provider',
                  value: providerName,
                ),
                const SizedBox(height: 10),
                BookingSummaryRowWidget(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _formatDate(selectedDate),
                ),
                const SizedBox(height: 10),
                BookingSummaryRowWidget(
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                  value: '${selectedSlot['startTime']} – ${selectedSlot['endTime']}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: onGoHome,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Back to Home',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'View Booking Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
