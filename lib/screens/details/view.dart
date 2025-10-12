import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/service_model.dart';
import '../../services/service_api.dart';
import '../../constant.dart';
import 'bloc.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) =>
        ServiceBloc(ServiceApi())..add(LoadServiceDetails(widget.serviceId)),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textDark),
            title: const Text(
              "تفاصيل الخدمة",
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ServiceLoaded) {
                final service = state.service;
                final images = [
                  if (service.imageUrl != null) service.imageUrl!,
                  if (service.imageUrl2 != null) service.imageUrl2!,
                  if (service.imageUrl3 != null) service.imageUrl3!,
                ];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ معرض الصور
                      if (images.isNotEmpty)
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
                                    pageBuilder: (_, __, ___) =>
                                        FullScreenServiceGallery(
                                          images: images,
                                          initialIndex: currentIndex,
                                        ),
                                  ),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  CarouselSlider.builder(
                                    itemCount: images.length,
                                    itemBuilder: (context, index, realIndex) {
                                      return Hero(
                                        tag:
                                        'service_image_${service.id}_$index',
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            imageUrl: images[index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: AppColors.background
                                                      .withOpacity(0.2),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
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
                                  // ✅ Dots
                                  Positioned(
                                    bottom: 10,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: List.generate(
                                        images.length,
                                            (index) => AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 400),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width:
                                          currentIndex == index ? 22 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: currentIndex == index
                                                ? AppColors.primary
                                                : Colors.white.withOpacity(0.5),
                                            borderRadius:
                                            BorderRadius.circular(12),
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
                        service.name ?? "اسم الخدمة غير متوفر",
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        service.description ?? "لا توجد تفاصيل متاحة حاليًا.",
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ✅ معلومات الخدمة بنفس تنسيق صفحة الإعلان
                      GestureDetector(
                        onTap: () {
                          if (service.phone != null &&
                              service.phone!.isNotEmpty) {
                            _callPhone(service.phone!);
                          }
                        },
                        child: _buildInfoTile(
                          icon: Icons.phone,
                          title: "رقم الهاتف",
                          value: service.phone ?? "غير متوفر",
                          textTheme: textTheme,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          final address =
                              "${service.address ?? ""}, ${service.area ?? ""}, ${service.governorate ?? ""}";
                          if (address.trim().isNotEmpty) {
                            _openMap(address);
                          }
                        },
                        child: _buildInfoTile(
                          icon: Icons.location_on,
                          title: "العنوان",
                          value:
                          "${service.address ?? ""}, ${service.area ?? ""}, ${service.governorate ?? ""}",
                          textTheme: textTheme,
                        ),
                      ),

                      _buildInfoTile(
                        icon: Icons.category,
                        title: "الفئة",
                        value: service.category ?? "غير متوفر",
                        textTheme: textTheme,
                      ),
                      _buildInfoTile(
                        icon: Icons.layers,
                        title: "الفئة الفرعية",
                        value: service.subcategory ?? "غير متوفر",
                        textTheme: textTheme,
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
                            if (service.phone != null &&
                                service.phone!.isNotEmpty) {
                              _callPhone(service.phone!);
                            }
                          },
                          icon: const Icon(Icons.phone_in_talk,
                              color: Colors.white),
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
                );
              } else if (state is ServiceError) {
                return Center(child: Text("حدث خطأ: ${state.message}"));
              }
              return const SizedBox();
            },
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
// ✅ شاشة عرض الصور بالحجم الكامل (مطابقة لتفاصيل الإعلان)
//////////////////////////////////////////////////////////
class FullScreenServiceGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenServiceGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenServiceGallery> createState() =>
      _FullScreenServiceGalleryState();
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
                tag: 'service_image_${widget.images[index]}_$index',
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              );
            },
          ),
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
