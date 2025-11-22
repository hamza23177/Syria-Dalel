import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // للـ Blur Effect

import '../../constant.dart';
import '../../services/contact_api.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchMap(String address) async {
    if (address.isEmpty) return;
    // نقوم بتشفير النص العربي ليفهمه المتصفح (تحويل المسافات والأحرف العربية لرموز)
    final query = Uri.encodeComponent(address);
    // نستخدم رابط بحث جوجل مابس العالمي (يعمل على ايفون واندرويد)
    final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    await _launchUrl(googleMapsUrl);
  }

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
          backgroundColor: const Color(0xFFF8F9FA),
          // زر تواصل عائم دائم الظهور (لزيادة نسبة التحويل)
          bottomNavigationBar: BlocBuilder<ContactBloc, ContactState>(
            builder: (context, state) {
              if (state is ContactLoaded && state.contact.whatsapp != null) {
                return _buildStickyBottomBar(state.contact.whatsapp!);
              }
              return const SizedBox.shrink();
            },
          ),
          body: BlocBuilder<ContactBloc, ContactState>(
            builder: (context, state) {
              if (state is ContactLoading) {
                return _buildShimmerLoading();
              } else if (state is ContactError) {
                return _buildErrorView(context, state.message);
              } else if (state is ContactLoaded) {
                final c = state.contact;
                return CustomScrollView(
                  slivers: [
                    // 1. هيدر احترافي متحرك
                    _buildSliverAppBar(),

                    // 2. المحتوى
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // رسالة تسويقية قوية
                                Text(
                                  "لماذا تنضم إلى دليل سوريا؟ 🚀",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ميزات الانضمام (Value Proposition)
                                _buildFeatureRow(FontAwesomeIcons.chartLine, "زيادة مبيعاتك", "وصل خدمتك لآلاف العملاء المحتملين يومياً."),
                                _buildFeatureRow(FontAwesomeIcons.bullhorn, "تسويق مجاني", "نحن نقوم بالتسويق عنك، أنت فقط استقبل الطلبات."),
                                _buildFeatureRow(FontAwesomeIcons.clock, "دعم مستمر", "فريقنا التقني جاهز لمساعدتك في أي وقت."),

                                const SizedBox(height: 30),
                                Divider(color: Colors.grey.shade200, thickness: 1),
                                const SizedBox(height: 20),

                                Center(
                                  child: Text(
                                    "قنوات التواصل الرسمية",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // بطاقات التواصل المحسنة
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (c.phone != null)
                                      Expanded(child: _buildGlassCard(
                                        icon: FontAwesomeIcons.phone,
                                        label: "اتصال",
                                        color: const Color(0xFF007AFF),
                                        onTap: () => _launchUrl("tel:${c.phone}"),
                                      )),
                                    const SizedBox(width: 12),
                                    if (c.whatsapp != null)
                                      Expanded(child: _buildGlassCard(
                                        icon: FontAwesomeIcons.whatsapp,
                                        label: "واتساب",
                                        color: const Color(0xFF25D366),
                                        onTap: () => _launchUrl("https://wa.me/${c.whatsapp!.replaceAll('+', '')}"),
                                      )),
                                    const SizedBox(width: 12),
                                    if (c.address != null)
                                      Expanded(child: _buildGlassCard(
                                        icon: FontAwesomeIcons.mapLocationDot,
                                        label: "الموقع",
                                        color: const Color(0xFFFF9500),
                                        onTap: () => _launchMap(c.address!), // ✅ هذا سيفتح الخريطة ويبحث عن العنوان
                                      )),
                                  ],
                                ),

                                const SizedBox(height: 100), // مساحة فارغة للزر العائم
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // --- Widgets احترافية ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "شريك النجاح",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/join_us.png", // تأكد من وجود صورة عالية الجودة هنا
              fit: BoxFit.cover,
            ),
            // تدرج لوني لزيادة وضوح النصوص
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent, // اللون الأخضر أو الثانوي
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "انضم لأكثر من 1000+ شريك", // Social Proof
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "وسّع نطاق عملك معنا",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(String whatsapp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () => _launchUrl("https://wa.me/${whatsapp.replaceAll('+', '')}"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366), // WhatsApp Color
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "تواصل معنا الآن مجاناً",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ... (ErrorView & ShimmerLoading can remain similar but updated to match new layout)
  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. أيقونة مع خلفية ناعمة
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 60,
                color: Colors.redAccent.shade200,
              ),
            ),
            const SizedBox(height: 24),

            // 2. عنوان ودي
            Text(
              "انقطع الاتصال!",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // 3. رسالة الخطأ
            Text(
              "لا تقلق، يبدو أنها مشكلة بسيطة في الإنترنت.\nحاول مرة أخرى لنكمل انضمامك إلينا.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // 4. زر إعادة محاولة احترافي
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // إعادة طلب البيانات
                  context.read<ContactBloc>().add(LoadContactInfo());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  "تحديث الصفحة",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. محاكاة الهيدر الكبير (SliverAppBar)
              Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. محاكاة عنوان "لماذا تنضم"
                    Container(
                      width: 150,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. محاكاة قائمة الميزات (3 عناصر)
                    _buildShimmerFeatureItem(),
                    _buildShimmerFeatureItem(),
                    _buildShimmerFeatureItem(),

                    const SizedBox(height: 30),

                    // 4. خط فاصل وهمي
                    Container(width: double.infinity, height: 1, color: Colors.white),
                    const SizedBox(height: 20),

                    // 5. محاكاة عنوان "قنوات التواصل"
                    Center(
                      child: Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. محاكاة بطاقات التواصل الثلاث
                    Row(
                      children: [
                        Expanded(child: _buildShimmerCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildShimmerCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildShimmerCard()),
                      ],
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

  // عنصر مساعد لبناء سطر الميزة في الشيمر
  Widget _buildShimmerFeatureItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 12, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عنصر مساعد لبناء الكرت في الشيمر
  Widget _buildShimmerCard() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}