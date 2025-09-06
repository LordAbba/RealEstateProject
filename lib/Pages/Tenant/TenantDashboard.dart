import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/AuthContoller.dart';
import '../../Models/PropertyModel.dart';
import '../../Services/PropertyService.dart';
import '../../Themes/AppTheme.dart';

class TenantController extends GetxController {
  var savedProperties = 0.obs;
  var recentSearches = 0.obs;
  var viewedProperties = 0.obs;
  var isLoading = false.obs;

  // Featured properties from database
  var featuredProperties = <PropertyModel>[].obs;

  final PropertyService _propertyService = Get.find<PropertyService>();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    isLoading.value = true;

    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      final userId = currentUser?.id;

      // Load featured properties from database
      final properties = await _propertyService.getFeaturedProperties(
        userId: userId,
        limit: 6,
      );
      featuredProperties.value = properties;

      // Load user statistics if logged in
      if (userId != null) {
        // Get user favorites count
        final favorites = await _propertyService.getUserFavorites(userId);
        savedProperties.value = favorites.length;

        // Mock other stats for now (you can implement these later)
        recentSearches.value = 12;
        viewedProperties.value = 28;
      } else {
        // Mock data for non-logged in users
        savedProperties.value = 0;
        recentSearches.value = 0;
        viewedProperties.value = 0;
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );

      // Show mock data as fallback
      savedProperties.value = 5;
      recentSearches.value = 12;
      viewedProperties.value = 28;

