import 'package:equatable/equatable.dart';

class RideHistoryItem extends Equatable {
  final String id;
  final String pickupAddress;
  final String dropAddress;
  final String dateString;
  final String timeString;
  final double fare;
  final String vehicleName;
  final String driverName;
  final String status;
  final String paymentMethod;

  const RideHistoryItem({
    required this.id,
    required this.pickupAddress,
    required this.dropAddress,
    required this.dateString,
    required this.timeString,
    required this.fare,
    required this.vehicleName,
    required this.driverName,
    required this.status,
    this.paymentMethod = 'Vybe Pay / UPI',
  });

  @override
  List<Object?> get props => [
    id,
    pickupAddress,
    dropAddress,
    dateString,
    timeString,
    fare,
    vehicleName,
    driverName,
    status,
    paymentMethod,
  ];
}
