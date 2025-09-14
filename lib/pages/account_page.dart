import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/services/theme.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/services/map_position.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child:
            trailing ??
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final themeService = context.watch<ThemeService>();
    final accountViewModel = context.watch<AccountViewModel>(); // Watch the ViewModel

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  children: [
                    if (accountViewModel.isLoggedIn &&
                        accountViewModel.firebaseUser?.photoURL != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(accountViewModel.firebaseUser!.photoURL!),
                        radius: 40,
                      )
                    else
                      Icon(Icons.account_circle, size: 80, color: colorScheme.inverseSurface),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          accountViewModel.isLoggedIn
                              ? _buildUserInfo(
                                context,
                                accountViewModel,
                              ) // Show user info and logout
                              : _buildLoginButton(context, accountViewModel), // Show login button
                    ),
                  ],
                ),
              ),
              _buildSettingsTile(
                context,
                title: 'Browsing History',
                onTap:
                    accountViewModel.isLoggedIn
                        ? () => GoRouter.of(context).push('/account/history')
                        : () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please log in to view your history.')),
                          );
                        },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                title: 'My Review',
                onTap:
                    accountViewModel.isLoggedIn
                        ? () => GoRouter.of(context).push('/account/reviews')
                        : () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please log in to view your reviews.')),
                          );
                        },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                title: 'Start Tutorial',
                onTap: () {
                  context.read<MapPositionService>().triggerTutorial();
                  GoRouter.of(context).go('/map');
                },
                trailing: Icon(Icons.play_circle_fill, color: colorScheme.secondary),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                title: 'Dark Theme',
                onTap: () => themeService.toggleTheme(),
                trailing: Switch(
                  value: themeService.isDarkMode,
                  onChanged: (value) => themeService.toggleTheme(),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to show when user is not logged in
  Widget _buildLoginButton(BuildContext context, AccountViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => viewModel.signInWithGoogle(),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          ),
          child: Row(
            children: [
              Icon(Icons.login, color: colorScheme.onPrimary),
              const SizedBox(width: 12),
              Text(
                'Log in with Google',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget to show when user is logged in
  Widget _buildUserInfo(BuildContext context, AccountViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewModel.firebaseUser?.displayName ?? 'Welcome!',
          style: textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          viewModel.firebaseUser?.email ?? '',
          style: textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => viewModel.signOut(), child: const Text('Log Out')),
      ],
    );
  }
}
