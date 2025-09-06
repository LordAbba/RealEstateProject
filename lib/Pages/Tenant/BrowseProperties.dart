// pages/tenant/browse_properties.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/AuthContoller.dart';
import '../../Models/PropertyModel.dart';
import '../../Services/PropertyService.dart';
import '../../Themes/AppTheme.dart';

class BrowsePropertiesController extends GetxController {
  var isLoading = false.obs;
  var isSearching = false.obs;
  var properties = <PropertyModel>[].obs;
  var filteredProperties = <PropertyModel>[].obs;

  var searchQuery = ''.obs;
  var selectedLocation = ''.obs;
  var minPrice = 0.0.obs;
  var maxPrice = 10000000.0.obs;
  var selectedBedrooms = 0.obs;
  var selectedBathrooms = 0.obs;

  var locations = <String>[].obs;

  final PropertyService _propertyService = Get.find<PropertyService>();

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  void loadProperties() async {
    try {
      isLoading.value = true;
      final result = await _propertyService.getAvailableProperties();

      properties.value = result;
      filteredProperties.value = result;

      // Extract unique locations
      locations.value = result
          .map((property) => property.location)
          .toSet()
          .toList();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load properties: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchProperties(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    var filtered = properties.where((property) {
      // Search query filter
      bool matchesSearch = searchQuery.value.isEmpty ||
          property.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          property.location.toLowerCase().contains(searchQuery.value.toLowerCase());

      // Location filter
      bool matchesLocation = selectedLocation.value.isEmpty ||
          property.location.contains(selectedLocation.value);

      // Price range filter
      bool matchesPrice = property.price >= minPrice.value &&
          property.price <= maxPrice.value;

      // Bedrooms filter
      bool matchesBedrooms = selectedBedrooms.value == 0 ||
          property.bedrooms >= selectedBedrooms.value;

      // Bathrooms filter
      bool matchesBathrooms = selectedBathrooms.value == 0 ||
          property.bathrooms >= selectedBathrooms.value;

      return matchesSearch && matchesLocation && matchesPrice &&
          matchesBedrooms && matchesBathrooms;
    }).toList();

    filteredProperties.value = filtered;
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedLocation.value = '';
    minPrice.value = 0.0;
    maxPrice.value = 10000000.0;
    selectedBedrooms.value = 0;
    selectedBathrooms.value = 0;
    filteredProperties.value = properties;
  }

  void toggleFavorite(PropertyModel property) async {
    try {
      final userId = Get.find<AuthController>().currentUser.value?.id;
      if (userId == null) return;

      await _propertyService.toggleFavorite(userId, property.id);

      // Update local state
      final index = filteredProperties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        filteredProperties[index] = property.copyWith(
            isFavorited: !property.isFavorited
        );
      }

      // Update original list too
      final originalIndex = properties.indexWhere((p) => p.id == property.id);
      if (originalIndex != -1) {
        properties[originalIndex] = property.copyWith(
            isFavorited: !property.isFavorited
        );
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

  void viewProperty(String propertyId) async {
    try {
      await _propertyService.incrementPropertyViews(propertyId);
      Get.toNamed('/tenant/property/$propertyId');
    } catch (e) {
      // Still navigate even if view count fails
      Get.toNamed('/tenant/property/$propertyId');
    }
  }
}

class BrowsePropertiesPage extends StatelessWidget {
  final BrowsePropertiesController controller = Get.put(BrowsePropertiesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Filter Sidebar (Desktop only)
          if (Get.width >= 768) _buildFilterSidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Search Bar and Mobile Filter Button
                _buildSearchBar(),

                // Properties Grid
                Expanded(
                  child: Obx(() => controller.isLoading.value
                      ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                      : _buildPropertiesGrid()),
                ),
              ],
            ),
          ),
        ],
      ),
      // Mobile Filter Sheet
      bottomSheet: Get.width < 768 ? null : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Browse Properties', style: AppTextStyles.cardTitle),
      actions: [
        // Filter results count
        Obx(() => Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMd),
          child: Center(
            child: Text(
              '${controller.filteredProperties.length} properties',
              style: AppTextStyles.cardSubtitle,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              onChanged: controller.searchProperties,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
            ),
          ),

          SizedBox(width: AppTheme.spacingMd),

          // Mobile Filter Button
          if (Get.width < 768)
            IconButton(
              onPressed: _showMobileFilterSheet,
              icon: Icon(Icons.filter_list),
            ),

          // Reset Filters Button
          TextButton.icon(
            onPressed: controller.resetFilters,
            icon: Icon(Icons.refresh, size: 18),
            label: Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar() {
    return Container(
      width: 300,
      color: AppTheme.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Header
          Container(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            child: Text('Filters', style: AppTextStyles.cardTitle),
          ),

          Divider(),

          // Filter Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              children: [
                _buildLocationFilter(),
                SizedBox(height: AppTheme.spacingLg),
                _buildPriceFilter(),
                SizedBox(height: AppTheme.spacingLg),
                _buildBedroomsFilter(),
                SizedBox(height: AppTheme.spacingLg),
                _buildBathroomsFilter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTextStyles.cardSubtitle.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppTheme.spacingSm),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedLocation.value.isEmpty ? null : controller.selectedLocation.value,
          onChanged: (value) {
            controller.selectedLocation.value = value ?? '';
            controller.applyFilters();
          },
          decoration: InputDecoration(
            hintText: 'Select location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
          items: [
            DropdownMenuItem<String>(value: '', child: Text('All Locations')),
            ...controller.locations.map((location) => DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            )).toList(),
          ],
        )),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Range', style: AppTextStyles.cardSubtitle.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppTheme.spacingSm),
        Obx(() => RangeSlider(
          values: RangeValues(controller.minPrice.value, controller.maxPrice.value),
          min: 0,
          max: 10000000,
          divisions: 100,
          labels: RangeLabels(
            '₦${(controller.minPrice.value / 1000).toStringAsFixed(0)}K',
            '₦${(controller.maxPrice.value / 1000).toStringAsFixed(0)}K',
          ),
          onChanged: (RangeValues values) {
            controller.minPrice.value = values.start;
            controller.maxPrice.value = values.end;
            controller.applyFilters();
          },
        )),
      ],
    );
  }

  Widget _buildBedroomsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Minimum Bedrooms', style: AppTextStyles.cardSubtitle.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppTheme.spacingSm),
        Obx(() => Wrap(
          spacing: AppTheme.spacingSm,
          children: [0, 1, 2, 3, 4].map((bedrooms) =>
              FilterChip(
                label: Text(bedrooms == 0 ? 'Any' : '$bedrooms+'),
                selected: controller.selectedBedrooms.value == bedrooms,
                onSelected: (selected) {
                  controller.selectedBedrooms.value = bedrooms;
                  controller.applyFilters();
                },
              )
          ).toList(),
        )),
      ],
    );
  }

  Widget _buildBathroomsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Minimum Bathrooms', style: AppTextStyles.cardSubtitle.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppTheme.spacingSm),
        Obx(() => Wrap(
          spacing: AppTheme.spacingSm,
          children: [0, 1, 2, 3, 4].map((bathrooms) =>
              FilterChip(
                label: Text(bathrooms == 0 ? 'Any' : '$bathrooms+'),
                selected: controller.selectedBathrooms.value == bathrooms,
                onSelected: (selected) {
                  controller.selectedBathrooms.value = bathrooms;
                  controller.applyFilters();
                },
              )
          ).toList(),
        )),
      ],
    );
  }

  Widget _buildPropertiesGrid() {
    return Obx(() {
      if (controller.filteredProperties.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
              SizedBox(height: AppTheme.spacingMd),
              Text('No properties found', style: AppTextStyles.cardTitle),
              Text('Try adjusting your filters', style: AppTextStyles.cardSubtitle),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Get.width > 1200 ? 3 : (Get.width > 768 ? 2 : 1),
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.filteredProperties.length,
        itemBuilder: (context, index) {
          final property = controller.filteredProperties[index];
          return _buildPropertyCard(property);
        },
      );
    });
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
                    // Favorite Button
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

                    // Status Badge
                    Positioned(
                      top: AppTheme.spacingSm,
                      left: AppTheme.spacingSm,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(property.status).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                        ),
                        child: Text(
                          property.status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                        _buildFeatureIcon(Icons.bed, property.bedrooms.toString()),
                        SizedBox(width: AppTheme.spacingMd),
                        _buildFeatureIcon(Icons.bathtub, property.bathrooms.toString()),
                        Spacer(),
                        Text('₦${(property.price / 1000).toStringAsFixed(0)}K/mo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            )),
                      ],
                    ),

                    if (property.views > 0)
                      Padding(
                        padding: EdgeInsets.only(top: AppTheme.spacingSm),
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 14, color: AppTheme.textSecondary),
                            SizedBox(width: 4),
                            Text('${property.views} views', style: AppTextStyles.caption),
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
    );
  }

  Widget _buildFeatureIcon(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        SizedBox(width: 4),
        Text(value, style: AppTextStyles.caption),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'rented':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  void _showMobileFilterSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: AppTextStyles.cardTitle),
                  TextButton(
                    onPressed: () {
                      controller.resetFilters();
                      Get.back();
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            ),

            Divider(),

            // Filter Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppTheme.spacingMd),
                children: [
                  _buildLocationFilter(),
                  SizedBox(height: AppTheme.spacingLg),
                  _buildPriceFilter(),
                  SizedBox(height: AppTheme.spacingLg),
                  _buildBedroomsFilter(),
                  SizedBox(height: AppTheme.spacingLg),
                  _buildBathroomsFilter(),
                ],
              ),
            ),

            // Apply Button
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}