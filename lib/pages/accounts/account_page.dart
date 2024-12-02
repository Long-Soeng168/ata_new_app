import 'package:ata_new_app/pages/auth/login_page.dart';
import 'package:ata_new_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _authService = AuthService();
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if user is logged in by verifying the token
    final token = await _authService.getToken();

    if (token == null) {
      // If no token, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Fetch user info if logged in
      await _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    final response = await _authService.getUserInfo();
    if (response['success']) {
      setState(() {
        _userName = response['user']['name']; // Display only the name
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildMenuItem(Icons.person, 'Profile', () {
                    // Navigate to profile screen
                  }),
                  _buildMenuItem(Icons.history, 'Order History', () {
                    // Navigate to order history screen
                  }),
                  _buildMenuItem(Icons.payment, 'Payment Methods', () {
                    // Navigate to payment methods screen
                  }),
                  _buildMenuItem(Icons.security, 'Security Settings', () {
                    // Navigate to security settings screen
                  }),
                  _buildMenuItem(Icons.help, 'Help & Support', () {
                    // Navigate to help and support screen
                  }),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _logout,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_outlined, color: Colors.white),
                          Text('Logout', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage('assets/profile_picture.png'),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle the error by setting a placeholder image/icon
            },
            child: const Icon(
              Icons.person, // Display this icon if image fails
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName ?? 'Loading...',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
      ),
      onTap: onTap,
    );
  }
}
