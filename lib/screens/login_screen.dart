import 'package:flutter/material.dart';
import 'guest_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isVendor;
  const LoginScreen({super.key, required this.isVendor});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _shopIdController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shopIdController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a network login call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show a beautiful dialog on successful mock login
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: widget.isVendor ? const Color(0xFF0D9488) : const Color(0xFF6C63FF),
                  width: 1.5,
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: widget.isVendor ? const Color(0xFF0D9488) : const Color(0xFF6C63FF),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Success',
                    style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                'Logged in successfully as ${widget.isVendor ? 'Seller (${_emailController.text})' : 'User (${_emailController.text})'}!',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: widget.isVendor ? const Color(0xFF0D9488) : const Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine style palette depending on User vs Seller selection
    final Color accentColor = widget.isVendor ? const Color(0xFF0D9488) : const Color(0xFF6C63FF);
    final String titleText = widget.isVendor ? 'Seller Log In' : 'User Log In';
    final String subtitleText = widget.isVendor 
        ? 'Manage your store and process local orders' 
        : 'Access your favorite local shops and deals';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Skip option in the app bar
         
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Heading
                Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 40),

                // Form Container / Clean Light Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Code Field (Only visible for Seller)
                      if (widget.isVendor) ...[
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
                          style: const TextStyle(color: Color(0xFF0F172A)),
                          validator: (value) {
                            if (widget.isVendor && (value == null || value.trim().isEmpty)) {
                              return 'Please enter your unique shop code';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'e.g. SHOP-1049',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.store_rounded, color: accentColor.withOpacity(0.7), size: 20),
                            filled: true,
                            fillColor: Colors.white,
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
                              borderSide: BorderSide(color: accentColor, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Email Field
                      Text(
                        widget.isVendor ? 'BUSINESS EMAIL' : 'EMAIL ADDRESS',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          prefixIcon: Icon(Icons.mail_outline_rounded, color: accentColor.withOpacity(0.7), size: 20),
                          filled: true,
                          fillColor: Colors.white,
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
                            borderSide: BorderSide(color: accentColor, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: accentColor.withOpacity(0.7), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                            borderSide: BorderSide(color: accentColor, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Remember me & Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: accentColor,
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: accentColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            shadowColor: accentColor.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
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
                
                // Social Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or Sign In With',
                        style: TextStyle(
                          color: const Color(0xFF64748B).withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.apple_rounded,
                      label: 'Apple',
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isVendor ? "Not a seller? " : "New to SingleMart? ",
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Sign up mock
                      },
                      child: Text(
                        widget.isVendor ? 'Register Store' : 'Create Account',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF0F172A),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
