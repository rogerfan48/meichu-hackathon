import 'package:flutter/material.dart';
import 'package:lexiaid/services/channel.dart';
import 'package:provider/provider.dart';
import '../view_models/account_vm.dart';
import '../view_models/settings_page_view_model.dart';
import '../services/theme.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  bool _isAccessibilityOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccessibilityStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibilityStatus();
    }
  }

  Future<void> _checkAccessibilityStatus() async {
    final bool isEnabled = await isScreenReaderEnabled();
    if (mounted) {
      setState(() {
        _isAccessibilityOn = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsPageViewModel?>(
      builder: (context, settingsVM, child) {
        final isLoading = settingsVM?.state == SettingsPageState.loading && settingsVM?.isLoggedIn == true;

        return Scaffold(
          appBar: AppBar(
            title: const Text('設定'),
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildAccountSection(context, settingsVM), // ** 這裡將被修改 **
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      context,
                      title: '功能設定',
                      children: [
                        _buildSpeechSettingsTile(context, settingsVM),
                        _buildScreenCaptureSwitch(context, settingsVM),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      context,
                      title: 'App 設定',
                      children: [
                        _buildThemeSwitch(context),
                        _buildInfoTile(context, icon: Icons.info_outline, title: 'App 版本', subtitle: '1.0.0'),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
  
  // --- Section Builders ---

  // ** 關鍵修改：重構帳號區塊為水平佈局 **
  Widget _buildAccountSection(BuildContext context, SettingsPageViewModel? settingsVM) {
    final bool isLoggedIn = settingsVM?.isLoggedIn ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            // 頭像
            CircleAvatar(
              radius: 30,
              backgroundImage: (isLoggedIn && settingsVM!.userPhotoUrl.isNotEmpty)
                  ? NetworkImage(settingsVM.userPhotoUrl)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: (isLoggedIn && settingsVM!.userPhotoUrl.isNotEmpty)
                  ? null
                  : Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey.shade600,
                    ),
            ),
            const SizedBox(width: 16),
            // 右側資訊與按鈕
            Expanded(
              child: isLoggedIn
                  ? _buildUserInfo(context, settingsVM!)
                  : _buildLoginButton(context),
            ),
          ],
        ),
      ),
    );
  }
  
  // 已登入時顯示的 Widget
  Widget _buildUserInfo(BuildContext context, SettingsPageViewModel settingsVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          settingsVM.userName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          settingsVM.userEmail,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // 將登出按鈕做得更小巧
        SizedBox(
          height: 30,
          child: TextButton(
            onPressed: () => settingsVM.signOut(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              foregroundColor: Colors.red,
            ),
            child: const Text('登出'),
          ),
        )
      ],
    );
  }

  // 未登入時顯示的 Widget
  Widget _buildLoginButton(BuildContext context) {
    final accountVMForAction = context.read<AccountViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '訪客',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '登入以同步您的進度',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: () => accountVMForAction.signInWithGoogle(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Google 登入', style: TextStyle(fontSize: 12)),
          ),
        )
      ],
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required String title, required List<Widget> children}) {
    // ... 此方法保持不變 ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8),
          child: Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }
  
  // ... 其他所有 Tile Builders 和 Dialogs 保持不變 ...
  Widget _buildSpeechSettingsTile(BuildContext context, SettingsPageViewModel? settingsVM) {
    if (settingsVM == null) return const SizedBox.shrink();
    final speechSpeed = settingsVM.userProfile?.defaultSpeechRate ?? 1.0;
    
    return ListTile(
      leading: const Icon(Icons.speed),
      title: const Text('語音速度'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${speechSpeed.toStringAsFixed(1)}x'),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () => _showSpeechSpeedDialog(context, speechSpeed, settingsVM),
    );
  }

  Widget _buildScreenCaptureSwitch(BuildContext context, SettingsPageViewModel? settingsVM) {
    if (settingsVM == null) return const SizedBox.shrink();
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          secondary: const Icon(Icons.screen_share),
          title: const Text('啟用螢幕擷取'),
          value: _isAccessibilityOn,
          onChanged: (bool value) async {
            setState(() { _isAccessibilityOn = value; });
            if (_isAccessibilityOn) {
              await startProjection();
              _showSnackBar(context, '螢幕擷取已啟用');
            } else {
              await stopProjection();
              _showSnackBar(context, '螢幕擷取已停用');
            }
          },
        );
      },
    );
  }

  Widget _buildThemeSwitch(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDarkMode = themeService.themeMode == ThemeMode.dark ||
        (themeService.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
            
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode_outlined),
      title: const Text('深色模式'),
      value: isDarkMode,
      onChanged: (bool value) {
        context.read<ThemeService>().toggleTheme();
      },
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  void _showSpeechSpeedDialog(BuildContext context, double currentSpeed, SettingsPageViewModel settingsVM) {
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
                onChanged: (value) => setDialogState(() => tempSpeed = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              settingsVM.updateSpeechRate(tempSpeed);
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
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}