// screens/home/home_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/repositories/ad_repository.dart';
import 'package:untitled2/screens/home/skeleton.dart';
import '../../constant.dart';
import '../../local/ad_cache.dart';
import '../../local/home_cache.dart';
import '../../repositories/home_repository.dart';
import '../../services/ad_service.dart';
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
        !bloc.isLoading &&
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
      filteredCategories = home.categories.where((cat) {
        bool governorateMatch = selectedGovernorate == null ||
            cat.area.governorate.name == selectedGovernorate;
        bool areaMatch = selectedArea == null || cat.area.name == selectedArea;
        return governorateMatch && areaMatch;
      }).toList();

      filteredSubCategories = home.subCategories.where((sub) {
        return filteredCategories.any((cat) => cat.id == sub.category.id);
      }).toList();

      filteredProducts = home.products.where((prod) {
        bool governorateMatch = selectedGovernorate == null ||
            prod.governorate == selectedGovernorate;
        bool areaMatch = selectedArea == null || prod.area == selectedArea;
        return governorateMatch && areaMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // استخدم Theme لتوحيد الألوان والخطوط
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => HomeBloc(
          HomeRepository(service: HomeService(), cache: HomeCache()),
        )..add(LoadHomeData()),
        child: Scaffold(
          backgroundColor: Colors.grey[50], // خلفية فاتحة جداً لإبراز المحتوى
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const HomeSkeleton();
              } else if (state is HomeLoaded) {
                homeData = state.data;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) applyFilter(homeData!);
                });

                final areasForSelectedGovernorate = selectedGovernorate == null
                    ? homeData!.areas
                    : homeData!.areas
                    .where((a) => a.governorate.name == selectedGovernorate)
                    .toList();

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // --- 1. Header مخصص بدلاً من AppBar ---
                    SliverToBoxAdapter(
                      child: _buildCustomHeader(context),
                    ),

                    // --- 2. الإعلانات والفلترة ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // سلايدر الإعلانات
                            Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))
                                  ]
                              ),
                              child: BlocProvider(
                                create: (_) => AdBloc(AdRepository(api: AdService(), cache: AdCache()))..add(FetchAdsEvent()),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: const AdCarouselView(),
                                ),
                              ),
                            ),

                            // الفلترة بتصميم عصري
                            _buildModernFilters(context, areasForSelectedGovernorate),

                            const SizedBox(height: 24),

                            // --- بنر دعوة للاشتراك ---
                            _buildPremiumBanner(context),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // --- 3. الأقسام الرئيسية ---
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SectionTitleWithMore(
                            title: "الأقسام الرئيسية",
                            onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesScreen())),
                          ),
                          CategoryHorizontalList(
                            categories: filteredCategories,
                            onEndReached: () => context.read<HomeBloc>().add(LoadMoreHomeData(page: context.read<HomeBloc>().currentPage + 1)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // --- 4. الأقسام الفرعية ---
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Text("تصفح حسب الفئات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          SubCategoryList(
                            subCategories: filteredSubCategories,
                            onEndReached: () => context.read<HomeBloc>().add(LoadMoreHomeData(page: context.read<HomeBloc>().currentPage + 1)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // --- 5. شبكة الخدمات ---
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text("أحدث الخدمات المميزة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72, // تحسين نسبة الطول للعرض
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return ProductCard(product: filteredProducts[index]);
                          },
                          childCount: filteredProducts.length,
                        ),
                      ),
                    ),

                    // --- 6. مؤشرات التحميل ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: state.isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : state.reachedEnd
                            ? Center(child: Text("وصلت لنهاية القائمة 🎉", style: TextStyle(color: Colors.grey)))
                            : const SizedBox(),
                      ),
                    ),
                  ],
                );
              } else if (state is HomeError) {
                return _buildErrorState(context, state.message);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // --- Widgets مساعدة داخلية ---

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("مرحباً بك 👋", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text("دليل سوريا", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
              // زر "أضف خدمتك" بتصميم بارز
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactView())),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text("أضف خدمتك", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // شريط بحث وهمي جمالي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[500]),
                const SizedBox(width: 10),
                Text("عن ماذا تبحث اليوم؟", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilters(BuildContext context, List areas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              context,
              label: "المحافظة",
              value: selectedGovernorate,
              items: homeData!.governorates.map((g) => g.name).toList(),
              onChanged: (val) {
                setState(() {
                  selectedGovernorate = val;
                  selectedArea = null;
                });
                applyFilter(homeData!);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              context,
              label: "المنطقة",
              value: selectedArea,
              items: areas.map<String>((a) => a.name as String).toList(),
              onChanged: (val) {
                setState(() => selectedArea = val);
                applyFilter(homeData!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text("الكل", style: TextStyle(fontSize: 13, color: Colors.grey[400])),
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.primary),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 24,
            child: Icon(Icons.star, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("كن مميزاً معنا!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text("اشترك الآن لتصل خدمتك لآلاف العملاء", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("عذراً، حدث خطأ ما", style: Theme.of(context).textTheme.titleLarge),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<HomeBloc>().add(LoadHomeData()),
            child: const Text("حاول مرة أخرى"),
          ),
        ],
      ),
    );
  }
}

// --- Widgets منفصلة محسنة ---

class SectionTitleWithMore extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionTitleWithMore({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Text("عرض الكل", style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// تصميم عصري لقائمة الفئات الأفقية
class CategoryHorizontalList extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback onEndReached;

  const CategoryHorizontalList({required this.categories, required this.onEndReached});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          if (index == categories.length - 1) onEndReached();

          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriesScreen())),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // مساحة للصورة داخل الدائرة
                      child: CachedNetworkImage(
                        imageUrl: cat.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(color: Colors.grey[100]),
                        errorWidget: (_, __, ___) => const Icon(Icons.category, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// بطاقة المنتج الاحترافية
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: product.id))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة مع شارة (Badge)
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                    ),
                  ),
                  // شارة الحالة (مثلاً: جديد أو موثق)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 10),
                          SizedBox(width: 4),
                          Text("مميز", style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // التفاصيل
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.area ?? 'سوريا',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    // زر وهمي صغير "تصفح"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "تصفح الخدمة",
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
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
// ✅ أضف هذا الكلاس في نهاية الملف لحل المشكلة
class SubCategoryList extends StatefulWidget {
  final List<SubCategory> subCategories;
  final VoidCallback onEndReached;

  const SubCategoryList({
    required this.subCategories,
    required this.onEndReached,
  });

  @override
  State<SubCategoryList> createState() => _SubCategoryListState();
}

class _SubCategoryListState extends State<SubCategoryList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 50) {
        widget.onEndReached();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "لا توجد فئات فرعية متاحة حالياً",
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      );
    }

    return SizedBox(
      height: 100, // ارتفاع مناسب للبطاقات العرضية
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.subCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
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
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    sub.imageUrl.isNotEmpty
                        ? sub.imageUrl
                        : 'https://via.placeholder.com/150', // صورة احتياطية
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), // تغميق الصورة قليلاً ليظهر النص
                    BlendMode.darken,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    sub.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
