import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubCategorySkeleton extends StatelessWidget {
  final double width;

  const SubCategorySkeleton({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.fromLTRB(width / 20, width / 20, width / 20, 0),
        padding: EdgeInsets.all(width / 20),
        height: width / 3.5,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الدائرة (صورة القسم)
            CircleAvatar(
              radius: width / 10,
              backgroundColor: Colors.white,
            ),

            // النصوص
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: width * 0.4,
                      color: Colors.white,
                    ),
                    Container(
                      height: 12,
                      width: width * 0.3,
                      color: Colors.white,
                    ),
                    Container(
                      height: 12,
                      width: width * 0.5,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // أيقونة وهمية
            Container(
              height: 24,
              width: 24,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
