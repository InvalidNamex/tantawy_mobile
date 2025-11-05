class VisitModel {
  final int transType;
  final int customerVendor;
  final String date;
  final double latitude;
  final double longitude;
  final String notes;

  VisitModel({
    required this.transType,
    required this.customerVendor,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'transType': transType,
    'customerVendor': customerVendor,
    'date': date,
    'latitude': latitude,
    'longitude': longitude,
    'notes': notes,
  };
}
