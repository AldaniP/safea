import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/profile_service.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<Map<String, dynamic>> _navItems = [
    {'icon': LucideIcons.home, 'label': 'Beranda', 'href': '/'},
    {'icon': LucideIcons.clipboardList, 'label': 'Asesmen', 'href': '/dass21'},
    {'icon': LucideIcons.activity, 'label': 'Analisis AI', 'href': '/analysis'},
    {'icon': LucideIcons.heart, 'label': 'Pendampingan', 'href': '/companion'},
    {'icon': LucideIcons.wind, 'label': 'Tenang Dulu', 'href': '/calm'},
    {'icon': LucideIcons.sparkles, 'label': 'Relaksasi', 'href': '/relaxation'},
    {'icon': LucideIcons.shield, 'label': 'Keamanan', 'href': '/safety'},
    {'icon': LucideIcons.barChart, 'label': 'Progres', 'href': '/progress'},
    {
      'icon': LucideIcons.stethoscope,
      'label': 'Konsultasi',
      'href': '/consultation',
    },
    {
      'icon': LucideIcons.briefcase,
      'label': 'For Business',
      'href': '/business',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final currentLocation = GoRouterState.of(context).uri.path;
        final profile = context.read<ProfileService>().getProfile();

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(context, currentLocation, profile),
                Expanded(child: widget.child),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(
                  LucideIcons.heart,
                  color: Color(0xFF14B8A6),
                ), // teal-500
                const SizedBox(width: 8),
                const Text(
                  'Safea',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.userCircle),
                onPressed: () => context.go('/account'),
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: _navItems.map((item) {
                        final isActive = currentLocation == item['href'];
                        return ListTile(
                          leading: Icon(
                            item['icon'] as IconData,
                            color: isActive
                                ? const Color(0xFF2DD4BF)
                                : Colors.grey,
                          ),
                          title: Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF2DD4BF)
                                  : Colors.grey,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          tileColor: isActive
                              ? const Color(0xFF2DD4BF).withValues(alpha: 0.1)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            context.go(item['href'] as String);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(LucideIcons.userCircle),
                    title: Text(profile['name'] as String),
                    subtitle: const Text('Personal Plan'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/account');
                    },
                  ),
                ],
              ),
            ),
          ),
          body: widget.child,
        );
      },
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    String currentLocation,
    Map<String, dynamic> profile,
  ) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.heart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Safea',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _navItems.map((item) {
                final isActive = currentLocation == item['href'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: InkWell(
                    onTap: () => context.go(item['href'] as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: InkWell(
              onTap: () => context.go('/account'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.userCircle,
                      size: 24,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Personal Plan',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
