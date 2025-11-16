import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/service_model.dart';
import '../details/view.dart';
import '../sub/sub_category_skeleton.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class ServiceScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;

  const ServiceScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
  });

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(FetchServices(subCategoryId: widget.subCategoryId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        // تحميل قبل الوصول للنهاية بـ 300 بكسل
        context.read<ServiceBloc>().add(
          FetchServices(subCategoryId: widget.subCategoryId, loadMore: true),
        );
      }
    });
    context.read<ServiceBloc>().add(FetchServices(subCategoryId: widget.subCategoryId));

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

    /// استدعاء الخدمات
    context
        .read<ServiceBloc>()
        .add(FetchServices(subCategoryId: widget.subCategoryId));
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
      textDirection: TextDirection.rtl, // لجعل الواجهة عربية
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xffF57752),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "الخدمات - ${widget.subCategoryName}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: 6, // عدد السكلتونات
                    itemBuilder: (context, index) {
                      return SubCategorySkeleton(width: _w);
                    },
                  );
                } else if (state is ServiceLoaded) {
                  if (state.services.isEmpty) {
                    return const Center(child: Text("لا توجد خدمات متاحة"));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.services.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.services.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                      }
                      final service = state.services[index];

                      return Opacity(
                        opacity: _animation.value,
                        child: Transform.translate(
                          offset: Offset(0, _animation2.value),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailScreen(serviceId: service.id),
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
                                  /// صورة الخدمة
                                  CircleAvatar(
                                    backgroundColor: Colors.orange.shade50,
                                    radius: _w / 10,
                                    backgroundImage: service.imageUrl != null
                                        ? NetworkImage(service.imageUrl!)
                                        : null,
                                    child: service.imageUrl == null
                                        ? const Icon(Icons.person_2_outlined,
                                        size: 30, color: Colors.grey)
                                        : null,
                                  ),

                                  /// معلومات الخدمة
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
                                            service.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textScaleFactor: 1.3,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                              Colors.black.withOpacity(.8),
                                            ),
                                          ),
                                          Text(
                                            service.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                              Colors.black.withOpacity(.7),
                                            ),
                                          ),
                                          Text(
                                            service.phone,
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
                } else if (state is ServiceError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ServiceBloc>().add(
                              FetchServices(subCategoryId: widget.subCategoryId),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("إعادة المحاولة"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF57752),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),

            /// Top Decoration (الـ Painter)
            CustomPaint(
              painter: MyPainter(),
              child: Container(height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

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
      ..cubicTo(
          size.width * .95, 0, size.width, 20, size.width, size.width * .08);

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
