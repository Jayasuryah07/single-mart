import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _registerVendor() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate a network register call
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Color(0xFF0D9488),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Merchant Submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your merchant store registration is pending review. You will be notified via email/phone once activated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Exit register screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Back to Login', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D9488);
    const Color secondaryColor = Color(0xFF0EA5E9);
    final LinearGradient gradient = LinearGradient(colors: [primaryColor, secondaryColor]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Store',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.08),
                          secondaryColor.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open Your Store!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Register your local business to post catalogs, manage inventory, and process orders on SingleMart.',
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Business Name
                  _buildLabel('BUSINESS NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _businessNameController,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your business name' : null,
                    decoration: _buildInputDecoration(
                      hint: 'Enter your business/shop name',
                      icon: Icons.storefront_rounded,
                      activeColor: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Owner Name
                  _buildLabel('OWNER FULL NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ownerNameController,
                    validator: (val) => val == null || val.trim().isEmpty ? "Please enter owner's full name" : null,
                    decoration: _buildInputDecoration(
                      hint: 'Enter owner\'s name',
                      icon: Icons.person_outline_rounded,
                      activeColor: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Business Email
                  _buildLabel('BUSINESS EMAIL'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _businessEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter business email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      hint: 'business@example.com',
                      icon: Icons.mail_outline_rounded,
                      activeColor: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phone Number Field
                  _buildLabel('PHONE NUMBER'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Center(
                            child: Text(
                              '+91',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (val) => val == null || val.trim().length != 10 ? 'Enter a valid 10-digit number' : null,
                          decoration: _buildInputDecoration(
                            hint: 'Enter phone number',
                            icon: Icons.phone_outlined,
                            activeColor: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Shop Address
                  _buildLabel('SHOP ADDRESS'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter the shop address' : null,
                    decoration: _buildInputDecoration(
                      hint: 'Enter building, street, and locality details...',
                      icon: Icons.location_on_outlined,
                      activeColor: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Register Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerVendor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Register Merchant',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required Color activeColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
