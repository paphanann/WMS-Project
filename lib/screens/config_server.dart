import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/server_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/auth_scaffold.dart';

class ConfigServerPage extends StatefulWidget {
  const ConfigServerPage({super.key});

  @override
  State<ConfigServerPage> createState() => _ConfigServerPageState();
}

class _ConfigServerPageState extends State<ConfigServerPage> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  bool _wasDisconnected = false;
  String _selectedDatabase = ServerConfigService.defaultDatabase;
  DateTime? _connectedAt;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final config = await ServerConfigService.load();
    final saved = await ServerConfigService.getSavedConnection();
    if (!mounted) return;

    DateTime? connectedAt;
    final connectedAtRaw = saved?['connectedAt'] as String?;
    if (connectedAtRaw != null) {
      connectedAt = DateTime.tryParse(connectedAtRaw);
    }

    setState(() {
      _ipController.text = config.ip;
      _portController.text = config.port;
      _selectedDatabase = config.database;
      if (saved != null) {
        _showSuccess = true;
        _connectedAt = connectedAt;
      }
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final connectedAt = await ServerConfigService.testAndSave(
        ip: _ipController.text.trim(),
        port: _portController.text.trim(),
        database: _selectedDatabase,
      );
      if (!mounted) return;

      setState(() {
        _connectedAt = connectedAt;
        _showSuccess = true;
        _wasDisconnected = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _formView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Icon(
              Icons.dns_outlined,
              size: 72,
              color: AppColors.primaryBlue.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'ตั้งค่าเซิร์ฟเวอร์',
              style: AppTextStyles.text(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'กรุณากรอกข้อมูลสำหรับเชื่อมต่อเซิร์ฟเวอร์',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
            const SizedBox(height: 24),
            AuthFormFields.label('IP Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ipController,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppTextStyles.body(color: AppColors.primaryBlue),
              decoration: AuthFormFields.decoration(
                hint: 'กรอก IP Address',
                prefixIcon: Icons.computer_outlined,
                iconColor: AppColors.primaryBlue,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอก IP Address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFormFields.label('Port'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _portController,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.body(color: AppColors.primaryBlue),
              decoration: AuthFormFields.decoration(
                hint: '3001',
                prefixIcon: Icons.hub_outlined,
                iconColor: AppColors.primaryBlue,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอก Port';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFormFields.label('Database'),
            const SizedBox(height: 8),
            AuthFormFields.dropdown(
              value: _selectedDatabase,
              items: ServerConfigService.databases,
              prefixIcon: Icons.storage_outlined,
              iconColor: AppColors.primaryBlue,
              onChanged: (v) {
                if (v != null) setState(() => _selectedDatabase = v);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'กดบันทึกเพื่อทดสอบการเชื่อมต่อและบันทึกค่า',
              style: AppTextStyles.caption(),
            ),
            const SizedBox(height: 24),
            AuthFormFields.blueButton(
              label: 'บันทึกการตั้งค่า',
              isLoading: _isLoading,
              onPressed: _saveConfig,
            ),
          ],
        ),
      ),
    );
  }

  Widget _successRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    const rowStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryBlue,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Text(label, style: rowStyle),
          const Spacer(),
          Text(value, style: rowStyle, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  void _changeServer() {
    setState(() => _showSuccess = false);
  }

  Future<void> _cancelConnection() async {
    await ServerConfigService.clearConnection();
    if (!mounted) return;
    setState(() {
      _wasDisconnected = true;
      _showSuccess = false;
      _connectedAt = null;
      _ipController.clear();
      _portController.text = '3001';
      _selectedDatabase = ServerConfigService.defaultDatabase;
    });
  }

  void _popToLogin() {
    if (_wasDisconnected) {
      Navigator.pop(context, false);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _successBtn({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = AppColors.primaryBlue,
    bool filled = false,
  }) {
    final style = AppTextStyles.text(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: filled ? Colors.white : color,
    );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(icon, color: Colors.white),
              label: Text(label, style: AppTextStyles.button()),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(icon, size: 22),
              label: Text(label, style: style),
            ),
    );
  }

  Widget _successView() {
    final connectedText = _connectedAt != null
        ? ServerConfigService.formatDateTime(_connectedAt!)
        : '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
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
              Icons.check_rounded,
              color: AppColors.accentGreen,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'เชื่อมต่อสำเร็จ!',
            style: AppTextStyles.text(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'เชื่อมต่อกับเซิร์ฟเวอร์ได้เรียบร้อยแล้ว',
            style: AppTextStyles.subtitle(),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _successRow(
                  icon: Icons.dns_outlined,
                  label: 'IP Address',
                  value: _ipController.text.trim(),
                ),
                Divider(
                  height: 1,
                  color: AppColors.borderGray.withValues(alpha: 0.8),
                ),
                _successRow(
                  icon: Icons.hub_outlined,
                  label: 'Port',
                  value: _portController.text.trim(),
                ),
                Divider(
                  height: 1,
                  color: AppColors.borderGray.withValues(alpha: 0.8),
                ),
                _successRow(
                  icon: Icons.storage_outlined,
                  label: 'Database',
                  value: _selectedDatabase,
                ),
                Divider(
                  height: 1,
                  color: AppColors.borderGray.withValues(alpha: 0.8),
                ),
                _successRow(
                  icon: Icons.access_time_outlined,
                  label: 'วันที่เชื่อมต่อ',
                  value: connectedText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _successBtn(
            label: 'เปลี่ยนเซิร์ฟเวอร์',
            icon: Icons.sync_rounded,
            onPressed: _changeServer,
          ),
          const SizedBox(height: 12),
          _successBtn(
            label: 'ยกเลิกการเชื่อมต่อ',
            icon: Icons.delete_outline,
            color: Colors.red,
            onPressed: _cancelConnection,
          ),
          const SizedBox(height: 12),
          _successBtn(
            label: 'กลับหน้าเข้าสู่ระบบ',
            icon: Icons.home_outlined,
            filled: true,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Config Server',
          style: AppTextStyles.text(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _popToLogin,
        ),
      ),
      body: _showSuccess ? _successView() : _formView(),
    );
  }
}
