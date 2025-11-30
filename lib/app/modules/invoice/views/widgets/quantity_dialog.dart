import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/invoice_controller.dart';
import '../../../../data/models/item_model.dart';
import '../../../../utils/max_value_formatter.dart';

class QuantityDialog extends StatefulWidget {
  final ItemModel item;
  final InvoiceController controller;

  const QuantityDialog({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  final TextEditingController mainQtyController = TextEditingController(
    text: '1',
  );
  final TextEditingController subQtyController = TextEditingController();
  final TextEditingController smallQtyController = TextEditingController();

  final RxDouble itemTotalPrice = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  @override
  void dispose() {
    mainQtyController.dispose();
    subQtyController.dispose();
    smallQtyController.dispose();
    super.dispose();
  }

  String _getProcessedValue(String value) {
    return value.replaceFirst(RegExp(r'^0+'), '');
  }

  void _calculatePrice() {
    double mainQty = double.tryParse(mainQtyController.text) ?? 0.0;
    double subQty = 0.0;
    double smallQty = 0.0;

    if (subQtyController.text.isNotEmpty &&
        (widget.item.mainUnitPack ?? 0) > 0) {
      subQty =
          (double.tryParse(subQtyController.text) ?? 0.0) /
          widget.item.mainUnitPack!;
    }

    if (smallQtyController.text.isNotEmpty &&
        (widget.item.subUnitPack ?? 0) > 0 &&
        (widget.item.mainUnitPack ?? 0) > 0) {
      smallQty =
          ((double.tryParse(smallQtyController.text) ?? 0.0) /
              widget.item.subUnitPack!) /
          widget.item.mainUnitPack!;
    }

    double totalQty = mainQty + subQty + smallQty;
    double price = widget.controller.getItemPrice(widget.item);
    double calculatedPrice = totalQty * price;

    itemTotalPrice.value = calculatedPrice.isNaN ? 0.0 : calculatedPrice;
  }

  void _onAddPressed() {
    double mainQty = double.tryParse(mainQtyController.text) ?? 0.0;
    double subQty = 0.0;
    double smallQty = 0.0;

    String quantityDetail = '';
    if (mainQty > 0) {
      quantityDetail +=
          '${widget.item.mainUnitName ?? 'Main Unit'}: ${mainQtyController.text}';
    }
    if (subQtyController.text.isNotEmpty) {
      if (quantityDetail.isNotEmpty) quantityDetail += '\n';
      quantityDetail +=
          '${widget.item.subUnitName ?? 'Sub Unit'}: ${subQtyController.text}';
      if ((widget.item.mainUnitPack ?? 0) > 0) {
        subQty =
            (double.tryParse(subQtyController.text) ?? 0.0) /
            widget.item.mainUnitPack!;
      }
    }
    if (smallQtyController.text.isNotEmpty) {
      if (quantityDetail.isNotEmpty) quantityDetail += '\n';
      quantityDetail +=
          '${widget.item.smallUnitName ?? 'Small Unit'}: ${smallQtyController.text}';
      if ((widget.item.subUnitPack ?? 0) > 0 &&
          (widget.item.mainUnitPack ?? 0) > 0) {
        smallQty =
            ((double.tryParse(smallQtyController.text) ?? 0.0) /
                widget.item.subUnitPack!) /
            widget.item.mainUnitPack!;
      }
    }

    double totalQty = mainQty + subQty + smallQty;

    if (totalQty <= 0) {
      Get.snackbar('Error', 'Please enter a valid quantity');
      return;
    }

    widget.controller.addItem(
      widget.item,
      quantity: totalQty,
      quantityDetail: quantityDetail,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.itemName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Text(widget.item.mainUnitName ?? 'Main Unit'),
                  title: TextFormField(
                    controller: mainQtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    onTap: () => mainQtyController.clear(),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        mainQtyController.text = _getProcessedValue(value);
                      } else {
                        mainQtyController.text = '0';
                      }
                      _calculatePrice();
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                      ),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.item.subUnitName != null)
                Card(
                  child: ListTile(
                    leading: Text(widget.item.subUnitName!),
                    title: TextFormField(
                      controller: subQtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      onTap: () => subQtyController.clear(),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          subQtyController.text = _getProcessedValue(value);
                        } else {
                          subQtyController.text = '0';
                        }
                        _calculatePrice();
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                        ),
                        LengthLimitingTextInputFormatter(6),
                        MaxValueInputFormatter(widget.item.mainUnitPack ?? 1),
                      ],
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                    trailing: Text(widget.item.mainUnitPack.toString()),
                  ),
                ),
              if (widget.item.smallUnitName != null)
                Card(
                  child: ListTile(
                    leading: Text(widget.item.smallUnitName!),
                    title: TextFormField(
                      controller: smallQtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      onTap: () => smallQtyController.clear(),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          smallQtyController.text = _getProcessedValue(value);
                        } else {
                          smallQtyController.text = '0';
                        }
                        _calculatePrice();
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(?!0+(\.0*)?$)[0-9]*\.?[0-9]*$'),
                        ),
                        LengthLimitingTextInputFormatter(6),
                        MaxValueInputFormatter(widget.item.subUnitPack ?? 1),
                      ],
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                    trailing: Text(widget.item.subUnitPack.toString()),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Price: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Obx(
                    () => Text(
                      itemTotalPrice.value.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onAddPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
