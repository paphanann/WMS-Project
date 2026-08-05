import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/auth_scaffold.dart';
import 'login.dart';

class ResetPasswordRequestPage extends StatefulWidget {
  const ResetPasswordRequestPage({super.key});

  @override
  State<ResetPasswordRequestPage> createState() =>
      _ResetPasswordRequestPageState();
}

class _ResetPasswordRequestPageState extends State<ResetPasswordRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedDatabase = AuthFormFields.databases.first;
  String _selectedWarehouse = AuthFormFields.warehouses.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => _isLoading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordOtpVerifyPage(
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => Navigator.pop(context),
      title: 'รีเซ็ตรหัสผ่าน',
      subtitle: 'กรอกข้อมูลเพื่อขอรับรหัส OTP',
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthFormFields.label('เลือกฐานข้อมูล'),
              const SizedBox(height: 8),
              AuthFormFields.dropdown<String>(
                value: _selectedDatabase,
                items: AuthFormFields.databases,
                prefixIcon: Icons.storage_outlined,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDatabase = value);
                },
              ),
              const SizedBox(height: 16),
              AuthFormFields.label('เลือกคลังสินค้า'),
              const SizedBox(height: 8),
              AuthFormFields.dropdown<String>(
                value: _selectedWarehouse,
                items: AuthFormFields.warehouses,
                prefixIcon: Icons.warehouse_outlined,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedWarehouse = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              AuthFormFields.label('รหัสผู้ใช้งาน'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                style: AppTextStyles.body(color: AppColors.primaryBlue),
                decoration: AuthFormFields.decoration(
                  hint: 'กรอกรหัสผู้ใช้งาน',
                  prefixIcon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกรหัสผู้ใช้งาน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthFormFields.label('อีเมล'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.body(color: AppColors.primaryBlue),
                decoration: AuthFormFields.decoration(
                  hint: 'กรอกอีเมลที่ลงทะเบียนไว้',
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  }
                  if (!value.contains('@')) {
                    return 'รูปแบบอีเมลไม่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.accentGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ระบบจะส่งรหัส OTP ไปยังอีเมลที่ลงทะเบียนไว้ '
                        'กรุณาตรวจสอบกล่องจดหมายของคุณ',
                        style: AppTextStyles.text(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                        ).copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AuthFormFields.primaryButton(
                label: 'ส่งรหัส OTP ไปที่อีเมล',
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed: _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordOtpVerifyPage extends StatefulWidget {
  const ResetPasswordOtpVerifyPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordOtpVerifyPage> createState() =>
      _ResetPasswordOtpVerifyPageState();
}

class _ResetPasswordOtpVerifyPageState extends State<ResetPasswordOtpVerifyPage> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _isOtpComplete =>
      _controllers.every((controller) => controller.text.length == 1);

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _confirmOtp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordNewPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => Navigator.pop(context),
      title: 'รีเซ็ตรหัสผ่าน',
      subtitle: 'กรอกรหัส OTP',
      child: AuthFormCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 44,
                  height: 52,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTextStyles.text(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borderGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onOtpChanged(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ไม่ได้รับรหัส? ', style: AppTextStyles.small()),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'ส่งรหัส OTP อีกครั้ง',
                    style: AppTextStyles.link(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AuthFormFields.primaryButton(
              label: 'ยืนยันรหัส OTP',
              onPressed: _isOtpComplete ? _confirmOtp : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordNewPasswordPage extends StatefulWidget {
  const ResetPasswordNewPasswordPage({super.key});

  @override
  State<ResetPasswordNewPasswordPage> createState() =>
      _ResetPasswordNewPasswordPageState();
}

class _ResetPasswordNewPasswordPageState
    extends State<ResetPasswordNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _requirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.text(
                fontSize: 12,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      onBack: () => Navigator.pop(context),
      title: 'รีเซ็ตรหัสผ่าน',
      subtitle: 'ตั้งรหัสผ่านใหม่',
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthFormFields.label('รหัสผ่านใหม่'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.body(color: AppColors.primaryBlue),
                decoration: AuthFormFields.decoration(
                  hint: 'กรอกรหัสผ่านใหม่',
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
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรหัสผ่านใหม่';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _requirementItem('อย่างน้อย 8 ตัวอักษร'),
              _requirementItem('ต้องมีตัวอักษรและตัวเลข'),
              _requirementItem('ห้ามมีช่องว่าง'),
              const SizedBox(height: 16),
              AuthFormFields.label('ยืนยันรหัสผ่านใหม่'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: AppTextStyles.body(color: AppColors.primaryBlue),
                decoration: AuthFormFields.decoration(
                  hint: 'กรอกรหัสผ่านใหม่อีกครั้ง',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณายืนยันรหัสผ่าน';
                  }
                  if (value != _passwordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AuthFormFields.primaryButton(
                label: 'ถัดไป',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordSuccessPage extends StatelessWidget {
  const ResetPasswordSuccessPage({super.key});

  void _backToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'รีเซ็ตรหัสผ่าน',
      child: AuthFormCard(
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: AppColors.accentGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'รีเซ็ตรหัสผ่านสำเร็จ',
              style: AppTextStyles.text(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณสามารถเข้าสู่ระบบด้วยรหัสผ่านใหม่ได้แล้ว',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
            const SizedBox(height: 24),
            AuthFormFields.primaryButton(
              label: 'กลับไปหน้าเข้าสู่ระบบ',
              onPressed: () => _backToLogin(context),
            ),
          ],
        ),
      ),
    );
  }
}
