
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/home_category_chips_widget.dart';
import './widgets/home_featured_services_widget.dart';
import './widgets/home_nearby_providers_widget.dart';
import './widgets/home_search_bar_widget.dart';
import './widgets/home_upcoming_booking_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  int _navIndex = 0;
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _categories = [
    {'icon': 'cleaning', 'label': 'Cleaning', 'color': 0xFF1565C0},
    {'icon': 'plumbing', 'label': 'Plumbing', 'color': 0xFF00695C},
    {'icon': 'electrical', 'label': 'Electrical', 'color': 0xFFE65100},
    {'icon': 'carpenter', 'label': 'Carpentry', 'color': 0xFF6A1B9A},
    {'icon': 'paint', 'label': 'Painting', 'color': 0xFF283593},
    {'icon': 'garden', 'label': 'Gardening', 'color': 0xFF2E7D32},
    {'icon': 'ac', 'label': 'AC Repair', 'color': 0xFF0277BD},
    {'icon': 'moving', 'label': 'Moving', 'color': 0xFF4E342E},
  ];

  final List<Map<String, dynamic>> _servicesMaps = [
    {
      'serviceId': 'svc_001',
      'title': 'Deep Home Cleaning',
      'category': 'Cleaning',
      'providerName': 'Maria Santos',
      'providerImageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
      'providerSemanticLabel':
          'Professional female cleaner with brown hair smiling in uniform',
      'serviceImageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_17622e44b-1772187349186.png',
      'serviceSemanticLabel':
          'Bright clean living room with organized furniture and spotless floors',
      'rating': 4.8,
      'reviewCount': 124,
      'priceType': 'HOURLY',
      'basePrice': 45.0,
      'isVerified': true,
      'distance': '1.2 km',
    },
    {
      'serviceId': 'svc_002',
      'title': 'Pipe Repair & Installation',
      'category': 'Plumbing',
      'providerName': 'James Okonkwo',
      'providerImageUrl':
          'https://images.unsplash.com/photo-1659353591742-9fa64d94738e',
      'providerSemanticLabel':
          'Middle-aged African man in blue work uniform holding wrench',
      'serviceImageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1a07a9909-1772083415193.png',
      'serviceSemanticLabel':
          'Plumber working under sink with copper pipes visible',
      'rating': 4.6,
      'reviewCount': 89,
      'priceType': 'FIXED',
      'basePrice': 120.0,
      'isVerified': true,
      'distance': '0.8 km',
    },
    {
      'serviceId': 'svc_003',
      'title': 'Electrical Wiring & Repair',
      'category': 'Electrical',
      'providerName': 'Priya Nair',
      'providerImageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_125538482-1766485545000.png',
      'providerSemanticLabel':
          'Young Indian woman electrician in safety gear with tools',
      'serviceImageUrl':
          'https://images.unsplash.com/photo-1628424123281-aafc8d41c5e4',
      'serviceSemanticLabel':
          'Close-up of electrical panel with colorful wires being connected',
      'rating': 4.9,
      'reviewCount': 203,
      'priceType': 'HOURLY',
      'basePrice': 65.0,
      'isVerified': true,
      'distance': '2.4 km',
    },
    {
      'serviceId': 'svc_004',
      'title': 'Interior Painting',
      'category': 'Painting',
      'providerName': 'Carlos Mendez',
      'providerImageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_171981ffb-1772650906231.png',
      'providerSemanticLabel':
          'Hispanic man in paint-stained overalls holding roller brush',
      'serviceImageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1ad324803-1774019383560.png',
      'serviceSemanticLabel':
          'Freshly painted white room interior with roller and paint tray on floor',
      'rating': 4.7,
      'reviewCount': 67,
      'priceType': 'FIXED',
      'basePrice': 200.0,
      'isVerified': false,
      'distance': '3.1 km',
    },
  ];

  final Map<String, dynamic> _upcomingBookingMap = {
    'bookingId': 'bkg_2847',
    'serviceName': 'Deep Home Cleaning',
    'providerName': 'Maria Santos',
    'providerImageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
    'providerSemanticLabel':
        'Professional female cleaner with brown hair smiling in uniform',
    'scheduledTime': '2026-05-12T10:00:00',
    'status': 'confirmed',
    'address': '42 Maple Street, Downtown',
    'totalPrice': 135.0,
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
    Future.delayed(const Duration(milliseconds: 300), () {
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
                if (index == 1) {
                  Navigator.pushNamed(context, AppRoutes.bookingScreen);
                }
              },
            ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(theme),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                HomeSearchBarWidget(onSearchTap: () {}, onFilterTap: () {}),
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

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        AppNavigation(
          currentIndex: _navIndex,
          onDestinationSelected: (index) {
            // TODO: Replace with Riverpod/Bloc for production
            setState(() => _navIndex = index);
          },
        ),
        Container(width: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(theme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeSearchBarWidget(
                              onSearchTap: () {},
                              onFilterTap: () {},
                            ),
                            const SizedBox(height: 20),
                            HomeCategoryChipsWidget(
                              categories: _categories,
                              selectedIndex: _selectedCategoryIndex,
                              onCategorySelected: (i) =>
                                  setState(() => _selectedCategoryIndex = i),
                            ),
                            const SizedBox(height: 20),
                            HomeFeaturedServicesWidget(
                              services: _servicesMaps,
                              isLoading: _isLoading,
                              isTablet: true,
                              onServiceTap: (service) => Navigator.pushNamed(
                                context,
                                AppRoutes.bookingScreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 320,
                        child: Column(
                          children: [
                            HomeUpcomingBookingWidget(
                              bookingData: _upcomingBookingMap,
                              isLoading: _isLoading,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.bookingScreen,
                              ),
                            ),
                            const SizedBox(height: 20),
                            HomeNearbyProvidersWidget(isLoading: _isLoading),
                          ],
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

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: theme.colorScheme.surface,
      shadowColor: theme.colorScheme.outline,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_repair_service_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'LocalService',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        background: Container(color: theme.colorScheme.surface),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: theme.colorScheme.onSurface,
                size: 26,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.signUpLoginScreen),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.primaryContainer,
              child: Text(
                'A',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
