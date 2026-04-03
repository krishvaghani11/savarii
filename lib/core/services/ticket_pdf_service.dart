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
    double _parse(dynamic v, double fallback) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? fallback;

    return TicketDownloadData(
      bookingId: map['bookingId'] ?? 'N/A',
      passengerName: map['passengerName'] ?? 'Unknown',
      passengerPhone: map['passengerPhone'] ?? 'N/A',
      journeyDate: map['journeyDate'] ?? 'N/A',
      route: map['route'] ?? 'N/A',
      busAndSeat: map['busAndSeat'] ?? 'N/A',
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      ticketPrice: _parse(map['ticketPrice'], 0.0),
      gst: _parse(map['gst'], 0.0),
      platformFee: _parse(map['platformFee'], 10.0),
      totalPaid: _parse(map['totalPaid'], 0.0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

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
      Get.snackbar(
        '✅ Ticket Downloaded',
        'Saved: Ticket_$safe.pdf',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFFE8F8F0),
        colorText: const Color(0xFF00A65A),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      _error('Could not save ticket: $e');
    }
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
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFEBEB),
      colorText: const Color(0xFFE82E59),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }
}
