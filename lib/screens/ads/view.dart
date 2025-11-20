import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart'; // يفضل إضافة هذه المكتبة لتأثير التحميل
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
            children: [
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: ads.length,
                itemBuilder: (context, index, realIndex) {
                  final ad = ads[index];
                  return _buildAdCard(ad, index);
                },
                options: CarouselOptions(
                  height: 220, // ارتفاع مثالي للإعلانات العريضة
                  autoPlay: true,
                  viewportFraction: 0.92, // عرض الصورة بالنسبة للشاشة
                  enlargeCenterPage: true, // تكبير العنصر الأوسط
                  enlargeStrategy: CenterPageEnlargeStrategy.height, // تكبير ناعم
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
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
          // في حال الخطأ نخفي القسم بدلاً من عرض نص قبيح، أو نعرض أيقونة تحديث
          return const SizedBox();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // ✅ تصميم بطاقة الإعلان الاحترافية
  Widget _buildAdCard(dynamic ad, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2), // ظل ملون بلون البراند
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. الصورة الخلفية
              CachedNetworkImage(
                imageUrl: (ad.firstImageUrl ?? "").replaceFirst("http://", "https://"),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),

              // 2. التدرج اللوني (Overlay) لقراءة النصوص بوضوح
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // 3. شارة "مميز" في الأعلى (تعطي احترافية)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "مميز",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. عدد الصور (إذا وجد)
              if (ad.images.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.white, size: 14),
                  ),
                ),

              // 5. المحتوى النصي وزر الدعوة (Call To Action)
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // نص العنوان (إذا وجد في المودل، أو نص افتراضي)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "اكتشف المزيد", // أو ad.title إذا وجد
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "أفضل العروض هنا", // نص تسويقي
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // زر التفاعل الدائري (Call to Action)
                    Pulse(
                      infinite: true,
                      duration: const Duration(seconds: 3),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary, // لون البراند
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ مؤشر الصفحات المتحرك (Worm Effect)
  Widget _buildAnimatedIndicators(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        bool isSelected = _current == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isSelected ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // ✅ شاشة تحميل جميلة (Skeleton)
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}