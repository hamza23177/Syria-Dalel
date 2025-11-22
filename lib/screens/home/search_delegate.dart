import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constant.dart'; // تأكد من المسار
import '../../models/home_model.dart'; // تأكد من المسار
// استيراد صفحات التفاصيل للانتقال إليها
import '../details/view.dart';
import '../category/view.dart'; // أو SubCategoryScreen

class ProfessionalSearchDelegate extends SearchDelegate {
  final List<Product> products;
  final List<Category> categories;
  final List<SubCategory> subCategories;

  ProfessionalSearchDelegate({
    required this.products,
    required this.categories,
    required this.subCategories,
  });

  // تخصيص ثيم شريط البحث ليتناسب مع التطبيق
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        toolbarHeight: 70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentOrSuggested(context);
    }
    return _buildSearchResults(context);
  }

  // --- واجهة الاقتراحات (عندما يكون البحث فارغاً) ---
  Widget _buildRecentOrSuggested(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "اكتشف شيئاً جديداً 🔥",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.take(6).map((cat) {
              return ActionChip(
                label: Text(cat.name),
                avatar: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(cat.imageUrl),
                  backgroundColor: Colors.transparent,
                ),
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black12,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onPressed: () {
                  query = cat.name;
                  showResults(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- واجهة عرض النتائج (الذكية) ---
  Widget _buildSearchResults(BuildContext context) {
    // 1. فلترة البيانات
    final normalizedQuery = query.toLowerCase().trim();

    final matchedCategories = categories.where((c) => c.name.toLowerCase().contains(normalizedQuery)).toList();
    final matchedSubCategories = subCategories.where((s) => s.name.toLowerCase().contains(normalizedQuery)).toList();
    final matchedProducts = products.where((p) => p.name.toLowerCase().contains(normalizedQuery)).toList();

    if (matchedCategories.isEmpty && matchedSubCategories.isEmpty && matchedProducts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 2. عرض الأقسام المطابقة
          if (matchedCategories.isNotEmpty) ...[
            _buildSectionTitle("الأقسام"),
            ...matchedCategories.map((cat) => _buildCategoryResult(context, cat)),
            const SizedBox(height: 20),
          ],

          // 3. عرض الفئات الفرعية المطابقة
          if (matchedSubCategories.isNotEmpty) ...[
            _buildSectionTitle("الفئات الفرعية"),
            ...matchedSubCategories.map((sub) => _buildSubCategoryResult(context, sub)),
            const SizedBox(height: 20),
          ],

          // 4. عرض الخدمات/المنتجات المطابقة
          if (matchedProducts.isNotEmpty) ...[
            _buildSectionTitle("الخدمات المتاحة"),
            ...matchedProducts.map((prod) => _buildProductResult(context, prod)),
          ],
        ],
      ),
    );
  }

  // --- مكونات واجهة المستخدم (Widgets) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCategoryResult(BuildContext context, Category cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(imageUrl: cat.imageUrl, fit: BoxFit.cover),
          ),
        ),
        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          // انتقل لصفحة القسم
          // Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesScreen()));
          close(context, null);
        },
      ),
    );
  }

  Widget _buildSubCategoryResult(BuildContext context, SubCategory sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: const Icon(Icons.subdirectory_arrow_right_rounded, color: Colors.grey),
        title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(sub.category.name, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        onTap: () {
          // انتقل لصفحة الساب كاتيغوري
          // Navigator.push(...);
          close(context, null);
        },
      ),
    );
  }

  Widget _buildProductResult(BuildContext context, Product prod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: prod.imageUrl,
            width: 60, height: 60, fit: BoxFit.cover,
            errorWidget: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
          ),
        ),
        title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(prod.area ?? "", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: prod.id)));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "لم نجد نتائج لـ \"$query\"",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "حاول البحث بكلمات أخرى أو تصفح الأقسام",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}