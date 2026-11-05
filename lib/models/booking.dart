import 'package:my_app/models/passenger.dart';

class Booking {
  const Booking({
    required this.pnr,
    required this.trainNumber,
    required this.trainName,
    required this.source,
    required this.destination,
    required this.journeyDate,
    required this.travelClass,
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
    required this.totalFare,
    this.id,
    this.userId,
    this.userEmail,
    this.farePerPassenger,
    this.passengerCount,
    this.status = 'CONFIRMED',
    this.paymentStatus = 'SIMULATED',
    this.createdAt,
  });

  final String? id;
  final String pnr;
  final String? userId;
  final String? userEmail;
  final String trainNumber;
  final String trainName;
  final String source;
  final String destination;
  final String journeyDate;
  final String travelClass;
  final List<Passenger> passengers;
  final String contactEmail;
  final String contactPhone;
  final int? farePerPassenger;
  final int? passengerCount;
  final int totalFare;
  final String status;
  final String paymentStatus;
  final DateTime? createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) {
    List<Passenger> parsedPassengers = [];
    if (json['passengers'] is List) {
      parsedPassengers = (json['passengers'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => Passenger.fromJson(p))
          .toList();
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    return Booking(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      pnr: json['pnr']?.toString() ?? 'N/A',
      userId: json['userId']?.toString(),
      userEmail: json['userEmail']?.toString(),
      trainNumber: json['trainNumber']?.toString() ?? '',
      trainName: json['trainName']?.toString() ?? 'Train',
      source: json['source']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      journeyDate: json['journeyDate']?.toString() ?? '',
      travelClass: json['travelClass']?.toString() ?? 'SL',
      passengers: parsedPassengers,
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      farePerPassenger: int.tryParse(json['farePerPassenger']?.toString() ?? ''),
      passengerCount: int.tryParse(json['passengerCount']?.toString() ?? '') ?? parsedPassengers.length,
      totalFare: int.tryParse(json['totalFare']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'CONFIRMED',
      paymentStatus: json['paymentStatus']?.toString() ?? 'SIMULATED',
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
        'pnr': pnr,
        'userId': userId,
        'userEmail': userEmail,
        'trainNumber': trainNumber,
        'trainName': trainName,
        'source': source,
        'destination': destination,
        'journeyDate': journeyDate,
        'travelClass': travelClass,
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'farePerPassenger': farePerPassenger,
        'passengerCount': passengerCount ?? passengers.length,
        'totalFare': totalFare,
        'status': status,
        'paymentStatus': paymentStatus,
      };
}
