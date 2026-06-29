class AppConstants {
  static const String appName = 'GlamBook';
  static const String appTagline = 'Ladies Beauty Salon Booking';

  // imgBB Configuration
  // IMPORTANT: Replace with your actual imgBB API Key
  static const String imgbbApiKey = 'e17751ff7fc53a61de7839fdb73d5f80';
  static const String imgbbUploadUrl = 'https://api.imgbb.com/1/upload';

  // Gemini Configuration
  // IMPORTANT: Replace with your actual Gemini API Key
  static const String geminiApiKey = 'AIzaSyAo7J9WpZuYkfSDntPuPhpcQVyu7DJFVzM';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String servicesCollection = 'services';
  static const String categoriesCollection = 'serviceCategories';
  static const String bookingsCollection = 'bookings';
  static const String settingsCollection = 'appSettings';
  static const String riskRulesCollection = 'riskRules';
  static const String bannersCollection = 'banners';
  static const String notificationsCollection = 'notifications';

  // Default Values
  static const String defaultProfileImage = 'https://i.ibb.co/example-placeholder.png';
}
