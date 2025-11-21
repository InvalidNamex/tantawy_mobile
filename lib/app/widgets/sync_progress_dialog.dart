import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Sync progress dialog widget
/// Shows real-time progress of data synchronization with progress bar and status updates
class SyncProgressDialog extends StatelessWidget {
  final RxDouble progress;
  final RxString status;
  final int invoiceCount;
  final int voucherCount;
  final int visitCount;

  const SyncProgressDialog({
    Key? key,
    required this.progress,
    required this.status,
    required this.invoiceCount,
    required this.voucherCount,
    required this.visitCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissal
      child: Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                'syncing_data'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Obx(
                () => Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress.value,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${(progress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (invoiceCount > 0) _buildSyncItem('invoices'.tr, invoiceCount),
              if (voucherCount > 0) _buildSyncItem('vouchers'.tr, voucherCount),
              if (visitCount > 0)
                _buildSyncItem('negative_visits'.tr, visitCount),
              SizedBox(height: 16),
              Obx(
                () => Text(
                  status.value,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncItem(String label, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$count ${count == 1 ? 'item'.tr : 'items'.tr}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
