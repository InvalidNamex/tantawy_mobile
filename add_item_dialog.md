import 'package:agent/controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '/controllers/home_controller.dart';
import '/helpers/toast.dart';
import '../constants.dart';
import '../controllers/directSOController.dart';
import '../controllers/sales_controller.dart';
import '../helpers/max_value_formatter.dart';
import '../models/api/api_invoice_item.dart';
import '../models/invoice_item_model.dart';
import '../models/item_model.dart';

void itemQtyPopUp(
  ItemModel item,
  SalesController controller,
  bool isSO, {
  required double? reserved,
  bool? isReturn = false,
}) {
  RxDouble itemTotalPrice = 0.0.obs;
  RxDouble itemTotalDiscount = 0.0.obs;
  RxDouble itemTotalTax = 0.0.obs;
  final sController = Get.find<SOController>();
  ItemModel? sItem = sController.customerItemsList.firstWhereOrNull(
    (sItem) => sItem.id == item.id,
  );
  Logger().i(sItem?.id.toString());
  //not the best way but in case of return ignore store check
  double stock =
      isReturn == true
          ? 999999999
          : (isSO ? sItem?.qtyBalance ?? 0 : item.qtyBalance ?? 0);
  double stockAfterReserved =
      isSO
          ? ((sItem?.qtyBalance ?? 0) - (reserved ?? 0))
          : item.qtyBalance ?? 0;
  controller.mainQty.text = '1';
  controller.subQty.text = '';
  controller.smallQty.text = '';
  String getProcessedValue(String value) {
    return value.replaceFirst(RegExp(r'^0+'), '');
  }

  calculatePrice() {
    double mainQty = double.parse(
      controller.mainQty.text.isEmpty ? '0' : controller.mainQty.text,
    );

    // Safe division with null checks to prevent NaN
    double subQty = 0.0;
    if (controller.subQty.text.isNotEmpty && (item.mainUnitPack ?? 0) > 0) {
      subQty = double.parse(controller.subQty.text) / item.mainUnitPack!;
    }

    double smallQty = 0.0;
    if (controller.smallQty.text.isNotEmpty &&
        (item.subUnitPack ?? 0) > 0 &&
        (item.mainUnitPack ?? 0) > 0) {
      smallQty =
          double.parse(controller.smallQty.text) /
          item.subUnitPack! /
          item.mainUnitPack!;
    }

    double totalQty = mainQty + subQty + smallQty;
    double calculatedPrice = totalQty * (item.price ?? 0);

    itemTotalPrice(calculatedPrice.isNaN ? 0.0 : calculatedPrice);

    double discountValue =
        itemTotalPrice.value * (item.disc != null ? (item.disc! / 100) : 0);
    itemTotalDiscount(discountValue.isNaN ? 0.0 : discountValue);

    double taxValue =
        (itemTotalPrice.value - itemTotalDiscount.value) *
        (item.vat != null ? (item.vat! / 100) : 0);
    itemTotalTax(taxValue.isNaN ? 0.0 : taxValue);
  }

  calculatePrice();
  final itemQuantityFormKey = GlobalKey<FormState>();

  if (Get.height < 750 && !kIsWeb) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        height: Get.height * 0.5,
        child: SingleChildScrollView(
          child: Form(
            key: itemQuantityFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.itemName ?? '',
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                ),
                Card(
                  child: ListTile(
                    leading: Text(item.mainUnit ?? 'Main Unit'.tr),
                    title: TextFormField(
                      onTap: () {
                        controller.mainQty.clear();
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final x = getProcessedValue(value);
                          controller.mainQty.text = x;
                        } else {
                          controller.mainQty.text = 0.toString();
                        }
                        calculatePrice();
                      },
                      textAlign: TextAlign.center,
                      controller: controller.mainQty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                        ), // Prevents negative values, zero, and allows only positive numbers with decimals
                        LengthLimitingTextInputFormatter(
                          6,
                        ), // Maximum 6 digits for quantity
                      ],
                      autofocus: true,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ), // Change the border color when focused
                        ),
                      ),
                    ),
                  ),
                ),
                item.subUnit.isBlank!
                    ? const SizedBox()
                    : Card(
                      child: ListTile(
                        leading: Text(item.subUnit ?? 'Sub Unit'.tr),
                        title: TextFormField(
                          onTap: () {
                            controller.subQty.clear();
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final x = getProcessedValue(value);
                              controller.subQty.text = x;
                            } else {
                              controller.subQty.text = 0.toString();
                            }
                            calculatePrice();
                          },
                          textAlign: TextAlign.center,
                          controller: controller.subQty,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                            ), // Prevents negative values, zero, and allows only positive numbers with decimals
                            LengthLimitingTextInputFormatter(
                              6,
                            ), // Maximum 6 digits for quantity
                            MaxValueInputFormatter(
                              item.mainUnitPack ?? 1,
                            ), // Custom formatter to limit the value
                          ],
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ), // Change the border color when focused
                            ),
                          ),
                        ),
                        trailing: Text(item.mainUnitPack.toString()),
                      ),
                    ),
                item.smallUnit.isBlank!
                    ? const SizedBox()
                    : Card(
                      child: ListTile(
                        leading: Text(item.smallUnit ?? 'Small Unit'.tr),
                        title: TextFormField(
                          onTap: () {
                            controller.smallQty.clear();
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final x = getProcessedValue(value);
                              controller.smallQty.text = x;
                            } else {
                              controller.smallQty.text = 0.toString();
                            }
                            calculatePrice();
                          },
                          textAlign: TextAlign.center,
                          controller: controller.smallQty,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                            ), // Prevents negative values, zero, and allows only positive numbers with decimals
                            LengthLimitingTextInputFormatter(
                              6,
                            ), // Maximum 6 digits for quantity
                            MaxValueInputFormatter(
                              item.subUnitPack ?? 1,
                            ), // Custom formatter to limit the value
                          ],
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ), // Change the border color when focused
                            ),
                          ),
                        ),
                        trailing: Text(item.subUnitPack.toString()),
                      ),
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total: '.tr,
                              style: const TextStyle(
                                color: darkColor,
                                fontSize: 16,
                              ),
                            ),
                            Obx(
                              () => Text(
                                (itemTotalPrice).toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Discount: '.tr,
                              style: const TextStyle(
                                color: darkColor,
                                fontSize: 16,
                              ),
                            ),
                            Obx(
                              () => Text(
                                (itemTotalDiscount).toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Tax: '.tr,
                              style: const TextStyle(
                                color: darkColor,
                                fontSize: 16,
                              ),
                            ),
                            Obx(
                              () => Text(
                                (itemTotalTax).toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 1,
                      height: 60,
                      child: VerticalDivider(
                        thickness: 1,
                        color: darkColor,
                        width: 1,
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Price: '.tr,
                              style: const TextStyle(
                                color: darkColor,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              (item.price ?? 0).toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        isReturn == true
                            ? SizedBox()
                            : Row(
                              children: [
                                Text(
                                  'Stock: '.tr,
                                  style: const TextStyle(
                                    color: darkColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  stock.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: Get.width,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      InvoiceItemModel invItemModel = InvoiceItemModel(
                        mainQty: double.tryParse(controller.mainQty.text),
                        subQty: double.tryParse(controller.subQty.text),
                        smallQty: double.tryParse(controller.smallQty.text),
                        itemName: item.itemName,
                        quantity:
                            '${controller.mainQty.text.isEmpty ? '' : '${item.mainUnit}: ${controller.mainQty.text}'}${controller.subQty.text.isEmpty ? '' : '\n${item.subUnit}: ${controller.subQty.text}'}${controller.smallQty.text.isEmpty ? '' : '\n${item.smallUnit}: ${controller.smallQty.text}'}',
                        price: double.parse(
                          (item.price ?? 0).toStringAsFixed(2),
                        ),
                        discount: double.parse(
                          itemTotalDiscount.value.toStringAsFixed(2),
                        ),
                        tax: double.parse(
                          itemTotalTax.value.toStringAsFixed(2),
                        ),
                        total:
                            ((itemTotalPrice.value - itemTotalDiscount.value) +
                                itemTotalTax.value),
                      ); //implement tax check feature here
                      final homeController = Get.find<HomeController>();
                      // Safe quantity calculation to prevent NaN
                      double mainQuantity =
                          (controller.mainQty.text != '0' &&
                                  controller.mainQty.text.isNotEmpty)
                              ? double.tryParse(controller.mainQty.text) ?? 0.0
                              : 0.0;

                      double subQuantity = 0.0;
                      if (controller.subQty.text != '0' &&
                          controller.subQty.text.isNotEmpty &&
                          (item.mainUnitPack ?? 0) > 0) {
                        subQuantity =
                            (double.tryParse(controller.subQty.text) ?? 0.0) /
                            item.mainUnitPack!;
                      }

                      double smallQuantity = 0.0;
                      if (controller.smallQty.text != '0' &&
                          controller.smallQty.text.isNotEmpty &&
                          (item.subUnitPack ?? 0) > 0 &&
                          (item.mainUnitPack ?? 0) > 0) {
                        smallQuantity =
                            ((double.tryParse(controller.smallQty.text) ??
                                    0.0) /
                                item.subUnitPack!) /
                            item.mainUnitPack!;
                      }

                      double totalQuantity =
                          mainQuantity + subQuantity + smallQuantity;
                      final authController = Get.find<AuthController>();
                      bool shouldCheck =
                          authController.sysInfoModel?.salesOrderNoQty == '0'
                              ? false
                              : true;
                      bool stockCheck =
                          shouldCheck
                              ? true
                              : isSO
                              ? totalQuantity <= stockAfterReserved
                              : totalQuantity <= stock;
                      bool check =
                          homeController
                              .addTaxableAndNonTaxableProductsInSales();
                      if (stockCheck) {
                        if (check) {
                          addItemToListFunction(
                            controller: controller,
                            invItemModel: invItemModel,
                            item: item,
                          );
                        } else {
                          //check if newly added item has tax and compare it to first item
                          if (controller.invoiceItemsList.isNotEmpty) {
                            bool firstItemTaxState =
                                controller.isFirstItemTaxed.value;
                            bool currentItemTaxState =
                                (item.vat ?? 0) > 0 ? true : false;
                            if (firstItemTaxState == currentItemTaxState) {
                              addItemToListFunction(
                                controller: controller,
                                invItemModel: invItemModel,
                                item: item,
                              );
                            } else {
                              Get.back();

                              // Show warning dialog
                              Get.dialog(
                                WillPopScope(
                                  onWillPop: () async => false,
                                  child: AlertDialog(
                                    title: Text('Warning'.tr),
                                    content: Text(
                                      'Cannot add taxed and non taxed items  in the same invoice'
                                          .tr,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text('OK'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                                barrierDismissible: false,
                              );
                            }
                          } else {
                            addItemToListFunction(
                              controller: controller,
                              invItemModel: invItemModel,
                              item: item,
                            );
                            (item.vat ?? 0) > 0
                                ? controller.isFirstItemTaxed(true)
                                : controller.isFirstItemTaxed(false);
                          }
                        }
                      } else {
                        Get.back();
                        AppToasts.errorToast('No stock available'.tr);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: darkColor),
                    child: Text(
                      'ADD'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: lightColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } else {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width:
                MediaQuery.of(Get.context!).size.width > 750
                    ? 700
                    : MediaQuery.of(Get.context!).size.width,
            child: SingleChildScrollView(
              child: Form(
                key: itemQuantityFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.itemName ?? '',
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    Card(
                      child: ListTile(
                        leading: Text(item.mainUnit ?? 'Main Unit'.tr),
                        title: TextFormField(
                          onTap: () {
                            controller.mainQty.clear();
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final x = getProcessedValue(value);
                              controller.mainQty.text = x;
                            } else {
                              controller.mainQty.text = 0.toString();
                            }
                            calculatePrice();
                          },
                          textAlign: TextAlign.center,
                          controller: controller.mainQty,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                            ), // Prevents negative values, zero, and allows only positive numbers with decimals
                            LengthLimitingTextInputFormatter(
                              6,
                            ), // Maximum 6 digits for quantity
                          ],
                          autofocus: true,
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ), // Change the border color when focused
                            ),
                          ),
                        ),
                      ),
                    ),
                    item.subUnit.isBlank!
                        ? const SizedBox()
                        : Card(
                          child: ListTile(
                            leading: Text(item.subUnit ?? 'Sub Unit'.tr),
                            title: TextFormField(
                              onTap: () {
                                controller.subQty.clear();
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final x = getProcessedValue(value);
                                  controller.subQty.text = x;
                                } else {
                                  controller.subQty.text = 0.toString();
                                }
                                calculatePrice();
                              },
                              textAlign: TextAlign.center,
                              controller: controller.subQty,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                                ), // Prevents negative values, zero, and allows only positive numbers with decimals
                                LengthLimitingTextInputFormatter(
                                  6,
                                ), // Maximum 6 digits for quantity
                                MaxValueInputFormatter(
                                  item.mainUnitPack ?? 1,
                                ), // Custom formatter to limit the value
                              ],
                              decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ), // Change the border color when focused
                                ),
                              ),
                            ),
                            trailing: Text(item.mainUnitPack.toString()),
                          ),
                        ),
                    item.smallUnit.isBlank!
                        ? const SizedBox()
                        : Card(
                          child: ListTile(
                            leading: Text(item.smallUnit ?? 'Small Unit'.tr),
                            title: TextFormField(
                              onTap: () {
                                controller.smallQty.clear();
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final x = getProcessedValue(value);
                                  controller.smallQty.text = x;
                                } else {
                                  controller.smallQty.text = 0.toString();
                                }
                                calculatePrice();
                              },
                              textAlign: TextAlign.center,
                              controller: controller.smallQty,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                                ), // Prevents negative values, zero, and allows only positive numbers with decimals
                                LengthLimitingTextInputFormatter(
                                  6,
                                ), // Maximum 6 digits for quantity
                                MaxValueInputFormatter(
                                  item.subUnitPack ?? 1,
                                ), // Custom formatter to limit the value
                              ],
                              decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ), // Change the border color when focused
                                ),
                              ),
                            ),
                            trailing: Text(item.subUnitPack.toString()),
                          ),
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total: '.tr,
                                  style: const TextStyle(
                                    color: darkColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    (itemTotalPrice).toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Discount: '.tr,
                                  style: const TextStyle(
                                    color: darkColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    (itemTotalDiscount).toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Tax: '.tr,
                                  style: const TextStyle(
                                    color: darkColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    (itemTotalTax).toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 1,
                          height: 60,
                          child: VerticalDivider(
                            thickness: 1,
                            color: darkColor,
                            width: 1,
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Price: '.tr,
                                  style: const TextStyle(
                                    color: darkColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  (item.price ?? 0).toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            isReturn == true
                                ? const SizedBox()
                                : Row(
                                  children: [
                                    Text(
                                      'Stock: '.tr,
                                      style: const TextStyle(
                                        color: darkColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      stock.toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                            isSO
                                ? Row(
                                  children: [
                                    Text(
                                      'Reserved: '.tr,
                                      style: const TextStyle(
                                        color: darkColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    //todo: display reserved
                                    Text(
                                      (reserved ?? 0).toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: Get.width,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          InvoiceItemModel invItemModel = InvoiceItemModel(
                            mainQty: double.tryParse(controller.mainQty.text),
                            subQty: double.tryParse(controller.subQty.text),
                            smallQty: double.tryParse(controller.smallQty.text),
                            itemName: item.itemName,
                            quantity:
                                '${controller.mainQty.text.isEmpty ? '' : '${item.mainUnit}: ${controller.mainQty.text}'}${controller.subQty.text.isEmpty ? '' : '\n${item.subUnit}: ${controller.subQty.text}'}${controller.smallQty.text.isEmpty ? '' : '\n${item.smallUnit}: ${controller.smallQty.text}'}',
                            price: double.parse(
                              (item.price ?? 0).toStringAsFixed(2),
                            ),
                            discount: double.parse(
                              itemTotalDiscount.value.toStringAsFixed(2),
                            ),
                            tax: double.parse(
                              itemTotalTax.value.toStringAsFixed(2),
                            ),
                            total:
                                ((itemTotalPrice.value -
                                        itemTotalDiscount.value) +
                                    itemTotalTax.value),
                          );
                          final homeController = Get.find<HomeController>();
                          // Safe quantity calculation to prevent NaN
                          double mainQuantity =
                              (controller.mainQty.text != '0' &&
                                      controller.mainQty.text.isNotEmpty)
                                  ? double.tryParse(controller.mainQty.text) ??
                                      0.0
                                  : 0.0;

                          double subQuantity = 0.0;
                          if (controller.subQty.text != '0' &&
                              controller.subQty.text.isNotEmpty &&
                              (item.mainUnitPack ?? 0) > 0) {
                            subQuantity =
                                (double.tryParse(controller.subQty.text) ??
                                    0.0) /
                                item.mainUnitPack!;
                          }

                          double smallQuantity = 0.0;
                          if (controller.smallQty.text != '0' &&
                              controller.smallQty.text.isNotEmpty &&
                              (item.subUnitPack ?? 0) > 0 &&
                              (item.mainUnitPack ?? 0) > 0) {
                            smallQuantity =
                                ((double.tryParse(controller.smallQty.text) ??
                                        0.0) /
                                    item.subUnitPack!) /
                                item.mainUnitPack!;
                          }

                          double totalQuantity =
                              mainQuantity + subQuantity + smallQuantity;
                          final authController = Get.find<AuthController>();
                          bool shouldCheck =
                              authController.sysInfoModel?.salesOrderNoQty ==
                                      '0'
                                  ? false
                                  : true;
                          bool stockCheck =
                              shouldCheck
                                  ? true
                                  : isSO
                                  ? totalQuantity <= stockAfterReserved
                                  : totalQuantity <= stock;
                          bool check =
                              homeController
                                  .addTaxableAndNonTaxableProductsInSales();
                          if (stockCheck) {
                            if (check) {
                              addItemToListFunction(
                                controller: controller,
                                invItemModel: invItemModel,
                                item: item,
                              );
                            } else {
                              if (controller.invoiceItemsList.isNotEmpty) {
                                bool firstItemTaxState =
                                    controller.isFirstItemTaxed.value;
                                bool currentItemTaxState =
                                    (item.vat ?? 0) > 0 ? true : false;
                                if (firstItemTaxState == currentItemTaxState) {
                                  addItemToListFunction(
                                    controller: controller,
                                    invItemModel: invItemModel,
                                    item: item,
                                  );
                                } else {
                                  Get.back();

                                  // Show warning dialog
                                  Get.dialog(
                                    WillPopScope(
                                      onWillPop: () async => false,
                                      child: AlertDialog(
                                        title: Text('Warning'.tr),
                                        content: Text(
                                          'Cannot add taxed and non taxed items  in the same invoice'
                                              .tr,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text('OK'.tr),
                                          ),
                                        ],
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );
                                }
                              } else {
                                addItemToListFunction(
                                  controller: controller,
                                  invItemModel: invItemModel,
                                  item: item,
                                );
                                (item.vat ?? 0) > 0
                                    ? controller.isFirstItemTaxed(true)
                                    : controller.isFirstItemTaxed(false);
                              }
                            }
                          } else {
                            Get.back();
                            AppToasts.errorToast(
                              'Not enough stock of this item'.tr,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkColor,
                        ),
                        child: Text(
                          'ADD'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: lightColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void addItemToListFunction({
  required SalesController controller,
  required InvoiceItemModel invItemModel,
  required ItemModel item,
}) {
  controller.invoiceItemsList.add(invItemModel);
  ApiInvoiceItem apiInvoiceItem = ApiInvoiceItem(
    itemId: item.id!,
    price: (item.price ?? 0),
    quantity:
        ((controller.mainQty.text != '0' && controller.mainQty.text.isNotEmpty
                ? int.parse(controller.mainQty.text)
                : 0.0) +
            (controller.subQty.text != '0' && controller.subQty.text.isNotEmpty
                ? (double.parse(controller.subQty.text) / item.mainUnitPack!)
                : 0.0) +
            (controller.smallQty.text != '0' &&
                    controller.smallQty.text.isNotEmpty
                ? ((double.parse(controller.smallQty.text) /
                        item.subUnitPack!) /
                    item.mainUnitPack!)
                : 0.0)),
    discountPercentage: (item.disc ?? 0),
    vatPercentage: (item.vat ?? 0),
    promoID: item.promoID ?? 0,
  );
  controller.apiInvoiceItemList.add(apiInvoiceItem);
  Get.back();
}
