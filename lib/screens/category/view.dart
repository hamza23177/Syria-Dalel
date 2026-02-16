// screens/category/view.dart

import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';


// Imports
import '../../models/area_model.dart';
import '../../models/governorate_model.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../services/area_service.dart';
import '../../services/governorate_service.dart';
import '../../services/category_service.dart';
import '../../services/preferences_service.dart';
import '../../services/ad_service.dart';
import '../../services/service_api.dart';
import '../../repositories/ad_repository.dart';
import '../../local/ad_cache.dart';
import '../../constant.dart';

// Blocs
import '../area/bloc.dart';
import '../area/event.dart';
import '../area/state.dart';
import '../contact/view.dart';
import '../governorate/bloc.dart';
import '../governorate/event.dart';
import '../governorate/state.dart';
import '../prod/bloc.dart';
import '../prod/event.dart';
import '../prod/state.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../ads/bloc.dart';
import '../ads/event.dart';
import '../ads/view.dart';

// Screens
import '../sub/view.dart';
import '../home/search_delegate.dart';
import '../home/search_bloc.dart';
import '../prod/service_repository.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with AutomaticKeepAliveClientMixin {
  String? selectedGovernorate;
  String? selectedArea;
  List<Category> allCategories = [];
  List<Category> displayedCategories = [];

  bool _isFiltering = false;
  bool _isServicesLoadingMore = false;

  // Scroll Controller to handle shrink/expand effects if needed
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final saved = await PreferencesService.getSavedLocation();
    if (saved['governorate'] != null && saved['area'] != null) {
      if (mounted) {
        setState(() {
          selectedGovernorate = saved['governorate'];
          selectedArea = saved['area'];
        });
      }
    }
  }

  // 2. دالة الفلترة المحسنة (مع تأثير التحميل)
  Future<void> _filterCategoriesWithEffect() async {
    setState(() {
      _isFiltering = true; // تفعيل الشيمر
    });

    // تأخير بسيط جداً (مثلاً 600 ميلي ثانية) للسماح للعين برؤية الشيمر
    // هذا يعطي انطباعاً بالفخامة والمعالجة
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      if (selectedGovernorate == null || selectedArea == null) {
        displayedCategories = List.from(allCategories);
      } else {
        displayedCategories = allCategories.where((cat) {
          final gMatch = cat.area.governorate.name == selectedGovernorate;
          final aMatch = cat.area.name == selectedArea;
          return gMatch && aMatch;
        }).toList();
      }
      _isFiltering = false; // إخفاء الشيمر وإظهار النتائج
    });
  }

  // دالة الفلترة العادية (بدون أنيميشن) للاستخدام عند التحميل الأولي
  void _initialFilter() {
    if (selectedGovernorate == null || selectedArea == null) {
      displayedCategories = List.from(allCategories);
    } else {
      displayedCategories = allCategories.where((cat) {
        final gMatch = cat.area.governorate.name == selectedGovernorate;
        final aMatch = cat.area.name == selectedArea;
        return gMatch && aMatch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CategoryBloc(CategoryService())..add(FetchCategories())),
          BlocProvider(create: (_) => GovernorateBloc(GovernorateService())..add(LoadGovernorates())),
          BlocProvider(create: (_) => AreaBloc(AreaService())..add(LoadAreas())),
          BlocProvider(create: (_) => AdBloc(AdRepository(api: AdService(), cache: AdCache()))..add(FetchAdsEvent())),
          BlocProvider(create: (_) => ServiceBloc(ServiceRepository(ServiceApi()))
            ..add(FetchServices(subCategoryId: null))),
        ],
        child: Scaffold(
          // لون خلفية عصري جداً (Off-white) يبرز البطاقات البيضاء
          backgroundColor: AppColors.background,
    floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactView()));
    },
      backgroundColor: AppColors.accent,
      icon: const Icon(Icons.add_business_rounded, color: Colors.white),
      label: const Text(
        "أضف خدمتك الآن",
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
        ),
      ),
      elevation: 4,
    ),

          body: SafeArea(
            bottom: false,
            child: Builder(
              builder: (context) {
                return BlocConsumer<CategoryBloc, CategoryState>(
                  listener: (context, state) {
                    if (state is CategoryLoaded && state.isOffline) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text(" وضع التصفح دون اتصال بالانترنيت", style: TextStyle(fontFamily: 'Cairo')), // تأكد من وجود خط جميل
                            ],
                          ),
                          backgroundColor: const Color(0xFF323232),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                    if (state is CategoryError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (allCategories != state.response.data) {
                          setState(() {
                            allCategories = state.response.data;
                            _initialFilter();
                          });
                        }
                      });
                    }
                    bool shouldShowLoading = (state is CategoryLoading && allCategories.isEmpty) || _isFiltering;

                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        // لوجيك الباجينشن المزدوج (للخدمات)
                        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                          // استدعاء باجينشن الخدمات
                          final serviceBloc = context.read<ServiceBloc>();
                          if (serviceBloc.state is ServiceLoaded && !(serviceBloc.state as ServiceLoaded).isLoadingMore) {
                            serviceBloc.add(FetchServices(subCategoryId: null, loadMore: true));
                          }
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                          // --- 1. هيدر البحث المتطور ---
                          // --- 1. الهيدر الاحترافي (Facebook/WhatsApp Style) ---
                          SliverAppBar(
                            pinned: true,
                            floating: true,
                            snap: true,
                            backgroundColor: Colors.white, // خلفية بيضاء نقية
                            surfaceTintColor: Colors.white, // لمنع تغير اللون عند السكرول في أندرويد الحديث
                            elevation: 0, // إلغاء الظل ليبدو مسطحاً وعصرياً
                            expandedHeight: 120, // ارتفاع يسمح بوجود العنوان وشريط البحث
                            toolbarHeight: 60,

                            // العنوان (دليل سوريا) بلون البراند
                            title: const Text(
                              "دليل سوريا",
                              style: TextStyle(
                                color: AppColors.primary, // اللون البرتقالي
                                fontWeight: FontWeight.w900, // خط عريض جداً وقوي
                                fontSize: 26,
                                fontFamily: 'Cairo', // تأكد من تناسق الخط
                                letterSpacing: -0.5,
                              ),
                            ),
                            centerTitle: false, // العنوان على اليمين

                            // شريط البحث يظهر في الأسفل كجزء من الهيدر
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(60),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                                child: _buildCleanSearchBar(context),
                              ),
                            ),
                          ),

                          // --- 2. سلايدر الإعلانات ---
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: const AdCarouselView(),
                                ),
                              ),
                            ),
                          ),

                          // --- 3. الفلتر الذكي (Sticky Header) ---
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverFiltersDelegate(
                              minHeight: 85.0, // زيادة الارتفاع
                              maxHeight: 85.0,
                              child: _buildGlassyFilters(context),
                            ),
                          ),

                          // --- 4. تلميح الموقع التفاعلي ---
                          if (selectedGovernorate == null || selectedArea == null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: const LocationSelectionHint(key: ValueKey('hint')),
                              ),
                            ),

                          // --- 5. شبكة الأقسام (الخدمات) ---
                          if (shouldShowLoading)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              sliver: SliverToBoxAdapter(child: _buildLoadingShimmerGrid()),
                            )
                          else if (state is CategoryError && allCategories.isEmpty)
                            SliverFillRemaining(child: _buildErrorView(context, state.message))
                          else if (displayedCategories.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text(
                                        "لا توجد خدمات متاحة هنا حالياً",
                                        style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      if (index < displayedCategories.length) {
                                        return _buildPremiumCard(displayedCategories[index], index);
                                      } else {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                    },
                                    childCount: displayedCategories.length +
                                        ((state is CategoryLoaded && state.isLoadingMore) ? 1 : 0),
                                  ),
                                ),
                              ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                              child: Row(
                                children: [
                                  Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "خدمات أضيفت حديثاً",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
                                  ),
                                  const Spacer(),
                                  Text("تصفح الكل", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ),
                          ),

                          // --- 🔥 7. قائمة الخدمات (SliverList with BlocBuilder) ---
                          BlocBuilder<ServiceBloc, ServiceState>(
                            builder: (context, serviceState) {
                              if (serviceState is ServiceLoading) {
                                return SliverToBoxAdapter(child: _buildServiceShimmer());
                              } else if (serviceState is ServiceLoaded) {
                                if (serviceState.services.isEmpty) {
                                  return SliverToBoxAdapter(child: _buildEmptyServicesCTA());
                                }
                                return SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      if (index >= serviceState.services.length) {
                                        return serviceState.isLoadingMore
                                            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                                            : const SizedBox();
                                      }
                                      return PremiumServiceCard(service: serviceState.services[index]);
                                    },
                                    childCount: serviceState.services.length + (serviceState.isLoadingMore ? 1 : 0),
                                  ),
                                );
                              } else if (serviceState is ServiceError) {
                                return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Text("حدث خطأ في تحميل الخدمات", textAlign: TextAlign.center)));
                              }
                              return const SliverToBoxAdapter(child: SizedBox());
                            },
                          ),

                          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components ---
  

  // 1. هيدر البحث الفخم
  Widget _buildModernSearchHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final searchRepository = ServiceRepository(ServiceApi());
        showSearch(
          context: context,
          delegate: ProfessionalSearchDelegate(GlobalSearchBloc(searchRepository)),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF909090).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.primary, size: 26),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "عن ماذا تبحث اليوم؟",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "ابحث عن خدمات، محلات، فنيين...",
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            )
          ],
        ),
      ),
    );
  }

  // 2. الفلتر الزجاجي (Glassmorphism)
  // 2. الفلتر الزجاجي (Glassmorphism) - النسخة المصححة والمحسنة
  Widget _buildGlassyFilters(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFFF6F8FB).withOpacity(0.85),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          alignment: Alignment.center,
          child: Row(
            children: [
              // --- Governorate Dropdown ---
              Expanded(
                child: BlocBuilder<GovernorateBloc, GovernorateState>(
                  builder: (context, state) {
                    List<String> govItems = [];
                    if (state is GovernorateLoaded) {
                      // نستخدم Set لمنع التكرار ثم نحولها لقائمة
                      govItems = state.governorates
                          .map((g) => g.name.trim()) // Trim لإزالة أي مسافات زائدة
                          .toSet()
                          .toList();
                    }

                    // التحقق: هل القيمة المحفوظة موجودة في القائمة الحالية؟
                    // إذا كانت القائمة فارغة (تحميل)، نبقي القيمة كما هي لنمنع الوميض
                    String? validatedGov = selectedGovernorate;
                    if (govItems.isNotEmpty && selectedGovernorate != null) {
                      if (!govItems.contains(selectedGovernorate)) {
                        validatedGov = null;
                      }
                    }

                    return _buildPremiumDropdown(
                      hint: "المحافظة",
                      value: validatedGov,
                      items: govItems,
                      icon: Icons.map_rounded,
                      onChanged: (val) async {
                        if (val == selectedGovernorate) return;

                        setState(() {
                          selectedGovernorate = val;
                          selectedArea = null; // تصفير المنطقة عند تغيير المحافظة إجباري
                        });

                        await PreferencesService.saveLocation(
                            governorate: selectedGovernorate ?? '', area: '');

                        _filterCategoriesWithEffect();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // --- Area Dropdown (تم الإصلاح هنا) ---
              Expanded(
                child: BlocBuilder<AreaBloc, AreaState>(
                  builder: (context, state) {
                    List<String> areaItems = [];

                    if (state is AreaLoaded) {
                      var areas = state.areas;

                      // فلترة المناطق بناءً على المحافظة المختارة
                      if (selectedGovernorate != null) {
                        areas = areas.where((a) => a.governorate.name.trim() == selectedGovernorate!.trim()).toList();
                      }

                      // استخراج الأسماء وتنظيفها ومنع التكرار
                      areaItems = areas
                          .map((a) => a.name.trim())
                          .where((name) => name.isNotEmpty)
                          .toSet()
                          .toList();
                    }

                    // التحقق الذكي:
                    // 1. إذا لم نقم باختيار محافظة بعد، لا تسمح باختيار منطقة
                    if (selectedGovernorate == null) {
                      areaItems = [];
                    }

                    // 2. التحقق من القيمة المختارة
                    String? validatedArea = selectedArea;

                    // إذا كانت القائمة تحتوي عناصر، والقيمة المختارة غير موجودة فيها، قم بتصفيرها
                    // هذا يحل مشكلة الـ Exception ويسمح بالاختيار الصحيح
                    if (areaItems.isNotEmpty && selectedArea != null) {
                      if (!areaItems.contains(selectedArea)) {
                        validatedArea = null;
                        // ملاحظة: لا نستدعي setState هنا لتجنب infinite rebuilds
                        // ولكن الـ Dropdown سيظهر كـ null بصرياً وهو الصحيح
                      }
                    } else if (areaItems.isEmpty && selectedGovernorate != null) {
                      // إذا كانت القائمة فارغة (ربما لم تحمل بعد)، يفضل ترك القيمة null
                      validatedArea = null;
                    }

                    return _buildPremiumDropdown(
                      hint: "المنطقة",
                      value: validatedArea,
                      items: areaItems,
                      icon: Icons.location_on_rounded,
                      onChanged: (val) async {
                        // هنا الإصلاح الجوهري: تأكد من أن التحديث يحدث
                        setState(() {
                          selectedArea = val;
                        });

                        await PreferencesService.saveLocation(
                            governorate: selectedGovernorate ?? '', area: selectedArea!);

                        _filterCategoriesWithEffect();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final bool isSelected = value != null;
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: isSelected ? AppColors.primary : Colors.grey[400]),
          hint: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 10),
              Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
          isExpanded: true,
          style: const TextStyle(
              color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo'), // استخدم خط التطبيق
          borderRadius: BorderRadius.circular(16),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 3. الكرت الخرافي (Premium Card)
  Widget _buildPremiumCard(Category category, int index) {
    // حركة دخول متتالية للبطاقات
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index % 5) * 100),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // حركة من الأسفل للأعلى
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _InteractiveCard(category: category),
    );
  }

  Widget _buildLoadingShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6, // عدد الكروت الوهمية
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 80, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 50, color: Colors.white),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  // شريط البحث "النظيف" بدون أيقونات (Clean Minimalist Search)
  Widget _buildCleanSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final searchRepository = ServiceRepository(ServiceApi());
        showSearch(
          context: context,
          delegate: ProfessionalSearchDelegate(GlobalSearchBloc(searchRepository)),
        );
      },
      child: Container(
        height: 45, // ارتفاع مريح للعين
        width: double.infinity,
        alignment: Alignment.centerRight, // النص يبدأ من اليمين
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5), // لون رمادي فاتح جداً (مثل فيسبوك)
          borderRadius: BorderRadius.circular(30), // حواف دائرية بالكامل (Capsule shape)
        ),
        child: Text(
          "ابحث عن خدمة، مطعم، مهنة...", // النص التوضيحي
          style: TextStyle(
            color: Colors.grey[500], // لون النص رمادي هادئ
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // شيمر للخدمات
  Widget _buildServiceShimmer() {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        ),
      )),
    );
  }

  // دعوة لإضافة خدمة (عندما تكون القائمة فارغة)
  Widget _buildEmptyServicesCTA() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.add_business, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "كن أول من يضيف خدمته!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            "هناك آلاف الزوار بانتظار خدماتك، ابدأ الآن.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded, size: 40, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<CategoryBloc>().add(FetchCategories()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("محاولة مجدداً"),
          ),
        ],
      ),
    );
  }

