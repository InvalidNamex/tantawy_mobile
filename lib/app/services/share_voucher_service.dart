import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/voucher_model.dart';
import '../services/connectivity_service.dart';
import '../utils/logger.dart';

class ShareVoucherService {
  static const double bodyFontSize = 18;
  static const double headerFontSize = 20;
  static const double titleFontSize = 24;

  /// Check if the text contains Arabic characters
  static bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Share a voucher as PDF
  static Future<void> shareVoucher({
    required VoucherResponseModel voucher,
    String? agentName,
  }) async {
    try {
      logger.d('📤 Starting share voucher process');
      logger.d('📄 Voucher ID: ${voucher.id}');
      logger.d('👤 Customer: ${voucher.customerVendorName}');
      logger.d('💰 Amount: ${voucher.amount}');

      // Check internet connectivity
      final connectivityService = Get.find<ConnectivityService>();
      final isConnected = await connectivityService.checkConnection();

      if (!isConnected) {
        logger.w('⚠️ No internet connection');
        Get.snackbar(
          'no_internet'.tr,
          'please_check_internet_connection'.tr,
          snackPosition: SnackPosition.bottom,
          duration: Duration(seconds: 3),
        );
        return;
      }

      logger.d('📐 Generating PDF document');
      final doc = await _generateDocument(
        voucher: voucher,
        agentName: agentName,
      );
      logger.d('✅ Document generated successfully');

      // Save PDF to temporary file
      final bytes = await doc.save();
      final tempDir = await getTemporaryDirectory();
      final voucherType = voucher.type == 1 ? 'receipt' : 'payment';
      final fileName =
          'voucher_${voucherType}_${voucher.voucherNumber ?? voucher.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      logger.d('💾 PDF saved to: ${file.path}');

      // Share the file
      final voucherTypeText = voucher.type == 1
          ? 'receive_voucher'.tr
          : 'payment_voucher'.tr;
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: '$voucherTypeText ${voucher.voucherNumber ?? voucher.id}',
        text:
            '$voucherTypeText ${voucher.customerVendorName} - ${voucher.amount.toStringAsFixed(2)} ${'currency'.tr}',
      );

      logger.d('✅ Share completed with result: ${result.status}');
    } catch (e, stackTrace) {
      logger.e('❌ Error in shareVoucher: $e');
      logger.e('Stack trace: $stackTrace');
      Get.snackbar(
        'error'.tr,
        '${e.toString()}',
        snackPosition: SnackPosition.bottom,
        duration: Duration(seconds: 5),
      );
      rethrow;
    }
  }

  /// Generate PDF document
  static Future<pw.Document> _generateDocument({
    required VoucherResponseModel voucher,
    String? agentName,
  }) async {
    try {
      logger.d('📝 Starting document generation');

      logger.d('🌐 Getting language preferences');
      bool isArabic =
          Get.locale?.languageCode == 'ar' || Get.locale?.languageCode == null;
      logger.d('🌍 Language: ${isArabic ? "Arabic" : "English"}');
      logger.d('🌍 Current locale: ${Get.locale?.languageCode}');

      logger.d('📄 Creating PDF document');
      final doc = pw.Document();

      logger.d('🔤 Loading Arabic font');
      final arabicFont = await _getArabicFont();
      logger.d('✅ Font loaded successfully');

      logger.d('🖼️ Loading logo image');
      final logoImage = await _getLogoImage();
      logger.d('✅ Logo loaded successfully');

      logger.d('📃 Building PDF page');
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          header: (context) {
            try {
              logger.d('📋 Building header');
              return _buildHeader(
                voucher: voucher,
                arabicFont: arabicFont,
                logoImage: logoImage,
                isArabic: isArabic,
              );
            } catch (e) {
              logger.e('❌ Error building header: $e');
              rethrow;
            }
          },
          build: (context) {
            try {
              logger.d('🔨 Building page content');
              return [
                pw.SizedBox(height: 16),
                _buildVoucherInfo(
                  voucher: voucher,
                  arabicFont: arabicFont,
                  isArabic: isArabic,
                ),
                pw.SizedBox(height: 20),
                _buildAmountSection(
                  voucher: voucher,
                  arabicFont: arabicFont,
                  isArabic: isArabic,
                ),
                pw.SizedBox(height: 20),
                if (voucher.notes.isNotEmpty)
                  _buildNotesSection(
                    voucher: voucher,
                    arabicFont: arabicFont,
                    isArabic: isArabic,
                  ),
              ];
            } catch (e) {
              logger.e('❌ Error building content: $e');
              rethrow;
            }
          },
          footer: (context) {
            try {
              logger.d('👣 Building footer');
              return _buildFooter(
                voucher: voucher,
                agentName: agentName,
                arabicFont: arabicFont,
                isArabic: isArabic,
              );
            } catch (e) {
              logger.e('❌ Error building footer: $e');
              rethrow;
            }
          },
        ),
      );

      logger.d('✅ Document generation completed');
      return doc;
    } catch (e, stackTrace) {
      logger.e('❌ Error in _generateDocument: $e');
      logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Load Arabic font
  static Future<pw.Font> _getArabicFont() async {
    try {
      logger.d('📥 Loading Cairo-Regular.ttf font');
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      logger.d('✅ Font data loaded: ${fontData.lengthInBytes} bytes');
      final font = pw.Font.ttf(fontData);
      logger.d('✅ Font created successfully');
      return font;
    } catch (e, stackTrace) {
      logger.e('❌ Error loading Arabic font: $e');
      logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Load logo image
  static Future<pw.ImageProvider> _getLogoImage() async {
    try {
      logger.d('📥 Loading logo.png image');
      final imageData = await rootBundle.load('assets/images/logo.png');
      logger.d('✅ Image data loaded: ${imageData.lengthInBytes} bytes');
      final image = pw.MemoryImage(imageData.buffer.asUint8List());
      logger.d('✅ Image created successfully');
      return image;
    } catch (e, stackTrace) {
      logger.e('❌ Error loading logo image: $e');
      logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Build text widget with proper direction
  static pw.Widget _buildText(
    String text, {
    required pw.Font font,
    double fontSize = bodyFontSize,
    bool bold = false,
    bool forceRTL = false,
    bool forceLTR = false,
    PdfColor color = PdfColors.black,
    pw.TextAlign? textAlign,
  }) {
    final isArabic = _isArabicText(text) || forceRTL;
    final direction = forceLTR ? pw.TextDirection.ltr : pw.TextDirection.rtl;

    return pw.Directionality(
      textDirection: isArabic ? direction : pw.TextDirection.ltr,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }

  /// Build header section
  static pw.Widget _buildHeader({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required pw.ImageProvider logoImage,
    required bool isArabic,
  }) {
    String title = isArabic ? 'سند قبض' : 'Receipt Voucher';
    if (voucher.type != 1) {
      title = isArabic ? 'سند صرف' : 'Payment Voucher';
    }

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(logoImage, width: 80, height: 80),
            pw.Column(
              crossAxisAlignment: isArabic
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  title,
                  font: arabicFont,
                  fontSize: titleFontSize,
                  bold: true,
                  color: voucher.type == 1
                      ? PdfColors.green700
                      : PdfColors.red700,
                ),
                pw.SizedBox(height: 4),
                _buildText(
                  voucher.voucherNumber ?? 'N/A',
                  font: arabicFont,
                  fontSize: headerFontSize,
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(
          thickness: 2,
          color: voucher.type == 1 ? PdfColors.green700 : PdfColors.red700,
        ),
      ],
    );
  }

  /// Build voucher info section
  static pw.Widget _buildVoucherInfo({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            label: isArabic ? 'العميل:' : 'Customer:',
            value: voucher.customerVendorName,
            arabicFont: arabicFont,
            isArabic: isArabic,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            label: isArabic ? 'التاريخ:' : 'Date:',
            value: DateFormat('yyyy-MM-dd').format(voucher.voucherDate),
            arabicFont: arabicFont,
            isArabic: isArabic,
          ),
        ],
      ),
    );
  }

  /// Build info row
  static pw.Widget _buildInfoRow({
    required String label,
    required String value,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    return pw.Row(
      children: [
        _buildText(label, font: arabicFont, fontSize: bodyFontSize, bold: true),
        pw.SizedBox(width: 8),
        _buildText(value, font: arabicFont, fontSize: bodyFontSize),
      ],
    );
  }

  /// Build amount section
  static pw.Widget _buildAmountSection({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: voucher.type == 1 ? PdfColors.green700 : PdfColors.red700,
          width: 2,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: voucher.type == 1 ? PdfColors.green50 : PdfColors.red50,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildText(
            isArabic ? 'المبلغ:' : 'Amount:',
            font: arabicFont,
            fontSize: titleFontSize,
            bold: true,
          ),
          _buildText(
            '${voucher.amount.toStringAsFixed(2)} ${isArabic ? 'ج.م' : 'EGP'}',
            font: arabicFont,
            fontSize: titleFontSize,
            bold: true,
            color: voucher.type == 1 ? PdfColors.green700 : PdfColors.red700,
          ),
        ],
      ),
    );
  }

  /// Build notes section
  static pw.Widget _buildNotesSection({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildText(
            isArabic ? 'ملاحظات:' : 'Notes:',
            font: arabicFont,
            fontSize: headerFontSize,
            bold: true,
          ),
          pw.SizedBox(height: 8),
          _buildText(voucher.notes, font: arabicFont, fontSize: bodyFontSize),
        ],
      ),
    );
  }

  /// Build footer section
  static pw.Widget _buildFooter({
    required VoucherResponseModel voucher,
    String? agentName,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    String agentText = agentName ?? (isArabic ? 'غير متوفر' : 'N/A');
    String agentLabel = isArabic ? 'المندوب:' : 'Agent:';

    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildText(
              '$agentLabel $agentText',
              font: arabicFont,
              fontSize: 14,
            ),
            _buildText(
              DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
              font: arabicFont,
              fontSize: 14,
            ),
          ],
        ),
      ],
    );
  }
}
