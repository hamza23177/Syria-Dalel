import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled2/screens/sub/sub_category_skeleton.dart';
import '../../services/service_api.dart';
import '../../services/sub_category_service.dart';
import '../prod/bloc.dart';
import '../prod/event.dart';
import '../prod/service_repository.dart';
import '../prod/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class SubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    /// Animation init
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {});
    });

    _animation2 = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => SubCategoryBloc(SubCategoryService())
          ..add(FetchSubCategories(categoryId: widget.categoryId)),
        child: Scaffold(
          backgroundColor: const Color(0xffF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xffF57752),
            elevation: 0,
            centerTitle: true,
            title: Text(
              "الأقسام الفرعية - ${widget.categoryName}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              BlocBuilder<SubCategoryBloc, SubCategoryState>(
                builder: (context, state) {
                  if (state is SubCategoryLoading) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 6, // عدد السكلتونات
                      itemBuilder: (context, index) {
                        return SubCategorySkeleton(width: _w);
                      },
                    );
                  } else if (state is SubCategoryLoaded) {
                    if (state.subCategories.isEmpty) {
                      return const Center(child: Text("لا توجد أقسام فرعية"));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.subCategories.length,
                      itemBuilder: (context, index) {
                        final sub = state.subCategories[index];

                        return Opacity(
                          opacity: _animation.value,
                          child: Transform.translate(
                            offset: Offset(0, _animation2.value),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (context) => ServiceBloc(
                                          ServiceRepository(ServiceApi()))
                                        ..add(FetchServices(
                                            subCategoryId: sub.id)),
                                      child: ServiceScreen(
                                        subCategoryId: sub.id,
                                        subCategoryName: sub.name,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    _w / 20, _w / 20, _w / 20, 0),
                                padding: EdgeInsets.all(_w / 20),
                                height: _w / 3.5,
                                width: _w,
                                decoration: BoxDecoration(
                                  color: const Color(0xffEDECEA),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.05),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// صورة القسم الفرعي
                                    CircleAvatar(
                                      backgroundColor: Colors.orange.shade50,
                                      radius: _w / 10,
                                      backgroundImage: sub.imageUrl != null
                                          ? NetworkImage(sub.imageUrl!)
                                          : null,
                                      child: sub.imageUrl == null
                                          ? const Icon(Icons.category,
                                          size: 30, color: Colors.grey)
                                          : null,
                                    ),

                                    /// معلومات القسم
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sub.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textScaleFactor: 1.3,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black
                                                    .withOpacity(.8),
                                              ),
                                            ),
                                            Text(
                                              sub.category.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black
                                                    .withOpacity(.7),
                                              ),
                                            ),
                                            Text(
                                              "في ${sub.category.area.name}",
                                              style: const TextStyle(
                                                color: Colors.deepOrange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const Icon(Icons.navigate_next,
                                        color: Colors.black54),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is SubCategoryError) {
                    return Center(child: Text("خطأ: ${state.message}"));
                  }
                  return const SizedBox();
                },
              ),

              /// Top Decoration
              CustomPaint(
                painter: MyPainter(),
                child: Container(height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// نفس الـ Painter تبع الخدمات
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_1 = Paint()
      ..color = const Color(0xffF57752)
      ..style = PaintingStyle.fill;

    Path path_1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .1, 0)
      ..cubicTo(size.width * .05, 0, 0, 20, 0, size.width * .08);

    Path path_2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * .9, 0)
      ..cubicTo(size.width * .95, 0, size.width, 20, size.width, size.width * .08);

    Paint paint_2 = Paint()
      ..color = const Color(0xffF57752)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Path path_3 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path_1, paint_1);
    canvas.drawPath(path_2, paint_1);
    canvas.drawPath(path_3, paint_2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
