import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/LandingPageController.dart';


class LandingPage extends StatelessWidget {
  final LandingController controller = Get.put(LandingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            // Hero Section
            _buildHeroSection(),
            // Features Section
            _buildFeaturesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Top Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Call: (+234) 813-456-7890',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    SizedBox(width: 24),
                    Icon(Icons.email, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Email: info@smarthouse.com',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: controller.goToLogin,
                      child: Text('Login', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    Text('|', style: TextStyle(color: Colors.grey.shade400)),
                    TextButton(
                      onPressed: controller.goToRegister,
                      child: Text('Register', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Navigation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('S', style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Smart House', style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    )),
                  ],
                ),

                // Navigation Links (Desktop)
                if (Get.width > 768)
                  Row(
                    children: [
                      _navLink('Home'),
                      _navLink('Services'),
                      _navLink('About'),
                      _navLink('Testimonial'),
                    ],
                  ),

                // Get Started Button
                ElevatedButton(
                  onPressed: controller.goToRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Get Started', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {
          switch (text.toLowerCase()) {
            case 'services':
              Get.toNamed('/services');
              break;
            case 'about':
              Get.toNamed('/about');
              break;
            case 'testimonial':
              Get.toNamed('/testimonials');
              break;
            case 'home':
            // Already on home page, scroll to top or do nothing
              break;
            default:
              break;
          }
        },
        child: Text(text, style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 16,
        )),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: Get.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF06B6D4),
          ],
        ),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1920&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Badge - CORRECTED VERSION
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'WELCOME TO SMART HOUSE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // Main Heading
            Text(
              'Find Your Perfect\nDream Home',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: Get.width > 768 ? 64 : 40,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),

            SizedBox(height: 24),

            // Subtitle
            Container(
              width: Get.width > 768 ? 600 : Get.width * 0.9,
              child: Text(
                'Discover verified properties with our secure platform connecting tenants, agents, and landlords. Your trusted partner in finding the perfect home.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
            ),

            SizedBox(height: 38),

            // CTA Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.goToRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('View Properties',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Contact Now',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),

            SizedBox(height: 34),

            _buildSearchCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      width: Get.width > 768 ? 800 : Get.width * 0.9,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Filters Row
          Get.width > 768 ? _buildDesktopSearchRow() : _buildMobileSearchColumn(),

          SizedBox(height: 16),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isSearching.value ? null : controller.onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isSearching.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Search Properties',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSearchRow() {
    return Row(
      children: [
        // Keywords
        Expanded(
          child: _buildSearchField(
            'Enter keywords',
            controller.searchKeywords,
            Icons.search,
          ),
        ),
        SizedBox(width: 12),

        // Type Dropdown
        Expanded(
          child: _buildDropdown(
            controller.selectedType,
            ['rent', 'sale'],
            ['For Rent', 'For Sale'],
          ),
        ),
        SizedBox(width: 12),

        // Property Type
        Expanded(
          child: _buildDropdown(
            controller.selectedPropertyType,
            ['apartment', 'house', 'duplex', 'studio'],
            ['Apartment', 'House', 'Duplex', 'Studio'],
          ),
        ),
        SizedBox(width: 12),

        // Location
        Expanded(
          child: _buildSearchField(
            'Location',
            controller.selectedLocation,
            Icons.location_on,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSearchColumn() {
    return Column(
      children: [
        _buildSearchField('Enter keywords', controller.searchKeywords, Icons.search),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                controller.selectedType,
                ['rent', 'sale'],
                ['For Rent', 'For Sale'],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                controller.selectedPropertyType,
                ['apartment', 'house', 'duplex', 'studio'],
                ['Apartment', 'House', 'Duplex', 'Studio'],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildSearchField('Location', controller.selectedLocation, Icons.location_on),
      ],
    );
  }

  Widget _buildSearchField(String hint, RxString controller, IconData icon) {
    return TextField(
      onChanged: (value) => controller.value = value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.orange),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown(RxString controller, List<String> values, List<String> labels) {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.value,
      onChanged: (value) => controller.value = value!,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.orange),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: values.asMap().entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.value,
          child: Text(labels[entry.key]),
        );
      }).toList(),
    ));
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          // Section Header
          Text(
            'Why Choose Smart House?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),

          // Fixed container with responsive width
          Container(
            width: Get.width > 768 ? 600 : Get.width * 0.9,
            child: Text(
              'Our platform provides a secure, efficient, and user-friendly experience for all your housing needs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ),

          SizedBox(height: 64),

          // Features Grid
          Container(
            width: Get.width > 768 ? 900 : Get.width * 0.9,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: Get.width > 768 ? 3 : 1,
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              childAspectRatio: Get.width > 768 ? 1.2 : 3,
              children: [
                _buildFeatureCard(
                  Icons.security,
                  'Secure & Verified',
                  'All properties and users are verified through our OTP-based authentication system for maximum security.',
                ),
                _buildFeatureCard(
                  Icons.search,
                  'Smart Search',
                  'Advanced filtering options help you find the perfect property that matches your specific requirements.',
                ),
                _buildFeatureCard(
                  Icons.star,
                  'Trusted Platform',
                  'Connect with verified agents, landlords, and find quality homes through our trusted network.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, color: Colors.orange, size: 32),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}