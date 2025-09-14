import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({
    super.key,
    required this.restaurantId,
    required this.child,
  });

  final String restaurantId;
  final Widget child;

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RegExp(r'/map/restaurant/(\w{20})/menu'))) {
      _tabController.index = 1;
    } else if (location.endsWith('/reviews')) {
      _tabController.index = 2;
    } else {
      _tabController.index = 0;
    }
  }

    void _onTabTapped(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/map/restaurant/${widget.restaurantId}/info');
        break;
      case 1:
        GoRouter.of(context).go('/map/restaurant/${widget.restaurantId}/menu');
        break;
      case 2:
        GoRouter.of(context).go('/map/restaurant/${widget.restaurantId}/reviews');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 36),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(vm.restaurantName),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabTapped,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Menu'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator()) // ✅ 加上 Loading 狀態
          : widget.child, // GoRouter 會把 Info/Menu/Reviews Page 作為 child 放在這裡
    );
  }
}
