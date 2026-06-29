import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/customer/home_widgets.dart';
import 'service_detail_screen.dart';
import 'category_services_screen.dart';
import 'all_featured_services_screen.dart';
import '../shared/notification_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider).value;
    final firestore = ref.watch(firestoreServiceProvider);
    final categoriesStream = firestore.streamCategories();
    final allServicesStream = firestore.streamServices();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200, // Adjusted height
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.vibrantPink,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.vibrantPink, AppColors.deepMagenta],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), // Tightened padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FadeInLeft(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // Constrain size
                                    children: [
                                      Text(
                                        'Hello, ${user?.fullName.split(' ')[0] ?? 'Beautiful'}!',
                                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        'What beauty service do you need?',
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              FadeInRight(
                                child: Row(
                                  children: [
                                    _IconButton(
                                      icon: Icons.notifications_none_rounded,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                                    ),
                                    const SizedBox(width: 8),
                                    _IconButton(
                                      icon: Icons.logout_rounded,
                                      onTap: () => ref.read(authServiceProvider).logout(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: FadeInUp(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                          decoration: InputDecoration(
                            hintText: 'Search services...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                        ),
                      const SizedBox(width: 8),
                      Icon(Icons.tune_rounded, color: AppColors.vibrantPink.withOpacity(0.7), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<List<ServiceModel>>(
            stream: allServicesStream,
            builder: (context, snapshot) {
              final services = snapshot.data ?? [];
              
              // Apply search filter
              final filteredServices = services.where((s) {
                return s.name.toLowerCase().contains(_searchQuery) ||
                       s.description.toLowerCase().contains(_searchQuery);
              }).toList();

              if (_searchQuery.isNotEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: filteredServices.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text('No results found.', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final service = filteredServices[index];
                              return FadeInUp(
                                delay: Duration(milliseconds: 50 * index),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(service.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                                    ),
                                    title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepMagenta)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('PKR ${NumberFormat('#,###').format(service.price)} • ${service.durationMinutes} mins', style: const TextStyle(color: AppColors.vibrantPink, fontWeight: FontWeight.bold)),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: AppColors.vibrantPink.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.vibrantPink),
                                    ),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredServices.length,
                          ),
                        ),
                );
              }

              // Original Home Layout (when search is empty)
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: const SectionHeader(title: 'Service Categories'),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: SizedBox(
                          height: 120,
                          child: StreamBuilder<List<CategoryModel>>(
                            stream: categoriesStream,
                            builder: (context, snapshot) {
                              final categories = snapshot.data ?? [];
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: categories.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(right: 24),
                                  child: CategoryCard(
                                    category: categories[index], 
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryServicesScreen(category: categories[index]))),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Featured Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.deepMagenta)),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllFeaturedServicesScreen())), 
                              child: const Text('View All', style: TextStyle(color: AppColors.vibrantPink, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: SizedBox(
                          height: 280,
                          child: Builder(
                            builder: (context) {
                              final featured = services.where((s) => s.isFeatured).toList();
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: featured.length,
                                itemBuilder: (context, index) => ServiceCard(
                                  service: featured[index],
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: featured[index]))),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: const SectionHeader(title: 'Recommended For You'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Show the long list only when NOT searching
          if (_searchQuery.isEmpty)
            StreamBuilder<List<ServiceModel>>(
              stream: allServicesStream,
              builder: (context, snapshot) {
                final services = snapshot.data ?? [];
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = services[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(service.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                              ),
                              title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepMagenta)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('PKR ${NumberFormat('#,###').format(service.price)} • ${service.durationMinutes} mins', style: const TextStyle(color: AppColors.vibrantPink, fontWeight: FontWeight.bold)),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.vibrantPink.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.vibrantPink),
                              ),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
                            ),
                          ),
                        );
                      },
                      childCount: services.length,
                    ),
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.deepMagenta));
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
