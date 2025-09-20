import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/cards_page_view_model.dart';
import '../view_models/account_vm.dart';
import '../widgets/flashcard/game_view.dart';
import '../widgets/flashcard/management_view.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();
    if (!accountVM.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('單字卡'), automaticallyImplyLeading: false),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              '請先至「設定」頁面登入以使用單字卡功能。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Consumer<CardsPageViewModel?>(
      builder: (context, viewModel, child) {
        if (viewModel == null) {
          return const Scaffold(body: Center(child: Text('ViewModel 初始化中...')));
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('單字卡'),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                tabs: const [
                  Tab(text: '管理卡片', icon: Icon(Icons.view_list)),
                  Tab(text: '遊戲模式', icon: Icon(Icons.games)),
                ],
                onTap: (index) {
                  // 從遊戲模式切換走時，重設遊戲狀態
                  if (viewModel.gameState != GameState.setup && index == 0) {
                    viewModel.endGame();
                  }
                },
              ),
            ),
            body: _buildBody(context, viewModel),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CardsPageViewModel viewModel) {
    switch (viewModel.pageState) {
      case CardsPageState.loading:
        return const Center(child: CircularProgressIndicator());
      case CardsPageState.error:
        return Center(child: Text(viewModel.errorMessage ?? '發生未知錯誤'));
      case CardsPageState.idle:
        return TabBarView(
          physics: const NeverScrollableScrollPhysics(), // 禁止滑動切換 Tab
          children: [
            CardManagementView(viewModel: viewModel),
            GameView(viewModel: viewModel),
          ],
        );
    }
  }
}