// --- ويدجت الكرت التفاعلي (منفصلة لتحسين الأداء) ---
class _InteractiveCard extends StatefulWidget {
  final Category category;
  const _InteractiveCard({required this.category});

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoryScreen(
                categoryId: widget.category.id, categoryName: widget.category.name),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // حواف دائرية كبيرة
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF909090).withOpacity(0.1), // ظل ناعم جداً
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. الصورة
              Expanded(
                flex: 7, // الصورة تأخذ مساحة أكبر
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFF6F8FB),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: widget.category.imageUrl?.replaceFirst("http://", "https://") ?? "",
                        fit: BoxFit.cover, // تغيير لـ Cover لجعل الصورة تملأ المكان بجمالية
                        placeholder: (_, __) => Center(
                            child: Icon(Icons.image, color: Colors.grey[300], size: 40)),
                        errorWidget: (_, __, ___) => Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.grey[300])),
                      ),
                    ),
                  ),
                ),
              ),
              // 2. النصوص
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.category.area.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// Delegate للفلتر (Sticky Header)
class _SliverFiltersDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverFiltersDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);
  @override
  bool shouldRebuild(_SliverFiltersDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
}

// --- ويدجت التلميح الاحترافي (نفس الكود السابق مع تعديلات طفيفة) ---
class LocationSelectionHint extends StatefulWidget {
  const LocationSelectionHint({super.key});

