// screens/category/view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Imports
import '../../models/area_model.dart';
import '../../models/governorate_model.dart';
import '../../models/category_model.dart';
import '../../services/area_service.dart';
import '../../services/governorate_service.dart';
import '../../services/category_service.dart';
import '../../services/preferences_service.dart';
import '../../services/ad_service.dart'; // تأكد من الاستيراد
import '../../services/service_api.dart'; // للبحث
import '../../repositories/ad_repository.dart'; // للإعلانات
import '../../local/ad_cache.dart'; // للكاش
import '../../constant.dart';

// Blocs
import '../area/bloc.dart';
import '../area/event.dart';
import '../area/state.dart';
import '../governorate/bloc.dart';
import '../governorate/event.dart';
import '../governorate/state.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../ads/bloc.dart'; // بلوك الإعلانات
import '../ads/event.dart';
import '../ads/view.dart'; // ويدجت الإعلانات (AdCarouselView)

// Screens
import '../sub/view.dart';
import '../home/search_delegate.dart'; // البحث
import '../home/search_bloc.dart';
import '../prod/service_repository.dart';


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin: يحافظ على مكان السكرول عند التنقل بين التابات

  String? selectedGovernorate;
  String? selectedArea;
  List<Category> allCategories = [];
  List<Category> displayedCategories = [];

  @override
  bool get wantKeepAlive => true; // تفعيل الحفاظ على الحالة

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final saved = await PreferencesService.getSavedLocation();
    if (saved['governorate'] != null && saved['area'] != null) {
      if(mounted) {
        setState(() {
          selectedGovernorate = saved['governorate'];
          selectedArea = saved['area'];
        });
      }
    }
  }

  void applyFilter() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ضروري للـ KeepAlive

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocProvider(
        providers: [
          // 1. بلوك الأقسام
          BlocProvider(create: (_) => CategoryBloc(CategoryService())..add(FetchCategories())),
          // 2. بلوك المناطق والمحافظات
          BlocProvider(create: (_) => GovernorateBloc(GovernorateService())..add(LoadGovernorates())),
          BlocProvider(create: (_) => AreaBloc(AreaService())..add(LoadAreas())),
          // 3. بلوك الإعلانات (تم نقله هنا)
          BlocProvider(create: (_) => AdBloc(AdRepository(api: AdService(), cache: AdCache()))..add(FetchAdsEvent())),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            bottom: false,
            child: BlocConsumer<CategoryBloc, CategoryState>( // 🔥 حولنا من Builder لـ Consumer
              listener: (context, state) {
                // 🔔 كود إظهار الرسالة هنا
                if (state is CategoryLoaded && state.isOffline) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // إخفاء أي رسالة سابقة
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.wifi_off, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text("أنت تتصفح النسخة المحفوظة (لا يوجد إنترنت)"),
                        ],
                      ),
                      backgroundColor: Colors.grey[800],
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }

                if (state is CategoryError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {

                // منطق تحديث البيانات
                if (state is CategoryLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (allCategories != state.response.data) {
                      setState(() {
                        allCategories = state.response.data;
                        applyFilter();
                      });
                    }
                  });
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (state is CategoryLoaded && !state.isLoadingMore) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                        context.read<CategoryBloc>().add(FetchCategories());
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(), // سكرول مرن مثل iOS
                    slivers: [
                      // --- 1. الهيدر والبحث (SliverAppBar) ---
                      // يختفي ويظهر بذكاء عند السكرول
                      SliverAppBar(
                        floating: true,
                        pinned: false,
                        snap: true,
                        backgroundColor: const Color(0xFFF8F9FA),
                        elevation: 0,
                        toolbarHeight: 80,
                        title: _buildSearchHeader(context),
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                      ),

                      // --- 2. الإعلانات (تم دمجها بذكاء) ---
                      // --- 2. الإعلانات (تم دمجها بذكاء) ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            // 🔥 التعديل هنا: أزلنا SizedBox(height: 180)
                            // وتركنا الويدجت تأخذ راحتها
                            child: const AdCarouselView(),
                          ),
                        ),
                      ),

                      // --- 3. الفلاتر (SliverPersistentHeader) ---
                      // تبقى مثبتة في الأعلى عند النزول للأسفل
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverFiltersDelegate(
                          minHeight: 70.0,
                          maxHeight: 70.0,
                          child: Container(
                            color: const Color(0xFFF8F9FA), // نفس لون الخلفية للاندماج
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                            child: _buildFiltersRow(context),
                          ),
                        ),
                      ),

                      // 🔥🔥🔥 الإضافة الاحترافية هنا 🔥🔥🔥
