import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/feature_card.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({
    super.key,
    required this.onNavigateToJourney,
    required this.onNavigateToContact,
  });

  final VoidCallback onNavigateToJourney;
  final VoidCallback onNavigateToContact;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 60 : 20,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppTheme.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'About Railway Booking Platform',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Page Title
            Text(
              'Transforming Railway Travel\nAcross The Nation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 40 : 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'Railway Booking is an advanced, high-performance ticket reservation platform engineered to offer commuters lightning-fast train searches, guaranteed seat allocations, and hassle-free journeys across India.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Mission & Vision Section
            LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = isDesktop
                    ? (constraints.maxWidth - 24) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: boxWidth,
                      child: _VisionCard(
                        icon: Icons.flag_rounded,
                        title: 'Our Mission',
                        description:
                            'To democratize rail travel by delivering a unified, reliable, and accessible booking experience that eliminates wait times, simplifies ticket management, and puts travelers first.',
                        accentColor: AppTheme.primary,
                      ),
                    ),
                    SizedBox(
                      width: boxWidth,
                      child: _VisionCard(
                        icon: Icons.remove_red_eye_rounded,
                        title: 'Our Vision',
                        description:
                            'To become the benchmark railway booking digital ecosystem in India, integrating smart AI routing, instantaneous PNR verification, and unified multi-modal passenger convenience.',
                        accentColor: AppTheme.accent,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 60),

            // WHY CHOOSE US?
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'PILLARS OF EXCELLENCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Why Choose Railway Booking?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 30 : 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const Text(
                    'Built on modern cloud architecture to deliver the fastest, most secure, and intuitive train ticket booking experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

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
                            icon: Icons.touch_app_rounded,
                            title: 'Easy Booking',
                            description:
                                'Seamless 3-step reservation flow with instant seat selection and pre-filled passenger details.',
                            badge: 'Effortless',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.lock_person_rounded,
                            title: 'Secure Authentication',
                            description:
                                'Military-grade bcrypt password hashing and tokenized JWT sessions keep your data safe.',
                            badge: 'Protected',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.map_rounded,
                            title: 'Convenient Planning',
                            description:
                                'Comprehensive station schedules, real-time seat matrices, and live fare breakdowns across all classes.',
                            badge: 'Smart Routes',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: const FeatureCard(
                            icon: Icons.devices_rounded,
                            title: 'Responsive Design',
                            description:
                                'Flawlessly optimized for Android phones, iPhones, tablets, laptops, and modern web browsers.',
                            badge: 'Universal',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Technology & Security Section
            Container(
              padding: EdgeInsets.all(isDesktop ? 36 : 24),
              decoration: BoxDecoration(
                color: const Color(0xCC0E1A29),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x22FFFFFF)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  return Row(
                    children: [
                      if (isWide) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: AppTheme.primary,
                            size: 48,
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Verified Database Persistence & Real PNRs',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Every reservation submitted on this platform communicates directly with our high-availability backend cluster. Tickets are assigned authentic 10-digit PNR references, persisted permanently, and instantly retrievable anytime.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary.withValues(alpha: 0.9),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: onNavigateToJourney,
                                  icon: const Icon(Icons.explore_rounded, size: 18),
                                  label: const Text('Start Exploring Trains'),
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
                                  onPressed: onNavigateToContact,
                                  icon: const Icon(Icons.support_agent_rounded,
                                      size: 18),
                                  label: const Text('Contact Our Team'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: const BorderSide(
                                      color: Color(0x33FFFFFF),
                                    ),
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
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  const _VisionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xCC0E1A29),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
