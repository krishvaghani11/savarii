import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String id;
  final String vendorId;
  final String name;
  final String email;
  final String phone;
  final String altPhone;
  final String dlNumber;
  final String aadharNumber;
  final String street;
  final String city;
  final String state;
  final String pinCode;
  final String profileImage;
  final String dlImage;
  final String aadharImage;
  final String status; // 'ACTIVE', 'ON TRIP', 'INACTIVE'
  final DateTime createdAt;

  DriverModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.email,
    required this.phone,
    required this.altPhone,
    required this.dlNumber,
    required this.aadharNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.profileImage,
    required this.dlImage,
    required this.aadharImage,
    this.status = 'ACTIVE',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'email': email,
      'phone': phone,
      'altPhone': altPhone,
      'dlNumber': dlNumber,
      'aadharNumber': aadharNumber,
      'street': street,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'profileImage': profileImage,
      'dlImage': dlImage,
      'aadharImage': aadharImage,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map, String id) {
    return DriverModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      altPhone: map['altPhone'] ?? '',
      dlNumber: map['dlNumber'] ?? '',
      aadharNumber: map['aadharNumber'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pinCode: map['pinCode'] ?? '',
      profileImage: map['profileImage'] ?? '',
      dlImage: map['dlImage'] ?? '',
      aadharImage: map['aadharImage'] ?? '',
      status: map['status'] ?? 'ACTIVE',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
