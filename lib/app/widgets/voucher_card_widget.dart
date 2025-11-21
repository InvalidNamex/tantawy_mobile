import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/models/voucher_model.dart';
import '../services/print_voucher_service.dart';
import '../utils/logger.dart';

/// Reusable voucher card widget for displaying voucher information
class VoucherCardWidget extends StatelessWidget {
  final VoucherResponseModel voucher;
  final String Function(int) getVoucherTypeText;
  final VoidCallback? onTap;

  const VoucherCardWidget({
    Key? key,
    required this.voucher,
    required this.getVoucherTypeText,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReceipt = voucher.type == 1;

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
              // Header with voucher number and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    voucher.voucherNumber ?? 'n_a'.tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.print,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => _printVoucher(context),
                        tooltip: 'print'.tr,
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isReceipt
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getVoucherTypeText(voucher.type),
                          style: TextStyle(
                            color: isReceipt
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              // Customer name
              Text(voucher.customerVendorName, style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              // Date
              Text(
                DateFormat('yyyy-MM-dd').format(voucher.voucherDate),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              // Notes
              if (voucher.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    voucher.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(height: 8),
              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        voucher.amount.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isReceipt
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                      Text(
                        'currency'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _printVoucher(BuildContext context) async {
    try {
      logger.d('🖨️ Print button clicked for voucher ${voucher.id}');

      await PrintVoucherService.printVoucher(
        voucher: voucher,
        agentName: null, // Can be passed from the parent if available
      );

      logger.d('✅ Print completed successfully');
    } catch (e, stackTrace) {
      logger.e('❌ Error printing voucher: $e');
      logger.e('Stack trace: $stackTrace');

      // Show detailed error message
      Get.snackbar(
        'error'.tr,
        'print_error'.tr,
        snackPosition: SnackPosition.bottom,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        isDismissible: true,
      );
    }
  }
}
