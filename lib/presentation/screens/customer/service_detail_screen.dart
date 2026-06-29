import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../core/providers/service_providers.dart';
import '../../widgets/shared/custom_button.dart';
import 'booking_screen.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDataProvider).value;
    final String skinType = user?.skinType ?? 'Unknown';
    
    // Risk Calculation Logic
    String riskLevel = 'Low';
    Color riskColor = Colors.green;
    String riskMessage = 'This service is generally safe for your skin type.';

    if (skinType.toLowerCase() == 'sensitive') {
      if (service.name.toLowerCase().contains('peel') || 
          service.name.toLowerCase().contains('chemical') ||
          service.description.toLowerCase().contains('strong')) {
        riskLevel = 'High';
        riskColor = Colors.red;
        riskMessage = 'Risk = High. This service may be too strong for sensitive skin.';
      } else {
        riskLevel = 'Medium';
        riskColor = Colors.orange;
        riskMessage = 'Risk = Medium. Please consult with our staff before booking.';
      }
    } else if (skinType.toLowerCase() == 'oily' && service.name.toLowerCase().contains('charcoal')) {
      riskLevel = 'Low';
      riskColor = Colors.green;
      riskMessage = 'Risk = Low. Perfectly suited for oily skin.';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.vibrantPink,
            leading: FadeIn(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(service.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black45],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.deepMagenta),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time_filled_rounded, size: 16, color: AppColors.vibrantPink.withOpacity(0.6)),
                                  const SizedBox(width: 6),
                                  Text('${service.durationMinutes} minutes', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.vibrantPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'PKR ${NumberFormat('#,###').format(service.price)}',
                            style: const TextStyle(color: AppColors.vibrantPink, fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const _SectionTitle(title: 'Overview'),
                    const SizedBox(height: 12),
                    Text(
                      service.description,
                      style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 15),
                    ),
                    
                    if (service.precautions != null && service.precautions!.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const _SectionTitle(title: 'Safety Precautions', color: Colors.orangeAccent),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withOpacity(0.1)),
                        ),
                        child: Text(
                          service.precautions!,
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 14),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    const _SectionTitle(title: 'AI Skin Analysis'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: riskColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: riskColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.shield_rounded, color: riskColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$riskLevel Risk Recommendation',
                                      style: TextStyle(color: riskColor, fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Based on your $skinType skin profile',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            riskMessage,
                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionTitle(title: 'Best Suited For'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: service.suitabilityTags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(fontSize: 13, color: AppColors.deepMagenta, fontWeight: FontWeight.bold),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 120), // Space for bottom sheet
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
          ],
        ),
        child: FadeInUp(
          child: CustomButton(
            text: 'Reserve Appointment',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(service: service),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;
  const _SectionTitle({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: color ?? AppColors.vibrantPink,
      ),
    );
  }
}
