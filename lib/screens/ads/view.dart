import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'ad_details_page.dart';
import 'bloc.dart';
import 'state.dart';
import '../../models/ad_model.dart';
import '../../constant.dart';

class AdCarouselView extends StatefulWidget {
  const AdCarouselView({super.key});

  @override
  State<AdCarouselView> createState() => _AdCarouselViewState();
}

class _AdCarouselViewState extends State<AdCarouselView> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  bool _showHint = true; // للتحكم في ظهور النص

  @override
  void initState() {
    super.initState();
    // إخفاء النص بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showHint = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        if (state is AdLoading) {
          return const SizedBox(height: 250);
        } else if (state is AdLoaded) {
          final ads = state.ads;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: ads.length,
                  itemBuilder: (context, index, realIndex) {
                    final ad = ads[index];

                    return GestureDetector(
                      onTapDown: (_) => setState(() => _current = index),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdDetailsPage(ad: ad),
                          ),
                        );
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: _current == index ? 0.98 : 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // الصورة
                              CachedNetworkImage(
                                imageUrl: ad.imageUrl ?? "",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.background.withOpacity(0.2),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),

                              // التدرج السفلي
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              // أيقونة تشير إلى إمكانية النقر على الصورة
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Pulse( // Animate_do effect for subtle animation
                                  infinite: true,
                                  duration: const Duration(seconds: 2),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.touch_app,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),

                              // النص الإرشادي مع اختفاء تدريجي
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: AnimatedOpacity(
                                    opacity: _showHint ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 800),
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.touch_app, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            "اضغط لمشاهدة التفاصيل",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 250,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    autoPlayInterval: const Duration(seconds: 5),
                    onPageChanged: (index, reason) {
                      setState(() => _current = index);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildIndicator(ads.length),
              ],
            ),
          );
        } else if (state is AdError) {
          return Center(child: Text(state.message));
        } else {
          return const SizedBox();
        }
      },
    );
  }
  Widget _buildIndicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final selected = _current == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? AppColors.primary.withOpacity(0.9)
                : AppColors.textLight.withOpacity(0.3),
          ),
        );
      }),
    );
  }
}

