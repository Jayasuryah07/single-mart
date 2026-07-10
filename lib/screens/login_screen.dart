import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'user_register_screen.dart';
import 'vendor_register_screen.dart';
import 'otp_screen.dart';

// --- Mock Home Screen ---
class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome to SingleMart!')),
    );
  }
}

// --- Main Login Screen ---
class LoginScreen extends StatefulWidget {
  final bool isVendor;
  const LoginScreen({super.key, required this.isVendor});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopIdController = TextEditingController();

  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // --- Lifecycle ---
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shopIdController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showSnackBar(
        'Please enter a valid 10-digit phone number',
        Colors.redAccent,
        Icons.warning_rounded,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://agsdemo.in/singlemartapi/public/api/check-mobile'),
        body: {
          'mobile': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = json.decode(response.body);
        final int code = resData['code'] is int 
            ? resData['code'] 
            : int.tryParse(resData['code']?.toString() ?? '200') ?? 200;

        if (code == 200) {
          final otpCode = resData['data']?.toString() ?? '';

          _showSnackBar(
            'OTP sent! (For Demo: $otpCode)',
            const Color(0xFF0D9488),
            Icons.check_circle_rounded,
          );

          // Firebase OTP verification trigger
          try {
            await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: '+91$phone',
              verificationCompleted: (PhoneAuthCredential credential) async {
                // Auto-retrieval completed, login will happen inside OTPScreen
              },
              verificationFailed: (FirebaseAuthException e) {
                debugPrint('Firebase phone verification failed: ${e.message}');
                _showSnackBar('Firebase Auth: ${e.message}', Colors.redAccent, Icons.error_outline_rounded);
                // Navigate to OTPScreen anyway so fallback API OTP can be verified
                if (mounted) {
                  setState(() => _isLoading = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTPScreen(
                        phoneNumber: phone,
                        verificationId: '',
                        apiOtp: otpCode,
                      ),
                    ),
                  );
                }
              },
              codeSent: (String verificationId, int? resendToken) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTPScreen(
                        phoneNumber: phone,
                        verificationId: verificationId,
                        apiOtp: otpCode,
                      ),
                    ),
                  );
                }
              },
              codeAutoRetrievalTimeout: (String verificationId) {},
            );
          } catch (firebaseErr) {
            debugPrint('Firebase Phone Auth setup error: $firebaseErr');
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPScreen(
                    phoneNumber: phone,
                    verificationId: '',
                    apiOtp: otpCode,
                  ),
                ),
              );
            }
          }

        } else {
          setState(() => _isLoading = false);
          _showSnackBar(
            resData['message'] ?? 'Mobile verification failed.',
            Colors.redAccent,
            Icons.warning_rounded,
          );
        }
      } else {
        final resData = json.decode(response.body);
        setState(() => _isLoading = false);
        _showSnackBar(
          resData['message'] ?? 'Connection error. Status code: ${response.statusCode}',
          Colors.redAccent,
          Icons.warning_rounded,
        );
      }
    } catch (e) {
      debugPrint('Error sending mobile check: $e');
      setState(() => _isLoading = false);
      _showSnackBar(
        'Server unreachable. Please check your connection.',
        Colors.redAccent,
        Icons.warning_rounded,
      );
    }
  }

  // --- UI Helpers ---
  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }



  // --- Registration Modals ---
  void _showRegistrationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how you want to join SingleMart',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            _buildRegistrationOption(
              icon: Icons.storefront_rounded,
              title: 'Register as Business',
              subtitle: 'Sell products & grow your business',
              color: const Color(0xFF0D9488),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF0EA5E9)],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VendorRegisterScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRegistrationOption(
              icon: Icons.person_outline_rounded,
              title: 'Register as User',
              subtitle: 'Shop locally & discover deals',
              color: const Color(0xFF6C63FF),
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFA59FFF)],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserRegisterScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }



  // --- Build ---
  @override
  Widget build(BuildContext context) {
    final bool isVendor = widget.isVendor;
    final Color primaryColor = isVendor ? const Color(0xFF0D9488) : const Color(0xFF6C63FF);
    final Color secondaryColor = isVendor ? const Color(0xFF0EA5E9) : const Color(0xFFA59FFF);
    final LinearGradient gradient = LinearGradient(
      colors: [primaryColor, secondaryColor],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextButton(
              onPressed: _showRegistrationOptions,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      secondaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVendor ? 'Seller Login' : 'Welcome Back!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isVendor
                          ? 'Manage your store and process orders'
                          : 'Sign in to discover amazing local deals',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isVendor) ...[
                      const Text(
                        'SHOP CODE / ID',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _shopIdController,
                        style: const TextStyle(
                            color: Color(0xFF0F172A), fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Enter your shop code',
                          hintStyle:
                              const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Icon(
                            Icons.store_rounded,
                            color: primaryColor.withOpacity(0.7),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
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
                            borderSide:
                                BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Phone
                    const Text(
                      'PHONE NUMBER',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
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
                            padding: EdgeInsets.symmetric(horizontal: 8),
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
                            style: const TextStyle(
                                color: Color(0xFF0F172A), fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 14),
                              prefixIcon: Icon(
                                Icons.phone_rounded,
                                color: primaryColor.withOpacity(0.7),
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 1),
                              ),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_phoneController.text.isNotEmpty &&
                        _phoneController.text.length < 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'Please enter a valid 10-digit number',
                          style: TextStyle(
                            color: Colors.redAccent.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Login Button
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
                            spreadRadius: 5,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
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
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isVendor ? "Don't have a store? " : "New to SingleMart? ",
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _showRegistrationOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isVendor ? 'Register Business' : 'Create Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}