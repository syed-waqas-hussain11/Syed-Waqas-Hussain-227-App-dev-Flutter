import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/contact.dart';

class StorageUploadException implements Exception {
  final String message;
  StorageUploadException(this.message);
  @override
  String toString() => 'StorageUploadException: $message';
}

class FirestoreService {
  FirestoreService._private();
  static final FirestoreService instance = FirestoreService._private();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage.
  ///
  /// The [onProgress] callback receives a double between 0..1 to indicate upload progress.
  /// Throws [StorageUploadException] on failure.
  Future<String> uploadImage(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final ref = _storage.ref().child('contact_images/$filename');
      final uploadTask = ref.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final total = event.totalBytes == 0 ? 1 : event.totalBytes;
          final progress = event.bytesTransferred / total;
          onProgress(progress.clamp(0.0, 1.0));
        });
      }

      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state != TaskState.success) {
        throw StorageUploadException('Upload failed (state=${snapshot.state})');
      }
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      throw StorageUploadException(e.toString());
    }
  }

  /// Saves contact metadata into Firestore. Throws on failure.
  Future<void> saveContact(Contact contact, {String? imageUrl}) async {
    final data = {
      'localId': contact.id,
      'name': contact.name,
      'email': contact.email,
      'age': contact.age,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final docId = contact.id?.toString();
    if (docId != null) {
      await _db
          .collection('contacts')
          .doc(docId)
          .set(data, SetOptions(merge: true));
    } else {
      await _db.collection('contacts').add(data);
    }
  }

  /// Deletes a contact document by local id. Throws on failure.
  Future<void> deleteContact(int id) async {
    await _db.collection('contacts').doc(id.toString()).delete();
  }
}
