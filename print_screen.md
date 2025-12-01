import 'package:agent/controllers/customer_controller.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/api/api_invoice_details_model.dart';
import '/models/api/api_po_detail_model.dart';
import '/models/api/api_po_master_model.dart';
import '/models/api/save_invoice/api_invoice_master_model.dart';
import '../controllers/home_controller.dart';
import '../controllers/sales_controller.dart';
import '../helpers/is_arabic.dart';
import '../models/item_model.dart';
import 'new_invoice/receipt_dialog.dart';

const double bodyFontSize = 20;
const double headerFontSize = 22;

double totalPrice({
  required List<InvDetailsModel> invoiceItems,
  required List<PODetailModel> salesPODetails,
  required bool includeVAT,
}) {
  if (invoiceItems.isNotEmpty) {
    double total = 0;
    for (InvDetailsModel item in invoiceItems) {
      double itemPrice = item.price ?? 0;
      if (includeVAT) {
        double vatAmount = item.vatAmount ?? 0;
        if (vatAmount > 0) {
          itemPrice += vatAmount;
        }
      }
      total += itemPrice;
    }
    return total;
  } else {
    double total = 0;
    for (PODetailModel item in salesPODetails) {
      double itemPrice = (item.price ?? 0) * item.qty!;
      if (includeVAT) {
        double taxPercentage = (item.taxPer ?? 0) / 100;
        if (taxPercentage > 0) {
          double discTotal = ((item.discPer ?? 0) / 100) * (item.price ?? 0);
          double vatAmount =
              ((((item.price ?? 0) - discTotal) * taxPercentage) * item.qty!);
          itemPrice += vatAmount;
        }
      }
      total += itemPrice;
    }
    return total;
  }
}

double totalDiscount({
  required List<InvDetailsModel> invoiceItems,
  required List<PODetailModel> salesPODetails,
}) {
  if (invoiceItems.isNotEmpty) {
    double total = 0;
    for (InvDetailsModel item in invoiceItems) {
      total += item.discount ?? 0;
    }
    return total;
  } else {
    double total = 0;
    for (PODetailModel item in salesPODetails) {
      total += ((((item.discPer ?? 0) / 100) * (item.price ?? 0)) * item.qty!);
    }
    return total;
  }
}

double totalVat({
  required List<InvDetailsModel> invoiceItems,
  required List<PODetailModel> salesPODetails,
}) {
  if (invoiceItems.isNotEmpty) {
    double total = 0;
    for (InvDetailsModel item in invoiceItems) {
      total += item.vatAmount ?? 0;
    }
    return total;
  } else {
    double total = 0;
    for (PODetailModel item in salesPODetails) {
      double discTotal = ((item.discPer ?? 0) / 100) * (item.price ?? 0);
      double taxPercentage = ((item.taxPer ?? 0) / 100);
      total += ((((item.price ?? 0) - discTotal) * taxPercentage) * item.qty!);
    }
    return total;
  }
}

