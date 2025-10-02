import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/service_api.dart';
import '../../models/service_model.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../constant.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  List<String> images = [];

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchMaps(String address) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$address");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients && images.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage >= images.length) {
          nextPage = 0; // loop
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }





  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => ServiceBloc(ServiceApi())..add(LoadServiceDetails(widget.serviceId)),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("تفاصيل الخدمة"),
            backgroundColor: AppColors.primary,
          ),
          body: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ServiceLoaded) {
                // ✨ هنا نبني الصور مرة واحدة عند تحميل البيانات
                images = [
                  if (state.service.imageUrl != null) state.service.imageUrl!,
                  if (state.service.imageUrl2 != null) state.service.imageUrl2!,
                  if (state.service.imageUrl3 != null) state.service.imageUrl3!,
                ];
                if (_timer == null) _startAutoScroll(); // نشغل التمرير بعد تحميل الصور
                return _buildDetails(context, state.service);
              } else if (state is ServiceError) {
                return Center(child: Text("خطأ: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ServiceModel service) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // الصور مع PageView
          _buildImageCarousel(),
          const SizedBox(height: 8),

          // بطاقة التفاصيل
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم الخدمة
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // الوصف
                if (service.description != null && service.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      service.description!,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                    ),
                  ),

                // العنوان - يفتح الخرائط
                InkWell(
                  onTap: () => _launchMaps("${service.address}, ${service.area}, ${service.governorate}"),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${service.address}, ${service.area}, ${service.governorate}",
                          style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // الهاتف - يفتح الاتصال
                InkWell(
                  onTap: () => _launchPhone(service.phone),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        service.phone,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                // باقي المواصفات
                _buildAttributeRow(Icons.category, "الفئة", service.category),
                const SizedBox(height: 8),
                _buildAttributeRow(Icons.layers, "الفئة الفرعية", service.subcategory),
                const SizedBox(height: 8),
                _buildAttributeRow(Icons.map, "المنطقة", service.area),
                const SizedBox(height: 8),
                _buildAttributeRow(Icons.location_city, "المحافظة", service.governorate),
              ],
            ),
          ),
        ],
      ),
    );
  }

// دالة مساعدة لعرض كل واصفة
  Widget _buildAttributeRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          "$label: $value",
          style: const TextStyle(fontSize: 15, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    if (images.isEmpty) return const SizedBox();

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: GestureDetector(
            onTap: () {
              // عند الضغط على الصورة، نفتح معرض كامل
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: Colors.black,
                    body: PhotoViewGallery.builder(
                      itemCount: images.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(images[index]),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3,
                        );
                      },
                      pageController: PageController(initialPage: _currentPage),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      scrollPhysics: const BouncingScrollPhysics(),
                    ),
                  ),
                ),
              );
            },
            child: CarouselSlider.builder(
              itemCount: images.length,
              itemBuilder: (context, index, realIdx) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                  ),
                );
              },
              options: CarouselOptions(
                height: 240,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            final bool isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 20 : 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }


}
