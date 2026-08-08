import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/server_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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

  InputDecoration _fieldDecoration({
    required IconData prefixIcon,
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint(),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: AppColors.primaryBlue, size: 22),
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
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.label()),
    );
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
            _fieldLabel('IP Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: AppTextStyles.body(color: AppColors.primaryBlue),
              decoration: _fieldDecoration(
                hint: 'กรอก IP Address',
                prefixIcon: Icons.computer_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอก IP Address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _fieldLabel('Port'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _portController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.body(color: AppColors.primaryBlue),
              decoration: _fieldDecoration(
                hint: '3001',
                prefixIcon: Icons.hub_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอก Port';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _fieldLabel('Database'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedDatabase),
              initialValue: _selectedDatabase,
              items: ServerConfigService.databases
                  .map(
                    (db) => DropdownMenuItem(
                      value: db,
                      child: Text(
                        db,
                        style: AppTextStyles.body(color: AppColors.primaryBlue),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedDatabase = value);
              },
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primaryBlue,
              ),
              decoration: _fieldDecoration(prefixIcon: Icons.storage_outlined),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'เมื่อกด "บันทึกการตั้งค่า" ระบบจะทำการทดสอบการเชื่อมต่อ '
                      'และบันทึกการตั้งค่าให้อัตโนมัติ',
                      style: AppTextStyles.text(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor:
                      AppColors.primaryBlue.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_outlined, color: Colors.white),
                label: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('บันทึกการตั้งค่า', style: AppTextStyles.button()),
              ),
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
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _changeServer,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.sync_rounded, size: 22),
              label: Text(
                'เปลี่ยนเซิร์ฟเวอร์',
                style: AppTextStyles.text(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _cancelConnection,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 22),
              label: Text(
                'ยกเลิกการเชื่อมต่อ',
                style: AppTextStyles.text(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              label: Text(
                'กลับหน้าเข้าสู่ระบบ',
                style: AppTextStyles.button(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
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
