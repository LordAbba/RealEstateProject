// pages/landlord/landlord_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/AuthContoller.dart';
import '../../Themes/AppTheme.dart';

class LandlordController extends GetxController {
  var totalProperties = 0.obs;
  var occupiedProperties = 0.obs;
  var vacantProperties = 0.obs;
  var totalAgents = 0.obs;
  var monthlyRevenue = 0.obs;
  var occupancyRate = 0.0.obs;
  var isLoading = false.obs;

  // Data lists
  var properties = <LandlordPropertyModel>[].obs;
  var agents = <AgentModel>[].obs;
  var recentActivities = <ActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1));

    // Mock data
    totalProperties.value = 8;
    occupiedProperties.value = 6;
    vacantProperties.value = 2;
    totalAgents.value = 3;
    monthlyRevenue.value = 2400000;
    occupancyRate.value = 75.0;

    properties.value = [
      LandlordPropertyModel(
        id: '1',
        title: 'Sunset Apartments Block A',
        location: 'Victoria Island',
        units: 12,
        occupiedUnits: 10,
        monthlyRevenue: 540000,
        status: 'active',
        agent: 'John Smith',
      ),
      LandlordPropertyModel(
        id: '2',
        title: 'Green Valley Duplex',
        location: 'Lekki Phase 1',
        units: 1,
        occupiedUnits: 1,
        monthlyRevenue: 800000,
        status: 'occupied',
        agent: 'Sarah Johnson',
      ),
    ];

    agents.value = [
      AgentModel(
        id: '1',
        name: 'John Smith',
        email: 'john@email.com',
        properties: 5,
        performance: 92,
      ),
      AgentModel(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah@email.com',
        properties: 3,
        performance: 88,
      ),
    ];

    recentActivities.value = [
      ActivityModel(
        type: 'rent',
        description: 'New tenant moved into Sunset Apartments Block A',
        timestamp: '2 hours ago',
        icon: Icons.person_add,
      ),
      ActivityModel(
        type: 'inquiry',
        description: 'New inquiry for Green Valley Duplex',
        timestamp: '5 hours ago',
        icon: Icons.message,
      ),
    ];

    isLoading.value = false;
  }

  void goToProperties() => Get.toNamed('/landlord/properties');
  void goToAgents() => Get.toNamed('/landlord/agents');
  void goToTenants() => Get.toNamed('/landlord/tenants');
  void goToReports() => Get.toNamed('/landlord/reports');
  void goToProfile() => Get.toNamed('/landlord/profile');
  void addNewProperty() => Get.toNamed('/landlord/properties/add');
}

class LandlordPropertyModel {
  final String id;
  final String title;
  final String location;
  final int units;
  final int occupiedUnits;
  final int monthlyRevenue;
  final String status;
  final String agent;

  LandlordPropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.units,
    required this.occupiedUnits,
    required this.monthlyRevenue,
    required this.status,
    required this.agent,
  });
}

class AgentModel {
  final String id;
  final String name;
  final String email;
  final int properties;
  final int performance;

  AgentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.properties,
    required this.performance,
  });
}

class ActivityModel {
  final String type;
  final String description;
  final String timestamp;
  final IconData icon;

  ActivityModel({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.icon,
  });
}

