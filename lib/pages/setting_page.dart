import 'package:flutter/material.dart';
import 'package:foodie/services/channel.dart';
import 'package:provider/provider.dart';
import 'package:foodie/view_models/account_vm.dart';
import '../view_models/settings_page_view_model.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ** 關鍵修復：現在只監聽 SettingsPageViewModel **
    // 它是 nullable (?)，因為使用者可能尚未登入，此時 ProxyProvider 會返回 null。
    return Consumer<SettingsPageViewModel?>(
      builder: (context, settingsVM, child) {
        // 如果用戶未登入，settingsVM 會是 null。
        // 我們從 viewModel 直接獲取登入狀態，如果 viewModel 為 null，則認定為未登入。
        final bool isLoggedIn = settingsVM?.isLoggedIn ?? false;
        final speechSpeed = settingsVM?.userProfile?.defaultSpeechRate ?? 1.0;
        final isLoading = settingsVM?.state == SettingsPageState.loading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('設定'),
            automaticallyImplyLeading: false,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Account Section
                    _buildAccountSection(context, settingsVM),
                    const SizedBox(height: 16),
                    // Screen Capture Section (只在登入後顯示)
                    if (isLoggedIn)
                      _buildScreenCaptureSection(context),
                    const SizedBox(height: 16),
                    // Speech Settings Section (只在登入後顯示)
                    if (isLoggedIn)
                      _buildSpeechSettingsSection(context, speechSpeed, settingsVM),
                    const SizedBox(height: 16),
                    // App Settings Section
                    _buildAppSettingsSection(context),
                    const SizedBox(height: 16),
                    // About Section
                    _buildAboutSection(context),
                  ],
                ),
        );
      },
    );
  }

  // --- Widget Builder Methods ---

  Widget _buildAccountSection(BuildContext context, SettingsPageViewModel? settingsVM) {
    // 如果 settingsVM 為 null 或 isLoggedIn 為 false，顯示登入按鈕
    if (settingsVM == null || !settingsVM.isLoggedIn) {
      // 為了在未登入時也能觸發登入，我們需要一個能呼叫 signInWithGoogle 的對象。
      // 這裡我們直接從 Provider 讀取一次 AccountViewModel 來使用。
      // 這是 Provider 的一個常見用法：`context.read` 用於觸發事件，`context.watch` 或 `Consumer` 用於監聽狀態。
      final accountVMForAction = context.read<AccountViewModel>();
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('帳號', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('尚未登入'),
                subtitle: const Text('登入以同步您的學習進度'),
                trailing: ElevatedButton(
                  onPressed: () => accountVMForAction.signInWithGoogle(),
                  child: const Text('Google 登入'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 已登入，顯示用戶資訊
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('帳號', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                backgroundImage: settingsVM.userPhotoUrl.isNotEmpty
                    ? NetworkImage(settingsVM.userPhotoUrl)
                    : null,
                child: settingsVM.userPhotoUrl.isEmpty
                    ? Text(
                        settingsVM.userName.isNotEmpty ? settingsVM.userName[0].toUpperCase() : 'G',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              title: Text(settingsVM.userName),
              subtitle: Text(settingsVM.userEmail),
              trailing: IconButton(
                onPressed: () => settingsVM.signOut(),
                icon: const Icon(Icons.logout),
                tooltip: '登出',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenCaptureSection(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isScreenCaptureOn = false; // 暫時的本地狀態
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('螢幕擷取', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('啟用螢幕擷取'),
                  subtitle: const Text('擷取螢幕內容以生成單字卡'),
                  value: isScreenCaptureOn,
                  onChanged: (bool value) async {
                    setState(() { isScreenCaptureOn = value; });
                    if (isScreenCaptureOn) {
                      await startProjection();
                      _showSnackBar(context, '螢幕擷取已啟用');
                    } else {
                      await stopProjection();
                      _showSnackBar(context, '螢幕擷取已停用');
                    }
                  },
                  secondary: const Icon(Icons.screen_share),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeechSettingsSection(
      BuildContext context, double speechSpeed, SettingsPageViewModel? settingsVM) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('語音設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('語音速度'),
              subtitle: Text('目前速度: ${speechSpeed.toStringAsFixed(1)}x'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showSpeechSpeedDialog(context, speechSpeed, settingsVM),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppSettingsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('App 設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('深色模式'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  _showSnackBar(context, '主題切換功能尚未實作');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('關於', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('App 版本'),
              subtitle: Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialogs and Helpers ---

  void _showSpeechSpeedDialog(
      BuildContext context, double currentSpeed, SettingsPageViewModel? settingsVM) {
    double tempSpeed = currentSpeed;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('調整語音速度'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('速度: ${tempSpeed.toStringAsFixed(1)}x'),
              Slider(
                value: tempSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) {
                  setDialogState(() { tempSpeed = value; });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsVM?.updateSpeechRate(tempSpeed);
              Navigator.pop(context);
              _showSnackBar(context, '語音速度已更新');
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}