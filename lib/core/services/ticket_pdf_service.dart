import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart' show Color, EdgeInsets;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────

/// Carries all ticket data needed to build the PDF.
class TicketDownloadData {
  final String bookingId;
  final String passengerName;
  final String passengerPhone;
  final String journeyDate;
  final String route;
  final String busAndSeat;
  final String paymentMethod;
  final double ticketPrice;
  final double gst;
  final double platformFee;
  final double totalPaid;

  TicketDownloadData({
    required this.bookingId,
    required this.passengerName,
    required this.passengerPhone,
    required this.journeyDate,
    required this.route,
    required this.busAndSeat,
    required this.paymentMethod,
    required this.ticketPrice,
    required this.gst,
    required this.platformFee,
    required this.totalPaid,
  });

  /// Build from a raw Firestore document map.
  factory TicketDownloadData.fromMap(Map<String, dynamic> map) {
    double parse(dynamic v, double fallback) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? fallback;

    return TicketDownloadData(
      bookingId: map['bookingId'] ?? 'N/A',
      passengerName: map['passengerName'] ?? 'Unknown',
      passengerPhone: map['passengerPhone'] ?? 'N/A',
      journeyDate: map['journeyDate'] ?? 'N/A',
      route: map['route'] ?? 'N/A',
      busAndSeat: map['busAndSeat'] ?? 'N/A',
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      ticketPrice: parse(map['ticketPrice'], 0.0),
      gst: parse(map['gst'], 0.0),
      platformFee: parse(map['platformFee'], 10.0),
      totalPaid: parse(map['totalPaid'], 0.0),
    );
  }
}

class ParcelDownloadData {
  final String trackingId;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String pickupLocation;
  final String dropLocation;
  final String estimatedPickupTime;
  final String estimatedDropTime;
  final String busAndDriver;
  final double weight;
  final String paymentMethod;
  final double baseFare;
  final double serviceFee;
  final double gst;
  final double totalPaid;

  ParcelDownloadData({
    required this.trackingId,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.pickupLocation,
    required this.dropLocation,
    required this.estimatedPickupTime,
    required this.estimatedDropTime,
    required this.busAndDriver,
    required this.weight,
    required this.paymentMethod,
    required this.baseFare,
    required this.serviceFee,
    required this.gst,
    required this.totalPaid,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Professional bank-statement-style receipt for wallet top-ups.
class WalletReceiptData {
  final String transactionId;
  final String razorpayPaymentId;
  final String accountName;
  final String mobile;
  final String remarks;
  final double amount;
  final String paymentMethod;
  final String status;
  final String dateTime;
  final String updatedBalance;

  WalletReceiptData({
    required this.transactionId,
    required this.razorpayPaymentId,
    required this.accountName,
    required this.mobile,
    required this.remarks,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.dateTime,
    required this.updatedBalance,
  });

  factory WalletReceiptData.fromMap(Map<String, dynamic> map) {
    double parse(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
    return WalletReceiptData(
      transactionId: map['transactionId'] ?? 'N/A',
      razorpayPaymentId: map['razorpayPaymentId'] ?? 'N/A',
      accountName: map['name'] ?? 'N/A',
      mobile: map['mobile'] ?? 'N/A',
      remarks: map['remarks'] ?? '',
      amount: parse(map['amount']),
      paymentMethod: map['paymentMethod'] ?? 'Razorpay',
      status: map['status'] ?? 'Completed',
      dateTime: map['createdAt'] ?? 'N/A',
      updatedBalance: map['updatedBalance'] ?? '₹0.00',
    );
  }
}

/// Generates a PDF ticket and saves it to the device's Downloads folder.
class TicketPdfService {
  // PDF palette – all PdfColor, no Flutter Color
  static const PdfColor _red = PdfColor.fromInt(0xFFE82E59);
  static const PdfColor _redLight = PdfColor.fromInt(0xFFFF6B6B);
  static const PdfColor _darkText = PdfColor.fromInt(0xFF1A1A2E);
  static const PdfColor _greyText = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _lightBg = PdfColor.fromInt(0xFFF8F9FA);
  static const PdfColor _white = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor _green = PdfColor.fromInt(0xFF00A65A);
  static const PdfColor _greenBg = PdfColor.fromInt(0xFFE8F8F0);
  static const PdfColor _border = PdfColor.fromInt(0xFFE5E7EB);
  static const PdfColor _pinkBg = PdfColor.fromInt(0xFFFFF1F3);
  static const PdfColor _pinkText = PdfColor.fromInt(0xFFFFCCCC);

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Builds the PDF, saves it, and shows a snackbar with the result.
  /// Generates the raw PDF bytes for uploading or saving.
  Future<Uint8List> generatePdfBytes(TicketDownloadData data) async {
    final pdf = await _buildPdf(data);
    return await pdf.save();
  }

  /// Builds the PDF, saves it, and shows a snackbar with the result.
  Future<void> downloadTicket(TicketDownloadData data) async {
    try {
      // 1. Storage permission (only needed for Android ≤ 12)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          _error('Storage permission is required to save the ticket.');
          return;
        }
      }

      // 2. Build + serialise
      final bytes = await generatePdfBytes(data);

      // 3. Write to Downloads
      final dir = await _downloadsDir();
      final safe = data.bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final path = '${dir.path}/Ticket_$safe.pdf';
      await File(path).writeAsBytes(bytes);

      // 4. Success
      _success('Ticket Downloaded', 'Saved: Ticket_$safe.pdf');
    } catch (e) {
      _error('Could not save ticket: $e');
    }
  }

  /// Builds the Parcel PDF, saves it, and shows a snackbar with the result.
  Future<void> downloadParcel(ParcelDownloadData data) async {
    try {
      // 1. Storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          _error('Storage permission is required to save the invoice.');
          return;
        }
      }

      // 2. Build + serialise
      final bytes = await generateParcelPdfBytes(data);

      // 3. Write to Downloads
      final dir = await _downloadsDir();
      final safe = data.trackingId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final path = '${dir.path}/Parcel_$safe.pdf';
      await File(path).writeAsBytes(bytes);

      // 4. Success
      _success('Invoice Downloaded', 'Saved: Parcel_$safe.pdf');
    } catch (e) {
      _error('Could not save invoice: $e');
    }
  }

