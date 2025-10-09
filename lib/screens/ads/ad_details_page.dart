import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ad_model.dart';
import '../../constant.dart';

class AdDetailsPage extends StatelessWidget {
  final AdModel ad;

  const AdDetailsPage({super.key, required this.ad});

  // فتح تطبيق الهاتف
  Future<void> _callPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
      await launchUrl(uri);
  }

  // فتح تطبيق الخرائط
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
              Hero(
                tag: "ad_${ad.id}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: ad.imageUrl ?? "",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 60),
                  ),
                ),
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

              // زر الاتصال الآن
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
