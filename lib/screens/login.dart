import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/warehouse.dart';
import '../services/auth_service.dart';
import '../services/server_config_service.dart';
import '../services/warehouse_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/auth_scaffold.dart';
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
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;
  bool _loadingWarehouses = false;
  String? _warehouseError;
  bool _connected = false;
  int _step = 0;

  String _database = ServerConfigService.defaultDatabase;
  List<Warehouse> _warehouses = [];
  String? _warehouseCode;

  @override
  void initState() {
    super.initState();
    _loadServerStatus();
  }

  Future<void> _loadServerStatus() async {
    final saved = await ServerConfigService.getSavedConnection();
    if (!mounted || saved == null) return;
    setState(() {
      _connected = true;
      _database = saved['database']?.toString() ?? _database;
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _goToWarehouseStep() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _warehouseError = null;
    });
    try {
      await AuthService.login(_username.text.trim(), _password.text);
      if (!mounted) return;
      setState(() => _step = 1);
      await _loadWarehouses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadWarehouses() async {
    setState(() {
      _loadingWarehouses = true;
      _warehouseError = null;
    });
    try {
      final warehouses = await WarehouseService.fetchList();
      if (!mounted) return;
      setState(() {
        _warehouses = warehouses;
        _warehouseCode = warehouses.isNotEmpty ? warehouses.first.code : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _warehouses = [];
        _warehouseCode = null;
        _warehouseError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loadingWarehouses = false);
    }
  }

  Future<void> _enterApp() async {
    if (_warehouseCode == null || _warehouseCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกคลังสินค้า')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('warehouseCode', _warehouseCode!);
      final selected = _warehouses.where((w) => w.code == _warehouseCode);
      if (selected.isNotEmpty) {
        await prefs.setString('warehouseName', selected.first.name);
      }
      await prefs.setString('database', _database);

      final name = prefs.getString('username') ?? _username.text.trim();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(username: name)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSync() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ConfigServerPage()),
    );
    if (!mounted) return;

    if (ok == true) {
      final config = await ServerConfigService.load();
      if (!mounted) return;
      setState(() {
        _connected = true;
        _database = config.database;
      });
    } else if (ok == false) {
      setState(() => _connected = false);
    }
  }

  Widget _statusDot() {
    final color = _connected ? AppColors.accentGreen : Colors.red;
    final text = _connected ? 'เชื่อมต่อแล้ว' : 'ยังไม่เชื่อมต่อ';
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
          text,
          style: AppTextStyles.text(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _warehouseTile(Warehouse wh) {
    final selected = _warehouseCode == wh.code;
    final color = selected ? AppColors.accentGreen : AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _warehouseCode = wh.code),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accentGreen : AppColors.borderGray,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.accentGreen : AppColors.borderGray,
              ),
              const SizedBox(width: 12),
              Icon(Icons.warehouse_outlined, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  wh.displayLabel,
                  style: AppTextStyles.text(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step1() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: AuthFormFields.label('เลือกฐานข้อมูล')),
            _statusDot(),
          ],
        ),
        const SizedBox(height: 8),
        AuthFormFields.dropdown(
          value: _database,
          items: AuthFormFields.databases,
          prefixIcon: Icons.storage_outlined,
          onChanged: (v) {
            if (v != null) setState(() => _database = v);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _openSync,
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text('Sync Server'),
          ),
        ),
        AuthFormFields.label('รหัสผู้ใช้งาน'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _username,
          textInputAction: TextInputAction.next,
          decoration: AuthFormFields.decoration(
            hint: 'กรอกรหัสผู้ใช้งาน',
            prefixIcon: Icons.person_outline,
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'กรุณากรอกรหัสผู้ใช้งาน' : null,
        ),
        const SizedBox(height: 16),
        AuthFormFields.label('รหัสผ่าน'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _password,
          obscureText: _hidePassword,
          onFieldSubmitted: (_) => _goToWarehouseStep(),
          decoration: AuthFormFields.decoration(
            hint: 'กรอกรหัสผ่าน',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          validator: (v) =>
              v == null || v.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ResetPasswordRequestPage(),
              ),
            ),
            child: Text('ลืมรหัสผ่าน?', style: AppTextStyles.link()),
          ),
        ),
        const SizedBox(height: 20),
        AuthFormFields.primaryButton(
          label: 'ถัดไป',
          icon: Icons.arrow_forward_rounded,
          isLoading: _loading,
          onPressed: _goToWarehouseStep,
        ),
      ],
    );
  }

  Widget _step2() {
    if (_loadingWarehouses) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (_warehouseError != null) {
      return Column(
        children: [
          Text(_warehouseError!, style: AppTextStyles.body()),
          const SizedBox(height: 8),
          Text(
            'ตรวจสอบว่า backend มี GET /api/warehouses',
            style: AppTextStyles.caption(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AuthFormFields.primaryButton(
            label: 'ลองใหม่',
            icon: Icons.refresh_rounded,
            onPressed: _loadWarehouses,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('กลับ'),
          ),
        ],
      );
    }

    if (_warehouses.isEmpty) {
      return Column(
        children: [
          Text(
            'ไม่พบคลังสินค้า',
            style: AppTextStyles.subtitle(),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('กลับ'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFormFields.label('เลือกคลังสินค้า'),
        const SizedBox(height: 12),
        for (final wh in _warehouses) _warehouseTile(wh),
        const SizedBox(height: 10),
        AuthFormFields.primaryButton(
          label: 'เข้าสู่ระบบ',
          icon: Icons.login_rounded,
          isLoading: _loading,
          onPressed: _enterApp,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final step1 = _step == 0;

    return AuthScaffold(
      title: step1 ? 'เชื่อมต่อระบบ' : 'เลือกคลังสินค้า',
      subtitle: step1
          ? 'กรุณาเลือกฐานข้อมูลและเข้าสู่ระบบ'
          : 'กรุณาเลือกคลังสินค้าเพื่อใช้งานระบบ',
      onBack: step1
          ? null
          : () {
              setState(() {
                _step = 0;
                _warehouseError = null;
              });
            },
      child: Form(
        key: _formKey,
        child: AuthFormCard(child: step1 ? _step1() : _step2()),
      ),
    );
  }
}
