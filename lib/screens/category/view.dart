import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import your models, services, blocs, and constants
import '../../models/area_model.dart';
import '../../models/governorate_model.dart';
import '../../services/area_service.dart';
import '../../services/governorate_service.dart';
import '../area/bloc.dart';
import '../area/event.dart';
import '../area/state.dart';
import '../governorate/bloc.dart';
import '../governorate/event.dart';
import '../governorate/state.dart';
import '../sub/view.dart'; // للانتقال للساب كاتيغوري
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';
import '../../constant.dart';
import '../../services/preferences_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // لم نعد بحاجة لـ ScrollController هنا لأننا سنستخدم NotificationListener
  // مثلما فعلت في SubCategoryScreen

  String? selectedGovernorate;
  String? selectedArea;

  // قائمة لتخزين البيانات القادمة من البلوك لتطبيق الفلتر عليها محلياً
  List<Category> allCategories = [];
  List<Category> displayedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final saved = await PreferencesService.getSavedLocation();
    if (saved['governorate'] != null && saved['area'] != null) {
      setState(() {
        selectedGovernorate = saved['governorate'];
        selectedArea = saved['area'];
      });
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CategoryBloc>(
            create: (_) => CategoryBloc(CategoryService())..add(FetchCategories()),
          ),
          BlocProvider<GovernorateBloc>(
            create: (_) => GovernorateBloc(GovernorateService())..add(LoadGovernorates()),
          ),
          BlocProvider<AreaBloc>(
            create: (_) => AreaBloc(AreaService())..add(LoadAreas()),
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                // 1. حالة التحميل الأولية (الشاشة فارغة تماماً)
                if (state is CategoryLoading && allCategories.isEmpty) {
                  return _buildLoadingShimmerGrid();
                }

                // 2. حالة الخطأ (والشاشة فارغة)
                if (state is CategoryError && allCategories.isEmpty) {
                  return _buildErrorView(context, state.message);
                }

                // 3. حالة البيانات موجودة (سواء محملة بالكامل أو تحمل المزيد)
                if (state is CategoryLoaded) {
                  // تحديث البيانات المحلية وتطبيق الفلتر
                  // نستخدم جدولة التحديث بعد انتهاء بناء الواجهة لتجنب أخطاء setState أثناء البناء
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (allCategories != state.response.data) {
                      setState(() {
                        allCategories = state.response.data;
                        applyFilter();
                      });
                    }
                  });
                }

                // استخدام NotificationListener كما في SubCategoryScreen
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (state is CategoryLoaded) {
                      // شرط الباجينيشن: وصلنا للنهاية + لا يوجد تحميل حالي + يوجد المزيد
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
                          !state.isLoadingMore) {
                        // هنا الـ context يعمل بشكل صحيح لأنه داخل الـ MultiBlocProvider
                        context.read<CategoryBloc>().add(FetchCategories());
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      // --- 1. الهيدر ---
                      SliverToBoxAdapter(
                        child: _buildHeader(context),
                      ),

                      // --- 2. الفلاتر (مثبتة) ---
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          minHeight: 80.0,
                          maxHeight: 80.0,
                          child: Container(
                            color: const Color(0xFFF8F9FA),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                            child: _buildFiltersRow(context),
                          ),
                        ),
                      ),

                      // --- 3. الشبكة (Grid) ---
                      if (displayedCategories.isEmpty && state is! CategoryLoading)
                        SliverFillRemaining(
                          child: Center(
                            child: Text("لا توجد أقسام مطابقة للبحث", style: TextStyle(color: Colors.grey[600])),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                // عرض البطاقات
                                if (index < displayedCategories.length) {
                                  return _buildAnimatedCard(displayedCategories[index], index);
                                }
                                // عرض اللودر في الأسفل عند سحب المزيد
                                else {
                                  return const Center(
                                    child: SizedBox(
                                      width: 30, height: 30,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                }
                              },
                              // عدد العناصر + 1 إذا كنا نحمل المزيد
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

  // --- مكونات الواجهة (Widgets) ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.only(right: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    shadowColor: Colors.black12
                ),
              ),
              Text(
                "استكشف الأقسام",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "كل ما تحتاجه من خدمات في مكان واحد",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
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

              return _buildCustomDropdown(
                hint: "المحافظة",
                value: selectedGovernorate,
                items: govs.map((g) => g.name).toList(),
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
              return _buildCustomDropdown(
                hint: "المنطقة",
                value: selectedArea,
                items: areas.map((a) => a.name).toList(),
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

  Widget _buildCustomDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(Category category, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index % 4) * 100),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _CategoryCard(category: category),
    );
  }

  Widget _buildLoadingShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
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
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text("حدث خطأ في الاتصال", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<CategoryBloc>().add(FetchCategories()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- كلاس البطاقة المخصص (نفس التصميم السابق) ---
class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // نمرر الاسم والـ ID للساب كاتيغوري كما طلبت
            builder: (_) => SubCategoryScreen(categoryId: category.id, categoryName: category.name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl?.replaceFirst("http://", "https://") ?? "",
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[100]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                category.area.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("تصفح", style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sliver Header Delegate ---
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
}