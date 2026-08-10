import 'package:flutter/material.dart';

import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/purchase_order_card.dart';
import '../widgets/wms_bottom_nav.dart';
import '../widgets/wms_page_header.dart';
import 'home.dart';
import 'receive.dart';

class PurchaseOrderListPage extends StatefulWidget {
  const PurchaseOrderListPage({super.key, this.username = 'PASS User'});

  final String username;

  @override
  State<PurchaseOrderListPage> createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<PurchaseOrderSummary> _orders = [];
  PurchaseOrderTab _selectedTab = PurchaseOrderTab.waiting;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await PurchaseOrderService.fetchPurchaseOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomePage(username: widget.username)),
      (route) => false,
    );
  }

  void _onNavTap(WmsNavItem item) {
    switch (item) {
      case WmsNavItem.home:
        _goHome();
      case WmsNavItem.receive:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceivePage(username: widget.username),
          ),
        );
      case WmsNavItem.stock:
      case WmsNavItem.menu:
        break;
    }
  }

  int _countForTab(PurchaseOrderTab tab) {
    return _orders.where((order) => order.tab == tab).length;
  }

  List<PurchaseOrderSummary> get _filteredOrders {
    final query = _searchController.text.trim();
    return _orders
        .where((order) => order.tab == _selectedTab)
        .where((order) => order.matchesSearch(query))
        .toList();
  }

  Widget _tabButton({
    required String label,
    required int count,
    required PurchaseOrderTab tab,
  }) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = tab),
        child: Column(
          children: [
            Text(
              '$label ($count)',
              textAlign: TextAlign.center,
              style: AppTextStyles.text(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accentGreen : AppColors.textGray,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.body(color: AppColors.primaryBlue),
            decoration: InputDecoration(
              hintText: 'ค้นหาเลขที่เอกสาร / ชื่อลูกค้า',
              hintStyle: AppTextStyles.hint(),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryBlue,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _bodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: Text('ลองใหม่', style: AppTextStyles.button()),
              ),
            ],
          ),
        ),
      );
    }

    final orders = _filteredOrders;
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบ Purchase Order',
          style: AppTextStyles.subtitle(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primaryBlue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return PurchaseOrderCard(order: orders[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          WmsPageHeader(
            title: 'Purchase Order',
            onHome: _goHome,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _searchBar(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _tabButton(
                  label: 'รอรับสินค้า',
                  count: _countForTab(PurchaseOrderTab.waiting),
                  tab: PurchaseOrderTab.waiting,
                ),
                _tabButton(
                  label: 'บางส่วน',
                  count: _countForTab(PurchaseOrderTab.partial),
                  tab: PurchaseOrderTab.partial,
                ),
                _tabButton(
                  label: 'รับครบแล้ว',
                  count: _countForTab(PurchaseOrderTab.complete),
                  tab: PurchaseOrderTab.complete,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _bodyContent()),
          WmsBottomNav(
            current: WmsNavItem.receive,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}
