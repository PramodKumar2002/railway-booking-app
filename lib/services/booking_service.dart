import 'package:my_app/models/booking.dart';
import 'package:my_app/models/passenger.dart';
import 'package:my_app/models/user_session.dart';
import 'package:my_app/services/api_service.dart';

class BookingResult {
  const BookingResult({
    required this.success,
    required this.message,
    this.pnr,
    this.booking,
  });

  final bool success;
  final String message;
  final String? pnr;
  final Booking? booking;
}

class BookingService {
  BookingService._internal();

  static final BookingService _instance = BookingService._internal();

  factory BookingService() => _instance;

  final ApiService _api = ApiService();

  Future<BookingResult> createBooking({
    required String trainNumber,
    required String trainName,
    required String source,
    required String destination,
    required String journeyDate,
    required String travelClass,
    required List<Passenger> passengers,
    required String contactEmail,
    required String contactPhone,
    required int farePerPassenger,
  }) async {
    final session = UserSession();

    final payload = {
      'userId': session.id ?? 'usr_guest',
      'userEmail': (session.email ?? contactEmail).trim().toLowerCase(),
      'trainNumber': trainNumber,
      'trainName': trainName,
      'source': source,
      'destination': destination,
      'journeyDate': journeyDate,
      'travelClass': travelClass,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'contactEmail': contactEmail.trim().toLowerCase(),
      'contactPhone': contactPhone.trim(),
      'farePerPassenger': farePerPassenger,
    };

    final response = await _api.post('/api/bookings', body: payload);

    if (response.success && response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      final pnr = data['pnr']?.toString();
      Booking? booking;
      if (data['booking'] is Map) {
        booking = Booking.fromJson(data['booking'] as Map<String, dynamic>);
      }

      return BookingResult(
        success: true,
        message: data['message']?.toString() ?? 'Booking confirmed successfully!',
        pnr: pnr,
        booking: booking,
      );
    }

    return BookingResult(
      success: false,
      message: response.message ?? 'Failed to submit booking to server.',
    );
  }

  Future<List<Booking>> getMyBookings(String email) async {
    if (email.trim().isEmpty) return [];

    final response = await _api.get(
      '/api/bookings/my-bookings',
      queryParams: {'email': email.trim().toLowerCase()},
    );

    if (response.success && response.data is Map && response.data['bookings'] is List) {
      final list = response.data['bookings'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((b) => Booking.fromJson(b))
          .toList();
    }

    return [];
  }

  Future<Booking?> getBookingByPnr(String pnr) async {
    final cleanPnr = pnr.trim();
    if (cleanPnr.isEmpty) return null;

    final response = await _api.get('/api/bookings/pnr/$cleanPnr');

    if (response.success && response.data is Map && response.data['booking'] is Map) {
      return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
    }

    return null;
  }
}
