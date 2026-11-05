import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({
    super.key,
    required this.onNavigateTab,
  });

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF040A12),
        border: Border(
          top: BorderSide(color: Color(0x1FFFFFFF), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 24,
        vertical: 48,
      ),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Railway Booking',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Your premier online gateway for seamless railway travel, instant train seat availability, verified PNR tracking, and secure reservations across India.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _SecurityBadge(
                            icon: Icons.security_rounded,
                            label: '256-Bit SSL Encrypted',
                          ),
                          const SizedBox(width: 12),
                          _SecurityBadge(
                            icon: Icons.verified_rounded,
                            label: 'Instant Confirmation',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // Quick Links
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FooterLink(title: 'Home', onTap: () => onNavigateTab(0)),
                      _FooterLink(title: 'About Platform', onTap: () => onNavigateTab(1)),
                      _FooterLink(title: 'Search Trains & Journey', onTap: () => onNavigateTab(2)),
                      _FooterLink(title: 'Book Ticket & PNR', onTap: () => onNavigateTab(3)),
                      _FooterLink(title: 'Contact Support', onTap: () => onNavigateTab(4)),
                    ],
                  ),
                ),

                // Travel & Assistance
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assistance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FooterInfo(
                        icon: Icons.phone_in_talk_rounded,
                        text: 'Toll-Free Helpline: 139',
                      ),
                      _FooterInfo(
                        icon: Icons.email_rounded,
                        text: 'support@railwaybooking.in',
                      ),
                      _FooterInfo(
                        icon: Icons.schedule_rounded,
                        text: '24/7 Passenger Support',
                      ),
                      _FooterInfo(
                        icon: Icons.location_on_rounded,
                        text: 'Rail Bhavan, New Delhi, India',
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            // Mobile column layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(width: 10),
                    const Text(
                      'Railway Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Book your train tickets with ease and travel comfortably to your destination.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _FooterLink(title: 'Home', onTap: () => onNavigateTab(0)),
                    _FooterLink(title: 'About', onTap: () => onNavigateTab(1)),
                    _FooterLink(title: 'Journey', onTap: () => onNavigateTab(2)),
                    _FooterLink(title: 'Book Ticket', onTap: () => onNavigateTab(3)),
                    _FooterLink(title: 'Contact', onTap: () => onNavigateTab(4)),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 36),
          const Divider(color: Color(0x1AFFFFFF), height: 1),
          const SizedBox(height: 24),

          // Bottom Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '© 2026 Railway Booking App. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Built with Flutter & Node.js',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: AppTheme.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
