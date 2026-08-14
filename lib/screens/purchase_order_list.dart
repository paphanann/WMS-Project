import 'package:flutter/material.dart';

import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/purchase_order_card.dart';
import '../widgets/wms_bottom_nav.dart';
import '../widgets/wms_page_header.dart';
import 'home.dart';
import 'purchase_order_detail.dart';
import 'receive.dart';

class PurchaseOrderListPage extends StatefulWidget {
  const PurchaseOrderListPage({super.key, this.username = 'PASS User'});

  final String username;

  @override
  State<PurchaseOrderListPage> createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final _search = TextEditingController();

  bool _loading = true;
  String? _error;
  List<PurchaseOrderSummary> _orders = [];
  PoTab _tab = PoTab.open;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orders = await PurchaseOrderService.fetchList();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        if (orders.any((o) => o.tab == PoTab.open)) {
          _tab = PoTab.open;
        } else if (orders.any((o) => o.tab == PoTab.closed)) {
          _tab = PoTab.closed;
        }
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

  void _onNavTap(WmsNavItem item) {
    if (item == WmsNavItem.home) {
      _goHome();
      return;
    }
    if (item == WmsNavItem.receive) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceivePage(username: widget.username),
        ),
      );
    }
  }

  int _count(PoTab tab) => _orders.where((o) => o.tab == tab).length;

  List<PurchaseOrderSummary> get _visible {
    final q = _search.text.trim();
    return _orders.where((o) => o.tab == _tab).where((o) => o.matchQuery(q)).toList();
  }

  Widget _tabItem(String label, PoTab tab) {
    final selected = _tab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = tab),
        child: Column(
          children: [
            Text(
              '$label (${_count(tab)})',
              textAlign: TextAlign.center,
              style: AppTextStyles.text(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.accentGreen : AppColors.textGray,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 3,
              color: selected ? AppColors.accentGreen : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
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
            ElevatedButton(
              onPressed: _load,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    final list = _visible;
    if (list.isEmpty) {
      return Center(
        child: Text(
          _orders.isEmpty ? 'ไม่พบ Purchase Order' : 'ไม่มี PO ในแท็บนี้',
          style: AppTextStyles.subtitle(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) => PurchaseOrderCard(
          order: list[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseOrderDetailPage(
                order: list[i],
                username: widget.username,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          WmsPageHeader(title: 'Purchase Order', onHome: _goHome),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ค้นหาเลขที่เอกสาร / ชื่อลูกค้า',
                hintStyle: AppTextStyles.hint(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _tabItem('รอรับสินค้า', PoTab.open),
                _tabItem('รับครบแล้ว', PoTab.closed),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _content()),
          WmsBottomNav(current: WmsNavItem.receive, onTap: _onNavTap),
        ],
      ),
    );
  }
}
