import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/assessment/dass21_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const SafeaAppDemo());
}

// Global notifier for ThemeMode so we can toggle it from anywhere easily
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class SafeaAppDemo extends StatelessWidget {
  const SafeaAppDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        // Adjust status bar style based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: currentMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Safea',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // LIGHT THEME (Lebih tenang, tidak terlalu terang)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF4A6572), // Muted, calm teal-navy
              primary: const Color(0xFF4A6572),
              secondary: const Color(0xFF88A0A8),
              surface: const Color(0xFFE8ECEB), // Muted off-white
              onSurface: const Color(0xFF2C3E50), // Soft dark text
            ),
            fontFamily: 'Inter',
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              headlineSmall: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
              bodyLarge: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF37474F),
              ),
              bodyMedium: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF546E7A),
              ),
            ),
          ),

          // DARK THEME (Gelap dan aman)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF88A0A8),
              primary: const Color(0xFF88A0A8), // Lighter teal for dark mode
              secondary: const Color(0xFF4A6572),
              surface: const Color(0xFF1E262C),
              onSurface: const Color(0xFFECEFF1),
            ),
            fontFamily: 'Inter',
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Color(0xFFECEFF1),
              ),
              headlineSmall: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: Color(0xFFECEFF1),
              ),
              bodyLarge: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFFCFD8DC),
              ),
              bodyMedium: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFFB0BEC5),
              ),
            ),
          ),
          home: const ResponsiveLayout(),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Helper: Glassmorphism Card
// -----------------------------------------------------------------------------
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? customColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 24.0,
    this.onTap,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        customColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.4));
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.5);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.2)
        : const Color(0xFF4A6572).withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: baseColor,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            splashColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Responsive Architecture
