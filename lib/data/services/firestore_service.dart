import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER COLLECTIONS
  Future<void> createUser(UserModel user) async {
    await _db.collection(AppConstants.usersCollection).doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection(AppConstants.usersCollection).doc(user.id).update(user.toMap());
  }

  // Check if a user is an admin
  Future<bool> isAdmin(String uid) async {
    final user = await getUser(uid);
    return user?.role == UserRole.admin;
  }

  // Generic Search/Filter for Admin Reports later
  Stream<List<UserModel>> streamCustomers() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'customer')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList());
  }

  // CATEGORIES
  Future<void> saveCategory(CategoryModel category) async {
    await _db.collection(AppConstants.categoriesCollection).doc(category.id.isEmpty ? null : category.id).set(category.toMap(), SetOptions(merge: true));
  }

  Stream<List<CategoryModel>> streamCategories() {
    return _db
        .collection(AppConstants.categoriesCollection)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection(AppConstants.categoriesCollection).doc(id).delete();
  }

  // SERVICES
  Future<void> saveService(ServiceModel service) async {
    await _db.collection(AppConstants.servicesCollection).doc(service.id.isEmpty ? null : service.id).set(service.toMap(), SetOptions(merge: true));
  }

  Stream<List<ServiceModel>> streamServices({String? categoryId}) {
    Query query = _db.collection(AppConstants.servicesCollection);
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => ServiceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<List<ServiceModel>> getServices() async {
    final snapshot = await _db.collection(AppConstants.servicesCollection).get();
    return snapshot.docs.map((doc) => ServiceModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> deleteService(String id) async {
    await _db.collection(AppConstants.servicesCollection).doc(id).delete();
  }

  // BOOKINGS
  Future<void> createBooking(BookingModel booking) async {
    final docRef = _db.collection(AppConstants.bookingsCollection).doc(booking.id.isEmpty ? null : booking.id);
    await docRef.set(booking.toMap());
    
    // Notify Admin of new booking
    await createNotification(NotificationModel(
      id: '',
      recipientId: 'admin',
      title: 'New Appointment! ✨',
      message: 'Customer ${booking.userSnapshot['fullName']} booked ${booking.serviceSnapshot['name']}.',
      type: NotificationType.newBooking,
      createdAt: DateTime.now(),
      data: {'bookingId': docRef.id, 'bookingNumber': booking.bookingNumber},
    ));
  }

  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<BookingModel>> streamAllBookings() {
    return _db
        .collection(AppConstants.bookingsCollection)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<BookingModel>> streamBookingsByStatus(BookingStatus status) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('status', isEqualTo: status.name)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status, {String? adminNotes}) async {
    final Map<String, dynamic> data = {
      'status': status.name,
      'updatedAt': Timestamp.now(),
    };
    if (adminNotes != null) data['adminNotes'] = adminNotes;
    await _db.collection(AppConstants.bookingsCollection).doc(bookingId).update(data);

    // Notify Customer about status change
    final bookingDoc = await _db.collection(AppConstants.bookingsCollection).doc(bookingId).get();
    if (bookingDoc.exists) {
      final booking = BookingModel.fromMap(bookingDoc.data()!, bookingDoc.id);
      
      NotificationType type = NotificationType.general;
      String title = 'Booking Update';
      String message = 'Your booking #${booking.bookingNumber} is now ${status.name}.';

      if (status == BookingStatus.approved) {
        type = NotificationType.bookingApproved;
        title = 'Booking Approved! 🎉';
        message = 'Your appointment for ${booking.serviceSnapshot['name']} has been confirmed.';
      } else if (status == BookingStatus.rejected) {
        type = NotificationType.bookingRejected;
        title = 'Booking Not Accepted';
        message = 'We couldn\'t accommodate your booking #${booking.bookingNumber}. Please try another slot.';
      }

      await createNotification(NotificationModel(
        id: '',
        recipientId: booking.userId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        data: {'bookingId': bookingId},
      ));
    }
  }

  // NOTIFICATIONS
  Future<void> createNotification(NotificationModel notification) async {
    await _db.collection(AppConstants.notificationsCollection).add(notification.toMap());
  }

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<NotificationModel>> streamAdminNotifications() {
    return _db
        .collection(AppConstants.notificationsCollection)
        .where('recipientId', isEqualTo: 'admin')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection(AppConstants.notificationsCollection).doc(notificationId).update({'isRead': true});
  }


  Future<List<BookingModel>> getBookingsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final query = await _db
        .collection(AppConstants.bookingsCollection)
        .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();
        
    return query.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
  }

  // AVAILABILITY SETTINGS
  Future<AvailabilitySettings> getAvailabilitySettings() async {
    final doc = await _db.collection(AppConstants.settingsCollection).doc('availability').get();
    if (doc.exists) {
      return AvailabilitySettings.fromMap(doc.data()!);
    }
    return AvailabilitySettings(); // Return default if not exists
  }

  Future<void> saveAvailabilitySettings(AvailabilitySettings settings) async {
    await _db.collection(AppConstants.settingsCollection).doc('availability').set(settings.toMap());
  }

  // SYSTEM SEEDING
  Future<void> seedData() async {
    // 1. Categories
    final categories = [
      CategoryModel(
        id: 'cat_facials',
        name: 'Facials & Skincare',
        description: 'Professional facial treatments for all skin types.',
        imageUrl: 'https://images.unsplash.com/photo-1570172234562-c67c74465201?auto=format&fit=crop&q=80&w=500',
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_hair',
        name: 'Hair Styling & Care',
        description: 'Expert haircuts, styling, and restorative treatments.',
        imageUrl: 'https://images.unsplash.com/photo-1560869713-7d0a294308ef?auto=format&fit=crop&q=80&w=500',
        sortOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_massage',
        name: 'Massages & Spa',
        description: 'Relaxing and therapeutic body massages.',
        imageUrl: 'https://images.unsplash.com/photo-1544161515-4ae6ce6ea858?auto=format&fit=crop&q=80&w=500',
        sortOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var cat in categories) {
      await saveCategory(cat);
    }

    // 2. Services
    final services = [
      ServiceModel(
        id: 'ser_hydra',
        categoryId: 'cat_facials',
        name: 'Hydra Facial (Premium)',
        description: 'A multi-step treatment that cleanses, exfoliates, and extracts impurities while replenishing skin with antioxidants.',
        imageUrl: 'https://images.unsplash.com/photo-1512290923902-8a9f81da236c?auto=format&fit=crop&q=80&w=500',
        price: 5500,
        durationMinutes: 60,
        isFeatured: true,
        isPopular: true,
        suitabilityTags: ['All Skin Types', 'Hydration', 'Deep Cleaning'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'ser_peel',
        categoryId: 'cat_facials',
        name: 'Strong Chemical Peel',
        description: 'A powerful chemical exfoliation to remove dead skin cells and reveal a brighter complexion. High intensity.',
        imageUrl: 'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9?auto=format&fit=crop&q=80&w=500',
        price: 8500,
        durationMinutes: 45,
        precautions: 'Avoid sun exposure for 48 hours. Not recommended for extremely sensitive skin.',
        suitabilityTags: ['Acne Control', 'Brightening'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'ser_charcoal',
        categoryId: 'cat_facials',
        name: 'Charcoal Detox Facial',
        description: 'Activated charcoal mask to draw out toxins and control excess oil. Perfectly suited for oily skin.',
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&q=80&w=500',
        price: 3500,
        durationMinutes: 45,
        suitabilityTags: ['Oily Skin', 'Pore Minimizing'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceModel(
        id: 'ser_massage',
        categoryId: 'cat_massage',
        name: 'Swedish Massage',
        description: 'A relaxing full-body massage using long strokes to relieve tension and stress.',
        imageUrl: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?auto=format&fit=crop&q=80&w=500',
        price: 4000,
        durationMinutes: 60,
        suitabilityTags: ['Relaxation', 'Stress Relief'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var ser in services) {
      await saveService(ser);
    }
  }
}
