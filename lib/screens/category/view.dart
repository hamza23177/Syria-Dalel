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
      filteredCategories = [];
      return;
    }

    filteredCategories = allCategories.where((cat) {
      bool governorateMatch = cat.area.governorate.name == selectedGovernorate;
      bool areaMatch = cat.area.name == selectedArea;
      return governorateMatch && areaMatch;
    }).toList();

    setState(() {}); // ✅ مهم عشان يحدّث الواجهة
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
            elevation: 1,
            centerTitle: false,
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "الأقسام",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
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

                // ✅ ما نفلتر مباشرة إلا إذا المحافظات والمناطق تحددت
                if (selectedGovernorate != null && selectedArea != null) {
                  applyFilter();
                }
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
                              return const Center(child: CircularProgressIndicator());
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
                                onChanged: (val) {
                                  setState(() {
                                    selectedGovernorate = val;
                                    selectedArea = null;
                                  });
                                  applyFilter();
                                },
                              );
                            } else if (state is GovernorateError) {
                              return Text("خطأ: ${state.message}");
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
                              return const Center(child: CircularProgressIndicator());
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
                                onChanged: (val) {
                                  setState(() {
                                    selectedArea = val;
                                  });
                                  applyFilter();
                                },
                              );
                            } else if (state is AreaError) {
                              return Text("خطأ: ${state.message}");
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
                      if (state is CategoryLoading && allCategories.isEmpty) {
                        // ✅ Skeleton Grid أثناء التحميل
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: 6, // عدد الكروت الوهمية
                          itemBuilder: (_, __) => categorySkeleton(_w),
                        );
                      } else if (filteredCategories.isEmpty) {
                        return Center(
                          child: Text(
                            "لا توجد فئات لهذه المنطقة",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                        );
                      } else {
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: filteredCategories.length + 1,
                          itemBuilder: (context, index) {
                            if (index < filteredCategories.length) {
                              final category = filteredCategories[index];
                              return card(category);
                            } else {
                              final bloc = context.read<CategoryBloc>();
                              final state = bloc.state;
                              if (state is CategoryLoaded &&
                                  state.response.meta.currentPage < state.response.meta.lastPage) {
                                return const Center(child: CircularProgressIndicator());
                              } else {
                                return const SizedBox();
                              }
                            }
                          },
                        );
                      }
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
                    child: Image.network(
                      category.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.textLight),
                      ),
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
