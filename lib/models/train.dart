class TrainClass {
  const TrainClass({
    required this.className,
    required this.availableSeats,
    required this.fare,
  });

  final String className;
  final int availableSeats;
  final int fare;

  factory TrainClass.fromJson(Map<String, dynamic> json, {int? fallbackFare}) {
    // Handle both { className: "SL" } and legacy { "0": "S", "1": "L" } or { "0": "3", "1": "A" }
    String name = 'SL';
    if (json['className'] != null) {
      name = json['className'].toString().trim();
    } else if (json['0'] != null) {
      name = '${json['0']}${json['1'] ?? ''}'.trim();
    }

    final seats = int.tryParse(json['availableSeats']?.toString() ?? '') ?? 50;

    int fareVal = int.tryParse(json['fare']?.toString() ?? '') ?? 0;
    if (fareVal <= 0 && fallbackFare != null) {
      switch (name.toUpperCase()) {
        case '1AC':
          fareVal = (fallbackFare * 2.2).round();
          break;
        case '2AC':
          fareVal = (fallbackFare * 1.5).round();
          break;
        case '3AC':
          fareVal = fallbackFare;
          break;
        case 'SL':
        default:
          fareVal = (fallbackFare * 0.45).round();
          if (fareVal < 350) fareVal = 350;
          break;
      }
    }

    return TrainClass(
      className: name.isEmpty ? 'SL' : name,
      availableSeats: seats,
      fare: fareVal > 0 ? fareVal : 850,
    );
  }

  Map<String, dynamic> toJson() => {
        'className': className,
        'availableSeats': availableSeats,
        'fare': fare,
      };
}

class Train {
  const Train({
    required this.trainNumber,
    required this.trainName,
    required this.source,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.runsOn,
    required this.classes,
    this.id,
    this.totalSeats,
    this.availableSeats,
    this.baseFare,
  });

  final String? id;
  final String trainNumber;
  final String trainName;
  final String source;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final List<String> runsOn;
  final List<TrainClass> classes;
  final int? totalSeats;
  final int? availableSeats;
  final int? baseFare;

  factory Train.fromJson(Map<String, dynamic> json) {
    final baseFareVal = int.tryParse(json['fare']?.toString() ?? '') ?? 1250;

    List<TrainClass> parsedClasses = [];
    if (json['classes'] is List && (json['classes'] as List).isNotEmpty) {
      parsedClasses = (json['classes'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => TrainClass.fromJson(c, fallbackFare: baseFareVal))
          .toList();
    }

    // Fallback classes if list was empty or malformed
    if (parsedClasses.isEmpty) {
      parsedClasses = [
        TrainClass(className: '1AC', availableSeats: 18, fare: (baseFareVal * 2.2).round()),
        TrainClass(className: '2AC', availableSeats: 42, fare: (baseFareVal * 1.5).round()),
        TrainClass(className: '3AC', availableSeats: 85, fare: baseFareVal),
        TrainClass(className: 'SL', availableSeats: 120, fare: (baseFareVal * 0.45).round().clamp(380, 10000)),
      ];
    }

    List<String> runs = [];
    if (json['runsOn'] is List) {
      runs = (json['runsOn'] as List).map((e) => e.toString()).toList();
    }
    if (runs.isEmpty) {
      runs = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }

    return Train(
      id: json['_id']?.toString(),
      trainNumber: json['trainNumber']?.toString() ?? '00000',
      trainName: json['trainName']?.toString() ?? 'Express Train',
      source: json['source']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      departureTime: json['departureTime']?.toString() ?? '--:--',
      arrivalTime: json['arrivalTime']?.toString() ?? '--:--',
      duration: json['duration']?.toString() ?? '--h --m',
      runsOn: runs,
      classes: parsedClasses,
      totalSeats: int.tryParse(json['totalSeats']?.toString() ?? ''),
      availableSeats: int.tryParse(json['availableSeats']?.toString() ?? ''),
      baseFare: baseFareVal,
    );
  }

  TrainClass getClass(String name) {
    return classes.firstWhere(
      (c) => c.className.toLowerCase() == name.toLowerCase(),
      orElse: () => classes.isNotEmpty ? classes.first : const TrainClass(className: 'SL', availableSeats: 50, fare: 850),
    );
  }

  int getFareForClass(String name) {
    return getClass(name).fare;
  }
}
