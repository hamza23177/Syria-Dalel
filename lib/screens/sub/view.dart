import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// تأكد من استيراد ملفاتك الصحيحة هنا
import '../../services/service_api.dart';
import '../../services/sub_category_service.dart';
import '../prod/bloc.dart';
import '../prod/event.dart';
import '../prod/service_repository.dart';
import '../prod/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../constant.dart'; // تأكد أن هذا الملف يحتوي على AppColors

class SubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => SubCategoryBloc(SubCategoryService())
          ..add(FetchSubCategories(categoryId: widget.categoryId)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA), // خلفية موحدة مع الواجهات السابقة
          body: BlocBuilder<SubCategoryBloc, SubCategoryState>(
            builder: (context, state) {
              // التعامل مع حالة التحميل الأولية
              if (state is SubCategoryLoading) {
                return _buildLoadingShimmer();
              }

              // التعامل مع الأخطاء
              else if (state is SubCategoryError) {
                return _buildErrorView(context, state.message);
              }

              // عرض البيانات
              else if (state is SubCategoryLoaded) {
                // إذا كانت القائمة فارغة تماماً رغم نجاح الطلب
                if (state.subCategories.isEmpty) {
                  return _buildEmptyView(context);
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // شرط الباجينيشن: وصلنا للنهاية + لا نقوم بالتحميل حالياً
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200 &&
                        !state.isLoadingMore) {
                      context.read<SubCategoryBloc>().add(
                        FetchSubCategories(categoryId: widget.categoryId),
                      );
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // 1. Header احترافي
                      SliverAppBar(
                        expandedHeight: 120.0,
                        floating: false,
                        pinned: true,
                        backgroundColor: const Color(0xFFF8F9FA),
                        elevation: 0,
                        centerTitle: false,
                        leading: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          title: Text(
                            widget.categoryName,
                            style: TextStyle(
                              color: AppColors.primary, // استخدام لون التطبيق الأساسي
                              fontWeight: FontWeight.w800,
                              fontSize: 18, // حجم أصغر قليلاً ليتناسب مع الـ Scroll
                            ),
                          ),
                        ),
                      ),

                      // 2. رسالة ترحيبية صغيرة (اختياري)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            "اختر القسم الفرعي لتصفح الخدمات المتاحة",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ),
                      ),

                      // 3. القائمة
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index < state.subCategories.length) {
                                // Animation Wrapper
                                return _buildAnimatedItem(
                                    index,
                                    _SubCategoryCard(sub: state.subCategories[index])
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: SizedBox(
                                      width: 25, height: 25,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                  ),
                                );
                              }
                            },
                            childCount: state.subCategories.length + (state.isLoadingMore ? 1 : 0),
                          ),
                        ),
                      ),

                      const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // --- Widgets مساعدة ---

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index % 5) * 100),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("لا توجد أقسام فرعية هنا", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text("حدث خطأ ما", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<SubCategoryBloc>().add(FetchSubCategories(categoryId: widget.categoryId)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

// --- تصميم البطاقة (Card) المحدث ---
class _SubCategoryCard extends StatelessWidget {
  final dynamic sub; // استبدل dynamic بنوع الموديل الخاص بك SubCategory

  const _SubCategoryCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => ServiceBloc(ServiceRepository(ServiceApi()))
                    ..add(FetchServices(subCategoryId: sub.id)),
                  child: ServiceScreen(
                    subCategoryId: sub.id,
                    subCategoryName: sub.name,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 1. الصورة
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: sub.imageUrl ?? "",
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Icon(Icons.image, color: Colors.grey),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 2. النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sub.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.folder_open, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sub.category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.primary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            sub.category.area.name,
                            style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. زر التصفح (أيقونة)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}