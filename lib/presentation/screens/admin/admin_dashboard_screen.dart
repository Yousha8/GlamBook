import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/booking_model.dart';
import 'category_management_screen.dart';
import 'service_management_screen.dart';
import 'booking_management_screen.dart';
import 'customer_list_screen.dart';
import '../shared/notification_screen.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/user_model.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreServiceProvider);
    final bookingsStream = firestore.streamAllBookings();
    final customersStream = firestore.streamCustomers();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: firestore.streamAdminNotifications(),
            builder: (context, snapshot) {
              final unreadCount = (snapshot.data ?? []).where((n) => !n.isRead).length;
              return _NotificationBell(unreadCount: unreadCount);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => ref.read(authServiceProvider).logout(),
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildWelcomeHeader(),
            ),
            const SizedBox(height: 32),
            
            // STATS SECTION
            StreamBuilder<List<BookingModel>>(
              stream: bookingsStream,
              builder: (context, bookingSnapshot) {
                return StreamBuilder<List<UserModel>>(
                  stream: customersStream,
                  builder: (context, customerSnapshot) {
                    final bookings = bookingSnapshot.data ?? [];
                    final customers = customerSnapshot.data ?? [];
                    
                    final stats = _calculateStats(bookings, customers);
                    
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: FadeInLeft(child: _PremiumStatCard(
                              label: 'Total Revenue',
                              value: 'PKR ${NumberFormat('#,###').format(stats.totalRevenue)}',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.deepMagenta,
                              trend: '+12%', // Mock trend
                            ))),
                            const SizedBox(width: 16),
                            Expanded(child: FadeInRight(child: _PremiumStatCard(
                              label: 'This Month',
                              value: 'PKR ${NumberFormat('#,###').format(stats.monthlyRevenue)}',
                              icon: Icons.trending_up_rounded,
                              color: AppColors.vibrantPink,
                              trend: '+5%',
                            ))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: FadeInLeft(delay: const Duration(milliseconds: 100), child: _PremiumStatCard(
                              label: 'Total Clients',
                              value: stats.totalCustomers.toString(),
                              icon: Icons.people_alt_rounded,
                              color: AppColors.roseGold,
                            ))),
                            const SizedBox(width: 16),
                            Expanded(child: FadeInRight(delay: const Duration(milliseconds: 100), child: _PremiumStatCard(
                              label: 'Pending',
                              value: stats.pendingBookings.toString(),
                              icon: Icons.hourglass_empty_rounded,
                              color: Colors.orange,
                              isAlert: stats.pendingBookings > 0,
                            ))),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 40),
            
            // QUICK ACTIONS
            FadeInUp(
              child: const Text(
                'Management Center',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionGrid(context),

            const SizedBox(height: 40),
            
            // RECENT ACTIVITY
            FadeInUp(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Bookings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementScreen())),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _RecentBookingsFeed(stream: bookingsStream),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    final timeStr = DateFormat('EEEE, d MMMM').format(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E263C)),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.calendar_month_rounded, color: AppColors.vibrantPink),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4, // Increased to prevent overflow
      children: [
        _PremiumActionCard(
          title: 'Booking Queue',
          subtitle: 'Manage appointments',
          icon: Icons.calendar_today_rounded,
          color: AppColors.deepMagenta,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementScreen())),
        ),
        _PremiumActionCard(
          title: 'Our Services',
          subtitle: 'Update treatments',
          icon: Icons.auto_awesome_mosaic_rounded,
          color: AppColors.hotPink,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceManagementScreen())),
        ),
        _PremiumActionCard(
          title: 'Categories',
          subtitle: 'Organize catalog',
          icon: Icons.category_rounded,
          color: AppColors.roseGold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen())),
        ),
        _PremiumActionCard(
          title: 'Client Lists',
          subtitle: 'User management',
          icon: Icons.face_retouching_natural_rounded,
          color: AppColors.vibrantPink,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
        ),
      ],
    );
  }

  _DashboardStats _calculateStats(List<BookingModel> bookings, List<UserModel> customers) {
    double totalRev = 0;
    double monthlyRev = 0;
    int pending = 0;
    final now = DateTime.now();

    for (var b in bookings) {
      if (b.status == BookingStatus.completed) {
        final price = (b.serviceSnapshot['price'] ?? 0).toDouble();
        totalRev += price;
        if (b.appointmentDate.month == now.month && b.appointmentDate.year == now.year) {
          monthlyRev += price;
        }
      }
      if (b.status == BookingStatus.pending) {
        pending++;
      }
    }

    return _DashboardStats(
      totalRevenue: totalRev,
      monthlyRevenue: monthlyRev,
      totalCustomers: customers.length,
      pendingBookings: pending,
    );
  }
}

class _DashboardStats {
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalCustomers;
  final int pendingBookings;
  _DashboardStats({required this.totalRevenue, required this.monthlyRevenue, required this.totalCustomers, required this.pendingBookings});
}

class _PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isAlert;

  const _PremiumStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != null)
                Text(trend!, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              if (isAlert && trend == null)
                const Icon(Icons.error_outline, color: Colors.orange, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Color(0xFF1E263C), fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PremiumActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PremiumActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.1), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E263C))),
              Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int unreadCount;
  const _NotificationBell({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E263C)),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.vibrantPink, shape: BoxShape.circle),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentBookingsFeed extends StatelessWidget {
  final Stream<List<BookingModel>> stream;
  const _RecentBookingsFeed({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: stream,
      builder: (context, snapshot) {
        final items = (snapshot.data ?? []).take(5).toList();
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Text('No recent activity')),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final booking = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.lightPink,
                  backgroundImage: NetworkImage(booking.serviceSnapshot['imageUrl'] ?? ''),
                ),
                title: Text(booking.serviceSnapshot['name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(DateFormat('MMM d, h:mm a').format(booking.appointmentDate), style: const TextStyle(fontSize: 11)),
                trailing: _buildSmallStatus(booking.status),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSmallStatus(BookingStatus status) {
    Color c = Colors.grey;
    if (status == BookingStatus.completed) c = Colors.teal;
    if (status == BookingStatus.pending) c = Colors.orange;
    if (status == BookingStatus.approved) c = Colors.blue;
    if (status == BookingStatus.rejected) c = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
