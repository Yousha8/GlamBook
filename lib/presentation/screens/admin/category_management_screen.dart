import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesStream = ref.watch(firestoreServiceProvider).streamCategories();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Categories Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _showCategoryDialog(context, ref),
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.vibrantPink, size: 28),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.vibrantPink));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('No categories defined yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final category = categories[index];
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.lightPink,
                      borderRadius: BorderRadius.circular(16),
                      image: category.imageUrl != null ? DecorationImage(image: NetworkImage(category.imageUrl!), fit: BoxFit.cover) : null,
                    ),
                    child: category.imageUrl == null ? const Icon(Icons.category_outlined, color: AppColors.deepMagenta) : null,
                  ),
                  title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E263C))),
                  subtitle: Text(category.description ?? 'No description', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SmallAction(
                        icon: Icons.edit_outlined, 
                        color: AppColors.deepMagenta, 
                        onTap: () => _showCategoryDialog(context, ref, category: category)
                      ),
                      const SizedBox(width: 8),
                      _SmallAction(
                        icon: Icons.delete_outline_rounded, 
                        color: Colors.redAccent, 
                        onTap: () => _deleteCategory(context, ref, category.id)
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

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {CategoryModel? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormDialog(category: category),
    );
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This will permanently remove this category.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(firestoreServiceProvider).deleteCategory(id);
    }
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

class CategoryFormDialog extends ConsumerStatefulWidget {
  final CategoryModel? category;
  const CategoryFormDialog({super.key, this.category});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descController.text = widget.category!.description ?? '';
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
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.category?.imageUrl;
      if (_imageFile != null) {
        imageUrl = await ref.read(imgBBServiceProvider).uploadImage(_imageFile!);
      }

      final category = CategoryModel(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        sortOrder: widget.category?.sortOrder ?? 0,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).saveCategory(category);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.category == null ? 'Add Category' : 'Edit Category',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: _imageFile != null
                    ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                    : (widget.category?.imageUrl != null
                        ? DecorationImage(image: NetworkImage(widget.category!.imageUrl!), fit: BoxFit.cover)
                        : null),
              ),
              child: (_imageFile == null && widget.category?.imageUrl == null)
                  ? const Icon(Icons.add_a_photo)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Category Name',
            hint: 'E.g. Hair Care',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Description',
            hint: 'Brief description',
            controller: _descController,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: widget.category == null ? 'Create Category' : 'Save Changes',
            isLoading: _isLoading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
