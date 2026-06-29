import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../widgets/shared/custom_button.dart';

class BookingManagementScreen extends ConsumerWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreServiceProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: const Text('Appointments Console', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Historical'),
            ],
            indicatorColor: AppColors.vibrantPink,
            labelColor: AppColors.vibrantPink,
            unselectedLabelColor: Colors.grey.shade400,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            _BookingList(stream: firestore.streamBookingsByStatus(BookingStatus.pending), onlyPending: false), 
            _BookingList(stream: firestore.streamAllBookings(), onlyPending: false),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends ConsumerWidget {
  final Stream<List<BookingModel>> stream;
  final bool onlyPending;

  const _BookingList({required this.stream, required this.onlyPending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<BookingModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.vibrantPink));
        }
        var bookings = snapshot.data ?? [];
        if (onlyPending) {
          bookings = bookings.where((b) => b.status == BookingStatus.pending).toList();
        }

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text('No appointments to display.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: bookings.length,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 6, color: _getStatusColor(booking.status)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${booking.bookingNumber}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blueGrey),
                                  ),
                                  _buildStatusBadge(booking.status),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.lightPink,
                                    backgroundImage: NetworkImage(booking.serviceSnapshot['imageUrl'] ?? ''),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking.serviceSnapshot['name'] ?? 'Service',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E263C)),
                                        ),
                                        Text(
                                          '${DateFormat('MMMM d, yyyy').format(booking.appointmentDate)} • ${booking.appointmentTime}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 40),
                              _buildInfoRow(Icons.person_outline_rounded, booking.userSnapshot['fullName'] ?? 'Guest'),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.phone_outlined, booking.userSnapshot['phone'] ?? 'No phone'),
                              const SizedBox(height: 24),
                              if (booking.status == BookingStatus.pending)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionButton(
                                        label: 'Reject',
                                        isOutlined: true,
                                        color: Colors.redAccent,
                                        onPressed: () => _updateStatus(ref, booking.id, BookingStatus.rejected),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ActionButton(
                                        label: 'Approve',
                                        color: AppColors.deepMagenta,
                                        onPressed: () => _updateStatus(ref, booking.id, BookingStatus.approved),
                                      ),
                                    ),
                                  ],
                                ),
                              if (booking.status == BookingStatus.approved)
                                _ActionButton(
                                  label: 'Mark as Completed',
                                  color: AppColors.vibrantPink,
                                  onPressed: () => _updateStatus(ref, booking.id, BookingStatus.completed),
                                ),
                            ],
                          ),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _updateStatus(WidgetRef ref, String id, BookingStatus status) async {
    await ref.read(firestoreServiceProvider).updateBookingStatus(id, status);
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.approved: return AppColors.deepMagenta;
      case BookingStatus.pending: return Colors.orangeAccent;
      case BookingStatus.rejected: return Colors.redAccent;
      case BookingStatus.completed: return AppColors.vibrantPink;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isOutlined;

  const _ActionButton({required this.label, required this.onPressed, required this.color, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
    );
  }
}
