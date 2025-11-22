import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../widgets/app_background.dart';
import '../controllers/items_stock_controller.dart';

class ItemsStockView extends GetView<ItemsStockController> {
  const ItemsStockView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('items_stock'.tr),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (controller.stockList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: context.colors.onSurface.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'no_stock_data'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      color: context.colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshStock,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          context.colors.primary.withOpacity(0.1),
                        ),
                        border: TableBorder.all(
                          color: context.colors.divider,
                          width: 1,
                        ),
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'item_name'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'stock'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onSurface,
                                fontSize: 16,
                              ),
                            ),
                            numeric: true,
                          ),
                        ],
                        rows: controller.stockList.map((item) {
                          final isNegative = item.stock < 0;
                          final stockColor = isNegative
                              ? context.colors.error
                              : context.colors.onSurface;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  item.itemName,
                                  style: TextStyle(
                                    color: context.colors.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  item.stock.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: stockColor,
                                    fontSize: 14,
                                    fontWeight: isNegative
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