class LandlordDashboard extends StatelessWidget {
  final LandlordController controller = Get.put(LandlordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      drawer: Get.width < 768 ? _buildMobileDrawer() : null,
      body: Row(
        children: [
          if (Get.width >= 768) _buildDesktopSidebar(),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _buildMainContent()),
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
      title: Text('Landlord Dashboard', style: AppTextStyles.cardTitle),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMd),
          child: CircleAvatar(
            backgroundColor: AppColors.landlord,
            child: Text('L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () {}),
                _buildNavItem(Icons.apartment, 'Properties', false, controller.goToProperties),
                _buildNavItem(Icons.people_outline, 'Tenants', false, controller.goToTenants),
                _buildNavItem(Icons.business_center_outlined, 'Agents', false, controller.goToAgents),
                _buildNavItem(Icons.analytics_outlined, 'Reports', false, controller.goToReports),
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
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('L', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Text('Landlord Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () => Get.back()),
                _buildNavItem(Icons.apartment, 'Properties', false, () {
                  Get.back();
                  controller.goToProperties();
                }),
                _buildNavItem(Icons.people_outline, 'Tenants', false, () {
                  Get.back();
                  controller.goToTenants();
                }),
                _buildNavItem(Icons.business_center_outlined, 'Agents', false, () {
                  Get.back();
                  controller.goToAgents();
                }),
                _buildNavItem(Icons.analytics_outlined, 'Reports', false, () {
                  Get.back();
                  controller.goToReports();
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
        leading: Icon(icon, color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
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

          // Portfolio Overview
          _buildPortfolioOverview(),

          SizedBox(height: AppTheme.spacingXl),

          // Quick Actions
          _buildQuickActions(),

          SizedBox(height: AppTheme.spacingXl),

          // Properties and Agents Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPropertiesSection()),
              if (Get.width > 768) SizedBox(width: AppTheme.spacingLg),
              if (Get.width > 768) Expanded(child: _buildAgentsSection()),
            ],
          ),

          if (Get.width <= 768) ...[
            SizedBox(height: AppTheme.spacingXl),
            _buildAgentsSection(),
          ],

          SizedBox(height: AppTheme.spacingXl),

          // Recent Activities
          _buildRecentActivities(),
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
                Text('Property Portfolio', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                SizedBox(height: AppTheme.spacingSm),
                Text('Manage Your Investment', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: AppTheme.spacingMd),
                Text('Monitor your properties, track revenue, and manage your real estate business.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
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
              child: Icon(Icons.account_balance, size: 60, color: Colors.white.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portfolio Overview', style: AppTextStyles.cardTitle),
        SizedBox(height: AppTheme.spacingMd),

        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: Get.width > 768 ? 5 : 2,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: Get.width > 768 ? 1.2 : 1.5,
          children: [
            Obx(() => _buildStatCard('Total Properties', controller.totalProperties.value.toString(), Icons.apartment, AppColors.landlord)),
            Obx(() => _buildStatCard('Occupied', controller.occupiedProperties.value.toString(), Icons.check_circle, AppColors.success)),
            Obx(() => _buildStatCard('Vacant', controller.vacantProperties.value.toString(), Icons.home, AppColors.warning)),
            Obx(() => _buildStatCard('Active Agents', controller.totalAgents.value.toString(), Icons.business_center, AppColors.agent)),
            Obx(() => _buildStatCard('Monthly Revenue', '₦${(controller.monthlyRevenue.value / 1000).toStringAsFixed(0)}K', Icons.monetization_on, AppColors.success)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(title, style: AppTextStyles.caption, textAlign: TextAlign.center),
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
            _buildActionCard('Add Property', Icons.add_home, AppTheme.primaryColor, controller.addNewProperty),
            _buildActionCard('Manage Properties', Icons.apartment, AppColors.landlord, controller.goToProperties),
            _buildActionCard('View Tenants', Icons.people, AppColors.tenant, controller.goToTenants),
            _buildActionCard('Agents Performance', Icons.analytics, AppColors.info, controller.goToAgents),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Properties', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: controller.goToProperties,
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),

        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.properties.length,
          itemBuilder: (context, index) {
            final property = controller.properties[index];
            return _buildPropertyItem(property);
          },
        )),
      ],
    );
  }

  Widget _buildPropertyItem(LandlordPropertyModel property) {
    Color statusColor = property.status == 'active' ? AppColors.success :
    property.status == 'occupied' ? AppColors.info : AppColors.warning;

    double occupancyRate = (property.occupiedUnits / property.units) * 100;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(property.title, style: AppTextStyles.cardTitle)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Text(
                  property.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingSm),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 4),
              Text(property.location, style: AppTextStyles.cardSubtitle),
            ],
          ),
          SizedBox(height: AppTheme.spacingSm),

          Row(
            children: [
              Text('Agent: ', style: AppTextStyles.caption),
              Text(property.agent, style: AppTextStyles.cardSubtitle),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Occupancy', style: AppTextStyles.caption),
                  Text('${property.occupiedUnits}/${property.units} units (${occupancyRate.toStringAsFixed(0)}%)',
                      style: AppTextStyles.cardSubtitle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Monthly Revenue', style: AppTextStyles.caption),
                  Text('₦${(property.monthlyRevenue / 1000).toStringAsFixed(0)}K',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Agents', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: controller.goToAgents,
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),

        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.agents.length,
          itemBuilder: (context, index) {
            final agent = controller.agents[index];
            return _buildAgentItem(agent);
          },
        )),
      ],
    );
  }

  Widget _buildAgentItem(AgentModel agent) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.agent,
            child: Text(agent.name[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: AppTheme.spacingMd),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.name, style: AppTextStyles.cardTitle),
                Text(agent.email, style: AppTextStyles.cardSubtitle),
                SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: [
                    Text('${agent.properties} properties', style: AppTextStyles.caption),
                    SizedBox(width: AppTheme.spacingMd),
                    Text('${agent.performance}% performance', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: Text('${agent.performance}%',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activities', style: AppTextStyles.cardTitle),
        SizedBox(height: AppTheme.spacingMd),

        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.recentActivities.length,
          itemBuilder: (context, index) {
            final activity = controller.recentActivities[index];
            return _buildActivityItem(activity);
          },
        )),
      ],
    );
  }

  Widget _buildActivityItem(ActivityModel activity) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(activity.icon, color: AppTheme.primaryColor, size: 20),
          ),
          SizedBox(width: AppTheme.spacingMd),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.description, style: AppTextStyles.cardSubtitle),
                SizedBox(height: 4),
                Text(activity.timestamp, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}