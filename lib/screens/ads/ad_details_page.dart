import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ad_model.dart'; // تأكد من المسار
import '../../constant.dart'; // تأكد من المسار
import 'package:carousel_slider/carousel_slider.dart';

class AdDetailsPage extends StatefulWidget {
  final AdModel ad;

  const AdDetailsPage({super.key, required this.ad});

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  int currentIndex = 0;

  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    // استخدام صيغة URI أكثر مرونة لفتح تطبيق الخرائط (جوجل أو غيره)
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final images = ad.images.map((e) => e.url).toList(); // تحويل قائمة الكائنات إلى قائمة URL فقط

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // خلفية موحدة
        body: Stack(
          children: [
            // 1. المحتوى القابل للتمرير (CustomScrollView)
            CustomScrollView(
              slivers: [
                // --- Header صورة غامرة (SliverAppBar) ---
                SliverAppBar(
                  expandedHeight: 350.0,
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
                    titlePadding: EdgeInsets.zero,
                    centerTitle: false,
                    background: _buildImageCarousel(images, ad.id),
                  ),
                ),

                // --- تفاصيل الإعلان ---
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    // تحريك الكونتينر للأعلى قليلاً فوق الصورة
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

                          // العنوان الرئيسي
                          Text(
                            ad.title ?? "إعلان مميز",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // شارة الإعلان
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "إعلان مدعوم",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // تفاصيل الإعلان
                          const Text(
                            "تفاصيل ووصف الإعلان",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ad.description ?? "لا يوجد وصف مفصل لهذا الإعلان حالياً.",
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // معلومات الاتصال والموقع
                          const Text(
                            "بيانات التواصل",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          // بطاقة الهاتف
                          _buildInfoCard(
                            icon: Icons.phone_in_talk_outlined,
                            title: "رقم الهاتف",
                            value: ad.phone ?? "غير متوفر",
                            isLink: ad.phone != null && ad.phone!.isNotEmpty,
                            onTap: () {
                              if (ad.phone != null && ad.phone!.isNotEmpty) _callPhone(ad.phone!);
                            },
                          ),
                          const SizedBox(height: 10),

                          // بطاقة العنوان
                          _buildInfoCard(
                            icon: Icons.location_on_outlined,
                            title: "العنوان",
                            value: ad.address ?? "غير متوفر",
                            isLink: ad.address != null && ad.address!.isNotEmpty,
                            onTap: () {
                              if (ad.address != null && ad.address!.isNotEmpty) _openMap(ad.address!);
                            },
                          ),

                          // مسافة فارغة في الأسفل لعدم تغطية المحتوى بالزر العائم
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. الشريط السفلي الثابت (Floating Bar)
            _buildFloatingActionRow(ad),
          ],
        ),
      ),
    );
  }

  // --- Widget: Carousel Images ---
  Widget _buildImageCarousel(List<String> images, int adId) {
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
                    pageBuilder: (_, __, ___) => FullScreenImageViewer(
                      images: widget.ad.images, // نستخدم الكائن الأصلي هنا
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'ad_image_${adId}_$index',
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

  // --- Widget: Info Card (سابقاً Tile) ---
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isLink,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLink ? onTap : null,
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

  // --- Widget: الشريط السفلي الثابت (Floating Action Row) ---
  Widget _buildFloatingActionRow(AdModel ad) {
    return Positioned(
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
              child: ElevatedButton.icon(
                onPressed: ad.phone != null && ad.phone!.isNotEmpty
                    ? () => _callPhone(ad.phone!)
                    : null,
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text(
                  "اتصل الآن",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey[300], // حالة عدم التوفر
                ),
              ),
            ),
            const SizedBox(width: 12),
            // زر الموقع (الثانوي)
            Expanded(
              child: OutlinedButton(
                onPressed: ad.address != null && ad.address!.isNotEmpty
                    ? () => _openMap(ad.address!)
                    : null,
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
    );
  }
}

//////////////////////////////////////////////////////////
/// ✅ عرض الصور بالحجم الكامل (Lightbox Modern Gallery)
//////////////////////////////////////////////////////////
class FullScreenImageViewer extends StatefulWidget {
  final List<AdImage> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
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
                tag: 'ad_image_${widget.images[index].id}_$index',
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index].url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          // ✅ نقاط التمرير
          Positioned(
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                bool selected = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: selected ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),

          // زر الإغلاق
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