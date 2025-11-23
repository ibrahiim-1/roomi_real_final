class AppConstants {
  // App Info
  static const String appName = 'ROOMI';
  static const String appTagline = 'Find Your Perfect Room';

  // Colors
  static const int primaryColorValue = 0xFFFF5722; // Deep Orange
  static const int secondaryColorValue = 0xFFFF7043;

  // Universities
  static const List<String> universities = [
    'Bahria University',
    'FAST',
    'COMSATS',
    'NUST',
    'Air University',
    'IIUI',
    'QAU',
    'Other',
  ];

  // Gender Options
  static const List<String> genderOptions = ['Boys', 'Girls', 'Unisex'];

  // Room Types
  static const List<String> roomTypes = [
    'Single',
    '1-Bed',
    '2-Bed',
    '3-Bed',
    '4-Bed',
  ];

  // Facilities
  static const List<String> facilities = [
    'WiFi',
    'Mess (1 meal)',
    'Mess (2 meals)',
    'Mess (3 meals)',
    'Laundry',
    'UPS',
    'Geyser',
    'Attached Bath',
    'AC',
    'Kitchen',
    'Parking',
    'CCTV',
  ];

  // Budget Range
  static const double minBudget = 5000.0;
  static const double maxBudget = 50000.0;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String hostelsCollection = 'hostels';
  static const String roomsCollection = 'rooms';
  static const String reviewsCollection = 'reviews';

  // Storage Paths
  static const String hostelImagesPath = 'hostel_images';
}

