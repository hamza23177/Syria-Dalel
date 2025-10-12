import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ad_model.dart';
import '../../constant.dart';
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
    await launchUrl(uri);
  }

  Future<void> _openMap(String address) async {
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark),
          title: Text(
            ad.title ?? "تفاصيل الإعلان",
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ معرض الصور مع انتقال إلى العرض الكامل
              if (ad.images.isNotEmpty)
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            transitionDuration:
                            const Duration(milliseconds: 400),
                            pageBuilder: (_, __, ___) => FullScreenImageViewer(
                              images: ad.images,
                              initialIndex: currentIndex,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CarouselSlider.builder(
                            itemCount: ad.images.length,
                            itemBuilder: (context, index, realIndex) {
                              final image = ad.images[index];
                              return Hero(
                                tag: 'ad_image_${ad.id}_$index',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    imageUrl: image.url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color:
                                      AppColors.background.withOpacity(0.2),
                                    ),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                  ),
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 280,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) {
                                setState(() => currentIndex = index);
                              },
                            ),
                          ),
                          // ✅ المؤشر السفلي (Dots)
                          Positioned(
                            bottom: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                ad.images.length,
                                    (index) => AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 400),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  width: currentIndex == index ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: currentIndex == index
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              Text(
                ad.title ?? "",
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ad.description ?? "لا توجد تفاصيل متاحة حاليًا.",
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 24),

              // رقم الهاتف
              GestureDetector(
                onTap: () {
                  if (ad.phone != null && ad.phone!.isNotEmpty) {
                    _callPhone(ad.phone!);
                  }
                },
                child: _buildInfoTile(
                  icon: Icons.phone,
                  title: "رقم الهاتف",
                  value: ad.phone ?? "غير متوفر",
                  textTheme: textTheme,
                ),
              ),

              // العنوان
              GestureDetector(
                onTap: () {
                  if (ad.address != null && ad.address!.isNotEmpty) {
                    _openMap(ad.address!);
                  }
                },
                child: _buildInfoTile(
                  icon: Icons.location_on,
                  title: "العنوان",
                  value: ad.address ?? "غير متوفر",
                  textTheme: textTheme,
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (ad.phone != null && ad.phone!.isNotEmpty) {
                      _callPhone(ad.phone!);
                    }
                  },
                  icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                  label: Text(
                    "تواصل الآن",
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      backgroundColor: Colors.black.withOpacity(0.95),
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
                    placeholder: (context, url) => const Center(
                      child:
                      CircularProgressIndicator(color: AppColors.primary),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          // ✅ نقاط التمرير (Dots)
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
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.4),
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
