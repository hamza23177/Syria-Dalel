import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// تأكد من استيراد ملفاتك الصحيحة
import '../../../models/service_model.dart';
import '../details/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../constant.dart'; // تأكد أن لديك AppColors

class ServiceScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;

  const ServiceScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
  });

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ✅ استدعاء واحد فقط للبيانات عند البدء
    context.read<ServiceBloc>().add(FetchServices(subCategoryId: widget.subCategoryId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // نفس خلفية الصفحات السابقة
        body: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            // 1. حالة التحميل الأولية
            if (state is ServiceLoading && (state is! ServiceLoaded)) {
              return _buildLoadingShimmer();
            }

            // 2. حالة الخطأ
            else if (state is ServiceError) {
              return _buildErrorView(context, state.message);
            }

            // 3. عرض البيانات
            else if (state is ServiceLoaded) {
              if (state.services.isEmpty) {
                return _buildEmptyView(context);
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  // ✅ منطق الباجينيشن المحسن والمتوافق مع Slivers
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200 &&
                      !state.isLoadingMore) {
                    context.read<ServiceBloc>().add(
                      FetchServices(
                          subCategoryId: widget.subCategoryId,
                          loadMore: true
                      ),
                    );
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // --- Header احترافي ---
                    SliverAppBar(
                      expandedHeight: 100.0,
                      floating: true,
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
                          widget.subCategoryName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    // --- إحصائية بسيطة (اختياري) ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Text(
                          "${state.services.length} خدمة متاحة",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // --- قائمة الخدمات ---
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            if (index < state.services.length) {
                              return _buildAnimatedItem(
                                index,
                                _ServiceCard(service: state.services[index]),
                              );
                            } else {
                              // مؤشر التحميل السفلي
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 25, height: 25,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                ),
                              );
                            }
                          },
                          childCount: state.services.length + (state.isLoadingMore ? 1 : 0),
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
    );
  }

  // --- Helper Widgets ---

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

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 110,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("عذراً، لا توجد خدمات متاحة حالياً", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<ServiceBloc>().add(FetchServices(subCategoryId: widget.subCategoryId)),
            child: const Text("إعادة المحاولة"),
          ),
        ],
      ),
    );
  }
}

// --- تصميم بطاقة الخدمة (Service Card) المحسن ---
class _ServiceCard extends StatelessWidget {
  final ServiceModel service; // تأكد من نوع الموديل

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
                builder: (_) => ServiceDetailScreen(serviceId: service.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. صورة الخدمة
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: service.imageUrl ?? "",
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Icon(Icons.person, color: Colors.grey),
                          errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    // أيقونة التحقق (اختياري)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified, size: 16, color: AppColors.primary),
                      ),
                    )
                  ],
                ),

                const SizedBox(width: 14),

                // 2. التفاصيل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم
                      Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // العنوان
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              service.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // رقم الهاتف وزر التفاعل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // رقم الهاتف بتصميم جذاب
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 12, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  service.phone,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // زر سهم صغير
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}