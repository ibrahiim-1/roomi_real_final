import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants.dart';
import '../core/error.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload hostel image
  Future<String> uploadHostelImage(File imageFile, String hostelId, String fileName) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.hostelImagesPath)
          .child(hostelId)
          .child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Error uploading image: $e');
    }
  }

  // Upload multiple hostel images
  Future<List<String>> uploadHostelImages(
    List<File> imageFiles,
    String hostelId,
  ) async {
    try {
      final List<String> urls = [];
      for (var imageFile in imageFiles) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final url = await uploadHostelImage(imageFile, hostelId, fileName);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw StorageException('Error uploading images: $e');
    }
  }

  // Delete hostel images
  Future<void> deleteHostelImages(String hostelId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.hostelImagesPath)
          .child(hostelId);

      final listResult = await ref.listAll();
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw StorageException('Error deleting images: $e');
    }
  }
}

