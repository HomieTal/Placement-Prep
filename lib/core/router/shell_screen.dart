import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_builder.dart';

class ShellScreen extends ConsumerStatefulWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;

  final _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/dashboard'},
    {'icon': Icons.school, 'label': 'Preparation', 'route': '/preparation'},
    {'icon': Icons.quiz, 'label': 'Mock Tests', 'route': '/mock-tests'},
    {'icon': Icons.code, 'label': 'Coding', 'route': '/coding'},
    {'icon': Icons.analytics, 'label': 'Analytics', 'route': '/analytics'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    // Update current index based on route
    for (int i = 0; i < _navItems.length; i++) {
      if (currentRoute.startsWith(_navItems[i]['route'] as String)) {
        _currentIndex = i;
        break;
      }
    }

    // Don't show bottom nav on desktop
    if (ResponsiveBuilder.isDesktop(context)) {
      return widget.child;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.go(_navItems[index]['route'] as String);
        },
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item['icon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}

