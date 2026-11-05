import 'package:flutter/material.dart';
import 'package:my_app/models/user_session.dart';
import 'package:my_app/theme/app_theme.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onOpenDrawer,
    required this.onLogout,
  });

  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onOpenDrawer;
  final VoidCallback onLogout;

  static const List<String> navTitles = [
    'Home',
    'About',
    'Journey',
    'Book Ticket',
    'Contact',
  ];

  static const List<IconData> navIcons = [
    Icons.home_rounded,
    Icons.info_outline_rounded,
    Icons.explore_rounded,
    Icons.confirmation_number_rounded,
    Icons.mail_outline_rounded,
  ];

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 860;

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xF207131E),
        border: const Border(
          bottom: BorderSide(color: Color(0x22FFFFFF), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          // Railway Brand / Logo
          InkWell(
            onTap: () => onTabSelected(0),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.train_rounded,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Railway Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'IRCTC Express Travel',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary.withValues(alpha: 0.8),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Desktop Navigation Links
          if (isDesktop) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(navTitles.length, (index) {
                final isSelected = activeIndex == index;
                return _NavItem(
                  title: navTitles[index],
                  icon: navIcons[index],
                  isSelected: isSelected,
                  onTap: () => onTabSelected(index),
                );
              }),
            ),
            const SizedBox(width: 20),

            // User Info & Logout Button
            ListenableBuilder(
              listenable: UserSession(),
              builder: (context, _) {
                final session = UserSession();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (session.isAuthenticated) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A5EEAD4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_circle_rounded,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              session.displayName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    _LogoutButton(onPressed: onLogout),
                  ],
                );
              },
            ),
          ] else ...[
            // Mobile Hamburger Button
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppTheme.textPrimary,
                size: 28,
              ),
              onPressed: onOpenDrawer,
              tooltip: 'Open Menu',
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;
    final hovered = _isHovered;

    final textColor = active
        ? AppTheme.primary
        : hovered
            ? Colors.white
            : AppTheme.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary.withValues(alpha: 0.12)
                : hovered
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Animated underline
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: active ? 28 : (hovered ? 18 : 0),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.primary
                      : AppTheme.accent.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0x33EF4444)
              : const Color(0x1AEF4444),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFEF4444)
                : const Color(0x66EF4444),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: Color(0xFFFCA5A5),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFCA5A5),
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
