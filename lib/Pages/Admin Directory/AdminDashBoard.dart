import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/AuthContoller.dart';
import '../../Themes/AppTheme.dart';

class AdminController extends GetxController {
  var totalUsers = 0.obs;
  var totalProperties = 0.obs;
  var pendingApprovals = 0.obs;
  var activeAgents = 0.obs;
  var totalTenants = 0.obs;
  var totalLandlords = 0.obs;
  var systemHealth = 98.5.obs;
  var isLoading = false.obs;

  // Data for charts and lists
  var userGrowthData = <Map<String, dynamic>>[].obs;
  var pendingProperties = <AdminPropertyModel>[].obs;
  var recentUsers = <AdminUserModel>[].obs;
  var systemActivities = <AdminActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1));

    // Mock data
    totalUsers.value = 156;
    totalProperties.value = 89;
    pendingApprovals.value = 12;
    activeAgents.value = 23;
    totalTenants.value = 98;
    totalLandlords.value = 35;

    // User growth data for chart
    userGrowthData.value = [
      {'month': 'Jan', 'users': 20},
      {'month': 'Feb', 'users': 35},
      {'month': 'Mar', 'users': 45},
      {'month': 'Apr', 'users': 62},
      {'month': 'May', 'users': 89},
      {'month': 'Jun', 'users': 156},
    ];

    pendingProperties.value = [
      AdminPropertyModel(
        id: '1',
        title: 'Modern 3BR Apartment',
        agent: 'John Smith',
        location: 'Victoria Island',
        price: '₦650,000/month',
        submittedAt: '2 hours ago',
        status: 'pending',
      ),
      AdminPropertyModel(
        id: '2',
        title: 'Luxury Duplex',
        agent: 'Sarah Johnson',
        location: 'Lekki Phase 1',
        price: '₦1,200,000/month',
        submittedAt: '4 hours ago',
        status: 'pending',
      ),
      AdminPropertyModel(
        id: '3',
        title: 'Executive 4BR House',
        agent: 'David Wilson',
        location: 'Ikoyi',
        price: '₦2,500,000/month',
        submittedAt: '6 hours ago',
        status: 'pending',
      ),
    ];

    recentUsers.value = [
      AdminUserModel(
        id: '1',
        name: 'Michael Brown',
        email: 'michael@email.com',
        role: 'tenant',
        joinedAt: '1 day ago',
        isVerified: true,
      ),
      AdminUserModel(
        id: '2',
        name: 'Lisa Wilson',
        email: 'lisa@email.com',
        role: 'agent',
        joinedAt: '2 days ago',
        isVerified: false,
      ),
      AdminUserModel(
        id: '3',
        name: 'James Anderson',
        email: 'james@email.com',
        role: 'landlord',
        joinedAt: '3 days ago',
        isVerified: true,
      ),
    ];

    systemActivities.value = [
      AdminActivityModel(
        type: 'user_registration',
        description: 'New tenant registered: Michael Brown',
        timestamp: '1 hour ago',
        icon: Icons.person_add,
        severity: 'info',
      ),
      AdminActivityModel(
        type: 'property_approval',
        description: 'Property approved: Modern 2BR Apartment',
        timestamp: '3 hours ago',
        icon: Icons.check_circle,
        severity: 'success',
      ),
      AdminActivityModel(
        type: 'user_suspension',
        description: 'User suspended for policy violation',
        timestamp: '1 day ago',
        icon: Icons.warning,
        severity: 'warning',
      ),
      AdminActivityModel(
        type: 'payment_issue',
        description: 'Payment failed for Property ID: PR001',
        timestamp: '2 days ago',
        icon: Icons.payment,
        severity: 'error',
      ),
    ];

    isLoading.value = false;
  }

  void goToUsers() => Get.toNamed('/admin/users');
  void goToProperties() => Get.toNamed('/admin/properties');
  void goToPendingApprovals() => Get.toNamed('/admin/properties/pending');
  void goToReports() => Get.toNamed('/admin/reports');
  void goToSettings() => Get.toNamed('/admin/settings');
  void goToSupport() => Get.toNamed('/admin/support');

  void approveProperty(String id) {
    // Remove from pending list
    pendingProperties.removeWhere((p) => p.id == id);
    pendingApprovals.value--;

    Get.snackbar(
      'Success',
      'Property approved successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  void rejectProperty(String id) {
    pendingProperties.removeWhere((p) => p.id == id);
    pendingApprovals.value--;

    Get.snackbar(
      'Property Rejected',
      'Property has been rejected',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
    );
  }

  void suspendUser(String userId) {
    recentUsers.removeWhere((user) => user.id == userId);
    totalUsers.value--;

    Get.snackbar(
      'User Suspended',
      'User has been suspended',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
    );
  }

  void verifyUser(String userId) {
    final userIndex = recentUsers.indexWhere((user) => user.id == userId);
    if (userIndex != -1) {
      recentUsers[userIndex] = AdminUserModel(
        id: recentUsers[userIndex].id,
        name: recentUsers[userIndex].name,
        email: recentUsers[userIndex].email,
        role: recentUsers[userIndex].role,
        joinedAt: recentUsers[userIndex].joinedAt,
        isVerified: true,
      );
      recentUsers.refresh();
    }

    Get.snackbar(
      'User Verified',
      'User verification completed',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}

class AdminPropertyModel {
  final String id;
  final String title;
  final String agent;
  final String location;
  final String price;
  final String submittedAt;
  final String status;

  AdminPropertyModel({
    required this.id,
    required this.title,
    required this.agent,
    required this.location,
    required this.price,
    required this.submittedAt,
    required this.status,
  });
}

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String joinedAt;
  final bool isVerified;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    required this.isVerified,
  });
}

