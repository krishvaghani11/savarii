import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firestore_service.dart';
import '../../../routes/app_routes.dart';

/// Keys used for persisting vendor session
const _kUid = 'session_uid';
const _kPhone = 'session_phone';
const _kRole = 'session_role';

class AuthController extends GetxController {
  final FirestoreService _firestore = Get.find();

  var selectedRole = ''.obs;
  var phone = ''.obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  String? uid;

  // ─────────────────────────────────────────────
  // LIFECYCLE: restore session from SharedPrefs
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  /// Reads the persisted uid/phone/role from disk and populates in-memory state.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString(_kUid);
    final savedPhone = prefs.getString(_kPhone);
    final savedRole = prefs.getString(_kRole);

    if (savedUid != null && savedUid.isNotEmpty) {
      uid = savedUid;
      phone.value = savedPhone ?? '';
      selectedRole.value = savedRole ?? '';
      isLoggedIn.value = true;
      debugPrint(
        '🔐 [AuthController] Session restored: uid=$uid role=$selectedRole',
      );
    }
  }

  /// Writes uid/phone/role to SharedPreferences so it survives cold starts.
  Future<void> _saveSession({
    required String uid,
    required String phone,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUid, uid);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kRole, role);
  }

  /// Call this when the user logs out to clear the persisted session.
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kPhone);
    await prefs.remove(_kRole);
  }

  // ─────────────────────────────────────────────
  // VENDOR SESSION (called by VendorOtpController
  // and VendorRegistrationController)
  // ─────────────────────────────────────────────
  /// Persists a vendor session after successful OTP login or registration.
  Future<void> saveVendorSession({
    required String vendorUid,
    required String vendorPhone,
  }) async {
    uid = vendorUid;
    phone.value = vendorPhone;
    selectedRole.value = 'vendor';
    isLoggedIn.value = true;
    await _saveSession(uid: vendorUid, phone: vendorPhone, role: 'vendor');
    debugPrint('✅ [AuthController] Vendor session saved: uid=$uid');
  }


  // ─────────────────────────────────────────────
  // CREATE CUSTOMER (new user)
  // ─────────────────────────────────────────────
  Future<void> _createCustomer() async {
    await _firestore.createUser(uid!, {
      "phone": phone.value,
      "role": "customer",
      "createdAt": DateTime.now(),
      "lastLogin": DateTime.now(),
      "isLoggedIn": true,
    });
    await _firestore.createWallet(uid!);
  }

  // ─────────────────────────────────────────────
  // CREATE VENDOR (after registration form)
  // ─────────────────────────────────────────────
  Future<void> createVendor({
    required String name,
    required String email,
    required String businessName,
    required String address,
  }) async {
    try {
      if (uid == null || uid!.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        Get.offAllNamed(AppRoutes.customerLogin);
        return;
      }
      await _firestore.createUser(uid!, {
        "phone": phone.value,
        "role": "vendor",
        "createdAt": DateTime.now(),
        "lastLogin": DateTime.now(),
        "isLoggedIn": true,
      });
      await _firestore.createVendor(uid!, {
        "userId": uid,
        "name": name,
        "email": email,
        "businessName": businessName,
        "address": address,
        "createdAt": DateTime.now(),
      });
      Get.offAllNamed(AppRoutes.locationAccess);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  Future<void> logout() async {
    await _clearSession();
    uid = null;
    phone.value = "";
    selectedRole.value = "";
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.customerLogin);
  }
}
