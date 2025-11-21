import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/voucher_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

class PrintVoucherService {
  static const double bodyFontSize = 18;
  static const double headerFontSize = 20;
  static const double titleFontSize = 24;

  /// Check if the text contains Arabic characters
  static bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Print a voucher
  static Future<void> printVoucher({
    required VoucherResponseModel voucher,
    String? agentName,
  }) async {
    try {
      logger.d('🖨️ Starting print voucher process');
      logger.d('📄 Voucher ID: ${voucher.id}');
      logger.d('👤 Customer: ${voucher.customerVendorName}');
      logger.d('💰 Amount: ${voucher.amount}');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          logger.d('📐 PDF format: ${format.width}x${format.height}');
          try {
            final doc = await _generateDocument(
              voucher: voucher,
              agentName: agentName,
            );
            logger.d('✅ Document generated successfully');
            return doc.save();
          } catch (e, stackTrace) {
            logger.e('❌ Error generating document: $e');
            logger.e('Stack trace: $stackTrace');
            rethrow;
          }
        },
      );
      logger.d('✅ Print layout completed successfully');
    } catch (e, stackTrace) {
      logger.e('❌ Error in printVoucher: $e');
      logger.e('Stack trace: $stackTrace');
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
    pw.TextDirection direction;

    if (forceRTL) {
      direction = pw.TextDirection.rtl;
    } else if (forceLTR) {
      direction = pw.TextDirection.ltr;
    } else {
      direction = _isArabicText(text)
          ? pw.TextDirection.rtl
          : pw.TextDirection.ltr;
    }

    return pw.Directionality(
      textDirection: direction,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? pw.FontWeight.bold : null,
        ),
        textAlign: textAlign,
      ),
    );
  }

  /// Build header with logo and voucher type
  static pw.Widget _buildHeader({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required pw.ImageProvider logoImage,
    required bool isArabic,
  }) {
    String voucherTypeText;
    if (voucher.type == AppConstants.voucherTypeReceipt) {
      voucherTypeText = 'receipt_voucher'.tr;
    } else if (voucher.type == AppConstants.voucherTypePayment) {
      voucherTypeText = 'payment_voucher'.tr;
    } else {
      voucherTypeText = 'receipt_voucher'.tr;
    }

    return pw.Column(
      children: [
        // Logo
        pw.Center(child: pw.Image(logoImage, width: 120, height: 120)),
        pw.SizedBox(height: 12),
        // Voucher type header
        pw.Container(
          width: double.infinity,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey900,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: _buildText(
            voucherTypeText,
            font: arabicFont,
            fontSize: titleFontSize,
            bold: true,
            color: PdfColors.white,
            forceRTL: isArabic,
          ),
        ),
      ],
    );
  }

  /// Build voucher information row
  static pw.Widget _buildVoucherInfo({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    final leftColumn = _buildText(
      '${'customer_name'.tr}: ${voucher.customerVendorName}',
      font: arabicFont,
      fontSize: headerFontSize,
      bold: true,
      forceRTL: isArabic,
    );
    final sizedBox = pw.SizedBox(width: 10);
    final rightColumn = _buildText(
      '${'voucher_number'.tr}: ${voucher.voucherNumber ?? voucher.id.toString()}',
      font: arabicFont,
      fontSize: headerFontSize,
      forceRTL: isArabic,
    );

    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: isArabic
            ? [rightColumn, sizedBox, leftColumn]
            : [leftColumn, sizedBox, rightColumn],
      ),
    );
  }

  /// Build amount section
  static pw.Widget _buildAmountSection({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey800, width: 2),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Row(
          crossAxisAlignment: isArabic
              ? pw.CrossAxisAlignment.end
              : pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildText(
              '${'amount'.tr}:',
              font: arabicFont,
              fontSize: headerFontSize,
              forceRTL: isArabic,
            ),
            pw.SizedBox(height: 8),
            _buildText(
              '${voucher.amount.toStringAsFixed(2)} ${'currency'.tr}',
              font: arabicFont,
              fontSize: titleFontSize,
              bold: true,
              color: voucher.type == AppConstants.voucherTypeReceipt
                  ? PdfColors.green700
                  : PdfColors.red700,
              forceRTL: isArabic,
            ),
          ],
        ),
      ),
    );
  }

  /// Build notes section
  static pw.Widget _buildNotesSection({
    required VoucherResponseModel voucher,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: isArabic
              ? pw.CrossAxisAlignment.start
              : pw.CrossAxisAlignment.end,
          children: [
            _buildText(
              '${'notes'.tr}:',
              font: arabicFont,
              fontSize: headerFontSize,
              bold: true,
              forceRTL: isArabic,
            ),
            pw.SizedBox(height: 8),
            _buildText(
              voucher.notes,
              font: arabicFont,
              fontSize: bodyFontSize,
              forceRTL: isArabic,
            ),
          ],
        ),
      ),
    );
  }

  /// Build footer with agent and date
  static pw.Widget _buildFooter({
    required VoucherResponseModel voucher,
    String? agentName,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    String formattedDate = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(voucher.voucherDate);

    // Get agent name from cache if not provided
    final storage = Get.find<StorageService>();
    final agent = storage.getAgent();
    String displayAgentName =
        agentName ?? agent?.name ?? 'agent_name_unavailable'.tr;

    final agentText = _buildText(
      '${'agent'.tr}: $displayAgentName',
      font: arabicFont,
      fontSize: bodyFontSize,
      forceRTL: isArabic,
    );

    final dateText = _buildText(
      '${'date'.tr}: $formattedDate',
      font: arabicFont,
      fontSize: bodyFontSize,
      forceRTL: isArabic,
    );

    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: isArabic ? [dateText, agentText] : [agentText, dateText],
        ),
      ],
    );
  }
}
