import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/home_category_chips_widget.dart';
import './widgets/home_featured_services_widget.dart';
import './widgets/home_nearby_providers_widget.dart';
import './widgets/home_search_bar_widget.dart';
import './widgets/home_upcoming_booking_widget.dart';
import './widgets/home_app_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  // Data populated with demo data
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Cleaning', 'icon': 'cleaning', 'color': 0xFF2196F3},
    {'label': 'Plumbing', 'icon': 'plumbing', 'color': 0xFFF44336},
    {'label': 'Electric', 'icon': 'electric', 'color': 0xFFFFC107},
    {'label': 'Laundry', 'icon': 'laundry', 'color': 0xFF4CAF50},
    {'label': 'Painting', 'icon': 'painting', 'color': 0xFF9C27B0},
    {'label': 'Repair', 'icon': 'repair', 'color': 0xFF795548},
  ];

  final List<Map<String, dynamic>> _servicesMaps = [
    {
      'id': 'svc_001',
      'title': 'House Deep Cleaning',
      'category': 'Cleaning',
      'providerName': 'Elena Petrova',
      'providerImageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
      'providerSemanticLabel': 'Elena Petrova',
      'serviceImageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
      'serviceSemanticLabel': 'Cleaning Service',
      'rating': 4.9,
      'reviewCount': 128,
      'basePrice': 45.0,
      'priceType': 'HOURLY',
      'distance': '1.2 km',
      'isVerified': true,
      'bio': 'Professional cleaning service with 5 years of experience.',
      'skills': ['Deep Cleaning', 'Eco-friendly'],
    },
    {
      'id': 'svc_002',
      'title': 'Master Plumber Repair',
      'category': 'Plumbing',
      'providerName': 'James Okonkwo',
      'providerImageUrl': 'https://images.unsplash.com/photo-1659353591742-9fa64d94738e',
      'providerSemanticLabel': 'James Okonkwo',
      'serviceImageUrl': 'https://images.unsplash.com/photo-1659353591742-9fa64d94738e',
      'serviceSemanticLabel': 'Plumbing Service',
      'rating': 4.7,
      'reviewCount': 85,
      'basePrice': 60.0,
      'priceType': 'FIXED',
      'distance': '0.8 km',
      'isVerified': true,
      'bio': 'Certified master plumber for all your home needs.',
      'skills': ['Pipe Repair', 'Installation'],
    },
    {
      'id': 'svc_003',
      'title': 'Electrical Maintenance',
      'category': 'Electric',
      'providerName': 'Priya Nair',
      'providerImageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_125538482-1766485545000.png',
      'providerSemanticLabel': 'Priya Nair',
      'serviceImageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_125538482-1766485545000.png',
      'serviceSemanticLabel': 'Electrical Service',
      'rating': 4.8,
      'reviewCount': 210,
      'basePrice': 55.0,
      'priceType': 'HOURLY',
      'distance': '2.4 km',
      'isVerified': true,
      'bio': 'Expert electrician with specialized training in home safety.',
      'skills': ['Wiring', 'Safety Audit'],
    },
  ];

  final Map<String, dynamic>? _upcomingBookingMap = {
    'serviceName': 'House Deep Cleaning',
    'providerName': 'Elena Petrova',
    'providerImageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
    'providerSemanticLabel': 'Elena Petrova',
    'status': 'CONFIRMED',
    'date': 'Tomorrow, May 12 · 10:00 AM',
  };

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildPhoneLayout(theme),
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        const HomeAppBarWidget(),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                HomeSearchBarWidget(
                  onSearchTap: () {
                    // TODO: Navigate to search screen
                  },
                  onFilterTap: () {
                    // TODO: Navigate to filters screen
                  },
                ),
                const SizedBox(height: 20),
                HomeCategoryChipsWidget(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: (index) {
                    // TODO: Replace with Riverpod/Bloc for production
                    setState(() => _selectedCategoryIndex = index);
                  },
                ),
                const SizedBox(height: 20),
                HomeUpcomingBookingWidget(
                  bookingData: _upcomingBookingMap,
                  isLoading: _isLoading,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.bookingScreen),
                ),
                const SizedBox(height: 24),
                HomeFeaturedServicesWidget(
                  services: _servicesMaps,
                  isLoading: _isLoading,
                  onServiceTap: (service) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.bookingScreen,
                      arguments: service,
                    );
                  },
                ),
                const SizedBox(height: 24),
                HomeNearbyProvidersWidget(isLoading: _isLoading),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
