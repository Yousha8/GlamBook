import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersStream = ref.watch(firestoreServiceProvider).streamCustomers();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Client Database', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: customersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.vibrantPink));
          }
          final customers = snapshot.data ?? [];
          if (customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('No clients registered yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final customer = customers[index];
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
                  leading: Hero(
                    tag: customer.id,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.lightPink,
                      backgroundImage: customer.profileImageUrl != null ? NetworkImage(customer.profileImageUrl!) : null,
                      child: customer.profileImageUrl == null 
                        ? Text(customer.fullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.deepMagenta)) 
                        : null,
                    ),
                  ),
                  title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E263C))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(customer.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text(customer.phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(color: AppColors.vibrantPink.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      icon: const Icon(Icons.analytics_outlined, color: AppColors.vibrantPink),
                      tooltip: 'Generate Report',
                      onPressed: () => _showReportFilterDialog(context, ref, customer),
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

  void _generateReport(BuildContext context, WidgetRef ref, UserModel customer, {
    DateTimeRange? dateRange,
    String? serviceFilter,
    BookingStatus? statusFilter,
  }) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch all bookings for this customer
      final snapshot = await ref.read(firestoreServiceProvider).streamUserBookings(customer.id).first;
      
      // Apply filters
      List<BookingModel> filtered = snapshot;
      if (dateRange != null) {
        filtered = filtered.where((b) => 
          b.appointmentDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) && 
          b.appointmentDate.isBefore(dateRange.end.add(const Duration(days: 1)))
        ).toList();
      }
      
      if (serviceFilter != null && serviceFilter != 'All Services') {
        filtered = filtered.where((b) => b.serviceSnapshot['name'] == serviceFilter).toList();
      }

      if (statusFilter != null) {
        filtered = filtered.where((b) => b.status == statusFilter).toList();
      }
      
      if (context.mounted) Navigator.pop(context); // Hide loading

      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No matching records for these filters.')));
        return;
      }

      await PDFReportService.generateCustomerReport(
        customer: customer,
        bookings: filtered,
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showReportFilterDialog(BuildContext context, WidgetRef ref, UserModel customer) {
    DateTimeRange? selectedRange;
    String? selectedService = 'All Services';
    BookingStatus? selectedStatus;

    final servicesAsync = ref.read(firestoreServiceProvider).getServices().asStream();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate History Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selection Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Date Picker
                const Text('Date Range', style: TextStyle(fontSize: 12, color: Colors.grey)),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(selectedRange == null 
                    ? 'All Time' 
                    : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}'),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (range != null) setDialogState(() => selectedRange = range);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Service Filter
                const Text('Filter by Service', style: TextStyle(fontSize: 12, color: Colors.grey)),

                StreamBuilder<List<ServiceModel>>(
                  stream: servicesAsync,
                  builder: (context, snapshot) {
                    final names = ['All Services', ...(snapshot.data?.map((e) => e.name) ?? [])];
                    return DropdownButton<String>(
                      isExpanded: true,
                      value: selectedService,
                      items: names.map((n) => DropdownMenuItem<String>(value: n, child: Text(n))).toList(),
                      onChanged: (val) => setDialogState(() => selectedService = val),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Status Filter
                const Text('Filter by Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                DropdownButton<BookingStatus?>(
                  isExpanded: true,
                  hint: const Text('All Statuses'),
                  value: selectedStatus,
                  items: [
                    const DropdownMenuItem<BookingStatus?>(value: null, child: Text('All Statuses')),
                    ...BookingStatus.values.map((s) => DropdownMenuItem<BookingStatus?>(value: s, child: Text(s.name.toUpperCase()))),
                  ],
                  onChanged: (val) => setDialogState(() => selectedStatus = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _generateReport(
                  context, ref, customer, 
                  dateRange: selectedRange,
                  serviceFilter: selectedService,
                  statusFilter: selectedStatus,
                );
              },
              child: const Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
