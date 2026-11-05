import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/train.dart';
import 'package:my_app/services/train_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/train_card.dart';

class JourneyTab extends StatefulWidget {
  const JourneyTab({
    super.key,
    required this.onBookTrain,
    this.initialSource,
    this.initialDestination,
    this.initialDate,
  });

  final void Function(
    Train train,
    String selectedClass,
    DateTime journeyDate,
    int passengerCount,
  ) onBookTrain;

  final String? initialSource;
  final String? initialDestination;
  final DateTime? initialDate;

  @override
  State<JourneyTab> createState() => _JourneyTabState();
}

class _JourneyTabState extends State<JourneyTab> {
  final TrainService _trainService = TrainService();

  List<String> _stations = TrainService.defaultStations;
  late String _source;
  late String _destination;
  late DateTime _journeyDate;
  int _passengerCount = 1;
  String _selectedClass = 'All';

  bool _isSearching = false;
  String? _errorMessage;
  List<Train> _trainResults = [];
  bool _hasSearched = false;

  static const List<String> travelClasses = [
    'All',
    'SL',
    '3AC',
    '2AC',
    '1AC',
  ];

  @override
  void initState() {
    super.initState();
    _source = widget.initialSource ?? 'New Delhi (NDLS)';
    _destination = widget.initialDestination ?? 'Mumbai Central (MMCT)';
    _journeyDate =
        widget.initialDate ?? DateTime.now().add(const Duration(days: 1));

    _loadStations();

    // If initial query was passed, perform search right away
    if (widget.initialSource != null && widget.initialDestination != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchTrains();
      });
    } else {
      // Default initial search so the user immediately sees trains
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchTrains();
      });
    }
  }

  Future<void> _loadStations() async {
    try {
      final list = await _trainService.getStations();
      if (mounted) {
        setState(() {
          _stations = list;
          if (!_stations.contains(_source) && _stations.isNotEmpty) {
            _source = _stations.first;
          }
          if (!_stations.contains(_destination) && _stations.length > 1) {
            _destination = _stations[1];
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _journeyDate.isBefore(DateTime.now())
          ? DateTime.now()
          : _journeyDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: Color(0xFF0F1B2B),
              onSurface: AppTheme.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0F1B2B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _journeyDate = picked);
    }
  }

  void _swapStations() {
    setState(() {
      final temp = _source;
      _source = _destination;
      _destination = temp;
    });
  }

  Future<void> _searchTrains() async {
    // Validation
    if (_source.trim().isEmpty || _destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both source and destination stations.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_source.trim().toLowerCase() == _destination.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and destination stations cannot be the same.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final journeyDateOnly =
        DateTime(_journeyDate.year, _journeyDate.month, _journeyDate.day);

    if (journeyDateOnly.isBefore(dateOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journey date cannot be in the past.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_passengerCount < 1 || _passengerCount > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select between 1 and 6 passengers.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_journeyDate);
      final trains = await _trainService.searchTrains(
        source: _source,
        destination: _destination,
        date: dateStr,
        travelClass: _selectedClass == 'All' ? null : _selectedClass,
      );

      if (mounted) {
        setState(() {
          _trainResults = trains;
          _isSearching = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _errorMessage = err.toString().replaceAll('Exception:', '').trim();
          _isSearching = false;
          _trainResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 60 : 16,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Search & Plan Journey',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select stations, pick your departure date, and choose from live Indian Railway schedules.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SEARCH FORM CONTAINER
            Container(
              padding: EdgeInsets.all(isDesktop ? 28 : 20),
              decoration: BoxDecoration(
                color: const Color(0xCC0E1A29),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x22FFFFFF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Source & Destination
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _StationSelector(
                            label: 'Origin Station',
                            value: _source,
                            stations: _stations,
                            icon: Icons.trip_origin_rounded,
                            onChanged: (val) {
                              if (val != null) setState(() => _source = val);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: IconButton(
                            onPressed: _swapStations,
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppTheme.primary,
                            ),
                            tooltip: 'Swap Stations',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0x1AFFFFFF),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _StationSelector(
                            label: 'Destination Station',
                            value: _destination,
                            stations: _stations,
                            icon: Icons.location_on_rounded,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _destination = val);
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _StationSelector(
                          label: 'Origin Station',
                          value: _source,
                          stations: _stations,
                          icon: Icons.trip_origin_rounded,
                          onChanged: (val) {
                            if (val != null) setState(() => _source = val);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _swapStations,
                            icon: const Icon(Icons.swap_vert_rounded, size: 18),
                            label: const Text('Swap Stations'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                            ),
                          ),
                        ),
                        _StationSelector(
                          label: 'Destination Station',
                          value: _destination,
                          stations: _stations,
                          icon: Icons.location_on_rounded,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _destination = val);
                            }
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Row 2: Date, Passenger Count, Travel Class
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Journey Date
                            Expanded(
                              flex: 3,
                              child: _DateField(
                                date: _journeyDate,
                                onTap: _selectDate,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Passengers Count
                            Expanded(
                              flex: 2,
                              child: _PassengerCountDropdown(
                                count: _passengerCount,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _passengerCount = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Travel Class
                            Expanded(
                              flex: 2,
                              child: _ClassDropdown(
                                selectedClass: _selectedClass,
                                classes: travelClasses,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedClass = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Search Button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isSearching ? null : _searchTrains,
                                icon: _isSearching
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF04151D),
                                        ),
                                      )
                                    : const Icon(Icons.search_rounded),
                                label: Text(_isSearching
                                    ? 'Searching...'
                                    : 'Search Trains'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: const Color(0xFF04151D),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Mobile/Tablet
                        return Column(
                          children: [
                            _DateField(
                              date: _journeyDate,
                              onTap: _selectDate,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _PassengerCountDropdown(
                                    count: _passengerCount,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _passengerCount = val);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ClassDropdown(
                                    selectedClass: _selectedClass,
                                    classes: travelClasses,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedClass = val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSearching ? null : _searchTrains,
                                icon: _isSearching
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF04151D),
                                        ),
                                      )
                                    : const Icon(Icons.search_rounded),
                                label: Text(_isSearching
                                    ? 'Searching Trains...'
                                    : 'Search Trains'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: const Color(0xFF04151D),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // SEARCH RESULTS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _hasSearched
                      ? 'Available Trains (${_trainResults.length})'
                      : 'Recommended Trains',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_trainResults.isNotEmpty)
                  Text(
                    '${DateFormat('dd MMM yyyy').format(_journeyDate)} • $_passengerCount Passenger(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Loading state
            if (_isSearching)
              Container(
                padding: const EdgeInsets.all(48),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text(
                      'Fetching live train schedules from Railway Cluster...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            // Error state
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0x1AF87171),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x44F87171)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFF87171),
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFFCA5A5)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _searchTrains,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            // Empty results
            else if (_hasSearched && _trainResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: const Color(0xCC0E1A29),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.train_rounded,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No direct trains found for this route',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try choosing different major junction stations or another travel date.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            // List of matching trains
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trainResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final train = _trainResults[index];
                  return TrainCard(
                    train: train,
                    initialClass:
                        _selectedClass != 'All' ? _selectedClass : null,
                    onBookNow: (selectedTrain, chosenClass) {
                      widget.onBookTrain(
                        selectedTrain,
                        chosenClass,
                        _journeyDate,
                        _passengerCount,
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StationSelector extends StatelessWidget {
  const _StationSelector({
    required this.label,
    required this.value,
    required this.stations,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> stations;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: stations.contains(value) ? value : stations.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F1B2B),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primary,
              ),
              items: stations.map((st) {
                return DropdownMenuItem<String>(
                  value: st,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          st,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Journey Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('EEE, dd MMM yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PassengerCountDropdown extends StatelessWidget {
  const _PassengerCountDropdown({
    required this.count,
    required this.onChanged,
  });

  final int count;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passengers',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: count,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F1B2B),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primary,
              ),
              items: List.generate(6, (i) => i + 1).map((c) {
                return DropdownMenuItem<int>(
                  value: c,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$c ${c == 1 ? "Passenger" : "Passengers"}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassDropdown extends StatelessWidget {
  const _ClassDropdown({
    required this.selectedClass,
    required this.classes,
    required this.onChanged,
  });

  final String selectedClass;
  final List<String> classes;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Travel Class',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedClass,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F1B2B),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primary,
              ),
              items: classes.map((cls) {
                return DropdownMenuItem<String>(
                  value: cls,
                  child: Text(
                    cls == 'All' ? 'All Classes' : cls,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
