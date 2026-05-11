import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/booking_confirm_button_widget.dart';
import './widgets/booking_date_strip_widget.dart';
import './widgets/booking_notes_widget.dart';
import './widgets/booking_price_summary_widget.dart';
import './widgets/booking_service_summary_widget.dart';
import './widgets/booking_time_slots_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  int _navIndex = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlotId;
  String _notes = '';
  bool _isSubmitting = false;
  String _selectedPaymentMethod = 'CARD';

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Service data will be populated from backend/API or navigation arguments
  late Map<String, dynamic> _serviceMap;

  // Time slots will be populated from backend/API
  final List<Map<String, dynamic>> _timeSlotsMaps = [];

  @override
  void initState() {
    super.initState();

    // Get service data from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _serviceMap = args;
    } else {
      // Initialize with empty map if no arguments passed
      _serviceMap = {
        'title': 'Service',
        'providerName': 'Provider',
        'rating': 0.0,
        'reviewCount': 0,
        'priceType': 'HOURLY',
        'basePrice': 0.0,
      };
    }

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a time slot to continue',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    // TODO: Replace with Riverpod/Bloc for production
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _isSubmitting = false);
      _showBookingConfirmationDialog();
    }
  }

  void _showBookingConfirmationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingSuccessSheet(
        serviceName: _serviceMap['title'] as String,
        providerName: _serviceMap['providerName'] as String,
        selectedDate: _selectedDate,
        selectedSlot: _timeSlotsMaps.firstWhere(
          (s) => s['slotId'] == _selectedSlotId,
          orElse: () => _timeSlotsMaps.first,
        ),
        onGoHome: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.homeScreen,
            (r) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isTablet ? _buildTabletLayout(theme) : _buildPhoneLayout(theme),
      ),
      bottomNavigationBar: isTablet
          ? null
          : AppNavigation(
              currentIndex: _navIndex,
              onDestinationSelected: (index) {
                // TODO: Replace with Riverpod/Bloc for production
                setState(() => _navIndex = index);
                if (index == 0) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homeScreen,
                    (r) => false,
                  );
                }
              },
            ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return Column(
      children: [
        _buildCustomAppBar(theme),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookingServiceSummaryWidget(service: _serviceMap),
                    const SizedBox(height: 20),
                    BookingDateStripWidget(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        // TODO: Replace with Riverpod/Bloc for production
                        setState(() {
                          _selectedDate = date;
                          _selectedSlotId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    BookingTimeSlotsWidget(
                      timeSlots: _timeSlotsMaps,
                      selectedSlotId: _selectedSlotId,
                      onSlotSelected: (slotId) {
                        // TODO: Replace with Riverpod/Bloc for production
                        setState(() => _selectedSlotId = slotId);
                      },
                    ),
                    const SizedBox(height: 20),
                    BookingNotesWidget(
                      onNotesChanged: (notes) {
                        // TODO: Replace with Riverpod/Bloc for production
                        setState(() => _notes = notes);
                      },
                    ),
                    const SizedBox(height: 20),
                    BookingPriceSummaryWidget(
                      service: _serviceMap,
                      selectedPaymentMethod: _selectedPaymentMethod,
                      onPaymentMethodChanged: (method) {
                        // TODO: Replace with Riverpod/Bloc for production
                        setState(() => _selectedPaymentMethod = method);
                      },
                    ),
                    const SizedBox(height: 24),
                    BookingConfirmButtonWidget(
                      isEnabled: _selectedSlotId != null,
                      isLoading: _isSubmitting,
                      onConfirm: _handleConfirmBooking,
                      totalPrice: _calculateTotal(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        AppNavigation(
          currentIndex: _navIndex,
          onDestinationSelected: (index) {
            // TODO: Replace with Riverpod/Bloc for production
            setState(() => _navIndex = index);
            if (index == 0) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.homeScreen,
                (r) => false,
              );
            }
          },
        ),
        Container(width: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: Column(
            children: [
              _buildCustomAppBar(theme),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: service info + date + slots
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              BookingServiceSummaryWidget(service: _serviceMap),
                              const SizedBox(height: 20),
                              BookingDateStripWidget(
                                selectedDate: _selectedDate,
                                onDateSelected: (date) {
                                  setState(() {
                                    _selectedDate = date;
                                    _selectedSlotId = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              BookingTimeSlotsWidget(
                                timeSlots: _timeSlotsMaps,
                                selectedSlotId: _selectedSlotId,
                                onSlotSelected: (slotId) =>
                                    setState(() => _selectedSlotId = slotId),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      // Right: notes + price + confirm
                      SizedBox(
                        width: 340,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              BookingNotesWidget(
                                onNotesChanged: (n) =>
                                    setState(() => _notes = n),
                              ),
                              const SizedBox(height: 20),
                              BookingPriceSummaryWidget(
                                service: _serviceMap,
                                selectedPaymentMethod: _selectedPaymentMethod,
                                onPaymentMethodChanged: (m) =>
                                    setState(() => _selectedPaymentMethod = m),
                              ),
                              const SizedBox(height: 24),
                              BookingConfirmButtonWidget(
                                isEnabled: _selectedSlotId != null,
                                isLoading: _isSubmitting,
                                onConfirm: _handleConfirmBooking,
                                totalPrice: _calculateTotal(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Service',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  _serviceMap['title'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.share_rounded,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    final basePrice = _serviceMap['basePrice'] as double;
    const serviceFee = 8.50;
    return basePrice + serviceFee;
  }
}

class _BookingSuccessSheet extends StatelessWidget {
  final String serviceName;
  final String providerName;
  final DateTime selectedDate;
  final Map<String, dynamic> selectedSlot;
  final VoidCallback onGoHome;

  const _BookingSuccessSheet({
    required this.serviceName,
    required this.providerName,
    required this.selectedDate,
    required this.selectedSlot,
    required this.onGoHome,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
                _SummaryRow(
                  icon: Icons.cleaning_services_rounded,
                  label: 'Service',
                  value: serviceName,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  icon: Icons.person_rounded,
                  label: 'Provider',
                  value: providerName,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _formatDate(selectedDate),
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                  value:
                      '${selectedSlot['startTime']} – ${selectedSlot['endTime']}',
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

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
