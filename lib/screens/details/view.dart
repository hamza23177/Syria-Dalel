import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/service_model.dart'; // تأكد من المسار
import '../../services/service_api.dart'; // تأكد من المسار
import '../../constant.dart'; // تأكد من وجود AppColors
import 'bloc.dart';
import 'detail_skeleton.dart'; // تأكد من وجود السكلتون
import 'event.dart';
import 'state.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // دالة الاتصال
  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // دالة فتح الخريطة
  Future<void> _openMap(String address) async {
    // نحاول فتح جوجل مابس مباشرة
    final query = Uri.encodeComponent(address);
    final googleUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      // fallback
      debugPrint('Could not launch map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => ServiceBloc(ServiceApi())..add(LoadServiceDetails(widget.serviceId)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA), // خلفية فاتحة عصرية
          body: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const ServiceDetailSkeleton();
              } else if (state is ServiceLoaded) {
                final service = state.service;
                final images = [
                  if (service.imageUrl != null) service.imageUrl!,
                  if (service.imageUrl2 != null) service.imageUrl2!,
                  if (service.imageUrl3 != null) service.imageUrl3!,
                ];

                return Stack(
                  children: [
                    // 1. المحتوى القابل للتمرير
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // --- Header صورة غامرة ---
                        SliverAppBar(
                          expandedHeight: 320.0,
                          pinned: true,
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          leading: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: _buildImageCarousel(images, service.id),
                          ),
                        ),

                        // --- تفاصيل الخدمة ---
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            // تحريك الكونتينر للأعلى قليلاً فوق الصورة
                            transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // مقبض صغير جمالي
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // التصنيف
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              service.category ?? "عام",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (service.subcategory != null)
                                            Text(
                                              "•  ${service.subcategory}",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // الاسم
                                      Text(
                                        service.name ?? "اسم الخدمة",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // نبذة عن الخدمة
                                      const Text(
                                        "نبذة عن الخدمة",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        service.description ?? "لا يوجد وصف متاح لهذه الخدمة حالياً.",
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.6,
                                          color: Colors.grey[700],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // معلومات التواصل والموقع
                                      const Text(
                                        "بيانات الاتصال",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),

                                      _buildInfoCard(
                                          icon: Icons.phone_in_talk_outlined,
                                          title: "رقم الهاتف",
                                          value: service.phone ?? "غير متوفر",
                                          isLink: true,
                                          onTap: () {
                                            if (service.phone != null) _callPhone(service.phone!);
                                          }
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                          icon: Icons.location_on_outlined,
                                          title: "العنوان",
                                          value: "${service.address ?? ""}, ${service.area ?? ""}, ${service.governorate ?? ""}",
                                          isLink: true,
                                          onTap: () {
                                            final address = "${service.address ?? ""}, ${service.area ?? ""}, ${service.governorate ?? ""}";
                                            if (address.trim().length > 4) _openMap(address);
                                          }
                                      ),

                                      // مسافة فارغة في الأسفل لعدم تغطية المحتوى بالزر العائم
                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. الشريط السفلي الثابت (Call to Action)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            // زر الاتصال (الأساسي)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (service.phone != null) _callPhone(service.phone!);
                                },
                                icon: const Icon(Icons.phone, color: Colors.white),
                                label: const Text(
                                  "تواصل الآن",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // زر الموقع (الثانوي)
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () {
                                  final address = "${service.address ?? ""}, ${service.area ?? ""}, ${service.governorate ?? ""}";
                                  if (address.trim().length > 4) _openMap(address);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Icon(Icons.map_outlined, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else if (state is ServiceError) {
                return Center(child: Text("عذراً، حدث خطأ: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // --- Widget: Carousel Images ---
  Widget _buildImageCarousel(List<String> images, int serviceId) {
    if (images.isEmpty) {
      return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)));
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => FullScreenServiceGallery(images: images, initialIndex: index),
                  ),
                );
              },
              child: Hero(
                tag: 'service_image_${serviceId}_$index',
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlay: true,
            onPageChanged: (index, reason) => setState(() => currentIndex = index),
          ),
        ),
        // التدرج اللوني الأسود في الأسفل لجعل النقاط واضحة
        Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
            ),
          ),
        ),
        // Dots Indicators
        Positioned(
          bottom: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentIndex == entry.key ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: currentIndex == entry.key ? AppColors.primary : Colors.white.withOpacity(0.6),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- Widget: Info Card ---
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isLink,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (isLink)
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ✅ معرض الصور (FullScreen) - نفس السابق ممتاز
class FullScreenServiceGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenServiceGallery({super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenServiceGallery> createState() => _FullScreenServiceGalleryState();
}

class _FullScreenServiceGalleryState extends State<FullScreenServiceGallery> {
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'service_image_${widget.images[index]}_$index',
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}