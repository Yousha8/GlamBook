import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import 'service_detail_screen.dart';

class CategoryServicesScreen extends ConsumerWidget {
  final CategoryModel category;
  const CategoryServicesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesStream = ref.watch(firestoreServiceProvider).streamServices(categoryId: category.id);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: StreamBuilder<List<ServiceModel>>(
        stream: servicesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final services = snapshot.data ?? [];
          if (services.isEmpty) {
            return const Center(child: Text('No services found for this category.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(service.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                  ),
                  title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('PKR ${service.price} • ${service.durationMinutes} mins'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.vibrantPink),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