      // Show mock featured properties
      featuredProperties.value = _getMockProperties();
    } finally {
      isLoading.value = false;
    }
  }

  List<PropertyModel> _getMockProperties() {
    return [
      PropertyModel(
        id: '1',
        title: 'Modern 2BR Apartment',
        description: 'Beautiful modern apartment in prime location',
        location: 'Victoria Island, Lagos',
        price: 450000,
        bedrooms: 2,
        bathrooms: 2,
        amenities: ['Air Conditioning', 'WiFi', 'Parking'],
        images: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=300'],
        status: 'available',
        views: 45,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        agentName: 'John Smith',
      ),
      PropertyModel(
        id: '2',
        title: 'Luxury 3BR Duplex',
        description: 'Spacious luxury duplex with modern amenities',
        location: 'Lekki Phase 1, Lagos',
        price: 800000,
        bedrooms: 3,
        bathrooms: 3,
        amenities: ['Swimming Pool', 'Gym', 'Security'],
        images: ['https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=300'],
        status: 'available',
        views: 67,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        agentName: 'Sarah Johnson',
      ),
    ];
  }

  void toggleFavorite(PropertyModel property) async {
    try {
      final userId = Get.find<AuthController>().currentUser.value?.id;
      if (userId == null) {
        Get.snackbar(
          'Login Required',
          'Please login to add properties to favorites',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
        );
        return;
      }

      await _propertyService.toggleFavorite(userId, property.id);

      // Update local state
      final index = featuredProperties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        featuredProperties[index] = property.copyWith(
            isFavorited: !property.isFavorited
        );
      }

      // Update saved properties count
      if (property.isFavorited) {
        savedProperties.value -= 1;
      } else {
        savedProperties.value += 1;
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorite: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void goToBrowse() => Get.toNamed('/tenant/browse');
  void goToFavorites() => Get.toNamed('/tenant/favorites');
  void goToProfile() => Get.toNamed('/tenant/profile');
  void viewProperty(String id) async {
    try {
      await _propertyService.incrementPropertyViews(id);
      Get.toNamed('/tenant/property/$id');
    } catch (e) {
      // Still navigate even if view increment fails
      Get.toNamed('/tenant/property/$id');
    }
  }
}

class TenantDashboard extends StatelessWidget {
  final TenantController controller = Get.put(TenantController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      drawer: Get.width < 768 ? _buildMobileDrawer() : null,
      body: Row(
        children: [
          // Desktop Sidebar
          if (Get.width >= 768) _buildDesktopSidebar(),

          // Main Content
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _buildMainContent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.loadDashboardData(),
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Tenant Dashboard',
        style: AppTextStyles.cardTitle.copyWith(color: AppTheme.textPrimary),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMd),
          child: CircleAvatar(
            backgroundColor: AppColors.tenant,
            child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 280,
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Center(
                    child: Text('S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Text('Smart House', style: AppTextStyles.cardTitle),
              ],
            ),
          ),

          Divider(),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () {}),
                _buildNavItem(Icons.search, 'Browse Properties', false, controller.goToBrowse),
                _buildNavItem(Icons.favorite_outline, 'My Favorites', false, controller.goToFavorites),
                _buildNavItem(Icons.person_outline, 'Profile', false, controller.goToProfile),

                SizedBox(height: AppTheme.spacingLg),
                Divider(),

                _buildNavItem(Icons.logout, 'Logout', false, () {
                  Get.find<AuthController>().signOut();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('T', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Text('Tenant Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () => Get.back()),
                _buildNavItem(Icons.search, 'Browse Properties', false, () {
                  Get.back();
                  controller.goToBrowse();
                }),
                _buildNavItem(Icons.favorite_outline, 'My Favorites', false, () {
                  Get.back();
                  controller.goToFavorites();
                }),
                _buildNavItem(Icons.person_outline, 'Profile', false, () {
                  Get.back();
                  controller.goToProfile();
                }),
              ],
            ),
          ),

          Divider(),
          _buildNavItem(Icons.logout, 'Logout', false, () {
            Get.back();
            Get.find<AuthController>().signOut();
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),

          SizedBox(height: AppTheme.spacingXl),

          // Stats Cards
          _buildStatsCards(),

          SizedBox(height: AppTheme.spacingXl),

          // Quick Actions
          _buildQuickActions(),

          SizedBox(height: AppTheme.spacingXl),

          // Featured Properties
          _buildFeaturedProperties(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Find Your Dream Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingMd),
                Text(
                  'Discover verified properties from trusted agents and landlords.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (Get.width > 768)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                Icons.home,
                size: 60,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: Get.width > 768 ? 3 : 1,
      mainAxisSpacing: AppTheme.spacingMd,
      crossAxisSpacing: AppTheme.spacingMd,
      childAspectRatio: Get.width > 768 ? 1.5 : 3,
      children: [
        Obx(() => _buildStatCard(
          'Saved Properties',
          controller.savedProperties.value.toString(),
          Icons.favorite,
          AppColors.tenant,
        )),
        Obx(() => _buildStatCard(
          'Recent Searches',
          controller.recentSearches.value.toString(),
          Icons.search,
          AppColors.info,
        )),
        Obx(() => _buildStatCard(
          'Properties Viewed',
          controller.viewedProperties.value.toString(),
          Icons.visibility,
          AppColors.success,
        )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingLg),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                )),
                Text(title, style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.cardTitle),
        SizedBox(height: AppTheme.spacingMd),

        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: Get.width > 768 ? 4 : 2,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard('Browse Properties', Icons.search, controller.goToBrowse),
            _buildActionCard('My Favorites', Icons.favorite, controller.goToFavorites),
            _buildActionCard('Recent Searches', Icons.history, () {}),
            _buildActionCard('Update Profile', Icons.person, controller.goToProfile),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        decoration: AppDecorations.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Featured Properties', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: controller.goToBrowse,
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),

        Obx(() {
          if (controller.featuredProperties.isEmpty) {
            return Container(
              height: 200,
              decoration: AppDecorations.cardDecoration,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: AppTheme.spacingMd),
                    Text('No featured properties available', style: AppTextStyles.cardSubtitle),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Get.width > 768 ? 2 : 1,
              mainAxisSpacing: AppTheme.spacingMd,
              crossAxisSpacing: AppTheme.spacingMd,
              childAspectRatio: Get.width > 768 ? 1.4 : 1.2,
            ),
            itemCount: controller.featuredProperties.length,
            itemBuilder: (context, index) {
              final property = controller.featuredProperties[index];
              return _buildPropertyCard(property);
            },
          );
        }),
      ],
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return GestureDetector(
      onTap: () => controller.viewProperty(property.id),
      child: Container(
        decoration: AppDecorations.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
                  image: DecorationImage(
                    image: NetworkImage(property.images.isNotEmpty
                        ? property.images.first
                        : 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=300'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: AppTheme.spacingSm,
                      right: AppTheme.spacingSm,
                      child: GestureDetector(
                        onTap: () => controller.toggleFavorite(property),
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                          ),
                          child: Icon(
                            property.isFavorited ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: property.isFavorited ? Colors.red : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (property.views > 0)
                      Positioned(
                        bottom: AppTheme.spacingSm,
                        left: AppTheme.spacingSm,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('${property.views}',
                                  style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Property Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(property.location,
                              style: AppTextStyles.cardSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        Icon(Icons.bed, size: 16, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text('${property.bedrooms}', style: AppTextStyles.caption),
                        SizedBox(width: AppTheme.spacingMd),
                        Icon(Icons.bathtub, size: 16, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text('${property.bathrooms}', style: AppTextStyles.caption),
                        Spacer(),
                        Text('₦${(property.price / 1000).toStringAsFixed(0)}K/month',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            )),
                      ],
                    ),
                    if (property.agentName != null)
                      Padding(
                        padding: EdgeInsets.only(top: AppTheme.spacingSm),
                        child: Text('Agent: ${property.agentName}',
                            style: AppTextStyles.caption),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}