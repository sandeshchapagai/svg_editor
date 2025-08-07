import 'package:flutter/material.dart';

class AnimatedTabBar extends StatefulWidget {
  const AnimatedTabBar({super.key});

  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar>
    with TickerProviderStateMixin {
  int activeIndex = 0;
  late AnimationController _slideController;
  late AnimationController _iconController;
  late Animation<double> _slideAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;

  final List<TabItem> tabs = [
    TabItem(label: 'Individual', icon: Icons.person),
    TabItem(label: 'Group', icon: Icons.group),
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2, // 12 degrees in radians
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutBack,
    ));

    // Start with first tab active
    _iconController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != activeIndex) {
      setState(() {
        activeIndex = index;
      });

      // Animate slide
      _slideController.forward();

      // Animate icon with stagger
      _iconController.reset();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _iconController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding background
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    left: activeIndex == 0 ? 0 : 150,
                    top: 0,
                    bottom: 0,
                    width: activeIndex == 0 ? 180 : 200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Tab buttons
              Row(
                children: [
                  _buildTabButton(0, 120),
                  _buildTabButton(1, 180),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, double width) {
    final isActive = activeIndex == index;
    final tab = tabs[index];

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon - only show when active
            if (isActive) ...[
              AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _iconRotationAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          tab.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],

            // Text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: isActive ? 0.5 : 0,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

class TabItem {
  final String label;
  final IconData icon;

  TabItem({required this.label, required this.icon});
}
