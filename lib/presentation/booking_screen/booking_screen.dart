import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/booking_confirm_button_widget.dart';
import './widgets/booking_date_strip_widget.dart';
import './widgets/booking_notes_widget.dart';
import './widgets/booking_price_summary_widget.dart';
import './widgets/booking_service_summary_widget.dart';
import './widgets/booking_time_slots_widget.dart';
import './widgets/booking_success_sheet_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
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

  // Time slots populated with demo data
  final List<Map<String, dynamic>> _timeSlotsMaps = [
    {'slotId': 'ts_01', 'startTime': '08:00 AM', 'endTime': '09:00 AM', 'period': 'Morning', 'isAvailable': true},
    {'slotId': 'ts_02', 'startTime': '09:00 AM', 'endTime': '10:00 AM', 'period': 'Morning', 'isAvailable': false},
    {'slotId': 'ts_03', 'startTime': '10:00 AM', 'endTime': '11:00 AM', 'period': 'Morning', 'isAvailable': true},
    {'slotId': 'ts_04', 'startTime': '01:00 PM', 'endTime': '02:00 PM', 'period': 'Afternoon', 'isAvailable': true},
    {'slotId': 'ts_05', 'startTime': '02:00 PM', 'endTime': '03:00 PM', 'period': 'Afternoon', 'isAvailable': true},
    {'slotId': 'ts_06', 'startTime': '06:00 PM', 'endTime': '07:00 PM', 'period': 'Evening', 'isAvailable': true},
    {'slotId': 'ts_07', 'startTime': '07:00 PM', 'endTime': '08:00 PM', 'period': 'Evening', 'isAvailable': false},
  ];

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
      builder: (context) => BookingSuccessSheetWidget(
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
            AppRoutes.mainContainer,
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
    return Column(
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
