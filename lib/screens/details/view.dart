import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/service_api.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../models/service_model.dart';

class ServiceDetailScreen extends StatelessWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => ServiceBloc(ServiceApi())..add(LoadServiceDetails(serviceId)),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("تفاصيل الخدمة"),
            backgroundColor: Colors.blueAccent,
          ),
          body: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ServiceLoaded) {
                return _buildDetails(context, state.service);
              } else if (state is ServiceError) {
                return Center(child: Text("خطأ: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ServiceModel service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صور الخدمة
          SizedBox(
            height: 200,
            child: PageView(
              children: [
                if (service.imageUrl != null)
                  Image.network(service.imageUrl!, fit: BoxFit.cover),
                if (service.imageUrl2 != null)
                  Image.network(service.imageUrl2!, fit: BoxFit.cover),
                if (service.imageUrl3 != null)
                  Image.network(service.imageUrl3!, fit: BoxFit.cover),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // اسم الخدمة
          Text(service.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.black87)),

          const SizedBox(height: 8),
          Text("📍 ${service.address}, ${service.area}, ${service.governorate}",
              style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 8),
          Text("📞 ${service.phone}", style: const TextStyle(fontSize: 16)),

          if (service.discountPrice != null) ...[
            const SizedBox(height: 8),
            Text("خصم: ${service.discountPrice} ل.س",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],

          const SizedBox(height: 16),
          Divider(),
          Text("الفئة: ${service.category}", style: const TextStyle(fontSize: 16)),
          Text("الفئة الفرعية: ${service.subcategory}", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
