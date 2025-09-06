// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Import your pages
import 'Controllers/AuthContoller.dart';
import 'Pages/Admin Directory/AdminDashBoard.dart';
import 'Pages/Agent/AddProperty.dart';
import 'Pages/Agent/AgentDashBoard.dart';
import 'Pages/Agent/ManageProperties.dart';
import 'Pages/Authentication Directory/LoginPage.dart';
import 'Pages/Authentication Directory/RegisterPage.dart';
import 'Pages/LandLord Directory/LandLordDashBoard.dart';
import 'Pages/Landing Page/AboutPage.dart';
import 'Pages/Landing Page/LandingPage.dart';
import 'Pages/Landing Page/ServicesPage.dart';
import 'Pages/Landing Page/TestimonialPages.dart';
import 'Pages/Tenant/BrowseProperties.dart';
import 'Pages/Tenant/FavoritePages.dart';
import 'Pages/Tenant/PropertyDetails.dart';
import 'Pages/Tenant/TenantDashboard.dart';
import 'Services/AuthService.dart';
import 'Services/SupaBaseService.dart';
import 'Services/PropertyService.dart';
import 'Services/ImageUploadService.dart';
import 'Themes/AppTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove # from URLs in web
  usePathUrlStrategy();

  // Initialize services
  await initServices();

  runApp(SmartHouseApp());
}

/// Initialize all services before app starts
Future<void> initServices() async {
  print('Starting services ...');

  // Initialize Supabase first
  await Get.putAsync(() => SupabaseService().init());

  // Initialize Auth Service
  await Get.putAsync(() => AuthService().init());

  // Initialize Property Service
  await Get.putAsync(() => PropertyService().init());

  // Initialize Image Upload Service
  await Get.putAsync(() => ImageUploadService().init());

  // Initialize Auth Controller as permanent service
  Get.put(AuthController(), permanent: true);

  print('All services started successfully');
}

class SmartHouseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart House Discovery',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Initial Route
      initialRoute: AppRoutes.landing,

      // Route Configuration
      getPages: AppRoutes.pages,

      // Unknown Route (404 Page)
      unknownRoute: GetPage(
        name: '/404',
        page: () => NotFoundPage(),
      ),

      // Default Transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),

      // Localization (if needed)
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
    );
  }
}

/// App Routes Configuration
class AppRoutes {
  // Public Routes
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/verify-otp';

  // New Pages Routes
  static const String services = '/services';
  static const String about = '/about';
  static const String testimonials = '/testimonials';

  // Tenant Routes
  static const String tenantDashboard = '/tenant/dashboard';
  static const String browseProperties = '/tenant/browse';
  static const String propertyDetails = '/tenant/property/:id';
  static const String favorites = '/tenant/favorites';
  static const String tenantProfile = '/tenant/profile';

  // Agent Routes
  static const String agentDashboard = '/agent/dashboard';
  static const String agentProperties = '/agent/properties';
  static const String addProperty = '/agent/properties/add';
  static const String editProperty = '/agent/properties/edit/:id';
  static const String agentInquiries = '/agent/inquiries';
  static const String agentProfile = '/agent/profile';

  // Landlord Routes
  static const String landlordDashboard = '/landlord/dashboard';
  static const String landlordProperties = '/landlord/properties';
  static const String landlordAddProperty = '/landlord/properties/add';
  static const String landlordTenants = '/landlord/tenants';
  static const String landlordAgents = '/landlord/agents';
  static const String landlordReports = '/landlord/reports';
  static const String landlordProfile = '/landlord/profile';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminProperties = '/admin/properties';
  static const String adminPendingApprovals = '/admin/properties/pending';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminSupport = '/admin/support';

  /// All app pages
  static List<GetPage> pages = [
    // Public Pages
    GetPage(
      name: landing,
      page: () => LandingPage(),
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: register,
      page: () => RegisterPage(),
    ),

    // New Pages
    GetPage(
      name: services,
      page: () => ServicesPage(),
    ),
    GetPage(
      name: about,
      page: () => AboutPage(),
    ),
    GetPage(
      name: testimonials,
      page: () => TestimonialsPage(),
    ),

    // Tenant Routes - Protected
    GetPage(
      name: tenantDashboard,
      page: () => TenantDashboard(),
      middlewares: [AuthMiddleware(), RoleMiddleware('tenant')],
    ),
    GetPage(
      name: browseProperties,
      page: () => BrowsePropertiesPage(),
      middlewares: [AuthMiddleware(), RoleMiddleware('tenant')],
    ),
    GetPage(
      name: propertyDetails,
      page: () => PropertyDetailsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: favorites,
      page: () => FavoritesPage(),
      middlewares: [AuthMiddleware(), RoleMiddleware('tenant')],
    ),

    // Agent Routes - Protected
    GetPage(
      name: agentDashboard,
      page: () => AgentDashboard(),
      middlewares: [AuthMiddleware(), RoleMiddleware('agent')],
    ),
    GetPage(
      name: agentProperties,
      page: () => ManagePropertiesPage(),
      middlewares: [AuthMiddleware(), RoleMiddleware('agent')],
    ),
    GetPage(
      name: addProperty,
      page: () => AddPropertyPage(),
      middlewares: [AuthMiddleware(), RoleMiddleware('agent')],
    ),

    // Landlord Routes - Protected
    GetPage(
      name: landlordDashboard,
      page: () => LandlordDashboard(),
      middlewares: [AuthMiddleware(), RoleMiddleware('landlord')],
    ),
    GetPage(
      name: landlordAddProperty,
      page: () => AddPropertyPage(), // Same page for both agent and landlord
      middlewares: [AuthMiddleware(), RoleMiddleware('landlord')],
    ),

    // Admin Routes - Protected
    GetPage(
      name: adminDashboard,
      page: () => AdminDashboard(),
      middlewares: [AuthMiddleware(), RoleMiddleware('admin')],
    ),
  ];
}
/// Authentication Middleware - Protects routes
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated.value) {
      return RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}

/// Role-based Middleware - Protects routes by user role
class RoleMiddleware extends GetMiddleware {
  final String requiredRole;

  RoleMiddleware(this.requiredRole);

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated.value) {
      return RouteSettings(name: AppRoutes.login);
    }

    // Fix: Compare string role values, not enum
    final userRole = authController.currentUser.value?.role.toString().split('.').last;

    if (userRole != requiredRole) {
      // Redirect to appropriate dashboard based on their role
      switch (userRole) {
        case 'tenant':
          return RouteSettings(name: AppRoutes.tenantDashboard);
        case 'agent':
          return RouteSettings(name: AppRoutes.agentDashboard);
        case 'landlord':
          return RouteSettings(name: AppRoutes.landlordDashboard);
        case 'admin':
          return RouteSettings(name: AppRoutes.adminDashboard);
        default:
          return RouteSettings(name: AppRoutes.login);
      }
    }

    return null;
  }
}

/// 404 Not Found Page
class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              '404',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.landing),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Go Home',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}