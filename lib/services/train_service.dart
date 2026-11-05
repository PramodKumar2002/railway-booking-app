import 'package:my_app/models/train.dart';
import 'package:my_app/services/api_service.dart';

class TrainService {
  TrainService._internal();

  static final TrainService _instance = TrainService._internal();

  factory TrainService() => _instance;

  final ApiService _api = ApiService();

  static const List<String> defaultStations = [
    'New Delhi (NDLS)',
    'Mumbai Central (MMCT)',
    'Bengaluru City (SBC)',
    'Chennai Central (MAS)',
    'Howrah (HWH)',
    'Varanasi Junction (BSB)',
    'Bhopal Junction (BPL)',
    'Ahmedabad Junction (ADI)',
    'Pune Junction (PUNE)',
    'Jaipur Junction (JP)',
    'Hyderabad Deccan (HYB)',
    'Thiruvananthapuram (TVC)',
    'Ernakulam Junction (ERS)',
  ];

  Future<List<String>> getStations() async {
    final response = await _api.get('/api/trains/stations');
    if (response.success && response.data is Map && response.data['stations'] is List) {
      final list = (response.data['stations'] as List).map((e) => e.toString()).toList();
      if (list.isNotEmpty) return list;
    }
    return defaultStations;
  }

  Future<List<Train>> searchTrains({
    required String source,
    required String destination,
    String? date,
    String? travelClass,
  }) async {
    final params = <String, dynamic>{
      'source': source.trim(),
      'destination': destination.trim(),
    };
    if (date != null && date.isNotEmpty) params['date'] = date;
    if (travelClass != null && travelClass.isNotEmpty && travelClass != 'All') {
      params['class'] = travelClass;
    }

    final response = await _api.get('/api/trains/search', queryParams: params);

    if (response.success && response.data is Map && response.data['trains'] is List) {
      final rawList = response.data['trains'] as List;
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => Train.fromJson(item))
          .toList();
    }

    // If API returned error or empty, raise exception with message
    if (!response.success) {
      throw Exception(response.message ?? 'Failed to fetch trains from server.');
    }

    return [];
  }

  Future<Train?> getTrainDetails(String trainNumber) async {
    final response = await _api.get('/api/trains/$trainNumber');
    if (response.success && response.data is Map && response.data['train'] is Map) {
      return Train.fromJson(response.data['train'] as Map<String, dynamic>);
    }
    return null;
  }
}
