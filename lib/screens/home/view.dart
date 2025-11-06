// screens/home/home_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:untitled2/repositories/ad_repository.dart';
import 'package:untitled2/screens/home/skeleton.dart';
import '../../constant.dart';
import '../../local/ad_cache.dart';
import '../../local/home_cache.dart';
import '../../repositories/home_repository.dart';
import '../../services/ad_service.dart';
import '../../services/notification_service.dart';
import '../ads/bloc.dart';
import '../ads/event.dart';
import '../ads/view.dart';
import '../category/view.dart';
import '../contact/view.dart';
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
      filteredCategories =
          home.categories.where((cat) {
            bool governorateMatch =
                selectedGovernorate == null ||
                cat.area.governorate.name == selectedGovernorate;
            bool areaMatch =
                selectedArea == null || cat.area.name == selectedArea;
            return governorateMatch && areaMatch;
          }).toList();

      // فلترة الفئات الفرعية
      filteredSubCategories =
          home.subCategories.where((sub) {
            return filteredCategories.any((cat) => cat.id == sub.category.id);
          }).toList();

      // فلترة المنتجات
      filteredProducts =
          home.products.where((prod) {
            bool governorateMatch =
                selectedGovernorate == null ||
                prod.governorate == selectedGovernorate;
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primary),
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
        create: (_) => HomeBloc(
          HomeRepository(
            service: HomeService(),
            cache: HomeCache(),
          ),
        )..add(LoadHomeData()),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ العنوان الرئيسي
                Text(
                  "دليل سوريا",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),

                // ✅ زر أنيق وغير مزعج
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactView()),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  label: Text(
                    "أضف خدمتك الآن",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
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

                final areasForSelectedGovernorate =
                    selectedGovernorate == null
                        ? homeData!.areas
                        : homeData!.areas
                            .where(
                              (a) => a.governorate.name == selectedGovernorate,
                            )
                            .toList();

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Hero Carousel ---
                      BlocProvider(
                        create: (_) => AdBloc(
                          AdRepository(
                            api: AdService(),
                            cache: AdCache(),
                          ),
                        )..add(FetchAdsEvent()),
                        child: const AdCarouselView(),
                      ),
                      const SizedBox(height: 24),

                      // --- Dropdown Filters ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ), // قلل التباعد قليلًا
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelText: "المحافظة",
                                  labelStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: selectedGovernorate,
                                items:
                                    homeData!.governorates.map((g) {
                                      return DropdownMenuItem(
                                        value: g.name,
                                        child: Text(
                                          g.name,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // ✅ يمنع تمدد النص
                                        ),
                                      );
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
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelText: "المنطقة",
                                  labelStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: selectedArea,
                                items:
                                    areasForSelectedGovernorate.map((a) {
                                      return DropdownMenuItem(
                                        value: a.name,
                                        child: Text(
                                          a.name,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // ✅ يمنع التمدد
                                        ),
                                      );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoriesScreen(),
                            ),
                          );
                        },
                      ),
                      CategoryHorizontalList(
                        categories: filteredCategories,
                        onEndReached: () {
                          context.read<HomeBloc>().add(
                            LoadMoreHomeData(
                              page: context.read<HomeBloc>().currentPage + 1,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      SectionTitle(title: "الفئات الفرعية"),
                      SubCategoryList(
                        subCategories: filteredSubCategories,
                        onEndReached: () {
                          context.read<HomeBloc>().add(
                            LoadMoreHomeData(
                              page: context.read<HomeBloc>().currentPage + 1,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      SectionTitle(title: "الخدمات"),
                      ProductGrid(
                        products: filteredProducts,
                        onEndReached: () {
                          context.read<HomeBloc>().add(
                            LoadMoreHomeData(
                              page: context.read<HomeBloc>().currentPage + 1,
                            ),
                          );
                        },
                      ),
                      if (state.reachedEnd)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "🎉 تم عرض كل الخدمات المتاحة",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
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
              } else if (state is HomeError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
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
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 100) {
        widget.onEndReached();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (ctx, i) {
            final cat = widget.categories[i];
            return InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoriesScreen()),
                  ),
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
                        imageUrl: (cat.imageUrl.isNotEmpty)
                            ? cat.imageUrl
                            : 'https://invalid.url',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/person.png',
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        ),
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
      ),
    );
  }
}

// ✅ تصميم عصري للفئات الفرعية
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 160,
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
                    builder:
                        (_) => SubCategoryScreen(
                          categoryId: sub.category.id,
                          categoryName: sub.category.name,
                        ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 12),
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // الصورة
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: (sub.imageUrl.isNotEmpty)
                            ? sub.imageUrl
                            : 'https://invalid.url', // رابط وهمي لتجنب الخطأ
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/person.png', // الصورة الافتراضية
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // التدرج والاسم
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        sub.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
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
      ),
    );
  }
}

class ProductGrid extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onEndReached;

  const ProductGrid({required this.products, required this.onEndReached});

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        controller: _controller,
        padding: const EdgeInsets.all(12),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (ctx, i) {
          final product = widget.products[i];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(serviceId: product.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ الصورة
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: CachedNetworkImage(
                  imageUrl: (product.imageUrl.isNotEmpty)
                      ? product.imageUrl
                      : 'https://invalid.url', // لتفادي الخطأ
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 130,
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/person.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 130,
                  ),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

              // ✅ المحتوى
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.area ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),

                      // ✅ الزر
                      // ✅ الزر الجديد الهادئ
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ServiceDetailScreen(
                                      serviceId: product.id,
                                    ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            "عرض",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            backgroundColor: AppColors.primary.withOpacity(
                              0.05,
                            ),
                          ),
                        ),
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

class SectionTitleWithMore extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionTitleWithMore({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text("مشاهدة الجميع ›"),
            ),
          ],
        ),
      ),
    );
  }
}