// -----------------------------------------------------------------------------
class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DashboardScreen(), // <--- NEW TAB
    TenangDuluScreen(),
    ChatScreen(),
    VaultScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Safea',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // Quick Exit
              },
              icon: const Icon(Icons.close_rounded, size: 20),
              label: const Text(
                'Keluar Cepat',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF37474F)
                    : const Color(0xFFCFD8DC),
                foregroundColor: isDark
                    ? const Color(0xFFECEFF1)
                    : const Color(0xFF37474F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Calm Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF171F24), // Very dark slate
                          Color(0xFF1E2226), // Dark neutral
                          Color(0xFF1B1A22), // Very dark plum
                        ]
                      : const [
                          Color(0xFFD3E0E2), // Muted teal-grey
                          Color(0xFFE4E9E8), // Soft grey-green
                          Color(0xFFD6D1DC), // Muted mauve
                        ],
                ),
              ),
            ),
          ),
          // Subtle background decorative circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF2C3E50).withValues(alpha: 0.2)
                    : const Color(0xFFB0C4DE).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF311B3B).withValues(alpha: 0.2)
                    : const Color(0xFFC8BBD4).withValues(alpha: 0.2),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            bottom: false,
            child: isDesktop
                ? Row(
                    children: [
                      _buildNavigationRail(isDark),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _screens[_selectedIndex],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _screens[_selectedIndex],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(isDark),
    );
  }

  Widget _buildNavigationRail(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationRail(
            backgroundColor: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.3),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            unselectedIconTheme: IconThemeData(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            indicatorColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: Text('Tenang'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: Text('Chat AI'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.lock_outline_rounded),
                selectedIcon: Icon(Icons.lock_rounded),
                label: Text('Brankas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: isDark ? Colors.white54 : Colors.black45,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Tenang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat AI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lock_outline_rounded),
                activeIcon: Icon(Icons.lock_rounded),
                label: 'Brankas',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Landing & Instant Safety Check (Home)
// -----------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'safea_icon',
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Aku di sini.\nKamu aman sekarang.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tarik napas perlahan. Kami siap mendampingimu kapan pun kamu siap.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),

                // AI Emotional Analysis Button (NEW)
                GlassCard(
                  onTap: () {
                    // Navigate to the AI Assessment
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Dass21Screen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFFD0E0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1D4ED8),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Analysis',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mulai asesmen dan analisis emosi',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Stabilization Button
                GlassCard(
                  onTap: () {
                    final parentState = context
                        .findAncestorStateOfType<_ResponsiveLayoutState>();
                    if (parentState != null) {
                      parentState._onItemTapped(1);
                    }
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF263238)
                              : const Color(0xFFC0D3D9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: isDark
                              ? const Color(0xFFB0BEC5)
                              : const Color(0xFF37474F),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tenang Dulu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latihan pernapasan & grounding',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Crisis Routing Button
                GlassCard(
                  onTap: () {
                    final parentState = context
                        .findAncestorStateOfType<_ResponsiveLayoutState>();
                    if (parentState != null) {
                      parentState._onItemTapped(3);
                    }
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF312844)
                              : const Color(0xFFD6CFE6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          color: isDark
                              ? const Color(0xFFD1C4E9)
                              : const Color(0xFF4527A0),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Butuh Bantuan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kontak darurat & simpan bukti',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 3. "Tenang Dulu" (Stabilization Mode)
// -----------------------------------------------------------------------------
enum BreathingMode { tenang, fokus }

class TenangDuluScreen extends StatefulWidget {
  const TenangDuluScreen({super.key});

  @override
  State<TenangDuluScreen> createState() => _TenangDuluScreenState();
}

class _TenangDuluScreenState extends State<TenangDuluScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  BreathingMode _currentMode = BreathingMode.tenang;
  String _breathingText = 'Tarik napas...';

  int _currentGroundingStep = 0;
  bool _showGroundingInfo = false;
  final List<Map<String, dynamic>> _groundingSteps = [
    {
      'icon': Icons.visibility_rounded,
      'text':
          'Sebutkan dalam hati 5 benda di sekitarmu yang berwarna biru atau yang menarik perhatianmu.',
    },
    {
      'icon': Icons.touch_app_rounded,
      'text':
          'Rasakan 4 benda di sekitarmu yang bisa kamu sentuh. Bagaimana teksturnya?',
    },
    {
      'icon': Icons.hearing_rounded,
      'text':
          'Dengarkan perlahan, sebutkan 3 suara berbeda yang bisa kamu dengar saat ini.',
    },
    {
      'icon': Icons.spa_rounded,
      'text':
          'Tarik napas perlahan, coba kenali 2 aroma yang bisa kamu cium baunya.',
    },
    {
      'icon': Icons.restaurant_rounded,
      'text':
          'Sebutkan 1 hal yang bisa kamu rasakan (kecap) di mulutmu saat ini.',
    },
  ];

  bool _isAmbientAudioOn = false;

  @override
  void initState() {
    super.initState();
    _setupBreathingAnimation();
  }

  void _setupBreathingAnimation() {
    if (_currentMode == BreathingMode.tenang) {
      _breathingController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      );
      _breathingAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.8,
            end: 1.2,
          ).chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 4,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.2,
            end: 0.8,
          ).chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 6,
        ),
      ]).animate(_breathingController);

      _breathingController.addListener(() {
        final val = _breathingController.value;
        String newText;
        if (val < 4 / 10) {
          newText = 'Tarik napas...';
        } else {
          newText = 'Hembuskan perlahan...';
        }
        if (_breathingText != newText) {
          setState(() => _breathingText = newText);
        }
      });
    } else {
      _breathingController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 16),
      );
      _breathingAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.8,
            end: 1.2,
          ).chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 4,
        ),
        TweenSequenceItem(tween: ConstantTween<double>(1.2), weight: 4),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.2,
            end: 0.8,
          ).chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 4,
        ),
        TweenSequenceItem(tween: ConstantTween<double>(0.8), weight: 4),
      ]).animate(_breathingController);

      _breathingController.addListener(() {
        final val = _breathingController.value;
        String newText;
        if (val < 4 / 16) {
          newText = 'Tarik napas...';
        } else if (val < 8 / 16) {
          newText = 'Tahan...';
        } else if (val < 12 / 16) {
          newText = 'Hembuskan perlahan...';
        } else {
          newText = 'Tahan...';
        }
        if (_breathingText != newText) {
          setState(() => _breathingText = newText);
        }
      });
    }
    _breathingController.repeat();
  }

  void _changeBreathingMode(BreathingMode mode) {
    if (_currentMode == mode) return;
    setState(() {
      _currentMode = mode;
      _breathingController.dispose();
      _setupBreathingAnimation();
    });
  }

  void _nextGroundingStep() {
    if (_currentGroundingStep < _groundingSteps.length - 1) {
      setState(() {
        _currentGroundingStep++;
      });
    } else {
      // Loop back to start
      setState(() {
        _currentGroundingStep = 0;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Section: Ambient Audio & Validation Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        'Ini bukan salahmu.',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: isDark
                                  ? const Color(0xFFD1C4E9)
                                  : const Color(0xFF5E35B1),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _isAmbientAudioOn
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                tooltip: 'Suara Latar (Ambient Audio)',
                onPressed: () {
                  setState(() {
                    _isAmbientAudioOn = !_isAmbientAudioOn;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isAmbientAudioOn
                            ? 'Suara latar diaktifkan'
                            : 'Suara latar dimatikan',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Breathing Exercise (Glowing & Morphing)
          SizedBox(
            height: 260,
            child: Center(
              child: AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  // To make it look more fluid, we modulate border radius
                  // based on animation value to create a slightly morphing shape
                  var morphVal = _breathingAnimation.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      Container(
                        width: 220 * morphVal,
                        height: 220 * morphVal,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (isDark
                                      ? const Color(0xFF88A0A8)
                                      : const Color(0xFFA8C0C8))
                                  .withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isDark
                                          ? const Color(0xFF88A0A8)
                                          : const Color(0xFFA8C0C8))
                                      .withValues(alpha: 0.3),
                              blurRadius: 40 * morphVal,
                              spreadRadius: 10 * morphVal,
                            ),
                          ],
                        ),
                      ),
                      // Inner Shape
                      Container(
                        width: 140 * morphVal,
                        height: 140 * morphVal,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF263238).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9),
                          border: Border.all(
                            color: const Color(
                              0xFF88A0A8,
                            ).withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            child: Text(
                              _breathingText,
                              key: ValueKey<String>(_breathingText),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Breathing Mode Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModePill(
                'Tenang',
                '4-6',
                'Menenangkan saraf & fisik',
                BreathingMode.tenang,
                isDark,
                primaryColor,
              ),
              const SizedBox(width: 12),
              _buildModePill(
                'Fokus',
                'Box',
                'Menjernihkan pikiran & mental',
                BreathingMode.fokus,
                isDark,
                primaryColor,
              ),
            ],
          ),

          const SizedBox(height: 56),

          // Grounding Technique Focus Card Carousel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Teknik Grounding 5-4-3-2-1',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _showGroundingInfo = !_showGroundingInfo;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _showGroundingInfo ? Icons.info : Icons.info_outline,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Teknik ini membantumu kembali ke momen saat ini dengan mengalihkan fokus dari kepanikan ke sekitarmu menggunakan 5 indera secara berurutan. Ikuti langkah di bawah ini perlahan-lahan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            crossFadeState: _showGroundingInfo
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 8),

          GlassCard(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey<int>(_currentGroundingStep),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _groundingSteps[_currentGroundingStep]['icon'],
                    size: 48,
                    color: primaryColor.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _groundingSteps[_currentGroundingStep]['text'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextGroundingStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        foregroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Sudah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_groundingSteps.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentGroundingStep == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentGroundingStep == index
                              ? primaryColor
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Emergency Fallback
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka rute darurat...')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.red[300] : Colors.red[700],
              ),
              child: const Text(
                'Masih merasa panik? Hubungi bantuan darurat.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModePill(
    String title,
    String subtitle,
    String description,
    BreathingMode mode,
    bool isDark,
    Color primaryColor,
  ) {
    final isSelected = _currentMode == mode;
    return InkWell(
      onTap: () => _changeBreathingMode(mode),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 160),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isDark ? Colors.white12 : Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.transparent,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Conversational AI Companion
// -----------------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Halo, aku Safea. Kamu aman bersamaku. Apa yang ingin kamu bagikan hari ini?',
    },
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _textController.clear();
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'isUser': false,
              'text':
                  'Aku mendengarmu. Pelan-pelan saja. Bernapaslah bersamaku jika kamu merasa cemas.',
            });
            _scrollToBottom();
          });
        }
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message['isUser'] as bool;
              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary
                        : (isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                      bottomLeft: !isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : (isDark ? Colors.white12 : Colors.white),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isUser ? 0.1 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Quick Reply Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              _buildQuickReplyChip('Aku bingung harus apa', isDark),
              const SizedBox(width: 8),
              _buildQuickReplyChip('Tolong temani aku', isDark),
              const SizedBox(width: 8),
              _buildQuickReplyChip('Aku merasa panik', isDark),
            ],
          ),
        ),

        // Chat Input Area (Glassmorphism)
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.5),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.white,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesanmu...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice Note feature coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: isDark ? const Color(0xFF1E262C) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReplyChip(String text, bool isDark) {
    return ActionChip(
      label: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onPressed: () => _sendMessage(text),
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.white.withValues(alpha: 0.8),
        ),
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }
}

