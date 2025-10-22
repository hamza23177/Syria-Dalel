// screens/home/home_view.dart
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
        _scrollController.position.maxScrollExtent - 200) {
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

                      SectionTitle(title: "الفئات"),
                      buildGridOrMessage(
                        items: filteredCategories,
                        emptyMessage: "لا توجد فئات لهذه المنطقة",
                        gridBuilder: () => CategoryHorizontalList(categories: filteredCategories),
                      ),

                      const SizedBox(height: 20),

                      SectionTitle(title: "الفئات الفرعية"),
                      buildGridOrMessage(
                        items: filteredSubCategories,
                        emptyMessage: "لا توجد فئات فرعية لهذه المنطقة",
                        gridBuilder: () => SubCategoryList(subCategories: filteredSubCategories),
                      ),

                      const SizedBox(height: 20),

                      SectionTitle(title: "الخدمات"),
                      buildGridOrMessage(
                        items: filteredProducts,
                        emptyMessage: "لا توجد منتجات لهذه المنطقة",
                        gridBuilder: () => ProductGrid(products: filteredProducts),
                      ),
                      if (state.isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              } else if (state is HomeError) {
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

class CategoryHorizontalList extends StatelessWidget {
  final List<Category> categories;
  const CategoryHorizontalList({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoriesScreen(), // شاشة كل الكاتيجوري
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      cat.imageUrl ?? '',
                      fit: BoxFit.cover,
                      height: 75,
                      width: 75,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(cat.name, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SubCategoryList extends StatelessWidget {
  final List<SubCategory> subCategories;
  const SubCategoryList({required this.subCategories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subCategories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final sub = subCategories[index];
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
                  Text(sub.name, style: Theme.of(context).textTheme.bodyLarge),
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

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (ctx, i) {
        final product = products[i];
        return ProductCard(product: product); // ✅ نمرر الـ Product كامل
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
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
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

