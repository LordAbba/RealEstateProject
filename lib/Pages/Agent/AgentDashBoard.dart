// pages/agent/agent_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AuthContoller.dart';
import '../../Themes/AppTheme.dart';

class AgentController extends GetxController {
  var totalListings = 0.obs;
  var activeListings = 0.obs;
  var totalViews = 0.obs;
  var pendingInquiries = 0.obs;
  var monthlyRevenue = 0.obs;
  var isLoading = false.obs;

  // Recent properties
  var recentProperties = <AgentPropertyModel>[].obs;
  var recentInquiries = <InquiryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1));

    // Mock data
    totalListings.value = 15;
    activeListings.value = 12;
    totalViews.value = 248;
    pendingInquiries.value = 8;
    monthlyRevenue.value = 450000;

    recentProperties.value = [
      AgentPropertyModel(
        id: '1',
        title: 'Modern 2BR Apartment',
        location: 'Victoria Island',
        price: '₦450,000/month',
        status: 'active',
        views: 45,
        inquiries: 3,
      ),
      AgentPropertyModel(
        id: '2',
        title: 'Luxury 3BR Duplex',
        location: 'Lekki Phase 1',
        price: '₦800,000/month',
        status: 'pending',
        views: 28,
        inquiries: 5,
      ),
    ];

    recentInquiries.value = [
      InquiryModel(
        id: '1',
        tenantName: 'John Doe',
        propertyTitle: 'Modern 2BR Apartment',
        message: 'Interested in viewing this property',
        timestamp: '2 hours ago',
      ),
      InquiryModel(
        id: '2',
        tenantName: 'Jane Smith',
        propertyTitle: 'Luxury 3BR Duplex',
        message: 'Is this property still available?',
        timestamp: '5 hours ago',
      ),
    ];

    isLoading.value = false;
  }

  void goToAddProperty() => Get.toNamed('/agent/properties/add');
  void goToManageProperties() => Get.toNamed('/agent/properties');
  void goToInquiries() => Get.toNamed('/agent/inquiries');
  void goToProfile() => Get.toNamed('/agent/profile');
  void editProperty(String id) => Get.toNamed('/agent/properties/edit/$id');
}

class AgentPropertyModel {
  final String id;
  final String title;
  final String location;
  final String price;
  final String status;
  final int views;
  final int inquiries;

  AgentPropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.status,
    required this.views,
    required this.inquiries,
  });
}

class InquiryModel {
  final String id;
  final String tenantName;
  final String propertyTitle;
  final String message;
  final String timestamp;

  InquiryModel({
    required this.id,
    required this.tenantName,
    required this.propertyTitle,
    required this.message,
    required this.timestamp,
  });
}

