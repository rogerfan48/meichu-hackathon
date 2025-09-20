import 'package:flutter/material.dart';
import 'package:foodie/services/channel.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isScreenCaptureOn = false;
  bool _isLoggedIn = false; // TODO: Connect to auth service
  double _speechSpeed = 1.0;
  String _userName = 'Guest'; // TODO: Connect to user model
  String _userEmail = ''; // TODO: Connect to user model

  @override
  void initState() {
    super.initState();
    _loadUserData(); // TODO: Load from backend
  }

  void _loadUserData() {
    // TODO: Load user data from auth service
    setState(() {
      _isLoggedIn = false; // Replace with actual auth status
      _userName = 'John Doe';
      _userEmail = 'john.doe@example.com';
    });
  }

  Future<void> _signIn() async {
    // TODO: Implement sign in logic
    setState(() {
      _isLoggedIn = true;
      _userName = 'John Doe';
      _userEmail = 'john.doe@example.com';
    });
    _showSnackBar('Signed in successfully!');
  }

  Future<void> _signOut() async {
    // TODO: Implement sign out logic
    setState(() {
      _isLoggedIn = false;
      _userName = 'Guest';
      _userEmail = '';
    });
    _showSnackBar('Signed out successfully!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSignInDialog() {
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => email = value,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => password = value,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signIn(); // TODO: Pass email and password
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showSpeechSpeedDialog() {
    double tempSpeed = _speechSpeed;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech Speed'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Speed: ${tempSpeed.toStringAsFixed(1)}x'),
              Slider(
                value: tempSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) {
                  setDialogState(() {
                    tempSpeed = value;
                  });
                },
              ),
              const Text('0.5x                    2.0x'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _speechSpeed = tempSpeed;
              });
              Navigator.pop(context);
              // TODO: Save speech speed to backend
              _showSnackBar('Speech speed updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Account Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoggedIn) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'G',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(_userName),
                      subtitle: Text(_userEmail),
                      trailing: IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        tooltip: 'Sign Out',
                      ),
                    ),
                  ] else ...[
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: const Text('Not signed in'),
                      subtitle: const Text('Sign in to sync your progress'),
                      trailing: ElevatedButton(
                        onPressed: _showSignInDialog,
                        child: const Text('Sign In'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Screen Capture Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Screen Capture',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Screen Capture'),
                    subtitle: const Text('Capture screen content to generate flashcards'),
                    value: _isScreenCaptureOn,
                    onChanged: (bool value) async {
                      setState(() {
                        _isScreenCaptureOn = value;
                      });
                      if (_isScreenCaptureOn) {
                        await startProjection();
                        _showSnackBar('Screen capture enabled');
                      } else {
                        await stopProjection();
                        _showSnackBar('Screen capture disabled');
                      }
                    },
                    secondary: const Icon(Icons.screen_share),
                  ),
                  if (_isScreenCaptureOn) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Screen capture is active. Words from your screen will be automatically added to your flashcard collection.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Speech Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Speech Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.speed),
                    title: const Text('Speech Speed'),
                    subtitle: Text('Current speed: ${_speechSpeed.toStringAsFixed(1)}x'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showSpeechSpeedDialog,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Voice Recognition'),
                    subtitle: const Text('Enable voice recognition for pronunciation practice'),
                    value: true, // TODO: Connect to actual setting
                    onChanged: (bool value) {
                      // TODO: Implement voice recognition toggle
                      _showSnackBar('Voice recognition ${value ? 'enabled' : 'disabled'}');
                    },
                    secondary: const Icon(Icons.mic),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (bool value) {
                        // TODO: Implement theme switching
                        _showSnackBar('Theme switching not implemented yet');
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement language selection
                      _showSnackBar('Language selection not implemented yet');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification preferences'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement notification settings
                      _showSnackBar('Notification settings not implemented yet');
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to help page
                      _showSnackBar('Help page not implemented yet');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to privacy policy
                      _showSnackBar('Privacy policy not implemented yet');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}