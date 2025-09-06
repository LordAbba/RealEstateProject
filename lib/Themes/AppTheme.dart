// theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFFFF6B35); // Orange
  static const Color primaryLightColor = Color(0xFFFF8A65);
  static const Color primaryDarkColor = Color(0xFFE64100);

  static const Color secondaryColor = Color(0xFF4F46E5); // Purple/Blue
  static const Color secondaryLightColor = Color(0xFF7C3AED);
  static const Color secondaryDarkColor = Color(0xFF3730A3);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFF06B6D4)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 50.0;

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLightColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryLightColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: _buildTextTheme(),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textTertiary),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(radiusMd)),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: spacingMd,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryLightColor,
        labelStyle: TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryDarkColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryDarkColor,
        surface: Color(0xFF1F2937),
        background: Color(0xFF111827),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),

      textTheme: _buildTextTheme(isDark: true),

      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),

      cardTheme: CardThemeData(
        color: Color(0xFF374151),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }

  // Build Text Theme
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? Colors.white : textPrimary;
    final Color textColorSecondary = isDark ? Colors.grey.shade300 : textSecondary;

    return TextTheme(
      // Display Styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),

      // Headline Styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),

      // Title Styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.1,
      ),

      // Body Styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.25,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColorSecondary,
        letterSpacing: 0.4,
        height: 1.3,
      ),

      // Label Styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColorSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textColorSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

// Custom Theme Extensions
class AppColors {
  static const Color success = AppTheme.successColor;
  static const Color warning = AppTheme.warningColor;
  static const Color error = AppTheme.errorColor;
  static const Color info = AppTheme.infoColor;

  // Property Status Colors
  static const Color available = Color(0xFF10B981);
  static const Color rented = Color(0xFFF59E0B);
  static const Color pending = Color(0xFF3B82F6);
  static const Color unavailable = Color(0xFF6B7280);

  // User Role Colors
  static const Color tenant = Color(0xFF8B5CF6);
  static const Color agent = Color(0xFF06B6D4);
  static const Color landlord = Color(0xFF10B981);
  static const Color admin = Color(0xFFEF4444);
}

// Custom Decorations
class AppDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    boxShadow: AppTheme.shadowSm,
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    boxShadow: AppTheme.shadowMd,
  );

  static BoxDecoration get gradientDecoration => BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
  );
}

// Custom Text Styles
class AppTextStyles {
  static TextStyle get hero => TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.1,
  );

  static TextStyle get cardTitle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  static TextStyle get cardSubtitle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textSecondary,
  );

  // Add this missing bodyText style
  static TextStyle get bodyText => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textPrimary,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textTertiary,
  );
}