// -----------------------------------------------------------------------------
// 5. Brankas Bukti (Evidence Vault) & Crisis Routing
// -----------------------------------------------------------------------------
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isUnlocked = false;
  final TextEditingController _pinController = TextEditingController();

  void _unlockVault() {
    if (_pinController.text == '1234') {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN Salah (Gunakan 1234)'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isUnlocked) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: GlassCard(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF312844)
                        : const Color(0xFFE8EAF6),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 48,
                    color: isDark
                        ? const Color(0xFFD1C4E9)
                        : const Color(0xFF5E35B1),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Brankas Rahasia',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan PIN untuk membuka',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    letterSpacing: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: TextStyle(
                      letterSpacing: 16,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _unlockVault,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF7E57C2)
                        : const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buka Brankas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Vault Dashboard & Crisis Routing
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Brankas Bukti',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua data di sini tersimpan aman dan terenkripsi secara lokal di perangkatmu.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit_document,
                  title: 'Catat\nKronologi',
                  color: isDark
                      ? const Color(0xFF263238)
                      : const Color(0xFFE8F0F2),
                  iconColor: isDark
                      ? const Color(0xFFB0BEC5)
                      : const Color(0xFF4A6572),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.mic_rounded,
                  title: 'Rekam\nSuara',
                  color: isDark
                      ? const Color(0xFF312844)
                      : const Color(0xFFF3E5F5),
                  iconColor: isDark
                      ? const Color(0xFFD1C4E9)
                      : const Color(0xFF5E35B1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          const Text(
            'Butuh Bantuan Segera?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildQuickDialButton(
            title: 'Hubungi SAPA 129',
            subtitle: 'Layanan Sahabat Perempuan dan Anak',
            icon: Icons.support_agent_rounded,
            color: isDark ? const Color(0xFF4A1A1A) : const Color(0xFFFDE8E8),
            textColor: isDark
                ? const Color(0xFFEF9A9A)
                : const Color(0xFFC62828),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildQuickDialButton(
            title: 'Panduan Hukum Dasar',
            subtitle: 'Ketahui hak-hakmu',
            icon: Icons.gavel_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.5),
            textColor: isDark ? Colors.white70 : Colors.black87,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDialButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: textColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
