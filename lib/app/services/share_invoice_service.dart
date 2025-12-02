import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/invoice_model.dart';
import '../data/models/invoice_detail_model.dart';
import '../data/models/item_model.dart';
import '../services/connectivity_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ShareInvoiceService {
  static const double bodyFontSize = 18;
  static const double headerFontSize = 20;
  static const double titleFontSize = 24;

  /// Check if the text contains Arabic characters
  static bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Format quantity with multiple units (main, sub, small)
  static String _formatQuantity(double rawQty, ItemModel? itemDetails) {
    if (itemDetails == null) {
      return rawQty.toStringAsFixed(2);
    }

    double mainUnitPack = itemDetails.mainUnitPack ?? 1.0;
    double subUnitPack = itemDetails.subUnitPack ?? 1.0;

    String mainUnitName = itemDetails.mainUnitName ?? 'Unit';
    String subUnitName = itemDetails.subUnitName ?? 'Sub';
    String smallUnitName = itemDetails.smallUnitName ?? 'Small';

    int mainUnits = rawQty.floor();
    double remainingAfterMain = rawQty - mainUnits;

    // Calculate sub units without rounding first to preserve precision
    double subUnitsDecimal = remainingAfterMain * mainUnitPack;
    int subUnits = subUnitsDecimal.floor();

    // Calculate remaining after sub units
    double remainingAfterSub = subUnitsDecimal - subUnits;
    int smallUnits = (remainingAfterSub * subUnitPack).round();

    StringBuffer formattedQty = StringBuffer();
    if (mainUnits > 0) {
      formattedQty.write('$mainUnits $mainUnitName');
    }
    if (subUnits > 0) {
      if (formattedQty.isNotEmpty) formattedQty.write('\n');
      formattedQty.write('$subUnits $subUnitName');
    }
    if (smallUnits > 0) {
      if (formattedQty.isNotEmpty) formattedQty.write('\n');
      formattedQty.write('$smallUnits $smallUnitName');
    }

    if (formattedQty.isEmpty) {
      return rawQty.toStringAsFixed(2);
    }
    return formattedQty.toString();
  }

  /// Share an invoice as PDF
  static Future<void> shareInvoice({
    required InvoiceResponseModel invoice,
    List<InvoiceDetailModel>? invoiceDetails,
    String? agentName,
  }) async {
    try {
      logger.d('📤 Starting share invoice process');
      logger.d('📄 Invoice ID: ${invoice.id}');
      logger.d('👤 Customer: ${invoice.customerVendorName}');
      logger.d('📦 Invoice details count: ${invoiceDetails?.length ?? 0}');

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
        invoice: invoice,
        invoiceDetails: invoiceDetails ?? [],
        agentName: agentName,
      );
      logger.d('✅ Document generated successfully');

      // Save PDF to temporary file
      final bytes = await doc.save();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'invoice_${invoice.invoiceNumber ?? invoice.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      logger.d('💾 PDF saved to: ${file.path}');

      // Share the file
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'invoice'.tr + ' ${invoice.invoiceNumber ?? invoice.id}',
        text:
            '${'invoice'.tr} ${invoice.customerVendorName} - ${invoice.netTotal.toStringAsFixed(2)} ${'currency'.tr}',
      );

      logger.d('✅ Share completed with result: ${result.status}');
    } catch (e, stackTrace) {
      logger.e('❌ Error in shareInvoice: $e');
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
    required InvoiceResponseModel invoice,
    required List<InvoiceDetailModel> invoiceDetails,
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
                invoice: invoice,
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
                _buildInvoiceInfo(
                  invoice: invoice,
                  arabicFont: arabicFont,
                  isArabic: isArabic,
                ),
                pw.SizedBox(height: 20),
                _buildItemsTable(
                  invoiceDetails: invoiceDetails,
                  arabicFont: arabicFont,
                  isArabic: isArabic,
                ),
                pw.SizedBox(height: 20),
                _buildTotals(
                  invoice: invoice,
                  invoiceDetails: invoiceDetails,
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
                invoice: invoice,
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
    required InvoiceResponseModel invoice,
    required pw.Font arabicFont,
    required pw.ImageProvider logoImage,
    required bool isArabic,
  }) {
    String title = isArabic ? 'فاتورة' : 'Invoice';
    if (invoice.invoiceType == AppConstants.invoiceTypeReturnSales) {
      title = isArabic ? 'فاتورة مرتجع' : 'Return Invoice';
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
                  color: PdfColors.blue700,
                ),
                pw.SizedBox(height: 4),
                _buildText(
                  invoice.invoiceNumber ?? 'N/A',
                  font: arabicFont,
                  fontSize: headerFontSize,
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 2, color: PdfColors.blue700),
      ],
    );
  }

  /// Build invoice info section
  static pw.Widget _buildInvoiceInfo({
    required InvoiceResponseModel invoice,
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
            value: invoice.customerVendorName,
            arabicFont: arabicFont,
            isArabic: isArabic,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            label: isArabic ? 'التاريخ:' : 'Date:',
            value: DateFormat('yyyy-MM-dd').format(invoice.invoiceDate),
            arabicFont: arabicFont,
            isArabic: isArabic,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            label: isArabic ? 'نوع الدفع:' : 'Payment Type:',
            value: _getPaymentTypeText(invoice.paymentType, isArabic),
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

  /// Build items table
  static pw.Widget _buildItemsTable({
    required List<InvoiceDetailModel> invoiceDetails,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    if (invoiceDetails.isEmpty) {
      return pw.Container();
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell(isArabic ? '#' : '#', arabicFont, bold: true),
            _buildTableCell(
              isArabic ? 'الصنف' : 'Item',
              arabicFont,
              bold: true,
            ),
            _buildTableCell(
              isArabic ? 'الكمية' : 'Quantity',
              arabicFont,
              bold: true,
            ),
            _buildTableCell(
              isArabic ? 'السعر' : 'Price',
              arabicFont,
              bold: true,
            ),
            _buildTableCell(
              isArabic ? 'الإجمالي' : 'Total',
              arabicFont,
              bold: true,
            ),
          ],
        ),
        // Data rows
        ...invoiceDetails.asMap().entries.map((entry) {
          final index = entry.key;
          final detail = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('${index + 1}', arabicFont),
              _buildTableCell(detail.itemName, arabicFont),
              _buildTableCell(
                _formatQuantity(detail.quantity, null),
                arabicFont,
              ),
              _buildTableCell(detail.price.toStringAsFixed(2), arabicFont),
              _buildTableCell(detail.total.toStringAsFixed(2), arabicFont),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: _buildText(text, font: font, fontSize: bodyFontSize, bold: bold),
    );
  }

  /// Build totals section
  static pw.Widget _buildTotals({
    required InvoiceResponseModel invoice,
    required List<InvoiceDetailModel> invoiceDetails,
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
        children: [
          _buildTotalRow(
            label: isArabic ? 'الإجمالي الصافي:' : 'Net Total:',
            value: invoice.netTotal.toStringAsFixed(2),
            arabicFont: arabicFont,
            isArabic: isArabic,
            bold: true,
          ),
          if (invoice.totalPaid > 0) ...[
            pw.SizedBox(height: 8),
            _buildTotalRow(
              label: isArabic ? 'المدفوع:' : 'Paid:',
              value: invoice.totalPaid.toStringAsFixed(2),
              arabicFont: arabicFont,
              isArabic: isArabic,
            ),
          ],
        ],
      ),
    );
  }

  /// Build total row
  static pw.Widget _buildTotalRow({
    required String label,
    required String value,
    required pw.Font arabicFont,
    required bool isArabic,
    bool bold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildText(
          label,
          font: arabicFont,
          fontSize: headerFontSize,
          bold: bold,
        ),
        _buildText(
          value,
          font: arabicFont,
          fontSize: headerFontSize,
          bold: bold,
          color: PdfColors.blue700,
        ),
      ],
    );
  }

  /// Build footer section
  static pw.Widget _buildFooter({
    required InvoiceResponseModel invoice,
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

  /// Get payment type text
  static String _getPaymentTypeText(int paymentType, bool isArabic) {
    switch (paymentType) {
      case AppConstants.paymentTypeCash:
        return isArabic ? 'نقدي' : 'Cash';
      case AppConstants.paymentTypeDeferred:
        return isArabic ? 'آجل' : 'Credit';
      default:
        return isArabic ? 'غير محدد' : 'Unknown';
    }
  }
}
