import 'package:cloud_firestore/cloud_firestore.dart';

class Hostel {
  final String id;
  final String name;
  final String ownerName;
  final String phone;
  final String address;
  final double? lat;
  final double? lng;
  final String gender; // Boys, Girls, Unisex
  final List<String> nearbyUniversities;
  final int totalSeats;
  final int bookedSeats;
  final List<String> photoUrls;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;
  final String createdBy;
  final String? description;
  final String? rules;
  final double minRent;
  final double maxRent;

  Hostel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.address,
    this.lat,
    this.lng,
    required this.gender,
    required this.nearbyUniversities,
    required this.totalSeats,
    required this.bookedSeats,
    required this.photoUrls,
    required this.averageRating,
    required this.reviewCount,
    required this.createdAt,
    required this.createdBy,
    this.description,
    this.rules,
    this.minRent = 0.0,
    this.maxRent = 0.0,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerName': ownerName,
      'phone': phone,
      'address': address,
      'lat': lat,
      'lng': lng,
      'gender': gender,
      'nearbyUniversities': nearbyUniversities,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
      'photoUrls': photoUrls,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'description': description,
      'rules': rules,
      'minRent': minRent,
      'maxRent': maxRent,
    };
  }

  // Create from Firestore document
  factory Hostel.fromMap(String id, Map<String, dynamic> map) {
    return Hostel(
      id: id,
      name: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
      gender: map['gender'] ?? 'Unisex',
      nearbyUniversities: List<String>.from(map['nearbyUniversities'] ?? []),
      totalSeats: map['totalSeats'] ?? 0,
      bookedSeats: map['bookedSeats'] ?? 0,
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      description: map['description'],
      rules: map['rules'],
      minRent: (map['minRent'] ?? 0.0).toDouble(),
      maxRent: (map['maxRent'] ?? 0.0).toDouble(),
    );
  }

  Hostel copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? phone,
    String? address,
    double? lat,
    double? lng,
    String? gender,
    List<String>? nearbyUniversities,
    int? totalSeats,
    int? bookedSeats,
    List<String>? photoUrls,
    double? averageRating,
    int? reviewCount,
    DateTime? createdAt,
    String? createdBy,
    String? description,
    String? rules,
    double? minRent,
    double? maxRent,
  }) {
    return Hostel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gender: gender ?? this.gender,
      nearbyUniversities: nearbyUniversities ?? this.nearbyUniversities,
      totalSeats: totalSeats ?? this.totalSeats,
      bookedSeats: bookedSeats ?? this.bookedSeats,
      photoUrls: photoUrls ?? this.photoUrls,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
    );
  }
}

