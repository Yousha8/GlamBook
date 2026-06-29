import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../widgets/shared/custom_button.dart';
// import 'payment_screen.dart'; // No longer needed

class BookingScreen extends ConsumerStatefulWidget {
  final ServiceModel service;
  const BookingScreen({super.key, required this.service});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTime;
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() async {
    setState(() => _isLoadingSlots = true);
    final settings = await ref.read(firestoreServiceProvider).getAvailabilitySettings();
    final firestore = ref.read(firestoreServiceProvider);

    if (!settings.openingDays.contains(_selectedDay.weekday)) {
      setState(() {
        _availableSlots = [];
        _isLoadingSlots = false;
      });
      return;
    }

    final bookings = await firestore.getBookingsByDate(_selectedDay);
    final bookedSlots = bookings
        .where((b) => [BookingStatus.pending, BookingStatus.approved, BookingStatus.completed].contains(b.status))
        .map((b) => b.appointmentTime)
        .toList();

    List<String> slots = [];
    final startTime = _parseTime(settings.openingTime);
    final endTime = _parseTime(settings.closingTime);
    
    DateTime currentSlot = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, startTime.hour, startTime.minute);
    final endDateTime = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, endTime.hour, endTime.minute);

    while (currentSlot.isBefore(endDateTime)) {
      final timeStr = DateFormat('HH:mm').format(currentSlot);
      if (!bookedSlots.contains(timeStr)) {
        slots.add(timeStr);
      }
      currentSlot = currentSlot.add(Duration(minutes: settings.slotDurationMinutes));
    }

    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
    });
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _confirmBooking() async {
    if (_selectedTime == null) return;
    setState(() => _isBooking = true);

    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) throw Exception('User not logged in');

      final bookingNumber = 'GB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final booking = BookingModel(
        id: '',
        bookingNumber: bookingNumber,
        userId: user.id,
        userSnapshot: user.toMap(),
        serviceId: widget.service.id,
        serviceSnapshot: widget.service.toMap(),
        appointmentDate: _selectedDay,
        appointmentTime: _selectedTime!,
        slotKey: '${DateFormat('yyyy-MM-dd').format(_selectedDay)}-$_selectedTime',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createBooking(booking);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => FadeIn(
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                  ),
                  const SizedBox(height: 24),
                  const Text('Booking Requested!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepMagenta)),
                  const SizedBox(height: 12),
                  Text('Registration ID: #$bookingNumber', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Payment Mode: Cash at Salon', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.vibrantPink)),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'We will notify you once GlamBook approves your appointment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepMagenta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close booking screen
                        Navigator.pop(context); // Close detail screen
                      },
                      child: const Text('Return Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reserve Your Slot', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepMagenta)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.deepMagenta),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepMagenta, fontSize: 18),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedTime = null;
                    });
                    _loadSlots();
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(color: AppColors.vibrantPink, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: AppColors.vibrantPink.withOpacity(0.15), shape: BoxShape.circle),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    todayTextStyle: const TextStyle(color: AppColors.vibrantPink, fontWeight: FontWeight.bold),
                    defaultTextStyle: const TextStyle(color: AppColors.deepMagenta),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeInUp(
                child: Row(
                  children: [
                    const Text('Available Times', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepMagenta)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${_availableSlots.length} Slots',
                        style: const TextStyle(color: AppColors.vibrantPink, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _isLoadingSlots
                ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
                : _availableSlots.isEmpty
                    ? FadeIn(child: const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('No slots available for this day.'))))
                    : FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _availableSlots.length,
                          itemBuilder: (context, index) {
                            final time = _availableSlots[index];
                            final isSelected = _selectedTime == time;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTime = isSelected ? null : time),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.vibrantPink : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.vibrantPink : Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(color: AppColors.vibrantPink.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                  ] : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.deepMagenta,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 140), // Space for button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -10)),
          ],
        ),
        child: FadeInUp(
          child: CustomButton(
            text: 'Request Appointment',
            isLoading: _isBooking,
            onPressed: _selectedTime != null ? _confirmBooking : () {},
          ),
        ),
      ),
    );
  }
}