// نظهر التلميح فقط إذا لم يتم اختيار المحافظة أو المنطقة
                      if (selectedGovernorate == null || selectedArea == null)
                        SliverToBoxAdapter(
                          child: AnimatedSwitcher(
                            // تأثير اختفاء ناعم جداً عند الاختيار
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return SizeTransition(sizeFactor: animation, child: FadeTransition(opacity: animation, child: child));
                            },
                            child: const LocationSelectionHint(key: ValueKey('hint')),
                          ),
                        ),

                      // --- 4. محتوى الشبكة (Grid) ---
                      if (state is CategoryLoading && allCategories.isEmpty)
                        SliverToBoxAdapter(child: _buildLoadingShimmerGrid())
                      else if (state is CategoryError && allCategories.isEmpty)
                        SliverFillRemaining(child: _buildErrorView(context, state.message))
                      else if (displayedCategories.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text("لا توجد أقسام في هذه المنطقة", style: TextStyle(color: Colors.grey[500]))),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72, // تحسين النسبة لتناسب الصور والنصوص
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  if (index < displayedCategories.length) {
                                    return _buildAnimatedCard(displayedCategories[index], index);
                                  } else {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  }
                                },
                                childCount: displayedCategories.length +
                                    ((state is CategoryLoaded && state.isLoadingMore) ? 1 : 0),
                              ),
                            ),
                          ),

                      const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  // هيدر البحث الجديد (عصري جداً)
  Widget _buildSearchHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final searchRepository = ServiceRepository(ServiceApi());
        showSearch(
          context: context,
          delegate: ProfessionalSearchDelegate(GlobalSearchBloc(searchRepository)),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("ابحث عن خدمة...", style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w400)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<GovernorateBloc, GovernorateState>(
            builder: (context, state) {
              List<Governorate> govs = [];
              if (state is GovernorateLoaded) govs = state.governorates;

              return _buildFilterChip(
                hint: "المحافظة",
                value: selectedGovernorate,
                items: govs.map((g) => g.name).toList(),
                icon: Icons.map_outlined,
                onChanged: (val) async {
                  setState(() {
                    selectedGovernorate = val;
                    selectedArea = null;
                  });
                  await PreferencesService.saveLocation(
                      governorate: selectedGovernorate!, area: selectedArea ?? '');
                  applyFilter();
                },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<AreaBloc, AreaState>(
            builder: (context, state) {
              List<Area> areas = [];
              if (state is AreaLoaded) {
                areas = state.areas.cast<Area>();
                if (selectedGovernorate != null) {
                  areas = areas.where((a) => a.governorate.name == selectedGovernorate).toList();
                }
              }
              return _buildFilterChip(
                hint: "المنطقة",
                value: selectedArea,
                items: areas.map((a) => a.name).toList(),
                icon: Icons.location_city_rounded,
                onChanged: (val) async {
                  setState(() => selectedArea = val);
                  await PreferencesService.saveLocation(
                      governorate: selectedGovernorate ?? '', area: selectedArea!);
                  applyFilter();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // تصميم Dropdown على شكل Chip عصري
  Widget _buildFilterChip({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    bool needsAttention = value == null;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))
        ],
        border: Border.all(
            color: needsAttention && (selectedGovernorate == null || selectedArea == null)
                ? AppColors.primary.withOpacity(0.5) // لون أحمر خفيف أو لون البراند
                : Colors.transparent,
            width: 1.5
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: value != null ? AppColors.primary : Colors.grey[400]),
          borderRadius: BorderRadius.circular(12),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(Category category, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index % 4) * 50), // حركة متتابعة
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubCategoryScreen(categoryId: category.id, categoryName: category.name),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: const Color(0xFFE0E0E0).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: category.imageUrl?.replaceFirst("http://", "https://") ?? "",
                        fit: BoxFit.contain, // تغيير ل contain لتظهر الصورة كاملة
                        placeholder: (_, __) => Center(child: Icon(Icons.image, color: Colors.grey[200], size: 40)),
                        errorWidget: (_, __, ___) => Center(child: Icon(Icons.broken_image, color: Colors.grey[300])),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 10, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              category.area.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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

  Widget _buildLoadingShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 6,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("تأكد من اتصالك بالإنترنت", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<CategoryBloc>().add(FetchCategories()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("تحديث", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Delegate للفلتر المثبت (Sticky Header)
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
  bool shouldRebuild(_SliverFiltersDelegate oldDelegate) => maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
}

// --- ويدجت التلميح الاحترافي ---
class LocationSelectionHint extends StatefulWidget {
  const LocationSelectionHint({super.key});

  @override
  State<LocationSelectionHint> createState() => _LocationSelectionHintState();
}

class _LocationSelectionHintState extends State<LocationSelectionHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // إعداد حركة القفز (Bouncing)
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // سرعة الحركة
      vsync: this,
    )..repeat(reverse: true); // تكرار الحركة ذهاباً وإياباً

    _animation = Tween<double>(begin: 0, end: 10).animate(
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // خلفية متدرجة جذابة
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // السهم المتحرك
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_animation.value), // تحريك للأعلى والأسفل
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
          // النص التوضيحي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "حدد منطقتك أولاً!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "لنظهر لك الخدمات المتاحة بالقرب منك بدقة.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}