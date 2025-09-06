import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Themes/AppTheme.dart';

class TestimonialsPage extends StatefulWidget {
  @override
  _TestimonialsPageState createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<TestimonialsPage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Testimonial> testimonials = [
    Testimonial(
      name: 'Guy Hawkins',
      role: '@guyhawkins',
      content: 'Impressed by the professionalism and attention to detail.',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
    ),
    Testimonial(
      name: 'Karla Lynn',
      role: '@karlalynn8',
      content: 'A seamless experience from start to finish. Highly recommend!',
      avatar: 'https://images.unsplash.com/photo-1494790108755-2616c6710a45?auto=format&fit=crop&w=100&q=80',
    ),
    Testimonial(
      name: 'Jane Cooper',
      role: '@janecooper',
      content: 'Reliable and trustworthy. Made my life so much easier!',
      avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80',
    ),
    Testimonial(
      name: 'David Johnson',
      role: '@davidjohnson',
      content: 'Outstanding service with excellent customer support throughout the entire process.',
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=100&q=80',
    ),
    Testimonial(
      name: 'Sarah Williams',
      role: '@sarahwilliams',
      content: 'Found my dream home within weeks. The platform is incredibly user-friendly.',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80',
    ),
    Testimonial(
      name: 'Michael Brown',
      role: '@michaelbrown',
      content: 'As an agent, this platform has transformed how I connect with clients.',
      avatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=100&q=80',
    ),
  ];

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
          'Testimonials',
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
            _buildTestimonialsSection(),
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
            'What Our Clients Say',
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
              'Real stories from real people who found their perfect homes through Smart House.',
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

  Widget _buildTestimonialsSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Testimonial',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Transformative Client Experiences',
            style: TextStyle(
              fontSize: Get.width > 768 ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 60),

          // Testimonials Carousel for Mobile
          if (Get.width <= 768) ...[
            Container(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: testimonials.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTestimonialCard(testimonials[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            _buildCarouselIndicators(),
          ],

          // Testimonials Grid for Desktop
          if (Get.width > 768) ...[
            Container(
              width: 1000,
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.8,
                children: testimonials.take(3).map((testimonial) => _buildTestimonialCard(testimonial)).toList(),
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: 800,
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.8,
                children: testimonials.skip(3).take(3).map((testimonial) => _buildTestimonialCard(testimonial)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Testimonial testimonial) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '"',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Testimonial Content
          Expanded(
            child: Text(
              testimonial.content,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 20),

          // User Info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: NetworkImage(testimonial.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      testimonial.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: testimonials.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              entry.key,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            width: _currentIndex == entry.key ? 24 : 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _currentIndex == entry.key
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
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
            'Join Our Happy Customers',
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
              'Experience the same exceptional service that has made our clients so satisfied.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 32),
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
              'Start Your Journey Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class Testimonial {
  final String name;
  final String role;
  final String content;
  final String avatar;

  Testimonial({
    required this.name,
    required this.role,
    required this.content,
    required this.avatar,
  });
}