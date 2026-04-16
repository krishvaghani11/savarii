import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:savarii/models/user_model.dart';
import 'package:savarii/models/vendor_model.dart';
import 'package:savarii/models/location_model.dart';
import 'package:savarii/models/bus_model.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String travelsCollection = 'travels';

  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // --- Customer Profile Methods ---
  Future<void> updateCustomerProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('customers')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getCustomerProfileStream(String uid) {
    return _db
        .collection('customers')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<Map<String, dynamic>?> getCustomerProfile(String uid) async {
    final doc = await _db.collection('customers').doc(uid).get();
    return doc.data();
  }

  Future<String> uploadCustomerProfileImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('customer_profiles').child('$uid.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading customer profile image: $e');
      rethrow;
    }
  }

  // --- Travels Methods ---
  Future<void> updateTravelsDetail(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection(travelsCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
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
    return _db
        .collection(travelsCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
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

  // --- Tickets Methods ---
  Future<void> addTicket(Map<String, dynamic> ticketData) async {
    await _db.collection('tickets').add(ticketData);
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _db.collection('tickets').doc(ticketId).update({'status': status});
  }

  /// Looks up a ticket document by its PNR / bookingId field.
  /// Returns the doc data including Firestore document ID as 'id', or null if not found.
  Future<Map<String, dynamic>?> getTicketByPnr(String pnr) async {
    try {
      final snapshot = await _db
          .collection('tickets')
          .where('bookingId', isEqualTo: pnr.trim())
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    } catch (e) {
      print('Error fetching ticket by PNR: $e');
      return null;
    }
  }

  Future<String> uploadTicketPdf(String bookingId, Uint8List pdfBytes) async {
    try {
      final ref = _storage.ref().child('tickets').child('$bookingId.pdf');
      await ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading ticket PDF for $bookingId: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getVendorTicketsStream(String vendorId) {
    return _db
        .collection('tickets')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getCustomerTicketsStream(
    String customerId,
  ) {
    return _db
        .collection('tickets')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // --- Parcels Methods ---
  Future<void> addParcel(Map<String, dynamic> parcelData) async {
    await _db.collection('parcels').add(parcelData);
  }

  Stream<List<Map<String, dynamic>>> getVendorParcelsStream(String vendorId) {
    return _db
        .collection('parcels')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getCustomerParcelsStream(
    String customerId,
  ) {
    return _db
        .collection('parcels')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> updateParcelStatus(String parcelId, String status) async {
    await _db.collection('parcels').doc(parcelId).update({'status': status});
  }

  Future<String> uploadParcelPdf(String trackingId, Uint8List pdfBytes) async {
    try {
      final ref = _storage.ref().child('parcels').child('$trackingId.pdf');
      await ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading parcel PDF for $trackingId: $e');
      rethrow;
    }
  }

  Future<void> addBookedSeatsToBus(
    String busId,
    String journeyDate,
    List<String> seats,
  ) async {
    final formattedDate = journeyDate.replaceAll('/', '-');
    await _db.collection('buses').doc(busId).update({
      'bookedSeatsByDate.$formattedDate': FieldValue.arrayUnion(seats),
    });
  }

  Future<int> getBookedSeatsCount(String busId, String formattedDate) async {
    try {
      final doc = await _db.collection('buses').doc(busId).get();
      if (!doc.exists) return 0;
      final data = doc.data() ?? {};
      final bookedSeatsByDate =
          data['bookedSeatsByDate'] as Map<String, dynamic>? ?? {};
      final bookedSeats =
          bookedSeatsByDate[formattedDate] as List<dynamic>? ?? [];
      return bookedSeats.length;
    } catch (e) {
      print('Error fetching booked seats count: $e');
      return 0;
    }
  }

  // --- Location Selection Methods ---
  Future<List<LocationModel>> getLocations() async {
    try {
      final snapshot = await _db.collection('locations').get();
      return snapshot.docs
          .map((doc) => LocationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  /// Search locations by name or city
  /// Supports partial matches and multi-word queries
  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      if (query.isEmpty) {
        return await getLocations();
      }

      final lowerQuery = query.toLowerCase().trim();
      final allLocations = await getLocations();

      // Filter locations based on query
      List<LocationModel> filtered = allLocations.where((loc) {
        final locNameLower = loc.name.toLowerCase();
        final locCityLower = loc.city.toLowerCase();

        return locNameLower.contains(lowerQuery) ||
            locCityLower.contains(lowerQuery);
      }).toList();

      // Sort by relevance
      filtered.sort((a, b) {
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();

        // Prioritize name matches over city matches
        bool aNameMatch = aName.contains(lowerQuery);
        bool bNameMatch = bName.contains(lowerQuery);

        if (aNameMatch && !bNameMatch) return -1;
        if (bNameMatch && !aNameMatch) return 1;

        // If both match name or both match city, sort alphabetically
        return aName.compareTo(bName);
      });

      return filtered;
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // --- Bus Search Methods ---
  Future<List<BusModel>> getActiveBuses() async {
    try {
      final snapshot = await _db
          .collection('buses')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching active buses: $e');
      return [];
    }
  }

  Future<List<BusModel>> searchBuses(String fromId) async {
    try {
      final snapshot = await _db
          .collection('buses')
          .where('route', arrayContains: fromId)
          .get();
      return snapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error searching buses: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSeatList(String busId) async {
    try {
      final snapshot = await _db
          .collection('seats')
          .doc(busId)
          .collection('seatList')
          .get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching seat list: $e');
      return [];
    }
  }

  // --- Wallet Methods ---
  Future<void> updateWalletBalance(String userId, double amountToAdd) async {
    // We use SetOptions(merge: true) in case walletBalance doesn't exist yet
    await _db.collection('users').doc(userId).set({
      'walletBalance': FieldValue.increment(amountToAdd),
    }, SetOptions(merge: true));
  }

  Future<void> addWalletTransaction(
    String userId,
    Map<String, dynamic> transactionData,
  ) async {
    // Store in root-level wallet_transactions collection with userId for cross-user queries
    final docRef = _db.collection('wallet_transactions').doc();
    await docRef.set({'docId': docRef.id, 'userId': userId, ...transactionData});
  }

  Future<void> debitWalletBalance({
    required String userId,
    required double amount,
    required Map<String, dynamic> walletTransactionData,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final txnRef = _db.collection('wallet_transactions').doc();

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      
      if (!userSnapshot.exists) {
        throw Exception('User document does not exist');
      }

      final currentBalance = (userSnapshot.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
      
      if (currentBalance < amount) {
        throw Exception('Insufficient wallet balance');
      }

      // 1. Deduct balance
      transaction.update(userRef, {
        'walletBalance': FieldValue.increment(-amount),
      });

      // 2. Log transaction
      transaction.set(txnRef, {
        'docId': txnRef.id,
        'userId': userId,
        ...walletTransactionData,
      });
    });
  }

  Stream<List<Map<String, dynamic>>> getWalletTransactions(String userId) {
    return _db
        .collection('wallet_transactions')
        .where('userId', isEqualTo: userId)
        // No orderBy here — avoids requiring a composite Firestore index.
        // We sort client-side after receiving the snapshot.
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          // Sort by createdAt descending (newest first)
          docs.sort((a, b) {
            final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(2000);
            final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
          return docs;
        });
  }

  Stream<double> streamWalletBalance(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    });
  }
}
