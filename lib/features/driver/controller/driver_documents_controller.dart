import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDocumentsController extends GetxController {
  FirestoreService get _firestore => Get.find<FirestoreService>();
  AuthController get _auth => Get.find<AuthController>();

  // ── Fixed slot definitions ──────────────────────────────────────────────
  // These define the UI slots. Firestore data is merged into them on load.
  final List<Map<String, dynamic>> _slotConfig = [
    {
      'id': 'aadhar',
      'title': 'Aadhar Card',
      'icon': Icons.badge_outlined,
    },
    {
      'id': 'dl',
      'title': 'Driving License',
      'icon': Icons.directions_car_outlined,
    },
    {
      'id': 'rc',
      'title': 'RC Book',
      'icon': Icons.menu_book_outlined,
    },
    {
      'id': 'insurance',
      'title': 'Insurance Card',
      'icon': Icons.shield_outlined,
    },
  ];

  /// Reactive list driving the UI
  final RxList<Map<String, dynamic>> documents = <Map<String, dynamic>>[].obs;

  /// Per-card upload-in-progress flag  (key = docId)
  final RxMap<String, bool> uploadingMap = <String, bool>{}.obs;

  /// Overall loading flag while fetching from Firestore
  final RxBool isLoading = false.obs;

  // Cached driver info to embed in each document record
  String _driverName = '';
  String _driverPhone = '';
  String _driverEmail = '';

  @override
  void onInit() {
    super.onInit();
    _loadDocuments();
  }

  // ── Load ────────────────────────────────────────────────────────────────

  Future<void> _loadDocuments() async {
    final uid = _auth.uid;
    if (uid == null) return;

    isLoading.value = true;
    try {
      // 1. Fetch driver's personal info so we can store it with each doc
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(uid)
          .get();
      if (driverDoc.exists) {
        final d = driverDoc.data()!;
        _driverName = d['name'] ?? '';
        _driverPhone = d['phone'] ?? '';
        _driverEmail = d['email'] ?? '';
      }

      // 2. Fetch already-uploaded document records
      final uploaded = await _firestore.getDriverDocuments(uid);
      final uploadedMap = {for (final u in uploaded) u['id'] as String: u};

      // 3. Merge slot config with uploaded data
      final merged = _slotConfig.map((slot) {
        final existing = uploadedMap[slot['id']];
        return {
          ...slot,
          'hasUploaded': existing != null,
          'downloadUrl': existing?['downloadUrl'] ?? '',
          'fileName': existing?['fileName'] ?? '',
          'uploadedAt': existing?['uploadedAt'] ?? '',
        };
      }).toList();

      documents.assignAll(merged);
    } catch (e) {
      print('Error loading driver documents: $e');
      Get.snackbar('Error', 'Failed to load documents. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Upload ──────────────────────────────────────────────────────────────

  Future<void> uploadDocument(int index) async {
    final uid = _auth.uid;
    if (uid == null) return;

    final docId = documents[index]['id'] as String;
    final docTitle = documents[index]['title'] as String;

    // 1. Open file picker — use FileType.any so the Android SAF document
    //    picker opens correctly. We validate the extension ourselves after.
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );
    } catch (e) {
      print('FilePicker error: $e');
      Get.snackbar(
        'Cannot Open Files',
        'Unable to open the file picker. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (result == null || result.files.isEmpty) return; // user cancelled

    final pickedFile = result.files.first;
    final ext = (pickedFile.extension ?? '').toLowerCase();

    // 2. Validate file type — only PDF and JPEG allowed
    if (ext != 'pdf' && ext != 'jpg' && ext != 'jpeg') {
      Get.snackbar(
        'Invalid File Type',
        'Only PDF and JPEG files are allowed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade900,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // 2. Validate size ≤ 1 MB
    final sizeBytes = pickedFile.size;
    if (sizeBytes > 1 * 1024 * 1024) {
      Get.snackbar(
        'File Too Large',
        'Maximum allowed size is 1 MB. Please compress the file and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // 3. Show per-card loader
    uploadingMap[docId] = true;

    try {
      final file = File(pickedFile.path!);
      final fileName = '$docId.$ext';

      // 4. Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('driver_documents')
          .child(uid)
          .child(fileName);

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: ext == 'pdf' ? 'application/pdf' : 'image/jpeg',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 5. Save record to Firestore sub-collection
      final now = DateTime.now().toIso8601String();
      await _firestore.saveDriverDocument(uid, docId, {
        'id': docId,
        'name': _driverName,
        'phone': _driverPhone,
        'email': _driverEmail,
        'downloadUrl': downloadUrl,
        'fileName': fileName,
        'uploadedAt': now,
        'status': 'Pending Verification',
      });

      // 6. Update the reactive list so the button flips to "View"
      final updated = Map<String, dynamic>.from(documents[index]);
      updated['hasUploaded'] = true;
      updated['downloadUrl'] = downloadUrl;
      updated['fileName'] = fileName;
      updated['uploadedAt'] = now;
      documents[index] = updated;

      Get.snackbar(
        'Document Successfully Completed',
        '$docTitle has been uploaded and is pending verification.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      print('Error uploading $docId: $e');
      Get.snackbar(
        'Upload Failed',
        'Could not upload $docTitle. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    } finally {
      uploadingMap[docId] = false;
    }
  }

  // ── View ────────────────────────────────────────────────────────────────

  Future<void> viewDocument(int index) async {
    final url = documents[index]['downloadUrl'] as String? ?? '';
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot Open',
        'Unable to open the document. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  bool isUploading(String docId) => uploadingMap[docId] == true;
}