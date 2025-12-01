import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/invoice_model.dart';
import '../data/models/invoice_detail_model.dart';
import '../data/models/item_model.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class PrintInvoiceService {
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

  /// Print an invoice
  static Future<void> printInvoice({
    required InvoiceResponseModel invoice,
    List<InvoiceDetailModel>? invoiceDetails,
    String? agentName,
  }) async {
    try {
      logger.d('🖨️ Starting print invoice process');
      logger.d('📄 Invoice ID: ${invoice.id}');
      logger.d('👤 Customer: ${invoice.customerVendorName}');
      logger.d('📦 Invoice details count: ${invoiceDetails?.length ?? 0}');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          logger.d('📐 PDF format: ${format.width}x${format.height}');
          try {
            final doc = await _generateDocument(
              invoice: invoice,
              invoiceDetails: invoiceDetails ?? [],
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
      logger.e('❌ Error in printInvoice: $e');
      logger.e('Stack trace: $stackTrace');
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

  /// Build header with logo and invoice type
  static pw.Widget _buildHeader({
    required InvoiceResponseModel invoice,
    required pw.Font arabicFont,
    required pw.ImageProvider logoImage,
    required bool isArabic,
  }) {
    String invoiceTypeText;
    if (invoice.invoiceType == AppConstants.invoiceTypeSales) {
      invoiceTypeText = 'invoice'.tr;
    } else if (invoice.invoiceType == AppConstants.invoiceTypeReturnSales) {
      invoiceTypeText = 'return_invoice'.tr;
    } else {
      invoiceTypeText = 'invoice'.tr;
    }

    return pw.Column(
      children: [
        // Logo
        pw.Center(child: pw.Image(logoImage, width: 120, height: 120)),
        pw.SizedBox(height: 12),
        // Invoice type header
        pw.Container(
          width: double.infinity,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey900,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: _buildText(
            invoiceTypeText,
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

  /// Build invoice information row
  static pw.Widget _buildInvoiceInfo({
    required InvoiceResponseModel invoice,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    final leftColumn = _buildText(
      '${'customer_name'.tr}: ${invoice.customerVendorName}',
      font: arabicFont,
      fontSize: headerFontSize,
      bold: true,
      forceRTL: isArabic,
    );
    final sizedBox = pw.SizedBox(width: 10);
    final rightColumn = _buildText(
      '${'invoice_number'.tr}: ${invoice.invoiceNumber ?? invoice.id.toString()}',
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

  /// Build items table
  static pw.Widget _buildItemsTable({
    required List<InvoiceDetailModel> invoiceDetails,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    // If no details provided, show placeholder
    if (invoiceDetails.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: _buildText(
          'no_items_available'.tr,
          font: arabicFont,
          fontSize: bodyFontSize,
          forceRTL: isArabic,
        ),
      );
    }

    // Get items from storage for unit information
    List<ItemModel> items = [];
    try {
      final storageService = Get.find<StorageService>();
      items = storageService.getItems();
      logger.d('📦 Retrieved ${items.length} items from storage');
    } catch (e) {
      logger.w('⚠️ Could not retrieve items from storage: $e');
    }

    List<pw.Widget> headers = [
      _buildText('item'.tr, font: arabicFont, bold: true, forceRTL: isArabic),
      _buildText(
        'quantity'.tr,
        font: arabicFont,
        bold: true,
        forceRTL: isArabic,
      ),
      _buildText('total'.tr, font: arabicFont, bold: true, forceRTL: isArabic),
    ];

    if (isArabic) {
      headers = headers.reversed.toList();
    }

    final List<List<pw.Widget>> data = invoiceDetails.map((item) {
      // Find matching ItemModel for unit information
      ItemModel? itemModel = items.firstWhereOrNull(
        (x) => x.itemName == item.itemName,
      );

      // Format quantity with units
      String formattedQty = _formatQuantity(item.quantity, itemModel);

      List<pw.Widget> row = [
        _buildText(
          item.itemName,
          font: arabicFont,
          fontSize: bodyFontSize,
          forceRTL: isArabic,
        ),
        _buildText(
          formattedQty,
          font: arabicFont,
          fontSize: bodyFontSize,
          forceRTL: isArabic,
        ),
        pw.Text(
          item.total.toStringAsFixed(2),
          style: pw.TextStyle(
            font: arabicFont,
            fontSize: bodyFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ];

      return isArabic ? row.reversed.toList() : row;
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey),
      headerStyle: pw.TextStyle(
        font: arabicFont,
        fontWeight: pw.FontWeight.bold,
        fontSize: headerFontSize,
      ),
      cellStyle: pw.TextStyle(font: arabicFont, fontSize: bodyFontSize),
      cellAlignment: isArabic
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      columnWidths: isArabic
          ? {
              0: pw.FlexColumnWidth(1), // Total
              1: pw.FlexColumnWidth(1.5), // Quantity
              2: pw.FlexColumnWidth(3), // Item
            }
          : {
              0: pw.FlexColumnWidth(3), // Item
              1: pw.FlexColumnWidth(1.5), // Quantity
              2: pw.FlexColumnWidth(1), // Total
            },
    );
  }

  /// Build totals section
  static pw.Widget _buildTotals({
    required InvoiceResponseModel invoice,
    required List<InvoiceDetailModel> invoiceDetails,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    // Use the actual discount and tax from invoice instead of calculating from details
    double totalDiscount = invoice.discountAmount;
    double totalTax = invoice.taxAmount;

    return pw.Directionality(
      textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Container(
        alignment: isArabic
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft,
        child: pw.Column(
          crossAxisAlignment: !isArabic
              ? pw.CrossAxisAlignment.end
              : pw.CrossAxisAlignment.start,
          children: [
            if (totalDiscount > 0)
              _buildText(
                '${'discount'.tr}: ${totalDiscount.toStringAsFixed(2)}',
                font: arabicFont,
                fontSize: headerFontSize,
                forceRTL: isArabic,
              ),
            pw.SizedBox(height: 4),
            if (totalTax > 0)
              _buildText(
                '${'tax'.tr}: ${totalTax.toStringAsFixed(2)}',
                font: arabicFont,
                fontSize: headerFontSize,
                forceRTL: isArabic,
              ),
            pw.SizedBox(height: 4),
            _buildText(
              '${'net_total'.tr}: ${invoice.netTotal.toStringAsFixed(2)}',
              font: arabicFont,
              fontSize: headerFontSize,
              bold: true,
              forceRTL: isArabic,
            ),
            pw.Divider(thickness: 2),
            // Add notes if available
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              _buildText(
                '${'notes'.tr}: ${invoice.notes}',
                font: arabicFont,
                fontSize: bodyFontSize,
                forceRTL: isArabic,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build footer with agent and date
  static pw.Widget _buildFooter({
    required InvoiceResponseModel invoice,
    String? agentName,
    required pw.Font arabicFont,
    required bool isArabic,
  }) {
    String formattedDate = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(invoice.invoiceDate);

    // Use storeName from invoice if agentName not provided
    String displayAgentName =
        agentName ?? invoice.storeName ?? 'agent_name_unavailable'.tr;

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
