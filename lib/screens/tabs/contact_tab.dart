import 'package:flutter/material.dart';
import 'package:my_app/models/user_session.dart';
import 'package:my_app/services/contact_service.dart';
import 'package:my_app/theme/app_theme.dart';

class ContactTab extends StatefulWidget {
  const ContactTab({super.key});

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final ContactService _contactService = ContactService();
  bool _isSubmitting = false;
  String? _successReferenceId;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final session = UserSession();
    _nameController.text = session.displayName == 'Passenger' ? '' : session.displayName;
    _emailController.text = session.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _successReferenceId = null;
      _successMessage = null;
    });

    try {
      final result = await _contactService.submitContactMessage(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        if (result.success) {
          _successReferenceId = result.referenceId;
          _successMessage = result.message;
          _subjectController.clear();
          _messageController.clear();
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
            content: Text('Error submitting inquiry: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
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
          vertical: 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        Icon(Icons.support_agent_rounded,
                            color: AppTheme.primary, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '24/7 Passenger Support & Assistance',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'We Are Here To Assist You',
                    style: TextStyle(
                      fontSize: isDesktop ? 36 : 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: const Text(
                      'Have an inquiry regarding train cancellations, booking assistance, refund queries, or special assistance? Reach out below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Two-column layout on Desktop
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;

                final formCard = Container(
                  padding: EdgeInsets.all(isDesktop ? 32 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0E1A29),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Send a Direct Message',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Success Alert
                        if (_successMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0x2234D399),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x5534D399),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF34D399),
                                  size: 26,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _successMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFF34D399),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (_successReferenceId != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Support Reference ID: ${_successReferenceId!}',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your name',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your full name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Address
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'passenger@example.com',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email.';
                            }
                            final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!regex.hasMatch(val.trim())) {
                              return 'Please enter a valid email format.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Subject
                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            hintText: 'e.g. Booking confirmation query',
                            prefixIcon: Icon(
                              Icons.subject_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a subject.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Message
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Message / Inquiry Details',
                            hintText: 'Provide detailed information about your travel request...',
                            alignLabelWithHint: true,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 10) {
                              return 'Please enter at least 10 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submitContact,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF04151D),
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              _isSubmitting
                                  ? 'Submitting to Support...'
                                  : 'Send Message',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: const Color(0xFF04151D),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                final infoCards = Column(
                  children: const [
                    _ContactInfoCard(
                      icon: Icons.phone_in_talk_rounded,
                      title: 'Railway Helpline (Toll-Free)',
                      subtitle: 'Dial 139 for 24/7 Security, Medical, and Inquiry assistance.',
                      badge: 'All India',
                      accentColor: AppTheme.primary,
                    ),
                    SizedBox(height: 14),
                    _ContactInfoCard(
                      icon: Icons.email_rounded,
                      title: 'Customer Care Email',
                      subtitle: 'support@railwaybooking.in\nAverage response time: under 2 hours',
                      badge: 'Fast Response',
                      accentColor: AppTheme.accent,
                    ),
                    SizedBox(height: 14),
                    _ContactInfoCard(
                      icon: Icons.location_city_rounded,
                      title: 'Headquarters',
                      subtitle: 'Railway Board, Rail Bhavan, Rafi Marg, New Delhi 110001, India',
                      badge: 'HQ',
                      accentColor: Color(0xFF34D399),
                    ),
                    SizedBox(height: 14),
                    _ContactInfoCard(
                      icon: Icons.emergency_rounded,
                      title: 'Emergency Rail Help',
                      subtitle: 'Dial 182 for RPF Security helpline across all running trains.',
                      badge: 'Emergency',
                      accentColor: Color(0xFFF87171),
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: formCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: infoCards),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      formCard,
                      const SizedBox(height: 24),
                      infoCards,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCC0E1A29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
