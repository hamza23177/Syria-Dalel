import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant.dart';
import '../../services/contact_api.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactBloc(ContactApi())..add(LoadContactInfo()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text("انضم إلى دليل سوريا",style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),),
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            centerTitle: false,
            elevation: 0.8,
          ),
          body: BlocBuilder<ContactBloc, ContactState>(
            builder: (context, state) {
              if (state is ContactLoading) {
                return _buildShimmerLoading();
              } else if (state is ContactError) {
                return Center(child: Text("حدث خطأ: ${state.message}"));
              } else if (state is ContactLoaded) {
                final c = state.contact;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🟢 العنوان الرئيسي
                      Text(
                        "كن جزءًا من دليل سوريا 🇸🇾",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "هل تملك مطعمًا، محلًا، عيادة، أو أي خدمة؟\nانضم إلينا الآن واجعل آلاف المستخدمين يرون خدمتك يوميًا.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 💎 صورة جمالية رمزية
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/images/join_us.png",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🟦 بطاقات وسائل التواصل
                      Text(
                        "اختر وسيلة التواصل المفضلة لديك:",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          if (c.phone != null && c.phone!.isNotEmpty)
                            _buildContactCard(
                              iconWidget: const FaIcon(FontAwesomeIcons.phone, color: Colors.white, size: 28),
                              label: "اتصال مباشر",
                              color: Colors.blueAccent,
                              onTap: () => _launchUrl("tel:${c.phone}"),
                            ),
                          if (c.whatsapp != null && c.whatsapp!.isNotEmpty)
                            _buildContactCard(
                              iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 28),
                              label: "واتساب",
                              color: Colors.green,
                              onTap: () => _launchUrl("https://wa.me/${c.whatsapp!.replaceAll('+', '')}"),
                            ),
                          if (c.googleMapLink != null && c.googleMapLink!.isNotEmpty)
                            _buildContactCard(
                              iconWidget: const FaIcon(FontAwesomeIcons.locationDot, color: Colors.white, size: 28),
                              label: "موقعنا على الخريطة",
                              color: Colors.orangeAccent,
                              onTap: () => _launchUrl(c.googleMapLink!),
                            ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // 🌟 دعوة ختامية قوية
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "ابدأ معنا اليوم!",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "انضم الآن إلى دليل سوريا ودعنا نعرض خدمتك أمام آلاف المستخدمين المهتمين بخدماتك.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _launchUrl("https://wa.me/${c.whatsapp!.replaceAll('+', '')}"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
                              label: const Text(
                                "تواصل الآن",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // ✅ تصميم الكارت الاحترافي لوسائل التواصل
  Widget _buildContactCard({
    required Widget iconWidget,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ تأثير التحميل
  // ✨ تأثير التحميل المتطابق مع الصفحة
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟢 العنوان الرئيسي
            Container(
              width: 220,
              height: 28,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 30),

            // 💎 صورة جمالية رمزية
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),

            // 🟦 عنوان وسائل التواصل
            Container(
              width: 220,
              height: 22,
              color: Colors.white,
            ),
            const SizedBox(height: 16),

            // 🧩 بطاقات التواصل
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(
                3,
                    (index) => Container(
                  width: 140,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🌟 مربع الدعوة الختامي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
