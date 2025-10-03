import 'package:ata_new_app/pages/accounts/account_settings_page.dart';
import 'package:ata_new_app/pages/auth/login_page.dart';
import 'package:ata_new_app/pages/garages/garage_admin/admin_garage_detail_page.dart';
import 'package:ata_new_app/pages/garages/garage_admin/garage_create_page.dart';
import 'package:ata_new_app/pages/shops/shop_admin/admin_shop_page.dart';
import 'package:ata_new_app/pages/shops/shop_admin/shop_create_page.dart';
import 'package:ata_new_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});
  final AuthService _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      final userInfo = await _authService.getUserInfo();
      final userShop = await _authService.getUserShop();
      final userGarage = await _authService.getUserGarage();
      return {
        'userInfo': userInfo,
        'userShop': userShop,
        'userGarage': userGarage,
      };
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching data
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || (snapshot.data?['error'] ?? false)) {
          // If there's an error or no valid user, display an error message
          return Drawer(
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    backgroundColor: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.1), // Subtle background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.login,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final userInfo = snapshot.data!['userInfo'];
        if (userInfo == null || !(userInfo['success'] ?? false)) {
          return Drawer(
            child: ListView(
              children: [
                const ListTile(
                  leading: Icon(Icons.account_circle, size: 42.0),
                  title: Text('Not logged in'),
                ),
                ..._buildDrawerItems(context, null, null, null),
              ],
            ),
          );
        }

        final user = userInfo['user'];
        final userShop = snapshot.data!['userShop'];
        final userGarage = snapshot.data!['userGarage'];

        return Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                accountName: Text(user['name'] ?? 'Unknown User'),
                accountEmail: Text(user['email'] ?? 'No email'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: (user['image'] != null &&
                          user['image'].toString().isNotEmpty)
                      ? NetworkImage(
                          'https://atech-auto.com/assets/images/users/thumb/${user['image']}')
                      : null,
                  child: (user['image'] == null ||
                          user['image'].toString().isEmpty)
                      ? const Icon(Icons.account_circle, size: 42.0)
                      : null,
                ),
              ),
              ..._buildDrawerItems(context, userShop, userGarage, user),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDrawerItems(
    BuildContext context,
    Map<String, dynamic>? userShop,
    Map<String, dynamic>? userGarage,
    Map<String, dynamic>? user,
  ) {
    return [
      ListTile(
        title: Text('Account Settings'),
        leading: Icon(
          Icons.account_circle_outlined,
          size: 28,
        ),
        onTap: () {
          Navigator.pop(context);
          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountSettingsPage(user: user),
              ),
            );
          }
        },
      ),
      ListTile(
        title: Text(userShop == null || !(userShop['success'] ?? false)
            ? 'Create Shop'
            : 'View Shop'),
        leading: Image.asset(
          'lib/assets/icons/shop_outline.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        onTap: () {
          Navigator.pop(context);
          if (userShop == null || !(userShop['success'] ?? false)) {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopCreatePage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminShopPage(shop: userShop['shop']),
              ),
            );
          }
        },
      ),
      ListTile(
        title: Text(userGarage == null || !(userGarage['success'] ?? false)
            ? 'Create Garage'
            : 'View Garage'),
        leading: Image.asset(
          'lib/assets/icons/garage_outline.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        onTap: () {
          Navigator.pop(context);
          if (userGarage == null || !(userGarage['success'] ?? false)) {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GarageCreatePage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminGarageDetailPage(garage: userGarage['garage']),
              ),
            );
          }
        },
      ),
      // ListTile(
      //   title: const Text('Favorites'),
      //   leading: const Icon(Icons.favorite_outline),
      //   onTap: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => FavoritePage()),
      //     );
      //   },
      // ),
      // ListTile(
      //   title: const Text('Settings'),
      //   leading: const Icon(Icons.settings_outlined),
      //   onTap: () {
      //     Navigator.pop(context);
      //   },
      // ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => _logout(context),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_outlined, color: Colors.white),
              SizedBox(width: 8.0),
              Text('Logout', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    ];
  }
}
