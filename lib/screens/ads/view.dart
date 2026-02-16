import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'ad_details_page.dart';
import 'bloc.dart';
import 'state.dart';
import '../../constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AdCarouselView extends StatefulWidget {
  const AdCarouselView({super.key});

  @override
  State<AdCarouselView> createState() => _AdCarouselViewState();
}

class _AdCarouselViewState extends State<AdCarouselView> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        if (state is AdLoading) {
          return _buildShimmerLoading();
        } else if (state is AdLoaded) {
          final ads = state.ads;
          if (ads.isEmpty) return const SizedBox();

          return Column(
            mainAxisSize: MainAxisSize.min, // 🔥 مهم جداً: يجعل العمود يأخذ أقل مساحة ممكنة
            children: [
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: ads.length,
                itemBuilder: (context, index, realIndex) {
                  final ad = ads[index];
                  return _buildAdCard(ad, index);
                },
                options: CarouselOptions(
                  // 🔥 التعديل الجوهري للـ Responsiveness
                  // بدلاً من height: 220، نستخدم aspectRatio
                  aspectRatio: 16 / 9, // نسبة السينما (مثالية للإعلانات)
                  // يمكنك استخدام 2.0 إذا أردت الإعلان أقل ارتفاعاً

                  viewportFraction: 1.0, // جعلنا الصورة تأخذ كامل العرض لجمالية أكثر
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false, // ألغيناها لأننا جعلنا العرض 1.0
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() => _current = index);
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildAnimatedIndicators(ads.length),
            ],
          );
        } else if (state is AdError) {
          return const SizedBox();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildAdCard(dynamic ad, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. الصورة الخلفية
            CachedNetworkImage(
              imageUrl: (ad.firstImageUrl ?? "").replaceFirst("http://", "https://"),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
            ),

            // 2. طبقة الظل التدريجي (لتحسين قراءة النصوص)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1), // ظل خفيف جداً من الأعلى
                    Colors.transparent,
                    Colors.black.withOpacity(0.8), // ظل قوي من الأسفل
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // 3. 🔥 شارة "مـمـيـز" الاحترافية (Golden Badge)
            Positioned(
              top: 12,
              left: 12, // وضعناها على اليسار لتكون مميزة (باعتبار التطبيق عربي RTL)
              child: _buildPremiumBadge(),
            ),

            // 4. النصوص والتفاصيل
            Positioned(
              bottom: 12,
              right: 12, // النصوص عربية (يمين)
              left: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // تصنيف الإعلان (اختياري)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "عرض خاص", // يمكن استبدالها بـ ad.categoryName
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // العنوان الرئيسي
                        Text(
                          "أقوى العروض الحصرية", // استبدلها بـ ad.title
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18, // تكبير الخط قليلاً
                            fontWeight: FontWeight.w900, // خط سميك جداً للفخامة
                            shadows: [
                              Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // زر "المزيد" (Call to Action)
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white, // لون أبيض ليتناقض مع الخلفية
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: Offset(0,2))
                      ],
                    ),
                    child: Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    // نستخدم FadeInDown لجذب الانتباه عند ظهور الإعلان
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          // تدرج ذهبي فخم
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700), // ذهبي فاقع
              Color(0xFFFFA500), // برتقالي ذهبي
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA500).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4), // ظل ليعطي بروزاً
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded, // أيقونة النجمة توحي بالتميز
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              "مُـمـيـز", // النص
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900, // خط عريض
                letterSpacing: 0.5, // تباعد أحرف خفيف
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIndicators(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: _current == index ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _current == index ? AppColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // 🔥 تعديل الشيمر ليكون Responsive أيضاً
  Widget _buildShimmerLoading() {
    return AspectRatio(
      aspectRatio: 16/9,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}