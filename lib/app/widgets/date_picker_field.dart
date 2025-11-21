import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'glassmorphic_container.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool allowClear;

  const DatePickerField({
    Key? key,
    this.initialDate,
    this.onDateChanged,
    this.label,
    this.firstDate,
    this.lastDate,
    this.allowClear = false,
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime selectedDate;
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Execute the callback function with the selected date
      widget.onDateChanged?.call(picked);
    }
  }

  void _clearDate() {
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 100,
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: GlassmorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.label != null) ...[
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                    Text(
                      dateFormatter.format(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.allowClear)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: _clearDate,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
