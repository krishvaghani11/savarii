import 'package:cloud_firestore/cloud_firestore.dart';
// models/vendor_model.dart
class VendorModel {
  final String uid; 
  final String userId; 
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String address;
  final DateTime createdAt;

  VendorModel({
    required this.uid,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.address,
    required this.createdAt,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VendorModel(
      uid: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      businessName: map['businessName'] ?? '',
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'businessName': businessName,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}