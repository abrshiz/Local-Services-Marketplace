import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import './widgets/bookings_list_item_widget.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'id': 'bk_001',
      'serviceName': 'House Deep Cleaning',
      'providerName': 'Elena Petrova',
      'date': 'Tomorrow, May 12',
      'time': '10:00 AM',
      'price': 45.0,
      'status': 'CONFIRMED',
      'imageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
    },
    {
      'id': 'bk_002',
      'serviceName': 'Kitchen Sink Repair',
      'providerName': 'James Okonkwo',
      'date': 'Thursday, May 14',
      'time': '02:30 PM',
      'price': 65.0,
      'status': 'PENDING',
      'imageUrl': 'https://images.unsplash.com/photo-1659353591742-9fa64d94738e',
    },
  ];

  final List<Map<String, dynamic>> _pastBookings = [
    {
      'id': 'bk_000',
      'serviceName': 'Full Home Sanitization',
      'providerName': 'Sarah Miller',
      'date': 'May 5, 2026',
      'time': '09:00 AM',
      'price': 120.0,
      'status': 'COMPLETED',
      'imageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_125538482-1766485545000.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: AppTheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(_upcomingBookings, theme),
          _buildBookingList(_pastBookings, theme),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Map<String, dynamic>> bookings, ThemeData theme) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingsListItemWidget(booking: booking);
      },
    );
  }
}
