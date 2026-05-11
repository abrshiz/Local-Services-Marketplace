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

  // Data will be populated from backend/API
  final List<Map<String, dynamic>> _categories = [];
  final List<Map<String, dynamic>> _servicesMaps = [];
  final Map<String, dynamic>? _upcomingBookingMap = null;

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
          onPressed: () {
            // TODO: Navigate to notifications screen
          },
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
            onTap: () {
              // Logout: navigate back to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.signUpLoginScreen,
                (route) => false,
              );
            },
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
