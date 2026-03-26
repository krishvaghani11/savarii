import 'package:cloud_firestore/cloud_firestore.dart';

class TravelsModel {
  final String vendorId;
  final String travelsName;
  final String gstNumber;
  final String businessType;
  final String establishedDate;
  final String contactPerson;
  final String mobileNumber;
  final String supportEmail;
  final String address;
  final String city;
  final String state;
  final List<String> primaryRoutes;
  final String? travelsImageUrl;
  final DateTime createdAt;

  TravelsModel({
    required this.vendorId,
    required this.travelsName,
    required this.gstNumber,
    required this.businessType,
    required this.establishedDate,
    required this.contactPerson,
    required this.mobileNumber,
    required this.supportEmail,
    required this.address,
    required this.city,
    required this.state,
    required this.primaryRoutes,
    this.travelsImageUrl,
    required this.createdAt,
  });

  factory TravelsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TravelsModel(
      vendorId: documentId,
      travelsName: map['travelsName'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      businessType: map['businessType'] ?? '',
      establishedDate: map['establishedDate'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      supportEmail: map['supportEmail'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      primaryRoutes: List<String>.from(map['primaryRoutes'] ?? []),
      travelsImageUrl: map['travelsImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'travelsName': travelsName,
      'gstNumber': gstNumber,
      'businessType': businessType,
      'establishedDate': establishedDate,
      'contactPerson': contactPerson,
      'mobileNumber': mobileNumber,
      'supportEmail': supportEmail,
      'address': address,
      'city': city,
      'state': state,
      'primaryRoutes': primaryRoutes,
      if (travelsImageUrl != null) 'travelsImageUrl': travelsImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