  @override
  State<LocationSelectionHint> createState() => _LocationSelectionHintState();
}

class _LocationSelectionHintState extends State<LocationSelectionHint> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.08), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_animation.value),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("حدد منطقتك لعرض الخدمات!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text("تصفح أفضل الخدمات القريبة منك الآن.", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}

class PremiumServiceCard extends StatelessWidget {
  final ServiceModel service;
  const PremiumServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // 1. تحديد الصورة الأساسية
    final String displayImage = service.imageUrl ??
        service.imageUrl2 ??
        service.imageUrl3 ??
        "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. قسم الصورة (Header)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: displayImage.replaceFirst("http://", "https://"),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[100]),
                    errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[50],
                        child: Icon(Icons.broken_image, color: Colors.grey[300])
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Text(
                    service.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. التفاصيل (Body)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- بداية الـ Row الذي كان يسبب المشكلة ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // المنطقة
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          service.area,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ], // <--- ✅ تم إضافة هذا الإغلاق المفقود
                ), // <--- ✅ تم إضافة هذا القوس المفقود
                // --- نهاية الـ Row ---

                const SizedBox(height: 8),

                Text(
                  service.description ?? "لا يوجد وصف متاح لهذه الخدمة...",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 16),

                // 3. أزرار التفاعل
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // الانتقال للتفاصيل
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("عرض التفاصيل", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // كود الاتصال
                        },
                        icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}