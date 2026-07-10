import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const DashboardScreen({
    super.key,
    required this.userData,
    required this.token,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _logout() {
    // Show a premium confirmation dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Logout Session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to end your current session and exit?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3 = Admin, 2 = Vendor, 1 = User
    final int userType = widget.userData['user_type'] is int 
        ? widget.userData['user_type'] 
        : int.tryParse(widget.userData['user_type']?.toString() ?? '1') ?? 1;

    switch (userType) {
      case 3:
        return _buildAdminDashboard();
      case 2:
        return _buildVendorDashboard();
      case 1:
      default:
        return _buildUserDashboard();
    }
  }

  // --- 1. ADMIN DASHBOARD (user_type: 3) ---
  Widget _buildAdminDashboard() {
    final String name = widget.userData['name'] ?? 'Administrator';
    final String email = widget.userData['email'] ?? 'admin@singlemart.com';
    final String position = widget.userData['user_position'] ?? 'Admin';
    final String status = widget.userData['status'] ?? 'Active';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: _buildAppBar(title: 'Admin Console', primaryColor: const Color(0xFF6C63FF)),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(
                name: name,
                subText: position,
                email: email,
                status: status,
                primaryColor: const Color(0xFF6C63FF),
                icon: Icons.admin_panel_settings_rounded,
              ),
              const SizedBox(height: 28),
              const Text(
                'System Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Users', '1,248', Icons.people_outline, const Color(0xFF6C63FF))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Active Stores', '42', Icons.storefront_rounded, Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('System Status', 'Nominal', Icons.check_circle_outline, Colors.teal)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Errors Logged', '0', Icons.bug_report_outlined, Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Administrative Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'User Management',
                icon: Icons.manage_accounts_rounded,
                color: const Color(0xFF6C63FF),
                onTap: () => _showComingSoon('User Management'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Merchant Approvals',
                icon: Icons.fact_check_rounded,
                color: Colors.orange,
                onTap: () => _showComingSoon('Merchant Approvals'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'System Logs',
                icon: Icons.receipt_long_rounded,
                color: Colors.teal,
                onTap: () => _showComingSoon('System Logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. VENDOR DASHBOARD (user_type: 2) ---
  Widget _buildVendorDashboard() {
    final String name = widget.userData['name'] ?? 'Vendor Merchant';
    final String email = widget.userData['email'] ?? 'vendor@singlemart.com';
    final String mobile = widget.userData['mobile'] ?? 'Mobile';
    final String status = widget.userData['status'] ?? 'Active';

    return Scaffold(
      backgroundColor: const Color(0xFFF2FBF9),
      appBar: _buildAppBar(title: 'Merchant Hub', primaryColor: const Color(0xFF0D9488)),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(
                name: name,
                subText: 'Merchant Partner',
                email: email,
                status: status,
                primaryColor: const Color(0xFF0D9488),
                icon: Icons.storefront_rounded,
                phone: mobile,
              ),
              const SizedBox(height: 28),
              const Text(
                'Store Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Today's Sales", '\$450.00', Icons.monetization_on_outlined, const Color(0xFF0D9488))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Active Listings', '38 Items', Icons.shopping_bag_outlined, Colors.purple)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('New Orders', '4 Pending', Icons.assignment_late_outlined, Colors.amber.shade700)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Store Views', '2,400', Icons.remove_red_eye_outlined, Colors.blue)),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Merchant Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Manage Products',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF0D9488),
                onTap: () => _showComingSoon('Manage Products'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Order Processing',
                icon: Icons.local_shipping_rounded,
                color: Colors.purple,
                onTap: () => _showComingSoon('Order Processing'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Store Settings',
                icon: Icons.settings_applications_rounded,
                color: Colors.blue,
                onTap: () => _showComingSoon('Store Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. USER DASHBOARD (user_type: 1) ---
  Widget _buildUserDashboard() {
    final String name = widget.userData['name'] ?? 'Valued Customer';
    final String email = widget.userData['email'] ?? 'shopper@singlemart.com';
    final String mobile = widget.userData['mobile'] ?? 'Mobile';
    final String status = widget.userData['status'] ?? 'Active';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: _buildAppBar(title: 'My Marketplace', primaryColor: const Color(0xFF6C63FF)),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(
                name: name,
                subText: 'Loyal Shopper',
                email: email,
                status: status,
                primaryColor: const Color(0xFF6C63FF),
                icon: Icons.account_circle_rounded,
                phone: mobile,
              ),
              const SizedBox(height: 28),
              const Text(
                'Shopping Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Orders', '12 Orders', Icons.shopping_basket_outlined, const Color(0xFF6C63FF))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Reward Points', '320 Pts', Icons.card_giftcard_rounded, Colors.pink)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Saved Stores', '6 Stores', Icons.favorite_border_rounded, Colors.redAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Cart Items', '3 Items', Icons.shopping_cart_outlined, Colors.teal)),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Shopping Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Start Shopping',
                icon: Icons.explore_rounded,
                color: const Color(0xFF6C63FF),
                onTap: () => _showComingSoon('Start Shopping'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Track Order History',
                icon: Icons.history_edu_rounded,
                color: Colors.pink,
                onTap: () => _showComingSoon('Order History'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Edit Shopping Profile',
                icon: Icons.manage_accounts_outlined,
                color: Colors.teal,
                onTap: () => _showComingSoon('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Shared Widget Builders ---

  PreferredSizeWidget _buildAppBar({required String title, required Color primaryColor}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String subText,
    required String email,
    required String status,
    required Color primaryColor,
    required IconData icon,
    String? phone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subText,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'active' 
                      ? Colors.teal.withOpacity(0.15) 
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: status.toLowerCase() == 'active' ? Colors.teal : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 36, color: Color(0xFFE2E8F0)),
          _buildInfoRow(Icons.mail_outline_rounded, email),
          if (phone != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone_outlined, '+91 $phone'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            val,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$module feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _performLogout() async {
    // Show a loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text('Logging out...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    // Call app-logout API
    try {
      final response = await http.post(
        Uri.parse('https://agsdemo.in/singlemartapi/public/api/app-logout'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));
      debugPrint('Logout response: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('Error calling logout API: $e');
    }

    // Clear preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(isVendor: false),
        ),
      );
    }
  }
}
