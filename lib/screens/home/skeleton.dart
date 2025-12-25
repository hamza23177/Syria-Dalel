// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
//
// class HomeSkeleton extends StatelessWidget {
//   const HomeSkeleton({super.key});
//
//   Widget buildBox({
//     double height = 100,
//     double width = double.infinity,
//     double radius = 12,
//   }) {
//     return Container(
//       height: height,
//       width: width,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(radius),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Hero Carousel Skeleton ---
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: buildBox(height: 200, radius: 16),
//             ),
//
//             const SizedBox(height: 16),
//
//             // --- Filters Skeleton ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: Row(
//                 children: [
//                   Expanded(child: buildBox(height: 55)),
//                   const SizedBox(width: 10),
//                   Expanded(child: buildBox(height: 55)),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // --- Categories Skeleton (horizontal list) ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: buildBox(height: 20, width: 100), // عنوان القسم
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 105,
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 6,
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (_, __) => Column(
//                   children: [
//                     buildBox(height: 75, width: 75, radius: 12),
//                     const SizedBox(height: 4),
//                     buildBox(height: 14, width: 60, radius: 8),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // --- SubCategories Skeleton (horizontal cards) ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: buildBox(height: 20, width: 120),
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 200,
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 4,
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (_, __) => Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     buildBox(height: 130, width: 160, radius: 12),
//                     const SizedBox(height: 6),
//                     buildBox(height: 16, width: 100, radius: 8),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // --- Products Skeleton (grid) ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: buildBox(height: 20, width: 120),
//             ),
//             const SizedBox(height: 8),
//             GridView.builder(
//               padding: const EdgeInsets.all(12),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: 4,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 0.75,
//               ),
//               itemBuilder: (_, __) => buildBox(height: 200, radius: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