class AdminActivityModel {
  final String type;
  final String description;
  final String timestamp;
  final IconData icon;
  final String severity;

  AdminActivityModel({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.severity,
  });
}

class AdminDashboard extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Admin Control Center', style: AppTextStyles.cardTitle),
      actions: [
        // System Health Indicator
        Obx(() => Container(
          margin: EdgeInsets.only(right: AppTheme.spacingMd),
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.health_and_safety, size: 16, color: AppColors.success),
              SizedBox(width: 4),
              Text('${controller.systemHealth.value}%',
                  style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        )),

        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined),
              Obx(() => controller.pendingApprovals.value > 0
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
                    '${controller.pendingApprovals.value}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : SizedBox()),
            ],
          ),
          onPressed: controller.goToPendingApprovals,
        ),

        Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMd),
          child: CircleAvatar(
            backgroundColor: AppColors.admin,
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
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Center(
                    child: Text('S', style: TextStyle(color: AppTheme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () {}),
                _buildNavItem(Icons.people_outline, 'Users', false, controller.goToUsers),
                _buildNavItem(Icons.home_work_outlined, 'Properties', false, controller.goToProperties),
                _buildNavItem(Icons.pending_actions, 'Pending Approvals', false, controller.goToPendingApprovals),
                _buildNavItem(Icons.analytics_outlined, 'Reports', false, controller.goToReports),
                _buildNavItem(Icons.support_agent, 'Support', false, controller.goToSupport),
                _buildNavItem(Icons.settings_outlined, 'Settings', false, controller.goToSettings),

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
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true, () => Get.back()),
                _buildNavItem(Icons.people_outline, 'Users', false, () {
                  Get.back();
                  controller.goToUsers();
                }),
                _buildNavItem(Icons.home_work_outlined, 'Properties', false, () {
                  Get.back();
                  controller.goToProperties();
                }),
                _buildNavItem(Icons.pending_actions, 'Pending Approvals', false, () {
                  Get.back();
                  controller.goToPendingApprovals();
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
        leading: Icon(icon, color: isActive ? AppColors.admin : AppTheme.textSecondary),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.admin : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.admin.withOpacity(0.1),
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
          // Admin Welcome Section
          _buildAdminWelcomeSection(),

          SizedBox(height: AppTheme.spacingXl),

          // System Statistics
          _buildSystemStats(),

          SizedBox(height: AppTheme.spacingXl),

          // Admin Quick Actions
          _buildAdminQuickActions(),

          SizedBox(height: AppTheme.spacingXl),

          // Pending Approvals & Recent Users
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPendingApprovals()),
              if (Get.width > 768) SizedBox(width: AppTheme.spacingLg),
              if (Get.width > 768) Expanded(child: _buildRecentUsers()),
            ],
          ),

          if (Get.width <= 768) ...[
            SizedBox(height: AppTheme.spacingXl),
            _buildRecentUsers(),
          ],

          SizedBox(height: AppTheme.spacingXl),

          // System Activities
          _buildSystemActivities(),
        ],
      ),
    );
  }

  Widget _buildAdminWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.admin, Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Control Center', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                SizedBox(height: AppTheme.spacingSm),
                Text('System Overview', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: AppTheme.spacingMd),
                Text('Monitor platform health, manage users, and oversee all system operations.',
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
              child: Icon(Icons.admin_panel_settings, size: 60, color: Colors.white.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Statistics', style: AppTextStyles.cardTitle),
        SizedBox(height: AppTheme.spacingMd),

        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: Get.width > 768 ? 6 : 3,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: Get.width > 768 ? 1.2 : 1,
          children: [
            Obx(() => _buildStatCard('Total Users', controller.totalUsers.value.toString(), Icons.people, AppColors.info)),
            Obx(() => _buildStatCard('Properties', controller.totalProperties.value.toString(), Icons.home, AppColors.landlord)),
            Obx(() => _buildStatCard('Pending', controller.pendingApprovals.value.toString(), Icons.pending, AppColors.warning)),
            Obx(() => _buildStatCard('Agents', controller.activeAgents.value.toString(), Icons.business_center, AppColors.agent)),
            Obx(() => _buildStatCard('Tenants', controller.totalTenants.value.toString(), Icons.person, AppColors.tenant)),
            Obx(() => _buildStatCard('Landlords', controller.totalLandlords.value.toString(), Icons.account_balance, AppColors.landlord)),
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

  Widget _buildAdminQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admin Actions', style: AppTextStyles.cardTitle),
        SizedBox(height: AppTheme.spacingMd),

        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: Get.width > 768 ? 4 : 2,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard('Manage Users', Icons.people, AppColors.info, controller.goToUsers),
            _buildActionCard('Review Properties', Icons.home_work, AppColors.landlord, controller.goToProperties),
            _buildActionCard('Pending Approvals', Icons.pending_actions, AppColors.warning, controller.goToPendingApprovals),
            _buildActionCard('System Reports', Icons.analytics, AppColors.success, controller.goToReports),
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
        decoration: AppDecorations.cardDecoration.copyWith(
          border: Border.all(color: color.withOpacity(0.2)),
        ),
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
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending Property Approvals', style: AppTextStyles.cardTitle),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${controller.pendingApprovals.value}',
                      style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ),

          Obx(() => controller.pendingProperties.isEmpty
              ? Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                  SizedBox(height: AppTheme.spacingMd),
                  Text('All caught up!', style: AppTextStyles.bodyText),
                  Text('No pending approvals', style: AppTextStyles.caption),
                ],
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.pendingProperties.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final property = controller.pendingProperties[index];
              return _buildPendingPropertyTile(property);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildPendingPropertyTile(AdminPropertyModel property) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Agent: ${property.agent}', style: AppTextStyles.caption),
                    Text('Location: ${property.location}', style: AppTextStyles.caption),
                    Text('Price: ${property.price}', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(property.submittedAt, style: AppTextStyles.caption),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => controller.approveProperty(property.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          minimumSize: Size(60, 32),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text('Approve', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => controller.rejectProperty(property.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          minimumSize: Size(60, 32),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text('Reject', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Users', style: AppTextStyles.cardTitle),
                TextButton(
                  onPressed: controller.goToUsers,
                  child: Text('View All', style: TextStyle(color: AppColors.admin)),
                ),
              ],
            ),
          ),

          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.recentUsers.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final user = controller.recentUsers[index];
              return _buildRecentUserTile(user);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildRecentUserTile(AdminUserModel user) {
    Color roleColor = user.role == 'tenant' ? AppColors.tenant
        : user.role == 'agent' ? AppColors.agent
        : AppColors.landlord;

    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: roleColor.withOpacity(0.1),
            child: Text(user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    if (user.isVerified)
                      Icon(Icons.verified, size: 16, color: AppColors.success),
                  ],
                ),
                Text(user.email, style: AppTextStyles.caption),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(user.role.toUpperCase(),
                          style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 8),
                    Text('• ${user.joinedAt}', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'verify':
                  controller.verifyUser(user.id);
                  break;
                case 'suspend':
                  controller.suspendUser(user.id);
                  break;
                case 'view':
                // Navigate to user details
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!user.isVerified)
                PopupMenuItem(
                  value: 'verify',
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 16, color: AppColors.success),
                      SizedBox(width: 8),
                      Text('Verify User'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: AppColors.info),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Suspend User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemActivities() {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('System Activities', style: AppTextStyles.cardTitle),
                TextButton(
                  onPressed: () => Get.toNamed('/admin/activities'),
                  child: Text('View All', style: TextStyle(color: AppColors.admin)),
                ),
              ],
            ),
          ),

          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.systemActivities.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = controller.systemActivities[index];
              return _buildActivityTile(activity);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildActivityTile(AdminActivityModel activity) {
    Color severityColor = activity.severity == 'success' ? AppColors.success
        : activity.severity == 'warning' ? AppColors.warning
        : activity.severity == 'error' ? AppColors.error
        : AppColors.info;

    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(activity.icon, color: severityColor, size: 20),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.description, style: AppTextStyles.bodyText),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(activity.type.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 8),
                    Text('• ${activity.timestamp}', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}