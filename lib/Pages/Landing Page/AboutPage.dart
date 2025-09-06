// Pages/About/AboutPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Themes/AppTheme.dart';

class AboutPage extends StatelessWidget {
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
          'About Us',
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
            _buildStorySection(),
            _buildMissionVisionSection(),
            _buildValuesSection(),
            _buildTeamSection(),
            _buildStatsSection(),
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
            'About Smart House',
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
              'Transforming the real estate experience through innovative technology and trusted partnerships.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Container(
        width: Get.width > 768 ? 1000 : double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Get.width > 768) ...[
              Expanded(
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 60),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Story',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Building the Future of Real Estate',
                    style: TextStyle(
                      fontSize: Get.width > 768 ? 36 : 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Founded in 2024, Smart House emerged from a simple vision: to make property discovery and real estate transactions as seamless and secure as possible. We recognized the challenges faced by tenants, agents, and landlords in the traditional real estate market.',
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Our platform bridges these gaps by providing a comprehensive, technology-driven solution that serves all stakeholders in the real estate ecosystem. From advanced search capabilities to secure transaction processing, we\'re committed to revolutionizing how people find and manage properties.',
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  if (Get.width <= 768) ...[
                    SizedBox(height: 32),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionVisionSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      color: Colors.grey.shade50,
      child: Container(
        width: Get.width > 768 ? 1000 : double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMissionVisionCard(
                'Our Mission',
                'To democratize access to quality housing by providing a transparent, secure, and efficient platform that connects property seekers with trusted real estate professionals.',
                Icons.flag,
              ),
            ),
            SizedBox(width: Get.width > 768 ? 40 : 0),
            if (Get.width > 768) ...[
              Expanded(
                child: _buildMissionVisionCard(
                  'Our Vision',
                  'To become the leading real estate technology platform in Nigeria and across Africa, transforming how people discover, evaluate, and secure their ideal properties.',
                  Icons.visibility,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMissionVisionCard(String title, String content, IconData icon) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 32),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            content,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Our Core Values',
            style: TextStyle(
              fontSize: Get.width > 768 ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: Get.width > 768 ? 600 : Get.width * 0.9,
            child: Text(
              'These principles guide every decision we make and every feature we build.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 60),
          Container(
            width: Get.width > 768 ? 1000 : double.infinity,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: Get.width > 768 ? 3 : 1,
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              childAspectRatio: Get.width > 768 ? 1 : 2,
              children: [
                _buildValueCard(
                  Icons.security,
                  'Security First',
                  'We prioritize the security and privacy of our users through advanced encryption and verification processes.',
                ),
                _buildValueCard(
                  Icons.people,
                  'Transparency',
                  'We believe in open and honest communication, providing clear information at every step of the process.',
                ),
                _buildValueCard(
                  Icons.speed,
                  'Innovation',
                  'We continuously evolve our platform with cutting-edge technology to improve user experience.',
                ),
                _buildValueCard(
                  Icons.support,
                  'Customer Focus',
                  'Our users are at the center of everything we do, driving our commitment to exceptional service.',
                ),
                _buildValueCard(
                  Icons.verified,
                  'Trust',
                  'We build trust through verified listings, authenticated users, and reliable service delivery.',
                ),
                _buildValueCard(
                  Icons.accessibility,
                  'Accessibility',
                  'We make quality housing accessible to everyone, regardless of their background or budget.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 32),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'Meet Our Team',
            style: TextStyle(
              fontSize: Get.width > 768 ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: Get.width > 768 ? 600 : Get.width * 0.9,
            child: Text(
              'Our diverse team of professionals is dedicated to transforming the real estate experience.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 60),
          Container(
            width: Get.width > 768 ? 800 : double.infinity,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: Get.width > 768 ? 3 : 1,
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              childAspectRatio: Get.width > 768 ? 0.8 : 1.5,
              children: [
                _buildTeamCard(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
                  'Mary Umeh',
                  'CEO & Founder',
                  'Leading Smart House with 10+ years in tech and real estate innovation.',
                ),
                _buildTeamCard(
                  'https://images.unsplash.com/photo-1494790108755-2616c6710a45?auto=format&fit=crop&w=200&q=80',
                  'Uche Abba',
                  'CTO',
                  'Architecting our platform with cutting-edge technology and security.',
                ),
                _buildTeamCard(
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
                  'Michael Jackson',
                  'Head of Operations',
                  'Ensuring smooth operations and exceptional user experiences.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String imageUrl, String name, String position, String description) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            position,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
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
            'Our Impact',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Get.width > 768 ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: Get.width > 768 ? 800 : double.infinity,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: Get.width > 768 ? 4 : 2,
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              childAspectRatio: 1,
              children: [
                _buildStatCard('1000+', 'Properties Listed'),
                _buildStatCard('500+', 'Happy Customers'),
                _buildStatCard('50+', 'Verified Agents'),
                _buildStatCard('98%', 'Satisfaction Rate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: Get.width > 768 ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}