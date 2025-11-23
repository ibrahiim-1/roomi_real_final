class Room {
  final String id;
  final String hostelId;
  final String type; // Single, 1-Bed, 2-Bed, 3-Bed, 4-Bed
  final double rentPerSeat;
  final int totalSeats;
  final int availableSeats;
  final Map<String, bool> facilities; // WiFi, Mess, Laundry, etc.
  final bool isBooked;

  Room({
    required this.id,
    required this.hostelId,
    required this.type,
    required this.rentPerSeat,
    required this.totalSeats,
    required this.availableSeats,
    required this.facilities,
    this.isBooked = false,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'hostelId': hostelId,
      'type': type,
      'rentPerSeat': rentPerSeat,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'facilities': facilities,
      'isBooked': isBooked,
    };
  }

  // Create from Firestore document
  factory Room.fromMap(String id, Map<String, dynamic> map) {
    return Room(
      id: id,
      hostelId: map['hostelId'] ?? '',
      type: map['type'] ?? 'Single',
      rentPerSeat: (map['rentPerSeat'] ?? 0.0).toDouble(),
      totalSeats: map['totalSeats'] ?? 1,
      availableSeats: map['availableSeats'] ?? 1,
      facilities: Map<String, bool>.from(map['facilities'] ?? {}),
      isBooked: map['isBooked'] ?? false,
    );
  }

  Room copyWith({
    String? id,
    String? hostelId,
    String? type,
    double? rentPerSeat,
    int? totalSeats,
    int? availableSeats,
    Map<String, bool>? facilities,
    bool? isBooked,
  }) {
    return Room(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      type: type ?? this.type,
      rentPerSeat: rentPerSeat ?? this.rentPerSeat,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      facilities: facilities ?? this.facilities,
      isBooked: isBooked ?? this.isBooked,
    );
  }
}

