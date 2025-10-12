import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant.dart';
import '../../services/contact_api.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import 'package:url_launcher/url_launcher.dart';

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
          appBar: AppBar(
            title: const Text("تواصل معنا"),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ---- العنوان والوصف ----
                      Text(
                        c.name ?? "تواصل معنا",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.description ?? "نحن سعداء بتواصلك معنا!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ---- بطاقات وسائل التواصل ----
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          if (c.phone != null && c.phone!.isNotEmpty)
                            _buildContactCard(
                              iconWidget: const FaIcon(FontAwesomeIcons.phone, color: Colors.blueAccent, size: 28),
                              label: "اتصال مباشر",
                              color: Colors.blueAccent,
                              onTap: () => _launchUrl("tel:${c.phone}"),
                            ),
                          if (c.whatsapp != null && c.whatsapp!.isNotEmpty)
                            _buildContactCard(
                              iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 28),
                              label: "واتساب",
                              color: Colors.green,
                              onTap: () => _launchUrl("https://wa.me/${c.whatsapp!.replaceAll('+', '')}"),
                            ),
                          if (c.googleMapLink != null && c.googleMapLink!.isNotEmpty)
                            _buildContactCard(
                              iconWidget: const FaIcon(FontAwesomeIcons.locationDot, color: Colors.orangeAccent, size: 28),
                              label: "العنوان",
                              color: Colors.orangeAccent,
                              onTap: () => _launchUrl(c.googleMapLink!),
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ---- العنوان النصي ----
                      if (c.address != null && c.address!.isNotEmpty)
                        Column(
                          children: [
                            const FaIcon(FontAwesomeIcons.mapMarkerAlt, color: AppColors.accent, size: 24),
                            const SizedBox(height: 8),
                            Text(
                              c.address!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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

  // ✅ تصميم الكارد
  Widget _buildContactCard({
    Widget? iconWidget,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget!,
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ Skeleton Loading
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(width: 180, height: 20, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: 250, height: 16, color: Colors.white),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(
                3,
                    (index) => Container(
                  width: 130,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
