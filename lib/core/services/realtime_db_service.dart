import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/models/live_tracking_model.dart';

/// Service for Firebase Realtime Database live tracking operations.
/// Registered as a GetxService so it lives for the app's lifetime.
class RealtimeDbService extends GetxService {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── RTDB Live Tracking ──────────────────────────────────────────────────────

  /// Returns a stream of [LiveTrackingModel] for the given [tripId].
  /// Emits null if the node doesn't exist yet.
  Stream<LiveTrackingModel?> trackingStream(String tripId) {
    final ref = _rtdb.ref('live_tracking/$tripId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      return LiveTrackingModel.fromMap(data as Map<dynamic, dynamic>);
    });
  }

  /// Updates the live location of the bus in Realtime Database.
  Future<void> updateLiveLocation(String busId, LiveTrackingModel location) async {
    try {
      debugPrint('RealtimeDbService: Attempting to update location for $busId...');
      final ref = _rtdb.ref('live_tracking/$busId');
      await ref.set(location.toMap());
      debugPrint('RealtimeDbService: Successfully updated location for $busId.');
    } catch (e) {
      debugPrint('RealtimeDbService: Error updating location for $busId: $e');
    }
  }

  // ── Firestore Trip Details ──────────────────────────────────────────────────


  /// One-time fetch of driver info from Firestore `drivers/{driverId}`.
  /// Returns null if the driver document doesn't exist.
  Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    try {
      final doc = await _firestore.collection('drivers').doc(driverId).get();
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      debugPrint('RealtimeDbService: Error fetching driver $driverId: $e');
      return null;
    }
  }

  /// One-time fetch of bus info from Firestore `buses/{busId}`.
  Future<Map<String, dynamic>?> getBusDetails(String busId) async {
    try {
      final doc = await _firestore.collection('buses').doc(busId).get();
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      debugPrint('RealtimeDbService: Error fetching bus $busId: $e');
      return null;
    }
  }
}
