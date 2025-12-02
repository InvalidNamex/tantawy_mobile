import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/models/invoice_model.dart';
import '../data/models/invoice_detail_model.dart';
import '../theme/app_colors_extension.dart';
import '../utils/constants.dart';
import '../services/print_invoice_service.dart';
import '../services/share_invoice_service.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

/// Reusable invoice card widget for displaying invoice information
class InvoiceCardWidget extends StatelessWidget {
  final InvoiceResponseModel invoice;
  final String Function(int) getStatusText;
  final String Function(int) getPaymentTypeText;
  final VoidCallback? onTap;

  const InvoiceCardWidget({
    Key? key,
    required this.invoice,
    required this.getStatusText,
    required this.getPaymentTypeText,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              _buildDateAndNumber(),
              SizedBox(height: 8),
              _buildTotalAndPayment(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Color statusColor;
    if (invoice.status == AppConstants.statusPaid) {
      statusColor = Colors.green;
    } else if (invoice.status == AppConstants.statusUnpaid) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            invoice.customerVendorName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.print, color: context.colors.primary),
              onPressed: () => _printInvoice(context),
              tooltip: 'print'.tr,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.share, color: context.colors.primary),
              onPressed: () => _shareInvoice(context),
              tooltip: 'share'.tr,
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                getStatusText(invoice.status),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _printInvoice(BuildContext context) async {
    try {
      logger.d('🖨️ Print button clicked for invoice ${invoice.id}');

      // Convert InvoiceDetailResponse to InvoiceDetailModel for printing
      List<InvoiceDetailModel> details = [];
      if (invoice.invoiceDetails != null &&
          invoice.invoiceDetails!.isNotEmpty) {
        details = invoice.invoiceDetails!.map((detail) {
          // Calculate total per item (quantity * price)
          // Since price is not in the response, we'll use netTotal / total quantity as approximation
          double itemTotal = invoice.netTotal / invoice.invoiceDetails!.length;

          return InvoiceDetailModel(
            itemName: detail.itemName,
            quantity: detail.itemQuantity,
            price: 0.0, // Price not provided in API
            discount: 0.0,
            vat: 0.0,
            total: itemTotal,
          );
        }).toList();
        logger.d('✅ Converted ${details.length} invoice details');
      } else {
        logger.d('⚠️ No invoice details available');
      }

      await PrintInvoiceService.printInvoice(
        invoice: invoice,
        invoiceDetails: details,
        agentName: Get.find<StorageService>().getAgent()?.name,
      );

      logger.d('✅ Print completed successfully');
      // Close loading dialog
      Get.back();
    } catch (e, stackTrace) {
      logger.e('❌ Error printing invoice: $e');
      logger.e('Stack trace: $stackTrace');

      // Show detailed error message
      Get.snackbar(
        'error'.tr,
        '${e.toString()}',
        snackPosition: SnackPosition.bottom,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        isDismissible: true,
      );
    }
  }

  void _shareInvoice(BuildContext context) async {
    try {
      logger.d('📤 Share button clicked for invoice ${invoice.id}');

      // Convert InvoiceDetailResponse to InvoiceDetailModel for sharing
      List<InvoiceDetailModel> details = [];
      if (invoice.invoiceDetails != null &&
          invoice.invoiceDetails!.isNotEmpty) {
        details = invoice.invoiceDetails!.map((detail) {
          // Calculate total per item (quantity * price)
          // Since price is not in the response, we'll use netTotal / total quantity as approximation
          double itemTotal = invoice.netTotal / invoice.invoiceDetails!.length;

          return InvoiceDetailModel(
            itemName: detail.itemName,
            quantity: detail.itemQuantity,
            price: 0.0, // Price not provided in API
            discount: 0.0,
            vat: 0.0,
            total: itemTotal,
          );
        }).toList();
        logger.d('✅ Converted ${details.length} invoice details');
      } else {
        logger.d('⚠️ No invoice details available');
      }

      await ShareInvoiceService.shareInvoice(
        invoice: invoice,
        invoiceDetails: details,
        agentName: Get.find<StorageService>().getAgent()?.name,
      );

      logger.d('✅ Share completed successfully');
    } catch (e, stackTrace) {
      logger.e('❌ Error sharing invoice: $e');
      logger.e('Stack trace: $stackTrace');

      // Show detailed error message
      Get.snackbar(
        'error'.tr,
        '${e.toString()}',
        snackPosition: SnackPosition.bottom,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        isDismissible: true,
      );
    }
  }

  Widget _buildDateAndNumber() {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        SizedBox(width: 8),
        Text(
          DateFormat('yyyy-MM-dd').format(invoice.invoiceDate),
          style: TextStyle(color: Colors.grey[600]),
        ),
        if (invoice.invoiceNumber != null) ...[
          SizedBox(width: 16),
          Icon(Icons.tag, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            invoice.invoiceNumber!,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildTotalAndPayment(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'total'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${invoice.netTotal.toStringAsFixed(2)} ${'currency'.tr}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              getPaymentTypeText(invoice.paymentType),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (invoice.totalPaid > 0)
              Text(
                '${'paid'.tr}: ${invoice.totalPaid.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
