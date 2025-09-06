import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Themes/AppTheme.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Our Services',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildServicesSection(),
            _buildCTASection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          Text(
            'Comprehensive Real Estate Services',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Get.width > 768 ? 42 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: Get.width > 768 ? 600 : Get.width * 0.9,
            child: Text(
              'From property discovery to secure transactions, we provide end-to-end solutions for all your real estate needs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          // For Tenants Section
          _buildServiceCategory(
            'For Tenants',
            'Find Your Perfect Home',
            [
              ServiceItem(
                Icons.search,
                'Property Search',
                'Advanced search filters to find properties that match your exact requirements and budget.',
              ),
              ServiceItem(
                Icons.verified_user,
                'Verified Listings',
                'All properties are verified by our team to ensure authenticity and accurate information.',
              ),
              ServiceItem(
                Icons.favorite,
                'Save Favorites',
                'Bookmark properties you love and get notified when similar ones become available.',
              ),
              ServiceItem(
                Icons.support_agent,
                '24/7 Support',
                'Get assistance anytime with our dedicated customer support team.',
              ),
            ],
          ),

          SizedBox(height: 80),

          // For Agents Section
          _buildServiceCategory(
            'For Agents',
            'Grow Your Business',
            [
              ServiceItem(
                Icons.add_business,
                'Property Management',
                'List and manage multiple properties with our comprehensive dashboard.',
              ),
              ServiceItem(
                Icons.analytics,
                'Analytics & Insights',
                'Track performance, views, and inquiries with detailed analytics.',
              ),
              ServiceItem(
                Icons.people,
                'Lead Generation',
                'Connect with potential clients and build your customer base.',
              ),
              ServiceItem(
                Icons.mobile_friendly,
                'Mobile Optimization',
                'Manage your business on the go with our mobile-optimized platform.',
              ),
            ],
          ),

          SizedBox(height: 80),

          // For Landlords Section
          _buildServiceCategory(
            'For Landlords',
            'Maximize Your Investment',
            [
              ServiceItem(
                Icons.home,
                'Property Listing',
                'List your properties with professional photos and detailed descriptions.',
              ),
              ServiceItem(
                Icons.person_search,
                'Tenant Screening',
                'Find reliable tenants through our verification and screening process.',
              ),
              ServiceItem(
                Icons.payment,
                'Rent Management',
                'Track rental payments and manage tenant communications efficiently.',
              ),
              ServiceItem(
                Icons.security,
                'Secure Transactions',
                'All transactions are secured with our advanced encryption technology.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategory(String category, String subtitle, List<ServiceItem> services) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // Category Header
          Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: Get.width > 768 ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 48),

          // Services Grid
          Container(
            width: Get.width > 768 ? 1000 : double.infinity,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: Get.width > 768 ? 2 : 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: Get.width > 768 ? 2.5 : 1.2,
              children: services.map((service) => _buildServiceCard(service)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              service.icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Get Started?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Get.width > 768 ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: Get.width > 768 ? 500 : double.infinity,
            child: Text(
              'Join thousands of satisfied users who have found their perfect homes through our platform.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Get.toNamed('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Get Started Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => Get.toNamed('/login'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white, width: 2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final IconData icon;
  final String title;
  final String description;

  ServiceItem(this.icon, this.title, this.description);
}