import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/server_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'config_server.dart';
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
  bool _isServerConnected = false;
  int _step = 0;

  String _selectedDatabase = ServerConfigService.defaultDatabase;
  String _selectedWarehouse = '01 - คลังหลัก (Main Warehouse)';

  static const _databases = ServerConfigService.databases;
  static const _warehouses = [
    '01 - คลังหลัก (Main Warehouse)',
    '02 - คลังสินค้า 2',
    '03 - คลังสินค้า 3',
    '04 - คลังสินค้า 4',
  ];

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

  void _goToWarehouseStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final data = await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;

      final user = data['user'] as Map<String, dynamic>? ?? {};
      final loggedInUsername =
          user['username']?.toString() ?? _usernameController.text.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('warehouse', _selectedWarehouse);
      await prefs.setString('database', _selectedDatabase);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(username: loggedInUsername),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncServer() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ConfigServerPage()),
    );
    if (!mounted) return;

    if (saved == true) {
      final config = await ServerConfigService.load();
      if (!mounted) return;
      setState(() {
        _isServerConnected = true;
        _selectedDatabase = config.database;
      });
    } else if (saved == false) {
      setState(() => _isServerConnected = false);
    }
  }

  Widget _connectionStatus() {
    final color = _isServerConnected ? AppColors.accentGreen : Colors.red;
    final label = _isServerConnected ? 'เชื่อมต่อแล้ว' : 'ยังไม่เชื่อมต่อ';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.text(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
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

  Widget _greenButton({
    required String label,
    required VoidCallback? onPressed,
    IconData icon = Icons.arrow_forward_rounded,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          disabledBackgroundColor: AppColors.accentGreen.withValues(alpha: 0.6),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(label, style: AppTextStyles.button()),
                ],
              ),
      ),
    );
  }

  Widget _warehouseTile(String warehouse) {
    final isSelected = _selectedWarehouse == warehouse;
    final accentColor =
        isSelected ? AppColors.accentGreen : AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _selectedWarehouse = warehouse),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accentGreen : AppColors.borderGray,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColors.accentGreen : AppColors.borderGray,
                size: 22,
              ),
              const SizedBox(width: 12),
              Icon(Icons.warehouse_outlined, color: accentColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  warehouse,
                  style: AppTextStyles.text(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step1Content() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _fieldLabel('เลือกฐานข้อมูล')),
            _connectionStatus(),
          ],
        ),
        const SizedBox(height: 8),
        _dropdownField<String>(
          value: _selectedDatabase,
          items: _databases,
          prefixIcon: Icons.storage_outlined,
          onChanged: (value) {
            if (value != null) setState(() => _selectedDatabase = value);
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _syncServer,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(
              Icons.sync_rounded,
              color: AppColors.primaryBlue,
              size: 18,
            ),
            label: Text(
              'Sync Server',
              style: AppTextStyles.text(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _fieldLabel('รหัสผู้ใช้งาน'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.body(color: AppColors.primaryBlue),
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
          onFieldSubmitted: (_) => _goToWarehouseStep(),
          style: AppTextStyles.body(color: AppColors.primaryBlue),
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
                setState(() => _obscurePassword = !_obscurePassword);
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
                side: const BorderSide(color: AppColors.borderGray),
                onChanged: (value) {
                  setState(() => _rememberPassword = value ?? false);
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
                    builder: (_) => const ResetPasswordRequestPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'ลืมรหัสผ่าน?',
                style: AppTextStyles.link(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _greenButton(
          label: 'ถัดไป',
          onPressed: _isLoading ? null : _goToWarehouseStep,
          icon: Icons.arrow_forward_rounded,
        ),
      ],
    );
  }

  Widget _step2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('เลือกคลังสินค้า'),
        const SizedBox(height: 12),
        for (final warehouse in _warehouses) _warehouseTile(warehouse),
        const SizedBox(height: 10),
        _greenButton(
          label: 'เข้าสู่ระบบ',
          onPressed: _isLoading ? null : _handleLogin,
          icon: Icons.login_rounded,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isStep1 = _step == 0;

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
                      isStep1 ? 'เชื่อมต่อระบบ' : 'เลือกคลังสินค้า',
                      style: AppTextStyles.text(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isStep1
                          ? 'กรุณาเลือกฐานข้อมูลและเข้าสู่ระบบ'
                          : 'กรุณาเลือกคลังสินค้าเพื่อใช้งานระบบ',
                      textAlign: TextAlign.center,
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
                      child: isStep1 ? _step1Content() : _step2Content(),
                    ),
                    if (!isStep1) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => setState(() => _step = 0),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                        label: Text(
                          'ย้อนกลับ',
                          style: AppTextStyles.link(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text('เวอร์ชัน 1.0.0', style: AppTextStyles.caption()),
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
