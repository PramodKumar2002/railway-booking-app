import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/user_session.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_footer.dart';
import 'package:my_app/widgets/feature_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onNavigateToJourney,
    required this.onNavigateToBooking,
    required this.onSearchRoute,
    required this.onNavigateTab,
  });

  final VoidCallback onNavigateToJourney;
  final VoidCallback onNavigateToBooking;
  final void Function(String source, String destination, DateTime date)
      onSearchRoute;
  final ValueChanged<int> onNavigateTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _sourceStation = 'New Delhi (NDLS)';
  String _destinationStation = 'Mumbai Central (MMCT)';
  DateTime _journeyDate = DateTime.now().add(const Duration(days: 1));

  static const List<String> stationOptions = [
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _journeyDate,
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
      final temp = _sourceStation;
      _sourceStation = _destinationStation;
      _destinationStation = temp;
    });
  }

  void _submitQuickSearch() {
    if (_sourceStation == _destinationStation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and destination stations must be different.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    widget.onSearchRoute(_sourceStation, _destinationStation, _journeyDate);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HERO SECTION with Background Image & Gradient Overlay
          Stack(
            children: [
              // Railway Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/railway_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Graceful dark fallback if asset is missing or loading
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF07131E), Color(0xFF0F263B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dark Navy Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xF207131E),
                        const Color(0xD90A1A2A),
                        const Color(0xFA07131E),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Hero Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 60 : 20,
                  vertical: isDesktop ? 64 : 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Welcoming Badge
                    ListenableBuilder(
                      listenable: UserSession(),
                      builder: (context, _) {
                        final session = UserSession();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.train_rounded,
                                color: AppTheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                session.isAuthenticated
                                    ? 'Welcome back, ${session.displayName} • Express Indian Railways'
                                    : 'Premier Indian Railway Reservation Portal',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Main Heading
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: Text(
                        'Your Journey Begins Here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 50 : 34,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Text(
                        'Book your train tickets with ease and travel comfortably to your destination.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 15,
                          color: AppTheme.textSecondary.withValues(alpha: 0.9),
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Call To Action Buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _HeroButton(
                          title: 'Book Your Ticket',
                          icon: Icons.confirmation_number_rounded,
                          isPrimary: true,
                          onPressed: widget.onNavigateToBooking,
                        ),
                        _HeroButton(
                          title: 'Explore Journeys',
                          icon: Icons.explore_rounded,
                          isPrimary: false,
                          onPressed: widget.onNavigateToJourney,
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Quick Search Bar Card
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Container(
                        padding: EdgeInsets.all(isDesktop ? 24 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xF20F1D2C),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Quick Train Search',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Live Seat Availability',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accent.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Source
                                  Expanded(
                                    flex: 3,
                                    child: _StationDropdownField(
                                      label: 'From Station',
                                      value: _sourceStation,
                                      options: stationOptions,
                                      icon: Icons.trip_origin_rounded,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _sourceStation = val);
                                        }
                                      },
                                    ),
                                  ),

                                  // Swap button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
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

                                  // Destination
                                  Expanded(
                                    flex: 3,
                                    child: _StationDropdownField(
                                      label: 'To Destination',
                                      value: _destinationStation,
                                      options: stationOptions,
                                      icon: Icons.location_on_rounded,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                              () => _destinationStation = val);
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Date Picker
                                  Expanded(
                                    flex: 2,
                                    child: _DateSelectorTile(
                                      date: _journeyDate,
                                      onTap: _selectDate,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Submit button
                                  ElevatedButton.icon(
                                    onPressed: _submitQuickSearch,
                                    icon: const Icon(
                                      Icons.search_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Find Trains'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: const Color(0xFF04151D),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              // Mobile layout
                              Column(
                                children: [
                                  _StationDropdownField(
                                    label: 'From Station',
                                    value: _sourceStation,
                                    options: stationOptions,
                                    icon: Icons.trip_origin_rounded,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _sourceStation = val);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _swapStations,
                                      icon: const Icon(
                                        Icons.swap_vert_rounded,
                                        size: 18,
                                        color: AppTheme.primary,
                                      ),
                                      label: const Text(
                                        'Swap Route',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _StationDropdownField(
                                    label: 'To Destination',
                                    value: _destinationStation,
                                    options: stationOptions,
                                    icon: Icons.location_on_rounded,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(
                                            () => _destinationStation = val);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _DateSelectorTile(
                                    date: _journeyDate,
                                    onTap: _selectDate,
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _submitQuickSearch,
                                      icon: const Icon(Icons.search_rounded),
                                      label: const Text('Find Trains'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        foregroundColor:
                                            const Color(0xFF04151D),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // KEY METRICS / STATISTICS SECTION
          Container(
            color: const Color(0xFF081524),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: 36,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 24,
              runSpacing: 20,
              children: const [
                _StatItem(
                  icon: Icons.train_rounded,
                  value: '500+',
                  label: 'Daily Express Trains',
                ),
                _StatItem(
                  icon: Icons.groups_rounded,
                  value: '10M+',
                  label: 'Happy Passengers',
                ),
                _StatItem(
                  icon: Icons.timer_rounded,
                  value: '99.8%',
                  label: 'On-Time Tracking',
                ),
                _StatItem(
                  icon: Icons.support_agent_rounded,
                  value: '24/7',
                  label: 'Helpline Support',
                ),
              ],
            ),
          ),

          // CORE FEATURES SECTION (Requested 4 Cards)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: 56,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'WHY TRAVEL WITH US',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crafted For Modern Railway Commuters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 32 : 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: const Text(
                    'Experience unmatched speed, accurate seat matrices, instant PNR issuance, and world-class service throughout your journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 4 Requested Feature Cards:
                // 1. Easy Online Booking
                // 2. Fast Train Search
                // 3. Secure Reservations
                // 4. Comfortable Journeys
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = isDesktop
                        ? (constraints.maxWidth - 48) / 4
                        : isTablet
                            ? (constraints.maxWidth - 20) / 2
                            : constraints.maxWidth;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.confirmation_number_rounded,
                            title: 'Easy Online Booking',
                            description:
                                'Book confirmed train tickets in just 3 steps with zero hassle and instant PNR generation.',
                            badge: 'Instant',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.speed_rounded,
                            title: 'Fast Train Search',
                            description:
                                'Real-time schedule lookups across Indian Railways with live seat availability and fares.',
                            badge: 'Real-time',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.security_rounded,
                            title: 'Secure Reservations',
                            description:
                                'Encrypted payments, verified identity protocols, and database-backed ticket confirmations.',
                            badge: '256-Bit SSL',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.airline_seat_recline_extra_rounded,
                            title: 'Comfortable Journeys',
                            description:
                                'Choose your preferred class — 1AC, 2AC, 3AC, or Sleeper with berth selection flexibility.',
                            badge: 'Premium',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // POPULAR ROUTES SHOWCASE
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POPULAR ROUTES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Trending Train Corridors',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: widget.onNavigateToJourney,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('View All Routes'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = isDesktop
                        ? (constraints.maxWidth - 32) / 3
                        : isTablet
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _RouteCard(
                            from: 'New Delhi (NDLS)',
                            to: 'Mumbai Central (MMCT)',
                            trainName: 'Mumbai Rajdhani Express',
                            trainNo: '12952',
                            duration: '15h 40m',
                            fareFrom: '₹820',
                            onTap: () => widget.onSearchRoute(
                              'New Delhi (NDLS)',
                              'Mumbai Central (MMCT)',
                              DateTime.now().add(const Duration(days: 1)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _RouteCard(
                            from: 'New Delhi (NDLS)',
                            to: 'Varanasi Junction (BSB)',
                            trainName: 'Vande Bharat Express',
                            trainNo: '22436',
                            duration: '8h 00m',
                            fareFrom: '₹1,750',
                            onTap: () => widget.onSearchRoute(
                              'New Delhi (NDLS)',
                              'Varanasi Junction (BSB)',
                              DateTime.now().add(const Duration(days: 1)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _RouteCard(
                            from: 'Bengaluru City (SBC)',
                            to: 'Ernakulam Junction (ERS)',
                            trainName: 'InterCity SF Express',
                            trainNo: '12677',
                            duration: '10h 45m',
                            fareFrom: '₹360',
                            onTap: () => widget.onSearchRoute(
                              'Bengaluru City (SBC)',
                              'Ernakulam Junction (ERS)',
                              DateTime.now().add(const Duration(days: 1)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Footer placed at the very bottom of the Home page scroll
          AppFooter(onNavigateTab: widget.onNavigateTab),
        ],
      ),
    );
  }
}

class _HeroButton extends StatefulWidget {
  const _HeroButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? (_isHovered ? const Color(0xFF14B8A6) : AppTheme.primary)
              : (_isHovered
                  ? const Color(0x2E5EEAD4)
                  : const Color(0x14FFFFFF)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isPrimary
                ? AppTheme.primary
                : (_isHovered ? AppTheme.primary : const Color(0x33FFFFFF)),
            width: 1.5,
          ),
          boxShadow: widget.isPrimary && _isHovered
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 19,
                    color: widget.isPrimary
                        ? const Color(0xFF04151D)
                        : AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: widget.isPrimary
                        ? const Color(0xFF04151D)
                        : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StationDropdownField extends StatelessWidget {
  const _StationDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
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
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F1B2B),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primary,
              ),
              items: options.map((station) {
                return DropdownMenuItem<String>(
                  value: station,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          station,
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

class _DateSelectorTile extends StatelessWidget {
  const _DateSelectorTile({
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('EEE, dd MMM yyyy').format(date);

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
                    formatted,
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

class _RouteCard extends StatefulWidget {
  const _RouteCard({
    required this.from,
    required this.to,
    required this.trainName,
    required this.trainNo,
    required this.duration,
    required this.fareFrom,
    required this.onTap,
  });

  final String from;
  final String to;
  final String trainName;
  final String trainNo;
  final String duration;
  final String fareFrom;
  final VoidCallback onTap;

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xE6132236) : const Color(0xCC0E1A29),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? AppTheme.primary.withValues(alpha: 0.5)
                : const Color(0x22FFFFFF),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${widget.trainNo}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                Text(
                  'From ${widget.fareFrom}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.trainName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.from,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppTheme.accent,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.to,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Check Availability'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
