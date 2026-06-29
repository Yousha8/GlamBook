import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../widgets/shared/custom_button.dart';

class CustomerBookingsScreen extends ConsumerWidget {
  const CustomerBookingsScreen({super.key});

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => FadeIn(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.vibrantPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.vibrantPink, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                booking.serviceSnapshot['name'],
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.deepMagenta),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Reference ID', '#${booking.bookingNumber}'),
              _buildDetailRow('Date', DateFormat('EEEE, MMM d').format(booking.appointmentDate)),
              _buildDetailRow('Time', booking.appointmentTime),
              _buildDetailRow('Cost', 'PKR ${NumberFormat('#,###').format(booking.serviceSnapshot['price'])}'),
              _buildDetailRow('Status', booking.status.name.toUpperCase()),
              const Divider(height: 32),
              const Text(
                'Please present this ID at the salon reception desk.',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Details', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.deepMagenta, fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreServiceProvider);
    final user = ref.watch(currentUserDataProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('My Appointments', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepMagenta)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BookingModel>>(
              stream: firestore.streamUserBookings(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          child: Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey.shade200),
                        ),
                        const SizedBox(height: 24),
                        const Text('No appointments yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: CustomButton(
                            text: 'Explore Services',
                            onPressed: () {
                              // Switching tab logic would go here
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: bookings.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: GestureDetector(
                        onTap: () => _showBookingDetails(context, booking),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        booking.serviceSnapshot['imageUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.spa_rounded)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking.serviceSnapshot['name'],
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.deepMagenta),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: #${booking.bookingNumber}',
                                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusBadge(status: booking.status),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.lightPink.withOpacity(0.3),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                                ),
                                child: Row(
                                  children: [
                                    _InfoItem(icon: Icons.calendar_today_rounded, label: DateFormat('MMM d, yyyy').format(booking.appointmentDate)),
                                    const Spacer(),
                                    _InfoItem(icon: Icons.access_time_rounded, label: booking.appointmentTime),
                                    const Spacer(),
                                    _InfoItem(icon: Icons.wallet_rounded, label: 'Cash'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty_rounded;
        break;
      case BookingStatus.approved:
        color = Colors.blue;
        label = 'Approved';
        icon = Icons.check_circle_outline_rounded;
        break;
      case BookingStatus.completed:
        color = Colors.green;
        label = 'Done';
        icon = Icons.task_alt_rounded;
        break;
      case BookingStatus.rejected:
      case BookingStatus.cancelledByAdmin:
      case BookingStatus.cancelledByCustomer:
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.vibrantPink),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepMagenta)),
      ],
    );
  }
}
