import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hostel_model.dart';
import '../models/room_model.dart';
import '../models/review_model.dart';
import '../core/constants.dart';
import '../core/error.dart' as app_error;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hostels
  Stream<List<Hostel>> getHostels() {
    return _firestore
        .collection(AppConstants.hostelsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Hostel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<Hostel>> getHostelsOnce() async {
    final snapshot = await _firestore
        .collection(AppConstants.hostelsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Hostel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Hostel?> getHostelById(String hostelId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .get();
      if (doc.exists) {
        return Hostel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw app_error.AppFirebaseException('Error fetching hostel: $e');
    }
  }

  Future<String> addHostel(Hostel hostel) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.hostelsCollection)
          .add(hostel.toMap());
      return docRef.id;
    } catch (e) {
      throw app_error.AppFirebaseException('Error adding hostel: $e');
    }
  }

  Future<void> updateHostel(String hostelId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .update(updates);
    } catch (e) {
      throw app_error.AppFirebaseException('Error updating hostel: $e');
    }
  }

  Future<void> deleteHostel(String hostelId) async {
    try {
      // Delete all rooms
      final roomsSnapshot = await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .collection(AppConstants.roomsCollection)
          .get();
      
      for (var doc in roomsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all reviews
      final reviewsSnapshot = await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .collection(AppConstants.reviewsCollection)
          .get();
      
      for (var doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete hostel
      await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .delete();
    } catch (e) {
      throw app_error.AppFirebaseException('Error deleting hostel: $e');
    }
  }

  // Rooms
  Stream<List<Room>> getRooms(String hostelId) {
    return _firestore
        .collection(AppConstants.hostelsCollection)
        .doc(hostelId)
        .collection(AppConstants.roomsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Room.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<Room>> getRoomsOnce(String hostelId) async {
    final snapshot = await _firestore
        .collection(AppConstants.hostelsCollection)
        .doc(hostelId)
        .collection(AppConstants.roomsCollection)
        .get();

    return snapshot.docs
        .map((doc) => Room.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<String> addRoom(String hostelId, Room room) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .collection(AppConstants.roomsCollection)
          .add(room.toMap());
      
      return docRef.id;
    } catch (e) {
      throw app_error.AppFirebaseException('Error adding room: $e');
    }
  }

  Future<void> updateRoom(String hostelId, String roomId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .collection(AppConstants.roomsCollection)
          .doc(roomId)
          .update(updates);
    } catch (e) {
      throw app_error.AppFirebaseException('Error updating room: $e');
    }
  }

  Future<void> deleteRoom(String hostelId, String roomId) async {
    try {
      final roomDoc = await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .collection(AppConstants.roomsCollection)
          .doc(roomId)
          .get();
      
      if (roomDoc.exists) {
        await roomDoc.reference.delete();
      }
    } catch (e) {
      throw app_error.AppFirebaseException('Error deleting room: $e');
    }
  }

  // Reviews
  Stream<List<Review>> getReviews(String hostelId) {
    return _firestore
        .collection(AppConstants.hostelsCollection)
        .doc(hostelId)
        .collection(AppConstants.reviewsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<Review>> getReviewsOnce(String hostelId) async {
    final snapshot = await _firestore
        .collection(AppConstants.hostelsCollection)
        .doc(hostelId)
        .collection(AppConstants.reviewsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Review.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<String> addReview(String hostelId, Review review) async {
    try {
      // Add review
      final docRef = await _firestore
          .collection(AppConstants.hostelsCollection)
          .doc(hostelId)
          .collection(AppConstants.reviewsCollection)
          .add(review.toMap());

      // Update hostel rating
      final reviews = await getReviewsOnce(hostelId);
      final totalRating = reviews.fold<double>(0, (sum, r) => sum + r.rating);
      final averageRating = reviews.isEmpty ? 0.0 : totalRating / reviews.length;

      await updateHostel(hostelId, {
        'averageRating': averageRating,
        'reviewCount': reviews.length,
      });

      return docRef.id;
    } catch (e) {
      throw app_error.AppFirebaseException('Error adding review: $e');
    }
  }

  // Get hostels by admin
  Stream<List<Hostel>> getHostelsByAdmin(String adminId) {
    return _firestore
        .collection(AppConstants.hostelsCollection)
        .where('createdBy', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Hostel.fromMap(doc.id, doc.data()))
            .toList());
  }
}