  /// Generates a bank-statement-style PDF receipt for wallet top-ups.
  Future<void> downloadWalletReceipt(WalletReceiptData data) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          _error('Storage permission is required to save the receipt.');
          return;
        }
      }
      final bytes = await _generateWalletReceiptBytes(data);
      final dir = await _downloadsDir();
      final safe = data.transactionId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final path = '${dir.path}/Receipt_$safe.pdf';
      await File(path).writeAsBytes(bytes);
      _success('Receipt Downloaded', 'Saved: Receipt_$safe.pdf');
    } catch (e) {
      _error('Could not save receipt: $e');
    }
  }

  Future<Uint8List> _generateWalletReceiptBytes(WalletReceiptData d) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontMono = await PdfGoogleFonts.robotoMonoRegular();

    final doc = pw.Document(
      title: 'Savarii Wallet Receipt',
      author: 'Savarii',
      subject: 'Receipt ${d.transactionId}',
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Bank-style header bar ──────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
              color: const PdfColor.fromInt(0xFF1A1A2E),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('SAVARII',
                          style: pw.TextStyle(
                              font: fontBold,
                              color: _white,
                              fontSize: 26,
                              letterSpacing: 3)),
                      pw.SizedBox(height: 3),
                      pw.Text('Digital Wallet',
                          style: pw.TextStyle(
                              color: const PdfColor.fromInt(0xFF9CA3AF),
                              fontSize: 10,
                              letterSpacing: 1)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('TRANSACTION RECEIPT',
                          style: pw.TextStyle(
                              font: fontBold,
                              color: _white,
                              fontSize: 11,
                              letterSpacing: 2)),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: _green,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(d.status.toUpperCase(),
                            style: pw.TextStyle(
                                font: fontBold,
                                color: _white,
                                fontSize: 9,
                                letterSpacing: 1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Amount block ────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              color: const PdfColor.fromInt(0xFFF8F9FA),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('AMOUNT CREDITED',
                      style: pw.TextStyle(
                          color: _greyText, fontSize: 9, letterSpacing: 1.5)),
                  pw.SizedBox(height: 6),
                  pw.Text('₹${d.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          font: fontBold,
                          color: _green,
                          fontSize: 36)),
                  pw.SizedBox(height: 4),
                  pw.Text(d.dateTime,
                      style: pw.TextStyle(
                          color: _greyText, fontSize: 10)),
                ],
              ),
            ),

            pw.Container(height: 1, color: _border),

            // ── Transaction details ────────────────────────────────────
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _bankSectionLabel('TRANSACTION DETAILS'),
                  pw.SizedBox(height: 14),
                  _bankRow('Transaction ID', d.transactionId,
                      mono: true, fontMono: fontMono),
                  _bankDivider(),
                  _bankRow('Razorpay Payment ID', d.razorpayPaymentId,
                      mono: true, fontMono: fontMono),
                  _bankDivider(),
                  _bankRow('Payment Method', d.paymentMethod),
                  _bankDivider(),
                  _bankRow('Status', d.status,
                      valueColor: d.status.toLowerCase() == 'completed'
                          ? _green
                          : _red),
                  pw.SizedBox(height: 24),
                  _bankSectionLabel('BENEFICIARY DETAILS'),
                  pw.SizedBox(height: 14),
                  _bankRow('Account Name', d.accountName),
                  _bankDivider(),
                  _bankRow('Mobile Number', d.mobile),
                  if (d.remarks.isNotEmpty) ...[
                    _bankDivider(),
                    _bankRow('Remarks', d.remarks),
                  ],
                  pw.SizedBox(height: 24),
                  _bankSectionLabel('BALANCE SUMMARY'),
                  pw.SizedBox(height: 14),
                  // Balance summary box
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFE8F8F0),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFFBBDDD0)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('CREDITED AMOUNT',
                                style: pw.TextStyle(
                                    color: _greyText,
                                    fontSize: 8,
                                    letterSpacing: 1)),
                            pw.SizedBox(height: 4),
                            pw.Text('₹${d.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    font: fontBold,
                                    color: _green,
                                    fontSize: 16)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('WALLET BALANCE',
                                style: pw.TextStyle(
                                    color: _greyText,
                                    fontSize: 8,
                                    letterSpacing: 1)),
                            pw.SizedBox(height: 4),
                            pw.Text(d.updatedBalance,
                                style: pw.TextStyle(
                                    font: fontBold,
                                    color: _darkText,
                                    fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 32),

                  // ── Footer ───────────────────────────────────────────
                  pw.Container(height: 1, color: _border),
                  pw.SizedBox(height: 14),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('savarii.app',
                          style: pw.TextStyle(
                              color: _greyText,
                              fontSize: 9,
                              letterSpacing: 0.5)),
                      pw.Text(
                          'System-generated receipt. No signature required.',
                          style: pw.TextStyle(
                              color: _greyText, fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return await doc.save();
  }

  pw.Widget _bankSectionLabel(String text) => pw.Text(
        text,
        style: pw.TextStyle(
            color: _greyText,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5),
      );

  pw.Widget _bankRow(
    String label,
    String value, {
    bool mono = false,
    pw.Font? fontMono,
    PdfColor? valueColor,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: pw.TextStyle(color: _greyText, fontSize: 11)),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: mono ? fontMono : null,
                color: valueColor ?? _darkText,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  pw.Widget _bankDivider() =>
      pw.Container(height: 0.5, color: const PdfColor.fromInt(0xFFE9EAEC));



  void _success(String title, String msg) {
    Get.snackbar(
      '✅ $title',
      msg,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFFE8F8F0),
      colorText: const Color(0xFF00A65A),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // ── PDF Construction ────────────────────────────────────────────────────────

  Future<pw.Document> _buildPdf(TicketDownloadData d) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final doc = pw.Document(
      title: 'Savarii Bus Ticket',
      author: 'Savarii',
      subject: 'Ticket ${d.bookingId}',
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _bookingRow(d),
                  pw.SizedBox(height: 20),
                  _line(),
                  pw.SizedBox(height: 20),
                  _passengerBox(d),
                  pw.SizedBox(height: 16),
                  _travelBox(d),
                  pw.SizedBox(height: 16),
                  _dashedLine(),
                  pw.SizedBox(height: 16),
                  _pricingBox(d),
                  pw.SizedBox(height: 28),
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return doc;
  }

  Future<pw.Document> _buildParcelPdf(ParcelDownloadData d) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final doc = pw.Document(
      title: 'Savarii Parcel Ticket',
      author: 'Savarii',
      subject: 'Parcel ${d.trackingId}',
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _headerForParcel(),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _parcelBookingRow(d),
                  pw.SizedBox(height: 20),
                  _line(),
                  pw.SizedBox(height: 20),
                  _senderReceiverBox(d),
                  pw.SizedBox(height: 16),
                  _logisticsBox(d),
                  pw.SizedBox(height: 16),
                  _dashedLine(),
                  pw.SizedBox(height: 16),
                  _parcelPricingBox(d),
                  pw.SizedBox(height: 28),
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return doc;
  }

  Future<Uint8List> generateParcelPdfBytes(ParcelDownloadData data) async {
    final pdf = await _buildParcelPdf(data);
    return await pdf.save();
  }

  // ── Sections ────────────────────────────────────────────────────────────────

  pw.Widget _header() => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
        decoration: const pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [_red, _redLight],
            begin: pw.Alignment.centerLeft,
            end: pw.Alignment.centerRight,
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SAVARII',
                    style: pw.TextStyle(
                        color: _white,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 3)),
                pw.Text('Bus Booking Service',
                    style: pw.TextStyle(color: _pinkText, fontSize: 11, letterSpacing: 1)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('BUS TICKET',
                    style: pw.TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2)),
                pw.Text('E-Ticket',
                    style: pw.TextStyle(color: _pinkText, fontSize: 10)),
              ],
            ),
          ],
        ),
      );

  pw.Widget _bookingRow(TicketDownloadData d) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _label('BOOKING ID'),
              pw.SizedBox(height: 4),
              pw.Text(d.bookingId,
                  style: pw.TextStyle(
                      color: _darkText, fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _greenBg,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text('CONFIRMED',
                style: pw.TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1)),
          ),
        ],
      );

  pw.Widget _passengerBox(TicketDownloadData d) => _infoCard(
        title: 'PASSENGER DETAILS',
        children: [
          _infoItem('Passenger Name', d.passengerName),
          _infoItem('Mobile', d.passengerPhone.isNotEmpty ? d.passengerPhone : 'N/A'),
          _infoItem('Journey Date', d.journeyDate),
        ],
      );

  pw.Widget _travelBox(TicketDownloadData d) => _infoCard(
        title: 'TRAVEL DETAILS',
        children: [
          _infoItem('Route', d.route),
          _infoItem('Bus & Seat', d.busAndSeat),
          _infoItem('Payment', d.paymentMethod),
        ],
      );

  pw.Widget _pricingBox(TicketDownloadData d) => pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: _white,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: _border),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _label('PAYMENT SUMMARY'),
            pw.SizedBox(height: 16),
            _priceRow('Ticket Price', d.ticketPrice),
            pw.SizedBox(height: 10),
            _priceRow('GST', d.gst),
            pw.SizedBox(height: 10),
            _priceRow('Platform Fee', d.platformFee),
            pw.SizedBox(height: 14),
            pw.Container(height: 1, color: _border),
            pw.SizedBox(height: 14),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL PAID',
                    style: pw.TextStyle(
                        color: _darkText, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('₹${d.totalPaid.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        color: _red, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      );

  // ── Parcel Sections ─────────────────────────────────────────────────────────

  pw.Widget _headerForParcel() => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
        decoration: const pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [_red, _redLight],
            begin: pw.Alignment.centerLeft,
            end: pw.Alignment.centerRight,
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SAVARII',
                    style: pw.TextStyle(
                        color: _white, fontSize: 28, fontWeight: pw.FontWeight.bold, letterSpacing: 3)),
                pw.Text('Parcel Logistics Service',
                    style: pw.TextStyle(color: _pinkText, fontSize: 11, letterSpacing: 1)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('PARCEL TICKET',
                    style: pw.TextStyle(
                        color: _white, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                pw.Text('E-Waybill',
                    style: pw.TextStyle(color: _pinkText, fontSize: 10)),
              ],
            ),
          ],
        ),
      );

  pw.Widget _parcelBookingRow(ParcelDownloadData d) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _label('TRACKING ID'),
              pw.SizedBox(height: 4),
              pw.Text(d.trackingId,
                  style: pw.TextStyle(
                      color: _darkText, fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _greenBg,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text('CONFIRMED',
                style: pw.TextStyle(
                    color: _green, fontSize: 11, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      );

  pw.Widget _senderReceiverBox(ParcelDownloadData d) => pw.Row(
    children: [
      pw.Expanded(child: _infoCard(
        title: 'SENDER DETAILS',
        children: [
          _infoItem('Name', d.senderName),
          _infoItem('Phone', d.senderPhone),
        ],
      )),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _infoCard(
        title: 'RECEIVER DETAILS',
        children: [
          _infoItem('Name', d.receiverName),
          _infoItem('Phone', d.receiverPhone),
        ],
      )),
    ]
  );

  pw.Widget _logisticsBox(ParcelDownloadData d) => _infoCard(
        title: 'LOGISTICS DETAILS',
        children: [
          _infoItem('Route', '${d.pickupLocation} → ${d.dropLocation}'),
          _infoItem('Pickup Est.', d.estimatedPickupTime),
          _infoItem('Weight (KG)', d.weight.toString()),
        ],
      );

  pw.Widget _parcelPricingBox(ParcelDownloadData d) => pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: _white,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: _border),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _label('PAYMENT SUMMARY'),
            pw.SizedBox(height: 16),
            _priceRow('Freight Base Fare', d.baseFare),
            pw.SizedBox(height: 10),
            _priceRow('Service Fee', d.serviceFee),
            pw.SizedBox(height: 10),
            _priceRow('GST (5%)', d.gst),
            pw.SizedBox(height: 14),
            pw.Container(height: 1, color: _border),
            pw.SizedBox(height: 14),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL PAID',
                    style: pw.TextStyle(
                        color: _darkText, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('₹${d.totalPaid.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        color: _red, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      );

  pw.Widget _footer() => pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            decoration: pw.BoxDecoration(
              color: _pinkBg,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Center(
              child: pw.Text(
                'Thank you for travelling with Savarii!',
                style: pw.TextStyle(
                    color: _red, fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'System-generated e-ticket. No signature required.',
              style: pw.TextStyle(color: _greyText, fontSize: 9),
            ),
          ),
        ],
      );

  // ── Reusable Building Blocks ─────────────────────────────────────────────────

  pw.Widget _infoCard({
    required String title,
    required List<pw.Widget> children,
  }) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: _lightBg,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: _border),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _label(title),
            pw.SizedBox(height: 14),
            pw.Row(
              children: children
                  .map((w) => pw.Expanded(child: w))
                  .toList(),
            ),
          ],
        ),
      );

  pw.Widget _infoItem(String label, String value) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
                color: _greyText,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.5),
          ),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  color: _darkText, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      );

  pw.Widget _priceRow(String label, double amount) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: _greyText, fontSize: 12)),
          pw.Text('₹${amount.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  color: _darkText, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      );

  pw.Widget _label(String text) => pw.Text(
        text,
        style: pw.TextStyle(
            color: _greyText,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1),
      );

  pw.Widget _line() => pw.Container(height: 1, color: _border);

  pw.Widget _dashedLine() => pw.Row(
        children: List.generate(
          42,
          (i) => pw.Expanded(
            child: pw.Container(height: 1, color: i.isEven ? _border : _white),
          ),
        ),
      );

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Future<Directory> _downloadsDir() async {
    if (Platform.isAndroid) {
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) {
          final dlPath = '${ext.path.split('Android').first}Download';
          final dir = Directory(dlPath);
          if (!await dir.exists()) await dir.create(recursive: true);
          return dir;
        }
      } catch (_) {}
    }
    return getApplicationDocumentsDirectory();
  }

  void _error(String msg) {
    Get.snackbar(
      '❌ Download Failed',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFFEBEB),
      colorText: const Color(0xFFE82E59),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }
}
