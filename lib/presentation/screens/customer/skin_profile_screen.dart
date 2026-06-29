import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/shared/custom_button.dart';

class SkinProfileScreen extends ConsumerStatefulWidget {
  const SkinProfileScreen({super.key});

  @override
  ConsumerState<SkinProfileScreen> createState() => _SkinProfileScreenState();
}

class _SkinProfileScreenState extends ConsumerState<SkinProfileScreen> {
  String? _skinType;
  String? _sensitivity;
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final List<String> _skinTypes = ['Oily', 'Dry', 'Combination', 'Normal', 'Sensitive'];
  final List<String> _sensitivityLevels = ['Low', 'Medium', 'High', 'Extreme'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserDataProvider).value;
    if (user != null) {
      _skinType = user.skinType;
      _sensitivity = user.skinSensitivity;
      _allergiesController.text = user.allergies ?? '';
      _notesController.text = user.notes ?? '';
    }
  }

  void _save() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user != null) {
        final updatedUser = user.copyWith(
          skinType: _skinType,
          skinSensitivity: _sensitivity,
          allergies: _allergiesController.text.trim(),
          notes: _notesController.text.trim(),
        );
        await ref.read(firestoreServiceProvider).updateUser(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              content: const Text('Skin Passport Updated! ✨', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Skin Passport', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepMagenta)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // Extra space for FAB/Nav
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.vibrantPink.withOpacity(0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.lightPink,
                            child: const Icon(Icons.face_retouching_natural_rounded, size: 50, color: AppColors.vibrantPink),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.vibrantPink, shape: BoxShape.circle),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Beauty User',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepMagenta),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSection(
                      title: 'Base Skin Type',
                      icon: Icons.spa_rounded,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _skinTypes.map((type) => _buildChip(type, _skinType, (val) => setState(() => _skinType = val))).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildSection(
                      title: 'Sensitivity Compass',
                      icon: Icons.waves_rounded,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _sensitivityLevels.map((level) => _buildChip(level, _sensitivity, (val) => setState(() => _sensitivity = val))).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildSection(
                      title: 'Allergies & Concerns',
                      icon: Icons.warning_amber_rounded,
                      child: TextField(
                        controller: _allergiesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'List any allergies or specific skin conditions...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppColors.vibrantPink),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: CustomButton(
                      text: 'Save Beauty Profile',
                      isLoading: _isLoading,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.vibrantPink),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.deepMagenta),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildChip(String label, String? selectedValue, Function(String) onSelected) {
    final isSelected = selectedValue == label;
    return GestureDetector(
      onTap: () => onSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vibrantPink : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.vibrantPink : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.vibrantPink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.deepMagenta,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
