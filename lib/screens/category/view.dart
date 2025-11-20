import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import your models, services, blocs, and constants here
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
import '../sub/view.dart';
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
  final ScrollController _scrollController = ScrollController();

  String? selectedGovernorate;
  String? selectedArea;

  List<Category> allCategories = [];
  List<Category> displayedCategories = [];
  List<Governorate> governorates = [];
  List<Area> areas = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  void _onScroll() {
    final bloc = context.read<CategoryBloc>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      bloc.add(FetchCategories());
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          backgroundColor: const Color(0xFFF8F9FA), // لون خلفية هادئ وعصري
          body: SafeArea(
            child: BlocListener<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategoryLoaded) {
                  final newData = state.response.data;
                  final existingIds = allCategories.map((e) => e.id).toSet();
                  final filtered = newData.where((c) => !existingIds.contains(c.id)).toList();

                  allCategories.addAll(filtered);
                  displayedCategories = List.from(allCategories);

                  if (selectedGovernorate != null && selectedArea != null) {
                    applyFilter();
                  }
                  setState(() {});
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Header Section
                  SliverToBoxAdapter(
                    child: Padding(
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
                                    padding: const EdgeInsets.only(right: 6), // تعديل بصري للسهم
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
                    ),
                  ),

                  // 2. Filters Section
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      minHeight: 80.0,
                      maxHeight: 80.0,
                      child: Container(
                        color: const Color(0xFFF8F9FA), // نفس لون الخلفية ليبدو شفافاً
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                        child: _buildFiltersRow(),
                      ),
                    ),
                  ),

                  // 3. Grid Section
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading && allCategories.isEmpty) {
                        return SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildSkeletonItem(),
                              childCount: 6,
                            ),
                          ),
                        );
                      }

                      if (state is CategoryError && allCategories.isEmpty) {
                        return SliverFillRemaining(
                          child: _buildErrorView(state.message, () {
                            context.read<CategoryBloc>().add(FetchCategories());
                          }),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7, // نسبة طول أفضل للبطاقة
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index < displayedCategories.length) {
                                // Animation logic
                                return _buildAnimatedCard(displayedCategories[index], index);
                              } else if (state is CategoryLoaded && state.isLoadingMore) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return null;
                            },
                            childCount: displayedCategories.length +
                                ((state is CategoryLoaded && state.isLoadingMore) ? 1 : 0),
                          ),
                        ),
                      );
                    },
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Filter Widgets ---
  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<GovernorateBloc, GovernorateState>(
            builder: (context, state) {
              if (state is GovernorateLoaded) {
                governorates = state.governorates;
                // Default Selection Logic
                if (selectedGovernorate == null && governorates.isNotEmpty) {
                  // لا نقوم بفرض قيمة هنا لترك الحرية للمستخدم، أو يمكن تفعيلها حسب الرغبة
                  // selectedGovernorate = governorates.first.name;
                }
                return _buildCustomDropdown(
                  hint: "المحافظة",
                  value: selectedGovernorate,
                  items: governorates.map((g) => g.name).toList(),
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
              }
              return _buildLoadingFilter();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<AreaBloc, AreaState>(
            builder: (context, state) {
              if (state is AreaLoaded) {
                areas = state.areas.cast<Area>();
                final filteredAreas = selectedGovernorate == null
                    ? areas
                    : areas.where((a) => a.governorate.name == selectedGovernorate).toList();

                return _buildCustomDropdown(
                  hint: "المنطقة",
                  value: selectedArea,
                  items: filteredAreas.map((a) => a.name).toList(),
                  onChanged: (val) async {
                    setState(() => selectedArea = val);
                    await PreferencesService.saveLocation(
                        governorate: selectedGovernorate ?? '', area: selectedArea!);
                    applyFilter();
                  },
                );
              }
              return _buildLoadingFilter();
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

  Widget _buildLoadingFilter() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // --- Card & Item Widgets ---
  Widget _buildAnimatedCard(Category category, int index) {
    // أنيميشن بسيط للظهور
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index % 4) * 100), // تأخير بسيط لكل عنصر
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // حركة من الأسفل للأعلى
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _CategoryCard(category: category),
    );
  }

  Widget _buildSkeletonItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- كلاس البطاقة المخصص ---
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
            // 1. الصورة
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: category.imageUrl?.replaceFirst("http://", "https://") ?? "",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[100]),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  // تدرج لوني خفيف فوق الصورة
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. المحتوى النصي
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
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

                    // زر وهمي صغير يدعو للنقر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "تصفح",
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
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

// --- كلاس مساعد لل Sliver Header ---
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}