class AgentDashboard extends StatelessWidget {
  final AgentController controller = Get.put(AgentController());

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
        onPressed: controller.goToAddProperty,
        backgroundColor: AppTheme.primaryColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Property', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Agent Dashboard', style: AppTextStyles.cardTitle),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined),
              Obx(() => controller.pendingInquiries.value > 0
                  ? Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${controller.pendingInquiries.value}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : SizedBox()),
            ],
          ),
          onPressed: controller.goToInquiries,
        ),
        Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMd),
          child: CircleAvatar(
            backgroundColor: AppColors.agent,
            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                _buildNavItem(Icons.home_work_outlined, 'My Properties', false, controller.goToManageProperties),
                _buildNavItem(Icons.add_home, 'Add Property', false, controller.goToAddProperty),
                _buildNavItem(Icons.message_outlined, 'Inquiries', false, controller.goToInquiries),
                _buildNavItem(Icons.analytics_outlined, 'Analytics', false, () {}),
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
                  child: Text('A', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Text('Agent Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () => Get.back()),
                _buildNavItem(Icons.home_work_outlined, 'My Properties', false, () {
                  Get.back();
                  controller.goToManageProperties();
                }),
                _buildNavItem(Icons.add_home, 'Add Property', false, () {
                  Get.back();
                  controller.goToAddProperty();
                }),
                _buildNavItem(Icons.message_outlined, 'Inquiries', false, () {
                  Get.back();
                  controller.goToInquiries();
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

          // Performance Stats
          _buildPerformanceStats(),

          SizedBox(height: AppTheme.spacingXl),

          // Quick Actions
          _buildQuickActions(),

          SizedBox(height: AppTheme.spacingXl),

          // Recent Properties & Inquiries
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentProperties()),
              if (Get.width > 768) SizedBox(width: AppTheme.spacingLg),
              if (Get.width > 768) Expanded(child: _buildRecentInquiries()),
            ],
          ),

          if (Get.width <= 768) ...[
            SizedBox(height: AppTheme.spacingXl),
            _buildRecentInquiries(),
          ],
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
                Text('Welcome back, Agent!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                SizedBox(height: AppTheme.spacingSm),
                Text('Manage Your Properties', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: AppTheme.spacingMd),
                Text('Track your listings, manage inquiries, and grow your business.',
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
              child: Icon(Icons.business, size: 60, color: Colors.white.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance Overview', style: AppTextStyles.cardTitle),
        SizedBox(height: AppTheme.spacingMd),

        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: Get.width > 768 ? 5 : 2,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: Get.width > 768 ? 1.2 : 1.5,
          children: [
            Obx(() => _buildStatCard('Total Listings', controller.totalListings.value.toString(), Icons.home_work, AppColors.agent)),
            Obx(() => _buildStatCard('Active Listings', controller.activeListings.value.toString(), Icons.check_circle, AppColors.success)),
            Obx(() => _buildStatCard('Total Views', controller.totalViews.value.toString(), Icons.visibility, AppColors.info)),
            Obx(() => _buildStatCard('Inquiries', controller.pendingInquiries.value.toString(), Icons.message, AppColors.warning)),
            Obx(() => _buildStatCard('Revenue', '₦${(controller.monthlyRevenue.value / 1000).toStringAsFixed(0)}K', Icons.monetization_on, AppColors.success)),
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
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
            _buildActionCard('Add Property', Icons.add_home, AppTheme.primaryColor, controller.goToAddProperty),
            _buildActionCard('Manage Properties', Icons.home_work, AppColors.agent, controller.goToManageProperties),
            _buildActionCard('View Inquiries', Icons.message, AppColors.warning, controller.goToInquiries),
            _buildActionCard('Analytics', Icons.analytics, AppColors.info, () {}),
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

  Widget _buildRecentProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Properties', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: controller.goToManageProperties,
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),

        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.recentProperties.length,
          itemBuilder: (context, index) {
            final property = controller.recentProperties[index];
            return _buildPropertyListItem(property);
          },
        )),
      ],
    );
  }

  Widget _buildPropertyListItem(AgentPropertyModel property) {
    Color statusColor = property.status == 'active' ? AppColors.success :
    property.status == 'pending' ? AppColors.warning : AppColors.unavailable;

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
              Expanded(
                child: Text(property.title, style: AppTextStyles.cardTitle),
              ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(property.price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: AppTheme.textSecondary),
                  SizedBox(width: 4),
                  Text('${property.views}', style: AppTextStyles.caption),
                  SizedBox(width: AppTheme.spacingMd),
                  Icon(Icons.message, size: 16, color: AppTheme.textSecondary),
                  SizedBox(width: 4),
                  Text('${property.inquiries}', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInquiries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Inquiries', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: controller.goToInquiries,
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),

        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.recentInquiries.length,
          itemBuilder: (context, index) {
            final inquiry = controller.recentInquiries[index];
            return _buildInquiryItem(inquiry);
          },
        )),
      ],
    );
  }

  Widget _buildInquiryItem(InquiryModel inquiry) {
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
              Text(inquiry.tenantName, style: AppTextStyles.cardTitle),
              Text(inquiry.timestamp, style: AppTextStyles.caption),
            ],
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(inquiry.propertyTitle, style: AppTextStyles.cardSubtitle),
          SizedBox(height: AppTheme.spacingSm),
          Text(inquiry.message, style: AppTextStyles.caption),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text('Reply'),
                ),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('View Property'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}