import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'home.dart';
import 'reset_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberPassword = true;
  bool _isLoading = false;

  String _selectedDatabase = 'SBO_PRD_CT';
  String _selectedWarehouse = '01 - คลังหลัก (Main Warehouse)';

  static const _databases = ['SBO_PRD_CT'];
  static const _warehouses = ['01 - คลังหลัก (Main Warehouse)'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('picture/wms_logo.png'), context);
      precacheImage(const AssetImage('picture/background.png'), context);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกรหัสผู้ใช้งาน';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          username: _usernameController.text.trim().isEmpty
              ? 'PASS User'
              : _usernameController.text.trim(),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required IconData prefixIcon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint(),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: AppColors.accentGreen, size: 22),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.label()),
    );
  }

  Widget _dropdownField<T>({
    required T value,
    required List<T> items,
    required IconData prefixIcon,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item.toString(),
                style: AppTextStyles.body(color: AppColors.primaryBlue),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primaryBlue,
      ),
      decoration: _fieldDecoration(prefixIcon: prefixIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'picture/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            gaplessPlayback: true,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'picture/wms_logo.png',
                      width: 200,
                      cacheWidth: 400,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'เข้าสู่ระบบจ้า',
                      style: AppTextStyles.text(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'กรุณาเลือกข้อมูลเพื่อเข้าสู่ระบบ',
                      style: AppTextStyles.subtitle(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _fieldLabel('เลือกฐานข้อมูล'),
                          const SizedBox(height: 8),
                          _dropdownField<String>(
                            value: _selectedDatabase,
                            items: _databases,
                            prefixIcon: Icons.storage_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedDatabase = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel('เลือกคลังสินค้า'),
                          const SizedBox(height: 8),
                          _dropdownField<String>(
                            value: _selectedWarehouse,
                            items: _warehouses,
                            prefixIcon: Icons.warehouse_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedWarehouse = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel('รหัสผู้ใช้งาน'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            style: AppTextStyles.body(
                              color: AppColors.primaryBlue,
                            ),
                            decoration: _fieldDecoration(
                              hint: 'กรอกรหัสผู้ใช้งาน',
                              prefixIcon: Icons.person_outline,
                            ),
                            validator: _validateUsername,
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel('รหัสผ่าน'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            style: AppTextStyles.body(
                              color: AppColors.primaryBlue,
                            ),
                            decoration: _fieldDecoration(
                              hint: 'กรอกรหัสผ่าน',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 28,
                                width: 28,
                                child: Checkbox(
                                  value: _rememberPassword,
                                  activeColor: AppColors.accentGreen,
                                  side: const BorderSide(
                                    color: AppColors.borderGray,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberPassword = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'จำรหัสผ่าน',
                                style: AppTextStyles.text(
                                  fontSize: 13,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ResetPasswordRequestPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.primaryBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Reset Password',
                                      style: AppTextStyles.link(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                disabledBackgroundColor: AppColors.accentGreen
                                    .withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.login_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'เข้าสู่ระบบ',
                                          style: AppTextStyles.button(),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'เวอร์ชัน 1.0.0',
                      style: AppTextStyles.caption(),
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
