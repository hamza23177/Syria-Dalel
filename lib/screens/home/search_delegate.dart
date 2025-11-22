import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart'; // تأكد من إضافتها للجمالية
import 'package:untitled2/screens/home/search_bloc.dart';
import '../../constant.dart';
import '../../models/service_model.dart'; // موديل الخدمة
import '../details/view.dart'; // صفحة التفاصيل

class ProfessionalSearchDelegate extends SearchDelegate {
  final GlobalSearchBloc searchBloc;

  ProfessionalSearchDelegate(this.searchBloc);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        toolbarHeight: 70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
        // hintText: "ابحث عن خدمة، منتج...",
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
          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
          onPressed: () {
            query = '';
            showSuggestions(context);
            searchBloc.add(SearchQueryChanged('')); // تصفير البحث
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
    searchBloc.add(SearchQueryChanged(query));
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // بمجرد الكتابة، نرسل الحدث للبلوك (مع Debounce تلقائي هناك)
    searchBloc.add(SearchQueryChanged(query));
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return BlocBuilder<GlobalSearchBloc, SearchState>(
      bloc: searchBloc,
      builder: (context, state) {
        if (state is SearchLoading) {
          return _buildShimmerLoading();
        } else if (state is SearchError) {
          return _buildErrorState(state.message);
        } else if (state is SearchEmpty) {
          return _buildEmptyState();
        } else if (state is SearchSuccess) {
          return Container(
            color: const Color(0xFFF8F9FA),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                return _buildServiceResult(context, state.results[index]);
              },
            ),
          );
        }
        return _buildInitialState(); // الحالة الأولية قبل البحث
      },
    );
  }

  // --- تصميم النتائج (بطاقة الخدمة) ---
  Widget _buildServiceResult(BuildContext context, ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Hero(
          tag: 'service_search_${service.id}', // أنيميشن جميل للصورة
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: service.imageUrl ?? "",
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
        ),
        title: Text(
          service.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Icon(Icons.location_on, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  service.area ?? "غير محدد",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // يمكنك إضافة السعر هنا إذا وجد
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
        ),
        onTap: () {
          // الذهاب للتفاصيل
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(serviceId: service.id)
          ));
        },
      ),
    );
  }

  // --- حالات الواجهة المختلفة ---

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
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
            "لا توجد نتائج مطابقة",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "حاول استخدام كلمات بحث أخرى",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("اكتب للبحث في جميع الخدمات...", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          // يمكنك هنا إضافة قائمة "عمليات البحث الأخيرة" مخزنة محلياً
          const Row(
            children: [
              Icon(Icons.bolt, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text("كلمات شائعة:", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ["تنظيف", "صيانة", "سيارات", "ديكور"].map((text) => ActionChip(
              label: Text(text),
              backgroundColor: Colors.white,
              onPressed: () {
                query = text; // تعيين النص في شريط البحث
                searchBloc.add(SearchQueryChanged(text)); // بدء البحث
              },
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(String msg) {
    return Center(child: Text(msg, style: const TextStyle(color: Colors.red)));
  }
}