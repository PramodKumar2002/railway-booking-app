import 'package:flutter/material.dart';
import 'package:my_app/models/user_session.dart';
import 'package:my_app/theme/app_theme.dart';

class ResponsiveDrawer extends StatelessWidget {
  const ResponsiveDrawer({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Home', 'icon': Icons.home_rounded},
    {'title': 'About', 'icon': Icons.info_outline_rounded},
    {'title': 'Journey', 'icon': Icons.explore_rounded},
    {'title': 'Book Ticket', 'icon': Icons.confirmation_number_rounded},
    {'title': 'Contact', 'icon': Icons.mail_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF07131E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x22FFFFFF), width: 1),
                ),
              ),
              child: ListenableBuilder(
                listenable: UserSession(),
                builder: (context, _) {
                  final session = UserSession();
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.train_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Railway Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              session.isAuthenticated
                                  ? (session.email ?? session.displayName)
                                  : 'Guest Passenger',
                              style: TextStyle(
                                fontSize: 12,
                                color: session.isAuthenticated
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Navigation Links
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isSelected = activeIndex == index;

                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 22,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).pop(); // Close drawer
                        onTabSelected(index);
                      },
                    ),
                  );
                },
              ),
            ),

            // Logout Action at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x1AEF4444),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x44EF4444)),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFFCA5A5),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    onLogout();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