Future<void> printPOpreview({
  InvMasterModel? invMaster,
  PoMasterModel? poMaster,
  bool vatIncluded = false,
  String? customerName,
  required List<InvDetailsModel> invoiceItems,
  required List<PODetailModel> salesPODetails,
  required bool isPO,
}) async {
  final salesController = Get.find<SalesController>();
  final homeController = Get.find<HomeController>();
  final customerController = Get.find<CustomerController>();
  bool vatHidden = homeController.vatHidden.value;

  await salesController.getFilteredItemsByCustomer(
    customerID:
        (invMaster == null
            ? poMaster?.custCode ?? '-'
            : invMaster.custCode ?? '-'),
  );
  List<ItemModel> items = salesController.customerItemsList;

  String date =
      invMaster != null
          ? invMaster.invDate != null
              ? DateFormat('dd/MM/yyyy').format(invMaster.invDate!)
              : '-'
          : poMaster?.transDate != null
          ? DateFormat('dd/MM/yyyy').format(poMaster!.transDate!)
          : '-';

  Future<pw.Font> getArabicFont() async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<pw.Document> generateDocument() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'language';
    String? value = prefs.getString(key);
    bool isArabic =
        value == 'ar' ||
        (value == null && Get.deviceLocale?.languageCode == 'ar');

    final doc = pw.Document();
    final arabicFont = await getArabicFont();

    pw.Widget buildText(
      String text, {
      double fontSize = bodyFontSize,
      bool bold = false,
      bool forceRTL = false,
      bool forceLTR = false,
      PdfColor color = PdfColors.black,
    }) {
      pw.TextDirection direction;

      if (forceRTL) {
        direction = pw.TextDirection.rtl;
      } else if (forceLTR) {
        direction = pw.TextDirection.ltr;
      } else {
        direction =
            isArabicCheck(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr;
      }

      return pw.Directionality(
        textDirection: direction,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: arabicFont,
            fontSize: fontSize,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : null,
          ),
        ),
      );
    }

    List<pw.Widget> headers = [
      buildText('Item'.tr, bold: true),
      buildText('Quantity'.tr, bold: true),
      buildText('Total'.tr, bold: true),
    ];

    if (isArabic) {
      headers = headers.reversed.toList();
    }

    final List<List<pw.Widget>> data =
        invoiceItems.isNotEmpty
            ? invoiceItems.map((item) {
              ItemModel? qtyItem = items.firstWhereOrNull((x) {
                return x.itemName == item.itemName;
              });

              double itemQuantity = item.qty ?? 0;
              double unitPrice = item.price ?? 0;
              double totalLinePrice = unitPrice * itemQuantity;

              if (vatHidden) {
                double vatAmount = item.vatAmount ?? 0;
                if (vatAmount > 0) {
                  totalLinePrice += vatAmount;
                }
              }

              List<pw.Widget> row = [
                buildText(item.itemName ?? ''),
                buildText(formatQuantity(itemQuantity, qtyItem)),
                pw.Text(
                  totalLinePrice.toStringAsFixed(2),
                  style: pw.TextStyle(
                    font: arabicFont, // Add Arabic font support
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ];
              return isArabic ? row.reversed.toList() : row;
            }).toList()
            : salesPODetails.map((item) {
              ItemModel? qtyItem = items.firstWhereOrNull((x) {
                return x.itemName == item.itemName;
              });

              double itemQuantity = item.qty ?? 0;
              double unitPrice = item.price ?? 0;
              double totalLinePrice = unitPrice * itemQuantity;

              if (vatHidden) {
                double taxPercentage = (item.taxPer ?? 0) / 100;
                if (taxPercentage > 0) {
                  double discTotal = ((item.discPer ?? 0) / 100) * unitPrice;
                  double vatAmount =
                      (((unitPrice - discTotal) * taxPercentage) *
                          itemQuantity);
                  totalLinePrice += vatAmount;
                }
              }

              List<pw.Widget> row = [
                buildText(item.itemName ?? ''),
                buildText(formatQuantity(itemQuantity, qtyItem)),
                pw.Text(
                  totalLinePrice.toStringAsFixed(2),
                  style: pw.TextStyle(
                    font: arabicFont, // Add Arabic font support
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ];

              return isArabic ? row.reversed.toList() : row;
            }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(bodyFontSize),
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        header:
            (context) => pw.Container(
              width: double.infinity,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(5),
              color: PdfColors.black,
              child: buildText(
                isPO ? 'Purchase Order'.tr : 'Invoice'.tr,
                color: PdfColors.white,
                fontSize: 24,
                bold: true,
                forceRTL: isArabic,
              ),
            ),
        build: (context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      buildText(
                        '${invMaster == null ? 'PO No:'.tr : 'Invoice No:'.tr} ${invMaster == null ? poMaster?.transID ?? '-' : invMaster.id ?? '-'}',
                        fontSize: headerFontSize,
                      ),
                      buildText(
                        '${'Customer Code: '.tr} ${invMaster == null ? poMaster?.custCode ?? '-' : invMaster.custCode ?? '-'}',
                        fontSize: headerFontSize,
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 5),
                  pw.Column(
                    children: [
                      buildText(
                        '${'Serial:'.tr} ${invMaster == null ? poMaster?.transID ?? '-' : invMaster.serial ?? '-'}',
                        fontSize: headerFontSize,
                      ),
                      buildText(
                        '${'Date:'.tr} $date',
                        fontSize: headerFontSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Row(
                    children: [
                      buildText(
                        '${'Customer Name:'.tr} ',
                        fontSize: headerFontSize,
                        bold: true,
                      ),
                      buildText(
                        invMaster == null
                            ? poMaster?.custName ?? '-'
                            : invMaster.custName ?? '-',
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Row(
                    children: [
                      buildText(
                        '${'Phone: '.tr} ',
                        fontSize: headerFontSize,
                        bold: true,
                      ),
                      buildText(
                        customerController.customersList
                                .firstWhereOrNull(
                                  (c) =>
                                      c.custCode ==
                                      (invMaster == null
                                          ? poMaster?.custCode ?? '-'
                                          : invMaster.custCode ?? '-'),
                                )
                                ?.phone ??
                            '-',
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                font: arabicFont,
                fontWeight: pw.FontWeight.bold,
                fontSize: bodyFontSize,
              ),
              cellStyle: pw.TextStyle(font: arabicFont),
              cellAlignment:
                  isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,

              columnWidths:
                  isArabic
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
            ),

            pw.SizedBox(height: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Row(
                children: [
                  invMaster != null
                      ? pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          buildText(
                            '${'Discount:'.tr} ${invMaster.discBefore?.toStringAsFixed(2) ?? '0'}',
                            fontSize: headerFontSize,
                          ),
                          if (!vatHidden)
                            buildText(
                              '${'Tax:'.tr} ${invMaster.vat?.toStringAsFixed(2) ?? '0'}',
                              fontSize: headerFontSize,
                            ),
                          buildText(
                            '${'Net Total:'.tr} ${invMaster.invAmount?.toStringAsFixed(2) ?? '0'}',
                            fontSize: headerFontSize,
                          ),
                          pw.Divider(),
                        ],
                      )
                      : pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          buildText(
                            '${'Discount:'.tr} ${totalDiscount(invoiceItems: invoiceItems, salesPODetails: salesPODetails).toStringAsFixed(2)}',
                            fontSize: headerFontSize,
                          ),
                          if (!vatHidden)
                            buildText(
                              '${'Tax:'.tr} ${totalVat(invoiceItems: invoiceItems, salesPODetails: salesPODetails).toStringAsFixed(2)}',
                              fontSize: headerFontSize,
                            ),
                          buildText(
                            '${'Net Total:'.tr} ${vatHidden ? totalPrice(invoiceItems: invoiceItems, salesPODetails: salesPODetails, includeVAT: true).toStringAsFixed(2) : ((totalPrice(invoiceItems: invoiceItems, salesPODetails: salesPODetails, includeVAT: false) - totalDiscount(invoiceItems: invoiceItems, salesPODetails: salesPODetails)) + totalVat(invoiceItems: invoiceItems, salesPODetails: salesPODetails)).toStringAsFixed(2)}',
                            fontSize: headerFontSize,
                          ),
                          pw.Divider(),
                        ],
                      ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Row(
                mainAxisAlignment:
                    isArabic
                        ? pw.MainAxisAlignment.end
                        : pw.MainAxisAlignment.start,
                children: [
                  buildText(
                    'Notes: '.tr,
                    fontSize: headerFontSize,
                    forceRTL: isArabic,
                  ),
                  buildText(
                    invMaster == null
                        ? poMaster?.transNotes ?? ''
                        : invMaster.invNote ?? '',
                    fontSize: headerFontSize,
                    forceRTL: isArabic,
                  ),
                ],
              ),
            ),
            vatIncluded
                ? pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: buildText('vat included'.tr, fontSize: headerFontSize),
                )
                : pw.SizedBox(),
          ];
        },
        footer:
            (context) => pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: double.infinity,
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.grey300,
                  child: buildText(
                    '${'Agent: '.tr} ${invMaster?.salesRepName ?? poMaster?.salesRepName ?? '-'}',
                    fontSize: 16,
                    forceRTL: isArabic,
                  ),
                ),
                pw.Container(
                  width: double.infinity,
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.grey300,
                  child: buildText(
                    '${'Branch: '.tr} ${invMaster?.branchId ?? poMaster?.branchId ?? '-'}',
                    fontSize: 16,
                    forceRTL: isArabic,
                  ),
                ),
              ],
            ),
      ),
    );
    return doc;
  }

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => (await generateDocument()).save(),
  );

  customerName != null
      ? Get.defaultDialog(
        title: 'Receipt Voucher'.tr,
        content: ReceiptDialog(customerNameArgument: customerName),
      )
      : Get.offNamed('/index-screen');
}

String formatQuantity(double rawQty, ItemModel? itemDetails) {
  if (itemDetails == null) {
    return rawQty.toStringAsFixed(2);
  }

  double mainUnitPack = itemDetails.mainUnitPack ?? 1.0;
  double subUnitPack = itemDetails.subUnitPack ?? 1.0;

  String mainUnitName = itemDetails.mainUnit ?? 'Unit';
  String subUnitName = itemDetails.subUnit ?? 'Sub';
  String smallUnitName = itemDetails.smallUnit ?? 'Small';

  int mainUnits = rawQty.floor();
  double remainingAfterMain = rawQty - mainUnits;
  int subUnits = (remainingAfterMain * mainUnitPack).round();
  double remainingAfterSub = (remainingAfterMain * mainUnitPack) - subUnits;
  int smallUnits = (remainingAfterSub * subUnitPack).round();
  StringBuffer formattedQty = StringBuffer();
  if (mainUnits > 0) {
    formattedQty.write('$mainUnits $mainUnitName');
  }
  if (subUnits > 0) {
    if (formattedQty.isNotEmpty) formattedQty.write(' \n');
    formattedQty.write('$subUnits $subUnitName');
  }
  if (smallUnits > 0) {
    if (formattedQty.isNotEmpty) formattedQty.write(' \n');
    formattedQty.write('$smallUnits $smallUnitName');
  }
  if (formattedQty.isEmpty) {
    return rawQty.toStringAsFixed(2);
  }
  return formattedQty.toString();
}
