import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:savarii/models/user_model.dart';
import 'package:savarii/models/vendor_model.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String travelsCollection = 'travels';

  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // --- Travels Methods ---
  Future<void> updateTravelsDetail(String uid, Map<String, dynamic> data) async {
    await _db.collection(travelsCollection).doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getTravelsDetail(String uid) async {
    try {
      final doc = await _db.collection(travelsCollection).doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error getting travels detail: $e');
    }
    return null;
  }

  Stream<Map<String, dynamic>?> getTravelsDetailStream(String uid) {
    return _db.collection(travelsCollection).doc(uid).snapshots().map((doc) => doc.data());
  }

  Future<String> uploadTravelsImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('travels_images').child('$uid.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading travels image: $e');
      rethrow;
    }
  }

  Future<String?> getTravelsImageUrl(String uid) async {
    try {
      final ref = _storage.ref().child('travels_images').child('$uid.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      // Ignored: Image might not exist yet
      return null;
    }
  }

  Future<void> createVendorProfile(VendorModel vendor) async {
    await _db.collection('vendors').doc(vendor.uid).set(vendor.toMap());
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String?> getProfileImageUrl(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      return null; // Ignore object-not-found exceptions internally
    }
  }

  Future<void> updateVendorProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('vendors').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<VendorModel?> getVendorProfile(String uid) async {
    final doc = await _db.collection('vendors').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return VendorModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<VendorModel?> getVendorProfileStream(String uid) {
    return _db.collection('vendors').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return VendorModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<UserModel?> getUserProfile(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }

    // Fallback for older vendor accounts that exist only in 'vendors' collection
    final vendorDoc = await _db.collection('vendors').doc(uid).get();
    if (vendorDoc.exists && vendorDoc.data() != null) {
      return UserModel(
        uid: vendorDoc.id,
        email: '', // Not stored in vendor doc
        role: 'vendor',
        createdAt:
            (vendorDoc.data()!['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.now(),
      );
    }

    return null;
  }

  Future<void> addBusData(Map<String, dynamic> busData) async {
    await _db.collection('buses').add(busData);
  }

  Stream<List<Map<String, dynamic>>> getVendorBusesStream(String vendorId) {
    return _db
        .collection('buses')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> updateBusStatus(String busId, bool isActive) async {
    await _db.collection('buses').doc(busId).update({'isActive': isActive});
  }

  Future<Map<String, dynamic>?> getBusById(String busId) async {
    final doc = await _db.collection('buses').doc(busId).get();
    if (doc.exists && doc.data() != null) {
      return {'id': doc.id, ...doc.data()!};
    }
    return null;
  }

  Future<void> updateBusData(String busId, Map<String, dynamic> busData) async {
    await _db.collection('buses').doc(busId).update(busData);
  }
}
