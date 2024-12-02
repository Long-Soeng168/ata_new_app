import 'package:ata_new_app/pages/dtc/dtc_page.dart';
import 'package:ata_new_app/pages/trainings/trainings_page.dart';
import 'package:ata_new_app/pages/garages/garages_page.dart';
import 'package:ata_new_app/pages/home/home_page.dart';
import 'package:ata_new_app/pages/shops/shops_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const ShopsPage(),
    const GaragesPage(),
    const DtcPage(),
    const TrainingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: _selectedIndex == 0
                ? Image.asset(
                    'lib/assets/icons/home.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'lib/assets/icons/home_outline.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: "Shop",
            icon: _selectedIndex == 1
                ? Image.asset(
                    'lib/assets/icons/shop.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'lib/assets/icons/shop_outline.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: "Garage",
            icon: _selectedIndex == 2
                ? Image.asset(
                    'lib/assets/icons/garage.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'lib/assets/icons/garage_outline.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: "DTC",
            icon: _selectedIndex == 3
                ? Image.asset(
                    'lib/assets/icons/dtc.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'lib/assets/icons/dtc_outline.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: "Trainings",
            icon: _selectedIndex == 4
                ? Image.asset(
                    'lib/assets/icons/training.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'lib/assets/icons/training_outline.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade400,
        onTap: _onItemTapped,
      ),
    );
  }
}
