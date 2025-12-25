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
        // إزالة الهوامش الجانبية لأننا نستخدم ClipRRect في الـ Parent
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. الصورة
            CachedNetworkImage(
              imageUrl: (ad.firstImageUrl ?? "").replaceFirst("http://", "https://"),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
            ),

            // 2. تدرج لوني
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // 3. النصوص (مع حماية من Overflow)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "اكتشف العروض",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 🔥 حماية النص من الخروج عن الحدود
                        Text(
                          "أقوى العروض الحصرية",
                          maxLines: 1, // سطر واحد فقط
                          overflow: TextOverflow.ellipsis, // وضع ... اذا النص طويل
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // الزر الصغير
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
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