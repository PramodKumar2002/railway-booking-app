import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/booking.dart';
import 'package:my_app/models/passenger.dart';
import 'package:my_app/models/train.dart';
import 'package:my_app/models/user_session.dart';
import 'package:my_app/services/booking_service.dart';
import 'package:my_app/theme/app_theme.dart';

class TicketBookingTab extends StatefulWidget {
  const TicketBookingTab({
    super.key,
    this.initialTrain,
    this.initialClass,
    this.initialDate,
    this.initialPassengerCount,
    required this.onNavigateToJourney,
  });

  final Train? initialTrain;
  final String? initialClass;
  final DateTime? initialDate;
  final int? initialPassengerCount;
  final VoidCallback onNavigateToJourney;

  @override
  State<TicketBookingTab> createState() => _TicketBookingTabState();
}

class _TicketBookingTabState extends State<TicketBookingTab>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();

  late TabController _tabController;

  // Booking Form State
  Train? _selectedTrain;
  late String _selectedClass;
  late DateTime _journeyDate;
  int _passengerCount = 1;

  final List<Passenger> _passengers = [];
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;
  BookingResult? _confirmedBookingResult;

  // My Bookings State
  final _pnrSearchController = TextEditingController();
  bool _isLoadingMyBookings = false;
  bool _isSearchingPnr = false;
  List<Booking> _myBookings = [];
  Booking? _searchedBooking;
  String? _pnrSearchError;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _selectedTrain = widget.initialTrain;
    _selectedClass = widget.initialClass ?? '3AC';
    _journeyDate =
        widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
    _passengerCount = widget.initialPassengerCount ?? 1;

    _syncPassengerCount();

    // Prefill from user session
    final session = UserSession();
    _emailController.text = session.email ?? '';
    _phoneController.text = session.phone ?? '';

    // Auto-fetch user's bookings if email is known
    if (session.email != null && session.email!.isNotEmpty) {
      _fetchMyBookings(session.email!);
    }
  }

  @override
  void didUpdateWidget(covariant TicketBookingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTrain != null &&
        widget.initialTrain != oldWidget.initialTrain) {
      setState(() {
        _selectedTrain = widget.initialTrain;
        _selectedClass = widget.initialClass ?? '3AC';
        _journeyDate =
            widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
        _passengerCount = widget.initialPassengerCount ?? 1;
        _confirmedBookingResult = null;
        _syncPassengerCount();
      });
      _tabController.animateTo(0);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pnrSearchController.dispose();
    super.dispose();
  }

  void _syncPassengerCount() {
    while (_passengers.length < _passengerCount) {
      _passengers.add(Passenger());
    }
    while (_passengers.length > _passengerCount) {
      _passengers.removeLast();
    }
  }

  int get _unitFare {
    if (_selectedTrain == null) return 1250;
    return _selectedTrain!.getFareForClass(_selectedClass);
  }

  int get _totalFare {
    return _unitFare * _passengerCount;
  }

  Future<void> _submitBooking() async {
    if (_selectedTrain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a train to book tickets.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Validate Passenger details
    for (int i = 0; i < _passengers.length; i++) {
      final p = _passengers[i];
      if (p.name.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter full name for Passenger #${i + 1}.'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
      final ageNum = int.tryParse(p.age.trim());
      if (ageNum == null || ageNum < 1 || ageNum > 120) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid age for Passenger #${i + 1}.'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
    }

    // Validate Contact
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid contact email address.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Show confirmation modal before calling backend
    final confirmed = await _showBookingSummaryDialog();
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_journeyDate);
      final result = await _bookingService.createBooking(
        trainNumber: _selectedTrain!.trainNumber,
        trainName: _selectedTrain!.trainName,
        source: _selectedTrain!.source,
        destination: _selectedTrain!.destination,
        journeyDate: dateStr,
        travelClass: _selectedClass,
        passengers: _passengers,
        contactEmail: email,
        contactPhone: phone,
        farePerPassenger: _unitFare,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        if (result.success) {
          _confirmedBookingResult = result;
          // Refresh user bookings list
          _fetchMyBookings(email);
        }
      });

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<bool?> _showBookingSummaryDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1B2B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        Icons.confirmation_number_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Confirm Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SummaryRow(
                  label: 'Train',
                  value:
                      '${_selectedTrain!.trainName} (#${_selectedTrain!.trainNumber})',
                ),
                _SummaryRow(
                  label: 'Route',
                  value:
                      '${_selectedTrain!.source} → ${_selectedTrain!.destination}',
                ),
                _SummaryRow(
                  label: 'Journey Date',
                  value: DateFormat('EEE, dd MMM yyyy').format(_journeyDate),
                ),
                _SummaryRow(
                  label: 'Class & Passengers',
                  value: '$_selectedClass • $_passengerCount Passenger(s)',
                ),
                _SummaryRow(
                  label: 'Contact',
                  value: '${_emailController.text} | ${_phoneController.text}',
                ),
                const Divider(color: Color(0x22FFFFFF), height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Fare Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_totalFare),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x1A5EEAD4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment Gateway: Simulated Test Mode. Ticket will be confirmed and saved directly to the database.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: const BorderSide(color: Color(0x33FFFFFF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: const Color(0xFF04151D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Confirm & Book',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchMyBookings(String email) async {
    if (email.trim().isEmpty) return;
    setState(() => _isLoadingMyBookings = true);
    try {
      final list = await _bookingService.getMyBookings(email);
      if (mounted) {
        setState(() {
          _myBookings = list;
          _isLoadingMyBookings = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMyBookings = false);
    }
  }

  Future<void> _searchPnr() async {
    final pnr = _pnrSearchController.text.trim();
    if (pnr.isEmpty) return;

    setState(() {
      _isSearchingPnr = true;
      _pnrSearchError = null;
      _searchedBooking = null;
    });

    try {
      final booking = await _bookingService.getBookingByPnr(pnr);
      if (mounted) {
        setState(() {
          _searchedBooking = booking;
          _isSearchingPnr = false;
          if (booking == null) {
            _pnrSearchError = 'No booking found matching PNR: $pnr';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingPnr = false;
          _pnrSearchError = 'Error retrieving PNR: ${e.toString()}';
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
            // Top Section Header & Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                            Icons.confirmation_number_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Ticket Reservation & PNR',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Book verified train tickets or track existing PNR reservation status.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xCC0E1A29),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x22FFFFFF)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.airplane_ticket_rounded, size: 18),
                    text: 'Book Train Ticket',
                  ),
                  Tab(
                    icon: Icon(Icons.receipt_long_rounded, size: 18),
                    text: 'My Bookings & PNR Lookup',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content Based on Tab
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  return _buildBookingView(isDesktop);
                } else {
                  return _buildMyBookingsView(isDesktop);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingView(bool isDesktop) {
    // If ticket was just successfully confirmed:
    if (_confirmedBookingResult != null) {
      return _buildSuccessConfirmationCard();
    }

    // If no train is selected yet:
    if (_selectedTrain == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xCC0E1A29),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_railway_rounded,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Train Selected For Booking',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const Text(
                'Please browse the Journey page to select your desired train, route, and travel class, then click "Book Now".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onNavigateToJourney,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Explore Trains On Journey Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: const Color(0xFF04151D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Main Booking Form
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected Train Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xF20F2033),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Icons.train_rounded,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTrain!.trainName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Train #${_selectedTrain!.trainNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: widget.onNavigateToJourney,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Change Train'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0x1AFFFFFF), height: 1),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _InfoChip(
                    label: 'From',
                    value:
                        '${_selectedTrain!.source} (${_selectedTrain!.departureTime})',
                  ),
                  _InfoChip(
                    label: 'To',
                    value:
                        '${_selectedTrain!.destination} (${_selectedTrain!.arrivalTime})',
                  ),
                  _InfoChip(
                    label: 'Date',
                    value: DateFormat('dd MMM yyyy').format(_journeyDate),
                  ),
                  _InfoChip(
                    label: 'Selected Class',
                    value: _selectedClass,
                    highlight: true,
                  ),
                  _InfoChip(
                    label: 'Fare per seat',
                    value: _currencyFormat.format(_unitFare),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // Passenger Details Form
        Container(
          padding: EdgeInsets.all(isDesktop ? 26 : 18),
          decoration: BoxDecoration(
            color: const Color(0xCC0E1A29),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Passenger Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_passengerCount Passenger(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Passenger rows
              ...List.generate(_passengerCount, (index) {
                final p = _passengers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x1AFFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passenger #${index + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isDesktop)
                        Row(
                          children: [
                            // Full Name
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: p.name,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'As per Govt ID proof',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    size: 18,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                onChanged: (val) => p.name = val,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Age
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                initialValue: p.age,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                  hintText: 'e.g. 28',
                                ),
                                onChanged: (val) => p.age = val,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Gender Dropdown
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: p.gender,
                                dropdownColor: const Color(0xFF0F1B2B),
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text('Female'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Other',
                                    child: Text('Other'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => p.gender = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Berth Preference
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: p.berthPreference,
                                dropdownColor: const Color(0xFF0F1B2B),
                                decoration: const InputDecoration(
                                  labelText: 'Berth Preference',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'No Preference',
                                    child: Text('No Preference'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Lower',
                                    child: Text('Lower'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Middle',
                                    child: Text('Middle'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Upper',
                                    child: Text('Upper'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Side Lower',
                                    child: Text('Side Lower'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => p.berthPreference = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        // Mobile Layout
                        Column(
                          children: [
                            TextFormField(
                              initialValue: p.name,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'As per Govt ID proof',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: AppTheme.primary,
                                ),
                              ),
                              onChanged: (val) => p.name = val,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: p.age,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Age',
                                      hintText: 'e.g. 28',
                                    ),
                                    onChanged: (val) => p.age = val,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: p.gender,
                                    dropdownColor: const Color(0xFF0F1B2B),
                                    decoration: const InputDecoration(
                                      labelText: 'Gender',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Male',
                                        child: Text('Male'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Female',
                                        child: Text('Female'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Other',
                                        child: Text('Other'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => p.gender = val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),

              // Button to add/remove passengers
              Row(
                children: [
                  if (_passengerCount < 6)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _passengerCount++;
                          _syncPassengerCount();
                        });
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Another Passenger'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                  if (_passengerCount > 1) ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _passengerCount--;
                          _syncPassengerCount();
                        });
                      },
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      label: const Text('Remove Last Passenger'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFCA5A5),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // Contact & Fare Summary Row
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 780;

            final contactCard = Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xCC0E1A29),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x22FFFFFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ticket Dispatch Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your PNR and SMS confirmation will be sent here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(
                        Icons.phone_iphone_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );

            final fareCard = Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF20F1F31),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fare Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Base Fare ($_selectedClass)',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(_unitFare),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Passengers ($_passengerCount)',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'x $_passengerCount',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'IRCTC Convenience Fee',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '₹0 (Waived)',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0x22FFFFFF), height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(_totalFare),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitBooking,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF04151D),
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(
                        _isSubmitting
                            ? 'Processing Booking...'
                            : 'Confirm & Book Ticket',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: const Color(0xFF04151D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: contactCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: fareCard),
                ],
              );
            } else {
              return Column(
                children: [
                  contactCard,
                  const SizedBox(height: 20),
                  fareCard,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSuccessConfirmationCard() {
    final result = _confirmedBookingResult!;
    final booking = result.booking;
    final pnr = result.pnr ?? booking?.pnr ?? '2349817290';

    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF34D399).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34D399).withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0x2234D399),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x6634D399)),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF34D399),
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Booking Confirmed!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // PNR Display Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x1A5EEAD4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOOKING REFERENCE / PNR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pnr,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pnr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PNR copied to clipboard!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: AppTheme.primary),
                  tooltip: 'Copy PNR',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Detailed Ticket Information
          if (booking != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Train',
                    value: '${booking.trainName} (#${booking.trainNumber})',
                  ),
                  _SummaryRow(
                    label: 'Route',
                    value: '${booking.source} → ${booking.destination}',
                  ),
                  _SummaryRow(
                    label: 'Date',
                    value: booking.journeyDate,
                  ),
                  _SummaryRow(
                    label: 'Class',
                    value: booking.travelClass,
                  ),
                  _SummaryRow(
                    label: 'Passengers',
                    value: booking.passengers
                        .map((p) => '${p.name} (${p.age}, ${p.gender})')
                        .join(', '),
                  ),
                  _SummaryRow(
                    label: 'Total Fare',
                    value: _currencyFormat.format(booking.totalFare),
                  ),
                  _SummaryRow(
                    label: 'Status',
                    value: booking.status,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _confirmedBookingResult = null;
                  });
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('View In My Bookings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: const Color(0xFF04151D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _confirmedBookingResult = null;
                    _selectedTrain = null;
                  });
                  widget.onNavigateToJourney();
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text('Book Another Train'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: Color(0x33FFFFFF)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookingsView(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PNR Lookup Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xCC0E1A29),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track Any Ticket by 10-Digit PNR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your reservation PNR number to check live booking status and passenger itinerary.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pnrSearchController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter 10-digit PNR (e.g. 6366261058)',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      onSubmitted: (_) => _searchPnr(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _isSearchingPnr ? null : _searchPnr,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: const Color(0xFF04151D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSearchingPnr
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF04151D),
                            ),
                          )
                        : const Text('Track PNR'),
                  ),
                ],
              ),

              // PNR Error
              if (_pnrSearchError != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x1AEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x33EF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: Color(0xFFF87171),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _pnrSearchError!,
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Searched Booking Card
              if (_searchedBooking != null) ...[
                const SizedBox(height: 18),
                _BookingCard(
                  booking: _searchedBooking!,
                  currencyFormat: _currencyFormat,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),

        // User's Saved Bookings List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Recent Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  _fetchMyBookings(email);
                }
              },
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.primary,
              ),
              tooltip: 'Refresh Bookings',
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_isLoadingMyBookings)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppTheme.primary),
          )
        else if (_myBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xCC0E1A29),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 40,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 12),
                Text(
                  'No bookings found on this account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Book a train ticket to view your confirmation and PNR status here.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myBookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _BookingCard(
                booking: _myBookings[index],
                currencyFormat: _currencyFormat,
              );
            },
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: highlight ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.currencyFormat,
  });

  final Booking booking;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCC0E1A29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1A5EEAD4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'PNR: ${booking.pnr}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        const Icon(Icons.copy_rounded, size: 16, color: AppTheme.primary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: booking.pnr));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PNR copied to clipboard!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    },
                    tooltip: 'Copy PNR',
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x2234D399),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x5534D399)),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${booking.trainName} (#${booking.trainNumber})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${booking.source} → ${booking.destination}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            children: [
              Text(
                'Date: ${booking.journeyDate}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                'Class: ${booking.travelClass}',
                style: const TextStyle(fontSize: 12, color: AppTheme.accent),
              ),
              Text(
                'Fare: ${currencyFormat.format(booking.totalFare)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
