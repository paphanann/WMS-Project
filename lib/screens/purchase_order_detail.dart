import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/wms_page_header.dart';
import 'home.dart';

class PurchaseOrderDetailPage extends StatefulWidget {
  const PurchaseOrderDetailPage({
    super.key,
    required this.order,
    this.username = 'PASS User',
  });

  final PurchaseOrderSummary order;
  final String username;

  @override
  State<PurchaseOrderDetailPage> createState() =>
      _PurchaseOrderDetailPageState();
}

class _LineInput {
  _LineInput(PurchaseOrderLine line)
      : line = line,
        receivedCtrl = TextEditingController(
          text: _qtyText(line.quantity),
        ),
        batchCtrl = TextEditingController();

  final PurchaseOrderLine line;
  final TextEditingController receivedCtrl;
  final TextEditingController batchCtrl;
  bool isFree = false;
  String binLocation = '';

  String get binText {
    if (binLocation.isNotEmpty) return binLocation;
    final wh = line.warehouseCode.isNotEmpty ? line.warehouseCode : '01';
    return '$wh / -';
  }

  static String _qtyText(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void dispose() {
    receivedCtrl.dispose();
    batchCtrl.dispose();
  }
}

class _PurchaseOrderDetailPageState extends State<PurchaseOrderDetailPage> {
  final _deliveryNoteCtrl = TextEditingController();
  final _receiveDateCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  PurchaseOrderSummary? _order;
  List<_LineInput> _lines = [];
  bool _addFreeItem = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _receiveDateCtrl.text = _formatDate(DateTime.now());
    _load();
  }

  @override
  void dispose() {
    _deliveryNoteCtrl.dispose();
    _receiveDateCtrl.dispose();
    for (final row in _lines) {
      row.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      PurchaseOrderSummary order;
      try {
        order = await PurchaseOrderService.fetchDetail(widget.order.docEntry);
      } catch (_) {
        order = widget.order;
      }

      if (!mounted) return;
      setState(() {
        _order = order;
        _lines = order.lines.map(_LineInput.new).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomePage(username: widget.username)),
      (_) => false,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: AppTextStyles.text(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.accentGreen,
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption()),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.text(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint(),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  static const _colProduct = 210.0;
  static const _colOrderQty = 76.0;
  static const _colReceiveQty = 84.0;
  static const _colFree = 48.0;
  static const _colBatch = 136.0;
  static const _colBin = 140.0;

  InputDecoration _compactInput({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint(),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _tableHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          text,
          style: AppTextStyles.text(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _tableCell(Widget child, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: child,
      ),
    );
  }

  String _qtyText(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  Widget _productCell(PurchaseOrderLine line) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primaryBlue,
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.itemCode,
                style: AppTextStyles.text(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                line.displayName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _lineTableRow(_LineInput row) {
    final line = row.line;
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray),
        ),
      ),
      children: [
        _tableCell(_productCell(line), _colProduct),
        _tableCell(
          Text(
            _qtyText(line.quantity),
            textAlign: TextAlign.center,
            style: AppTextStyles.text(fontWeight: FontWeight.w600),
          ),
          _colOrderQty,
        ),
        _tableCell(
          TextField(
            controller: row.receivedCtrl,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: _compactInput(),
          ),
          _colReceiveQty,
        ),
        _tableCell(
          Center(
            child: Checkbox(
              value: row.isFree,
              activeColor: AppColors.accentGreen,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (v) => setState(() => row.isFree = v ?? false),
            ),
          ),
          _colFree,
        ),
        _tableCell(
          TextField(
            controller: row.batchCtrl,
            decoration: _compactInput(hint: 'LOT...'),
          ),
          _colBatch,
        ),
        _tableCell(
          Text(
            row.binText,
            style: AppTextStyles.text(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          _colBin,
        ),
      ],
    );
  }

  Widget _linesTable() {
    final tableWidth = _colProduct +
        _colOrderQty +
        _colReceiveQty +
        _colFree +
        _colBatch +
        _colBin;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(_colProduct),
              1: FixedColumnWidth(_colOrderQty),
              2: FixedColumnWidth(_colReceiveQty),
              3: FixedColumnWidth(_colFree),
              4: FixedColumnWidth(_colBatch),
              5: FixedColumnWidth(_colBin),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                ),
                children: [
                  _tableHeaderCell('สินค้า / รายละเอียด', _colProduct),
                  _tableHeaderCell('จำนวนที่สั่ง\n(ชิ้น)', _colOrderQty),
                  _tableHeaderCell('จำนวนรับ\n(ชิ้น)', _colReceiveQty),
                  _tableHeaderCell('ฟรี', _colFree),
                  _tableHeaderCell('Batch / Lot No.', _colBatch),
                  _tableHeaderCell('คลัง / Bin Location', _colBin),
                ],
              ),
              for (final row in _lines) _lineTableRow(row),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        required ? '$text *' : text,
        style: AppTextStyles.label(),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppTextStyles.body()),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    final order = _order ?? widget.order;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard(
            children: [
              _infoRow('เลขที่เอกสาร (PO)', order.poNo,
                  valueColor: AppColors.accentGreen),
              _infoRow('วันที่เอกสาร', order.dateText),
              _infoRow('ชื่อลูกค้า', order.cardName),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('ข้อมูลการรับสินค้า'),
          _fieldLabel('วันที่รับสินค้า', required: true),
          TextField(
            controller: _receiveDateCtrl,
            readOnly: true,
            decoration: _inputDecoration(
              suffix: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('เลขที่ใบส่งของ', required: true),
          TextField(
            controller: _deliveryNoteCtrl,
            decoration: _inputDecoration(hint: 'DN...'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _sectionTitle('รายการสินค้า (${_lines.length})'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentGreen,
                  side: const BorderSide(color: AppColors.accentGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('เพิ่มรายการสินค้า'),
              ),
            ],
          ),
          if (_lines.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ยังไม่มีรายการสินค้า\n(รอ backend ส่ง lines[] มา)',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle(),
              ),
            )
          else
            _linesTable(),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _addFreeItem,
                activeColor: AppColors.accentGreen,
                onChanged: (v) => setState(() => _addFreeItem = v ?? false),
              ),
              const Text('เพิ่มรายการสินค้าฟรี'),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('แนบเอกสาร'),
          Text('ใบส่งของ / Delivery Note', style: AppTextStyles.caption()),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('ถ่ายภาพ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          WmsPageHeader(
            title: 'Purchase Order Detail',
            onBack: () => Navigator.pop(context),
            onHome: _goHome,
          ),
          Expanded(child: _body()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: AppColors.accentGreen, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_2_outlined),
                  label: Text(
                    'พิมพ์ Label',
                    style: AppTextStyles.text(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    minimumSize: const Size(0, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _saving
                      ? const SizedBox.shrink()
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('บันทึก', style: AppTextStyles.button()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
