import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/AuthContoller.dart';
import '../../Models/PropertyModel.dart';
import '../../Services/PropertyService.dart';
import '../../Services/ImageUploadService.dart';
import '../../Themes/AppTheme.dart';

class ManagePropertiesController extends GetxController {
  var properties = <PropertyModel>[].obs;
  var filteredProperties = <PropertyModel>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'all'.obs;
  var searchQuery = ''.obs;
  var selectedProperty = Rxn<PropertyModel>();

  final PropertyService _propertyService = Get.find<PropertyService>();
  final ImageUploadService _imageUploadService = Get.find<ImageUploadService>();

  final filterOptions = [
    {'value': 'all', 'label': 'All Properties'},
    {'value': 'available', 'label': 'Available'},
    {'value': 'rented', 'label': 'Rented'},
    {'value': 'pending', 'label': 'Pending Approval'},
    {'value': 'suspended', 'label': 'Suspended'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  void loadProperties() async {
    try {
      isLoading.value = true;
      final currentUser = Get.find<AuthController>().currentUser.value;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userProperties = await _propertyService.getPropertiesByUser(currentUser.id);
      properties.value = userProperties;
      applyFilters();

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

  void applyFilters() {
    var filtered = properties.where((property) {
      // Status filter
      bool matchesStatus = selectedFilter.value == 'all' ||
          property.status == selectedFilter.value;

      // Search filter
      bool matchesSearch = searchQuery.value.isEmpty ||
          property.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          property.location.toLowerCase().contains(searchQuery.value.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();

    filteredProperties.value = filtered;
  }

  void searchProperties(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void filterByStatus(String status) {
    selectedFilter.value = status;
    applyFilters();
  }

  void deleteProperty(PropertyModel property) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Property'),
          content: Text('Are you sure you want to delete "${property.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      // Delete images from storage
      if (property.images.isNotEmpty) {
        await _imageUploadService.deletePropertyImages(property.images);
      }

      // Delete property from database
      await _propertyService.deleteProperty(property.id);

      // Remove from local lists
      properties.removeWhere((p) => p.id == property.id);
      applyFilters();

      Get.snackbar(
        'Success',
        'Property deleted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete property: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void togglePropertyStatus(PropertyModel property) async {
    try {
      String newStatus;
      if (property.status == 'available') {
        newStatus = 'suspended';
      } else if (property.status == 'suspended') {
        newStatus = 'available';
      } else {
        Get.snackbar(
          'Info',
          'Cannot change status of ${property.status} property',
          backgroundColor: AppColors.info,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      await _propertyService.updateProperty(property.id, {'status': newStatus});

      // Update local property
      final index = properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        properties[index] = property.copyWith(status: newStatus);
        applyFilters();
      }

      Get.snackbar(
        'Success',
        'Property status updated to $newStatus',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update property status: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void editProperty(PropertyModel property) {
    // Navigate to edit page (you can implement this later)
    Get.toNamed('/agent/properties/edit/${property.id}', arguments: property);
  }

  void viewPropertyDetails(PropertyModel property) {
    selectedProperty.value = property;
    _showPropertyDetailsDialog();
  }

  void _showPropertyDetailsDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width > 768 ? 600 : Get.width * 0.9,
          height: Get.height * 0.8,
          child: PropertyDetailsDialog(property: selectedProperty.value!),
        ),
      ),
    );
  }

  void addNewProperty() {
    Get.toNamed('/agent/properties/add');
  }

  void refreshProperties() {
    loadProperties();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'rented':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Available';
      case 'rented':
        return 'Rented';
      case 'pending':
        return 'Pending Review';
      case 'suspended':
        return 'Suspended';
      default:
        return status.toUpperCase();
    }
  }
}

class ManagePropertiesPage extends StatelessWidget {
  final ManagePropertiesController controller = Get.put(ManagePropertiesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _buildPropertiesList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addNewProperty,
        backgroundColor: AppTheme.primaryColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Property', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Manage Properties', style: AppTextStyles.cardTitle),
      actions: [
        Obx(() => Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMd),
          child: Center(
            child: Text(
              '${controller.filteredProperties.length} properties',
              style: AppTextStyles.cardSubtitle,
            ),
          ),
        )),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: controller.refreshProperties,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: controller.searchProperties,
            decoration: InputDecoration(
              hintText: 'Search properties...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),

          SizedBox(height: AppTheme.spacingMd),

          // Filter Chips
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.filterOptions.map((filter) {
                final isSelected = controller.selectedFilter.value == filter['value'];
                return Padding(
                  padding: EdgeInsets.only(right: AppTheme.spacingSm),
                  child: FilterChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.filterByStatus(filter['value']!);
                      }
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPropertiesList() {
    return Obx(() {
      if (controller.filteredProperties.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        itemCount: controller.filteredProperties.length,
        itemBuilder: (context, index) {
          final property = controller.filteredProperties[index];
          return _buildPropertyCard(property);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.selectedFilter.value == 'all'
                ? Icons.home_outlined
                : Icons.filter_list_off,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: AppTheme.spacingMd),
          Text(
            controller.selectedFilter.value == 'all'
                ? 'No Properties Found'
                : 'No ${controller.selectedFilter.value} properties',
            style: AppTextStyles.cardTitle,
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(
            controller.selectedFilter.value == 'all'
                ? 'Start by adding your first property'
                : 'Try changing your filter or add new properties',
            style: AppTextStyles.cardSubtitle,
          ),
          SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: controller.addNewProperty,
            icon: Icon(Icons.add),
            label: Text('Add Property'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        children: [
          // Property Header with Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
              image: DecorationImage(
                image: NetworkImage(
                    property.images.isNotEmpty
                        ? property.images.first
                        : 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Status Badge
                Positioned(
                  top: AppTheme.spacingMd,
                  left: AppTheme.spacingMd,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(property.status),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      controller.getStatusLabel(property.status),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Actions Menu
                Positioned(
                  top: AppTheme.spacingMd,
                  right: AppTheme.spacingMd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            controller.editProperty(property);
                            break;
                          case 'toggle':
                            controller.togglePropertyStatus(property);
                            break;
                          case 'delete':
                            controller.deleteProperty(property);
                            break;
                          case 'view':
                            controller.viewPropertyDetails(property);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        if (property.status == 'available' || property.status == 'suspended')
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  property.status == 'available' ? Icons.pause : Icons.play_arrow,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(property.status == 'available' ? 'Suspend' : 'Activate'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
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

          // Property Details
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: AppTextStyles.cardTitle,
                    maxLines: 2,
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

                SizedBox(height: AppTheme.spacingMd),

                // Property Stats Row
                Row(
                  children: [
                    _buildStatItem(Icons.bed, '${property.bedrooms}'),
                    SizedBox(width: AppTheme.spacingMd),
                    _buildStatItem(Icons.bathtub, '${property.bathrooms}'),
                    SizedBox(width: AppTheme.spacingMd),
                    _buildStatItem(Icons.visibility, '${property.views}'),
                    Spacer(),
                    Text(
                      '₦${(property.price / 1000).toStringAsFixed(0)}K/month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),

                if (property.description.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingMd),
                  Text(
                    property.description,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                SizedBox(height: AppTheme.spacingMd),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.viewPropertyDetails(property),
                        icon: Icon(Icons.visibility, size: 16),
                        label: Text('View Details'),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.editProperty(property),
                        icon: Icon(Icons.edit, size: 16),
                        label: Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        SizedBox(width: 4),
        Text(value, style: AppTextStyles.caption),
      ],
    );
  }
}

// Property Details Dialog
class PropertyDetailsDialog extends StatelessWidget {
  final PropertyModel property;

  const PropertyDetailsDialog({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  property.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images
                if (property.images.isNotEmpty) ...[
                  Container(
                    height: 200,
                    child: PageView.builder(
                      itemCount: property.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            image: DecorationImage(
                              image: NetworkImage(property.images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingLg),
                ],

                // Details
                _buildDetailRow('Price', '₦${(property.price / 1000).toStringAsFixed(0)}K/month'),
                _buildDetailRow('Location', property.location),
                _buildDetailRow('Bedrooms', property.bedrooms.toString()),
                _buildDetailRow('Bathrooms', property.bathrooms.toString()),
                _buildDetailRow('Status', property.status.toUpperCase()),
                _buildDetailRow('Views', property.views.toString()),

                if (property.description.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingLg),
                  Text('Description', style: AppTextStyles.cardTitle),
                  SizedBox(height: AppTheme.spacingSm),
                  Text(property.description, style: AppTextStyles.bodyText),
                ],

                if (property.amenities.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingLg),
                  Text('Amenities', style: AppTextStyles.cardTitle),
                  SizedBox(height: AppTheme.spacingSm),
                  Wrap(
                    spacing: AppTheme.spacingSm,
                    runSpacing: AppTheme.spacingSm,
                    children: property.amenities.map((amenity) => Chip(
                      label: Text(amenity, style: TextStyle(fontSize: 12)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.cardSubtitle),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyText),
          ),
        ],
      ),
    );
  }
}