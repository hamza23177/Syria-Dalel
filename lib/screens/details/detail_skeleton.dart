import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant.dart';

class ServiceDetailSkeleton extends StatelessWidget {
  const ServiceDetailSkeleton({super.key});

  Widget buildBox({
    double height = 100,
    double width = double.infinity,
    double radius = 12,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        // لون بارز أكثر من الخلفية مع Opacity منخفضة
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // تدرج الألوان للـ Shimmer
      baseColor: AppColors.background.withOpacity(0.8),
      highlightColor: AppColors.white.withOpacity(0.9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- معرض الصور Skeleton ---
            buildBox(height: 280, radius: 20),
            const SizedBox(height: 20),

            // --- عنوان الخدمة Skeleton ---
            buildBox(height: 24, radius: 8),
            const SizedBox(height: 10),

            // --- وصف الخدمة Skeleton ---
            buildBox(height: 16, radius: 8),
            const SizedBox(height: 6),
            buildBox(height: 16, radius: 8),
            const SizedBox(height: 24),

            // --- معلومات الخدمة Skeleton ---
            ...List.generate(4, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildBox(height: 14, radius: 6),
                          const SizedBox(height: 4),
                          buildBox(height: 16, radius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 40),

            // --- الأزرار Skeleton ---
            Row(
              children: [
                Expanded(
                  child: buildBox(
                    height: 50,
                    radius: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildBox(
                    height: 50,
                    radius: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
