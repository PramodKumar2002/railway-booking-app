import 'package:flutter/material.dart';
import 'package:my_app/models/train.dart';
import 'package:my_app/screens/tabs/about_tab.dart';
import 'package:my_app/screens/tabs/contact_tab.dart';
import 'package:my_app/screens/tabs/home_tab.dart';
import 'package:my_app/screens/tabs/journey_tab.dart';
import 'package:my_app/screens/tabs/ticket_booking_tab.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_navbar.dart';
import 'package:my_app/widgets/logout_dialog.dart';
import 'package:my_app/widgets/responsive_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _activeTabIndex;

  // Shared state for navigation across tabs
  String? _journeySource;
  String? _journeyDestination;
  DateTime? _journeyDate;

  Train? _bookingTrain;
  String? _bookingClass;
  DateTime? _bookingDate;
  int? _bookingPassengerCount;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() => _activeTabIndex = index);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _confirmLogout() {
    LogoutDialog.show(context);
  }

  void _handleQuickSearchFromHome(
    String source,
    String destination,
    DateTime date,
  ) {
    setState(() {
      _journeySource = source;
      _journeyDestination = destination;
      _journeyDate = date;
      _activeTabIndex = 2; // Switch to Journey Tab
    });
  }

  void _handleBookNowFromTrain(
    Train train,
    String selectedClass,
    DateTime journeyDate,
    int passengerCount,
  ) {
    setState(() {
      _bookingTrain = train;
      _bookingClass = selectedClass;
      _bookingDate = journeyDate;
      _bookingPassengerCount = passengerCount;
      _activeTabIndex = 3; // Switch to Ticket Booking Tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      drawer: ResponsiveDrawer(
        activeIndex: _activeTabIndex,
        onTabSelected: _onTabSelected,
        onLogout: _confirmLogout,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Desktop / Mobile Navbar
            AppNavbar(
              activeIndex: _activeTabIndex,
              onTabSelected: _onTabSelected,
              onOpenDrawer: _openDrawer,
              onLogout: _confirmLogout,
            ),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _activeTabIndex,
                children: [
                  // Tab 0: Home Page / Hero (Footer is at the end of scroll)
                  HomeTab(
                    onNavigateToJourney: () => _onTabSelected(2),
                    onNavigateToBooking: () => _onTabSelected(3),
                    onSearchRoute: _handleQuickSearchFromHome,
                    onNavigateTab: _onTabSelected,
                  ),

                  // Tab 1: About Page
                  AboutTab(
                    onNavigateToJourney: () => _onTabSelected(2),
                    onNavigateToContact: () => _onTabSelected(4),
                  ),

                  // Tab 2: Journey Page
                  JourneyTab(
                    key: ValueKey('$_journeySource-$_journeyDestination'),
                    initialSource: _journeySource,
                    initialDestination: _journeyDestination,
                    initialDate: _journeyDate,
                    onBookTrain: _handleBookNowFromTrain,
                  ),

                  // Tab 3: Ticket Booking Page
                  TicketBookingTab(
                    key: ValueKey(_bookingTrain?.trainNumber ?? 'no-train'),
                    initialTrain: _bookingTrain,
                    initialClass: _bookingClass,
                    initialDate: _bookingDate,
                    initialPassengerCount: _bookingPassengerCount,
                    onNavigateToJourney: () => _onTabSelected(2),
                  ),

                  // Tab 4: Contact Page
                  const ContactTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
