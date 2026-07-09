import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isVendorSelected = false; // default is customer (false)
  bool _hasSelectedRole = false; // check if they picked a role

  final List<OnboardItem> _items = [
    OnboardItem(
      title: 'Welcome to SingleMart',
      description: 'Your premium unified local marketplace connecting local buyers and sellers seamlessly in one beautiful platform.',
      icon: Icons.storefront_rounded,
      color: const Color(0xFF6C63FF),
      tag: 'MARKETPLACE',
    ),
    OnboardItem(
      title: 'Shop from Local Stores',
      description: 'Order groceries, fresh food, or daily essentials. Fast delivery, quality service, and direct support for neighborhood merchants.',
      icon: Icons.local_mall_rounded,
      color: const Color(0xFF6C63FF),
      tag: 'JOIN AS USER',
    ),
    OnboardItem(
      title: 'Grow Your Shop Business',
      description: 'List your items, manage incoming orders, track payouts, and reach thousands of local customers with powerful merchant tools.',
      icon: Icons.analytics_rounded,
      color: const Color(0xFF0D9488), // Clean Teal color for Light Theme Vendor
      tag: 'JOIN AS SELLER',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(isVendor: _isVendorSelected),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure white background
      body: SafeArea(
        child: Stack(
          children: [
            // Soft background ambient glows for light theme
            Positioned(
              top: -80,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_currentPage == 2
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF6C63FF))
                          .withOpacity(0.06),
                      blurRadius: 80,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            
            // Page contents
            Column(
              children: [
                // Top Skip Action Bar
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 24.0, bottom: 8.0),
                    child: _currentPage < 3
                        ? TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(isVendor: false),
                                ),
                              );
                            },
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Color(0xFF64748B), // Slate grey
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox(height: 48), // Keep layout height stable
                  ),
                ),
                
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: 4, // 3 onboarding slides + 1 role selector
                    itemBuilder: (context, index) {
                      if (index < 3) {
                        final item = _items[index];
                        return _buildSlide(item);
                      } else {
                        return _buildRoleSelectionSlide();
                      }
                    },
                  ),
                ),
                
                // Bottom control section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) => _buildIndicator(index)),
                      ),
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      _currentPage < 3
                          ? SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Next',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _hasSelectedRole ? _navigateToLogin : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasSelectedRole
                                      ? (_isVendorSelected ? const Color(0xFF0D9488) : const Color(0xFF6C63FF))
                                      : const Color(0xFFE2E8F0),
                                  foregroundColor: _hasSelectedRole
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  disabledBackgroundColor: const Color(0xFFF1F5F9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: _hasSelectedRole ? 3 : 0,
                                  shadowColor: _hasSelectedRole
                                      ? (_isVendorSelected
                                          ? const Color(0xFF0D9488).withOpacity(0.3)
                                          : const Color(0xFF6C63FF).withOpacity(0.3))
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _hasSelectedRole
                                          ? 'Join as ${_isVendorSelected ? 'Seller' : 'User'}'
                                          : 'Select Your Role',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.login_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic container
          Container(
            height: 240,
            width: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  item.color.withOpacity(0.12),
                  item.color.withOpacity(0.01),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.color.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: 64,
                  color: item.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Badge tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: item.color.withOpacity(0.15)),
            ),
            child: Text(
              item.tag,
              style: TextStyle(
                color: item.color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A), // Charcoal
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF475569), // Slate grey
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionSlide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Your Path',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us how you plan to use SingleMart so we can customize your portal experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 40),
          
          // Role Selection Cards
          _buildRoleCard(
            title: 'Join as a User',
            subtitle: 'Shopper Profile',
            description: 'Browse local sellers, shop items, track deliveries and get customer loyalty rewards.',
            icon: Icons.local_mall_rounded,
            isSelected: _hasSelectedRole && !_isVendorSelected,
            activeColor: const Color(0xFF6C63FF),
            onTap: () {
              setState(() {
                _isVendorSelected = false;
                _hasSelectedRole = true;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            title: 'Join as a Seller',
            subtitle: 'Store Owner/Merchant Profile',
            description: 'Setup your catalog, track store views, fulfill order packages and manage finances.',
            icon: Icons.storefront_rounded,
            isSelected: _hasSelectedRole && _isVendorSelected,
            activeColor: const Color(0xFF0D9488),
            onTap: () {
              setState(() {
                _isVendorSelected = true;
                _hasSelectedRole = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.04)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? activeColor.withOpacity(0.08)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: isSelected ? 15 : 8,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon wrapper
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.12)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? activeColor : const Color(0xFF94A3B8),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: activeColor,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? activeColor : const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isActive = _currentPage == index;
    Color indicatorColor = const Color(0xFF6C63FF);
    if (_currentPage == 2) {
      indicatorColor = const Color(0xFF0D9488); // Vendor color
    } else if (_currentPage == 3 && _hasSelectedRole) {
      indicatorColor = _isVendorSelected ? const Color(0xFF0D9488) : const Color(0xFF6C63FF);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? indicatorColor : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String tag;

  OnboardItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tag,
  });
}
