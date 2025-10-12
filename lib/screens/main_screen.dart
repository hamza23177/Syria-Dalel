import 'package:flutter/material.dart';
import '../constant.dart';
import 'category/view.dart';
import 'contact/view.dart';
import 'home/view.dart';

class PersistentBtmBarExample extends StatefulWidget {
  const PersistentBtmBarExample({super.key});

  @override
  State<PersistentBtmBarExample> createState() =>
      _PersistentBtmBarExampleState();
}

class _PersistentBtmBarExampleState extends State<PersistentBtmBarExample> {
  int _index = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      CategoriesScreen(),
      ContactView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_index],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                label: 'الرئيسية',
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: 'الأقسام',
                icon: Icon(Icons.category),
              ),
              BottomNavigationBarItem(
                label: 'تواصل معنا',
                icon: Icon(Icons.contact_mail),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- الشاشات بدون ScrollController ---

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "الإعلانات",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "تواصل معنا",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
