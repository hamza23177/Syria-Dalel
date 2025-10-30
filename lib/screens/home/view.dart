// screens/home/home_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:untitled2/screens/home/skeleton.dart';
import '../../constant.dart';
import '../../services/ad_service.dart';
import '../../services/notification_service.dart';
import '../ads/bloc.dart';
import '../ads/event.dart';
import '../ads/view.dart';
import '../category/view.dart';
import '../details/view.dart';
import '../sub/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../services/home_service.dart';
import '../../models/home_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? selectedGovernorate;
  String? selectedArea;
  List<Category> filteredCategories = [];
  List<SubCategory> filteredSubCategories = [];
  List<Product> filteredProducts = [];
  HomeData? homeData;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bloc = context.read<HomeBloc>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250 &&
        !bloc.isLoadingMore &&
        bloc.hasMore) {
      bloc.add(LoadMoreHomeData(page: bloc.currentPage + 1));
    }
    if (bloc.cachedData != null &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 250 &&
        !bloc.isLoadingMore &&
        bloc.hasMore) {
      bloc.add(LoadMoreHomeData(page: bloc.currentPage + 1));
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  void applyFilter(HomeData home) {
    setState(() {
      // فلترة الفئات
      filteredCategories = home.categories.where((cat) {
        bool governorateMatch = selectedGovernorate == null || cat.area.governorate.name == selectedGovernorate;
        bool areaMatch = selectedArea == null || cat.area.name == selectedArea;
        return governorateMatch && areaMatch;
      }).toList();

      // فلترة الفئات الفرعية
      filteredSubCategories = home.subCategories.where((sub) {
        return filteredCategories.any((cat) => cat.id == sub.category.id);
      }).toList();

      // فلترة المنتجات
      filteredProducts = home.products.where((prod) {
        bool governorateMatch = selectedGovernorate == null || prod.governorate == selectedGovernorate;
        bool areaMatch = selectedArea == null || prod.area == selectedArea;
        return governorateMatch && areaMatch;
      }).toList();
    });
  }

  Widget buildGridOrMessage<T>({
    required List<T> items,
    required Widget Function() gridBuilder,
    String emptyMessage = "لا توجد بيانات متاحة",
  }) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary),
          ),
        ),
      );
    } else {
      return gridBuilder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => HomeBloc(HomeService())..add(LoadHomeData()),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0.8,
            centerTitle: false,
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "دليل سوريا",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.primary),
          ),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const HomeSkeleton();
              } else if (state is HomeLoaded) {
                homeData ??= state.data; // فقط خزّن البيانات عند أول تحميل
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) applyFilter(homeData!);
                });

                final areasForSelectedGovernorate = selectedGovernorate == null
                    ? homeData!.areas
                    : homeData!.areas.where((a) => a.governorate.name == selectedGovernorate).toList();

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Hero Carousel ---
                      BlocProvider(
                        create: (_) => AdBloc(AdService())..add(FetchAdsEvent()),
                        child: const AdCarouselView(),
                      ),// ✅ هنا نضع الإعلان الاحترافي
                      const SizedBox(height: 24),

                      // --- Dropdown Filters ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  labelText: "المحافظة",
                                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: selectedGovernorate,
                                items: homeData!.governorates.map((g) {
                                  return DropdownMenuItem(value: g.name, child: Text(g.name));
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedGovernorate = val;
                                    selectedArea = null;
                                  });
                                  applyFilter(homeData!);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  labelText: "المنطقة",
                                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: selectedArea,
                                items: areasForSelectedGovernorate.map((a) {
                                  return DropdownMenuItem(value: a.name, child: Text(a.name));
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedArea = val;
                                  });
                                  applyFilter(homeData!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SectionTitle(title: "الفئات"),
                      // buildGridOrMessage(
                      //   items: filteredCategories,
                      //   emptyMessage: "لا توجد فئات لهذه المنطقة",
                      //   gridBuilder: () => CategoryHorizontalList(categories: filteredCategories),
                      // ),
                      SectionTitleWithMore(
                        title: "الفئات",
                        onViewAll: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesScreen()));
                        },
                      ),
                      CategoryHorizontalList(
                        categories: filteredCategories,
                        onEndReached: () {
                          context.read<HomeBloc>().add(LoadMoreHomeData(page: context.read<HomeBloc>().currentPage + 1));
                        },
                      ),

                      const SizedBox(height: 20),

                      SectionTitle(title: "الفئات الفرعية"),
                      SubCategoryList(
                        subCategories: filteredSubCategories,
                        onEndReached: () {
                          context.read<HomeBloc>().add(LoadMoreHomeData(page: context.read<HomeBloc>().currentPage + 1));
                        },
                      ),

                      const SizedBox(height: 20),

                      SectionTitle(title: "الخدمات"),
                      ProductGrid(
                        products: filteredProducts,
                        onEndReached: () {
                          context.read<HomeBloc>().add(LoadMoreHomeData(page: context.read<HomeBloc>().currentPage + 1));
                        },
                      ),
                      if (state.reachedEnd)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "🎉 تم عرض كل الخدمات المتاحة",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      else if (state.isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
              else if (state is HomeError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<HomeBloc>().add(LoadHomeData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            "إعادة المحاولة",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
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
}

// --- Widgets ---
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class CategoryHorizontalList extends StatefulWidget {
  final List<Category> categories;
  final VoidCallback onEndReached;

  const CategoryHorizontalList({
    required this.categories,
    required this.onEndReached,
  });

  @override
  _CategoryHorizontalListState createState() => _CategoryHorizontalListState();
}

class _CategoryHorizontalListState extends State<CategoryHorizontalList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 100) {
        widget.onEndReached();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (ctx, i) {
          final cat = widget.categories[i];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesScreen())),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: cat.imageUrl ?? '',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: widget.categories.length,
      ),
    );
  }
}



class SubCategoryList extends StatefulWidget {
  final List<SubCategory> subCategories;
  final VoidCallback onEndReached;

  const SubCategoryList({
    required this.subCategories,
    required this.onEndReached,
  });

  @override
  _SubCategoryListState createState() => _SubCategoryListState();
}

class _SubCategoryListState extends State<SubCategoryList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 100) {
        widget.onEndReached();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.subCategories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final sub = widget.subCategories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubCategoryScreen(
                    categoryId: sub.category.id,
                    categoryName: sub.category.name,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              margin: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      sub.imageUrl ?? '',
                      fit: BoxFit.cover,
                      height: 130,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(sub.name,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String image;

  const CategoryCard({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class ProductGrid extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onEndReached;

  const ProductGrid({
    required this.products,
    required this.onEndReached,
  });

  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 100) {
        widget.onEndReached();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _controller,
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.products.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (ctx, i) {
        final product = widget.products[i];
        return ProductCard(product: product);
      },
    );
  }
}


class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.name, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(serviceId: product.id), // ✅ الآن الـ id متوفر
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("عرض التفاصيل"),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitleWithMore extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionTitleWithMore({
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text("مشاهدة الجميع ›"),
          ),
        ],
      ),
    );
  }
}
