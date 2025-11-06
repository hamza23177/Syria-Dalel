import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:shimmer/shimmer.dart';
import '../../services/preferences_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  String? selectedGovernorate;
  String? selectedArea;

  List<Category> allCategories = [];
  List<Category> filteredCategories = [];
  List<Governorate> governorates = [];
  List<Area> areas = [];
  List<Category> displayedCategories = [];

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {});
    });

    _controller.forward();

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
    final state = bloc.state;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      bloc.add(FetchCategories());
    }
  }



  void applyFilter() {
    if (selectedGovernorate == null || selectedArea == null) {
      displayedCategories = allCategories;
    } else {
      displayedCategories = allCategories.where((cat) {
        final gMatch = cat.area.governorate.name == selectedGovernorate;
        final aMatch = cat.area.name == selectedArea;
        return gMatch && aMatch;
      }).toList();
    }

    setState(() {});
  }


  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget categorySkeleton(double _w) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة الوهمية
              Expanded(
                flex: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
              ),
              // النصوص الوهمية
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(_w / 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(height: 14, width: _w * 0.4, color: Colors.white),
                      Container(height: 12, width: _w * 0.6, color: Colors.white),
                      Container(height: 12, width: _w * 0.3, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;

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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0.8,
            centerTitle: false,
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "الأقسام",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.primary),
          ),
          body: BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state is CategoryLoaded) {
                if (state.response.meta.currentPage > 1) {
                  allCategories.addAll(state.response.data);
                } else {
                  allCategories = state.response.data;
                }

                // أول تحميل
                displayedCategories = allCategories;

                // إذا كان المستخدم اختار محافظة ومنطقة مسبقًا
                if (selectedGovernorate != null && selectedArea != null) {
                  applyFilter();
                }

                setState(() {});
              }
            },

            child: Column(
              children: [
                // 🔽 Dropdowns المحافظات والمناطق
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // المحافظات
                      Expanded(
                        child: // داخل BlocBuilder للمحافظات
                        BlocBuilder<GovernorateBloc, GovernorateState>(
                          builder: (context, state) {
                            if (state is GovernorateLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } else if (state is GovernorateLoaded) {
                              governorates = state.governorates;
                              // ✅ أول مرة نحمل نختار أول محافظة
                              if (selectedGovernorate == null && governorates.isNotEmpty) {
                                selectedGovernorate = governorates.first.name;
                                if (allCategories.isNotEmpty) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    applyFilter(); // ✅ يتم استدعاؤها بعد انتهاء build
                                  });
                                }
                              }
                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  // ✅ بدل كلمة "المحافظة" خليها تظهر اسم المحافظة المختارة
                                  labelText: selectedGovernorate ?? "اختر المحافظة",
                                ),
                                value: selectedGovernorate,
                                items: governorates
                                    .map((g) => DropdownMenuItem(value: g.name, child: Text(g.name)))
                                    .toList(),
                                onChanged: (val) async {
                                  setState(() {
                                    selectedGovernorate = val;
                                    selectedArea = null;
                                  });
                                  await PreferencesService.saveLocation(
                                    governorate: selectedGovernorate!,
                                    area: selectedArea ?? '',
                                  );
                                  applyFilter();
                                },
                              );
                            } else if (state is GovernorateError) {
                              // return Text("خطأ:");
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // المناطق
                      Expanded(
                        child: // داخل BlocBuilder للمناطق
                        BlocBuilder<AreaBloc, AreaState>(
                          builder: (context, state) {
                            if (state is AreaLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } else if (state is AreaLoaded) {
                              areas = state.areas.cast<Area>();

                              final filteredAreas = selectedGovernorate == null
                                  ? areas
                                  : areas.where((a) => a.governorate.name == selectedGovernorate).toList();

                              // ✅ أول مرة نحدد منطقة
                              if (selectedArea == null && filteredAreas.isNotEmpty) {
                                selectedArea = filteredAreas.first.name;
                                if (allCategories.isNotEmpty) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    applyFilter(); // ✅
                                  });
                                }
                              }

                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  // ✅ بدل كلمة "المنطقة" خليها تظهر اسم المنطقة المختارة
                                  labelText: selectedArea ?? "اختر المنطقة",
                                ),
                                value: selectedArea,
                                items: filteredAreas
                                    .map((a) => DropdownMenuItem(value: a.name, child: Text(a.name)))
                                    .toList(),
                                onChanged: (val) async {
                                  setState(() {
                                    selectedArea = val;
                                  });
                                  await PreferencesService.saveLocation(
                                    governorate: selectedGovernorate ?? '',
                                    area: selectedArea!,
                                  );
                                  applyFilter();
                                },

                              );
                            } else if (state is AreaError) {
                              // return Text("خطأ: ");
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // GridView الكاتيغوريات
                Expanded(
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: 6,
                          itemBuilder: (_, __) => categorySkeleton(_w),
                        );
                      }

                      if (state is CategoryLoaded) {
                        final categories = displayedCategories;


                        return NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              context.read<CategoryBloc>().add(FetchCategories());
                            }
                            return false;
                          },
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: categories.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < categories.length) {
                                return card(categories[index]);
                              } else {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }
                      if (state is CategoryError) {
                        return _buildErrorView(
                          state.message,
                              () {
                            context.read<CategoryBloc>().add(FetchCategories());
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              "حدث خطأ أثناء تحميل البيانات",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget card(Category category) {
    double _w = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: _animation.value,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, animation, __) {
                return FadeTransition(
                  opacity: animation,
                  child: SubCategoryScreen(categoryId: category.id, categoryName: category.name),
                );
              },
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textLight,
                          size: 40,
                        ),
                      ),
                    )
                        : Image.asset(
                      'assets/images/person.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),

                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(_w / 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(category.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(category.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey)),
                        Text("في ${category.area.name}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.accent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
