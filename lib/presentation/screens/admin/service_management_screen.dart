import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';

class ServiceManagementScreen extends ConsumerWidget {
  const ServiceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesStream = ref.watch(firestoreServiceProvider).streamServices();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Service Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _showServiceDialog(context, ref),
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.vibrantPink, size: 28),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream: servicesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.vibrantPink));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final services = snapshot.data ?? [];
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_outlined, size: 64, color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('No services found. Add your first treatment!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: services.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      service.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60, height: 60, 
                        color: Colors.grey.shade100, 
                        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E263C)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (service.isFeatured) 
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'PKR ${NumberFormat('#,###').format(service.price)} • ${service.durationMinutes}m', 
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.vibrantPink, fontSize: 13)
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SmallAction(
                        icon: Icons.edit_outlined, 
                        color: AppColors.deepMagenta, 
                        onTap: () => _showServiceDialog(context, ref, service: service)
                      ),
                      const SizedBox(width: 8),
                      _SmallAction(
                        icon: Icons.delete_outline_rounded, 
                        color: Colors.redAccent, 
                        onTap: () => _deleteService(context, ref, service.id)
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showServiceDialog(BuildContext context, WidgetRef ref, {ServiceModel? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceFormDialog(service: service),
    );
  }

  void _deleteService(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service?'),
        content: const Text('This will permanently remove this service.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(firestoreServiceProvider).deleteService(id);
    }
  }
}

class ServiceFormDialog extends ConsumerStatefulWidget {
  final ServiceModel? service;
  const ServiceFormDialog({super.key, this.service});

  @override
  ConsumerState<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends ConsumerState<ServiceFormDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String? _selectedCategoryId;
  bool _isFeatured = false;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descController.text = widget.service!.description;
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.durationMinutes.toString();
      _selectedCategoryId = widget.service!.categoryId;
      _isFeatured = widget.service!.isFeatured;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _save() async {
    if (_nameController.text.isEmpty || _selectedCategoryId == null) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.service?.imageUrl;
      if (_imageFile != null) {
        imageUrl = await ref.read(imgBBServiceProvider).uploadImage(_imageFile!);
      }

      if (imageUrl == null && widget.service == null) {
        throw Exception('Image is required for new services');
      }

      final service = ServiceModel(
        id: widget.service?.id ?? '',
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl ?? '',
        price: double.tryParse(_priceController.text) ?? 0.0,
        durationMinutes: int.tryParse(_durationController.text) ?? 30,
        isFeatured: _isFeatured,
        createdAt: widget.service?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).saveService(service);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesStream = ref.watch(firestoreServiceProvider).streamCategories();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.service == null ? 'Add Service' : 'Edit Service',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : (widget.service?.imageUrl != null
                          ? DecorationImage(image: NetworkImage(widget.service!.imageUrl), fit: BoxFit.cover)
                          : null),
                ),
                child: (_imageFile == null && widget.service?.imageUrl == null)
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<CategoryModel>>(
              stream: categoriesStream,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  decoration: const InputDecoration(labelText: 'Category'),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(label: 'Service Name', hint: 'E.g. Bridal Facial', controller: _nameController),
            const SizedBox(height: 16),
            CustomTextField(label: 'Description', hint: 'Detail of service', controller: _descController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'Price (\$)', hint: '0.00', controller: _priceController, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(label: 'Duration (m)', hint: '30', controller: _durationController, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Featured Service'),
              value: _isFeatured,
              onChanged: (val) => setState(() => _isFeatured = val),
              activeColor: AppColors.vibrantPink,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.service == null ? 'Create Service' : 'Save Changes',
              isLoading: _isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
