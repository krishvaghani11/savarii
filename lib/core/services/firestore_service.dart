import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> createUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> createWallet(String uid) {
    return _db.collection('wallets').doc(uid).set({
      "userId": uid,
      "balance": 0,
      "currency": "INR",
    });
  }

  Future<void> createVendor(String uid, Map<String, dynamic> data) {
    return _db.collection('vendors').doc(uid).set(data);
  }
}
