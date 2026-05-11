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
