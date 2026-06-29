import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  approved,
  rejected,
  rescheduled,
  completed,
  cancelledByCustomer,
  cancelledByAdmin,
  noShow,
}

class BookingModel {
  final String id;
  final String bookingNumber;
  final String userId;
  final Map<String, dynamic> userSnapshot; // Snapshot of user data at time of booking
  final String serviceId;
  final Map<String, dynamic> serviceSnapshot; // Snapshot of service data
  final DateTime appointmentDate;
  final String appointmentTime;
  final String slotKey; // Unique key for the slot (YYYY-MM-DD-HH-mm)
  final BookingStatus status;
  final String? customerNotes;
  final String? adminNotes;
  final String? riskLevel;
  final String? riskReason;
  final String? assignedStaffId;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.userId,
    required this.userSnapshot,
    required this.serviceId,
    required this.serviceSnapshot,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.slotKey,
    required this.status,
    this.customerNotes,
    this.adminNotes,
    this.riskLevel,
    this.riskReason,
    this.assignedStaffId,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingNumber': bookingNumber,
      'userId': userId,
      'userSnapshot': userSnapshot,
      'serviceId': serviceId,
      'serviceSnapshot': serviceSnapshot,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'appointmentTime': appointmentTime,
      'slotKey': slotKey,
      'status': status.name,
      'customerNotes': customerNotes,
      'adminNotes': adminNotes,
      'riskLevel': riskLevel,
      'riskReason': riskReason,
      'assignedStaffId': assignedStaffId,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      bookingNumber: map['bookingNumber'] ?? '',
      userId: map['userId'] ?? '',
      userSnapshot: Map<String, dynamic>.from(map['userSnapshot'] ?? {}),
      serviceId: map['serviceId'] ?? '',
      serviceSnapshot: Map<String, dynamic>.from(map['serviceSnapshot'] ?? {}),
      appointmentDate: (map['appointmentDate'] as Timestamp).toDate(),
      appointmentTime: map['appointmentTime'] ?? '',
      slotKey: map['slotKey'] ?? '',
      status: BookingStatus.values.byName(map['status'] ?? 'pending'),
      customerNotes: map['customerNotes'],
      adminNotes: map['adminNotes'],
      riskLevel: map['riskLevel'],
      riskReason: map['riskReason'],
      assignedStaffId: map['assignedStaffId'],
      cancellationReason: map['cancellationReason'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class AvailabilitySettings {
  final List<int> openingDays; // [1, 2, 3, 4, 5, 6] (1=Monday)
  final String openingTime; // "09:00"
  final String closingTime; // "20:00"
  final String? breakStart; // "13:00"
  final String? breakEnd; // "14:00"
  final int slotDurationMinutes;
  final List<DateTime> closedDates;
  final int maxBookingsPerSlot;

  AvailabilitySettings({
    this.openingDays = const [1, 2, 3, 4, 5, 6],
    this.openingTime = '09:00',
    this.closingTime = '20:00',
    this.breakStart,
    this.breakEnd,
    this.slotDurationMinutes = 30,
    this.closedDates = const [],
    this.maxBookingsPerSlot = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'openingDays': openingDays,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
      'slotDurationMinutes': slotDurationMinutes,
      'closedDates': closedDates.map((d) => Timestamp.fromDate(d)).toList(),
      'maxBookingsPerSlot': maxBookingsPerSlot,
    };
  }

  factory AvailabilitySettings.fromMap(Map<String, dynamic> map) {
    return AvailabilitySettings(
      openingDays: List<int>.from(map['openingDays'] ?? [1, 2, 3, 4, 5, 6]),
      openingTime: map['openingTime'] ?? '09:00',
      closingTime: map['closingTime'] ?? '20:00',
      breakStart: map['breakStart'],
      breakEnd: map['breakEnd'],
      slotDurationMinutes: map['slotDurationMinutes'] ?? 30,
      closedDates: (map['closedDates'] as List? ?? []).map((d) => (d as Timestamp).toDate()).toList(),
      maxBookingsPerSlot: map['maxBookingsPerSlot'] ?? 1,
    );
  }
}
