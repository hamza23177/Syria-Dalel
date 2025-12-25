//screens/main_screen.dart

import 'package:flutter/material.dart';
import '../constant.dart';
import 'category/view.dart';
import 'contact/view.dart';
// لم نعد بحاجة لاستيراد home/view.dart لأننا دمجناها

class PersistentBtmBarExample extends StatefulWidget {
  const PersistentBtmBarExample({super.key});

  @override
  State<PersistentBtmBarExample> createState() =>
      _PersistentBtmBarExampleState();
}

class _PersistentBtmBarExampleState extends State<PersistentBtmBarExample> {
  int _index = 0; // سيبدأ تلقائياً من الأقسام لأنها ستكون في المؤشر 0

  // تعريف الشاشات كثوابت للحفاظ على الحالة (Performance Optimization)
  final List<Widget> _screens = [
    const CategoriesScreen(), // أصبحت هي الرئيسية
    const ContactView(),      // تواصل معنا
    // يمكنك إضافة شاشة ثالثة هنا مثل "المفضلة" أو "حسابي" مستقبلاً
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // استخدام IndexedStack يحافظ على حالة الشاشة عند التبديل (مهم جداً للأداء)
        body: IndexedStack(
          index: _index,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                label: 'الرئيسية', // غيرنا الاسم ليتناسب مع موقعها الجديد
                icon: Icon(Icons.dashboard_rounded), // أيقونة تعبر عن الأقسام والخدمات
              ),
              BottomNavigationBarItem(
                label: 'تواصل معنا',
                icon: Icon(Icons.support_agent_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}