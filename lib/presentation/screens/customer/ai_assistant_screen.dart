import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/glam_bot_providers.dart';
import '../../../domain/ai_assistant/models/ai_conversation_turn.dart';
import '../../../domain/ai_assistant/models/ai_assistant_action.dart';
import '../../../domain/ai_assistant/models/recommended_service_result.dart';
import '../../../data/models/service_model.dart';
import 'service_detail_screen.dart';
import 'booking_screen.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;
    _messageController.clear();
    setState(() => _isTyping = true);
    _scrollToBottom();

    final userProfile = ref.read(currentUserDataProvider).value;
    final services = ref.read(allServicesProvider).value ?? [];
    final categories = ref.read(allCategoriesProvider).value ?? [];
    
    final coordinator = await ref.read(salonAiCoordinatorProvider.future);
    
    // Process query
    await coordinator.processQuery(text, userProfile, services, categories);
    
    if (mounted) {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _clearHistory() async {
    final coordinator = await ref.read(salonAiCoordinatorProvider.future);
    await coordinator.clearMemory();
    setState(() {});
  }

  void _handleAction(AiAssistantAction action, List<ServiceModel> allServices) {
    if (action.type == AiActionType.openBookingSheet || action.type == AiActionType.openServiceDetails) {
       final serviceId = action.payload?['serviceId'];
       if (serviceId != null) {
          try {
            final service = allServices.firstWhere((s) => s.id == serviceId);
            if (action.type == AiActionType.openBookingSheet) {
               Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(service: service)));
            } else {
               Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
            }
          } catch(e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service currently unavailable.')),
            );
          }
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coordinatorAsync = ref.watch(salonAiCoordinatorProvider);
    final servicesAsync = ref.watch(allServicesProvider);
    
    final bool isReady = coordinatorAsync.hasValue && servicesAsync.hasValue && servicesAsync.value!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GlamBot Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              isReady ? 'Powered by GlamBot Expert System' : 'Syncing salon menu...',
              style: TextStyle(
                fontSize: 11, 
                color: isReady ? AppColors.vibrantPink.withOpacity(0.7) : Colors.orange,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.deepMagenta,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Memory?'),
                  content: const Text('This will delete all current conversation context.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearHistory();
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: !isReady 
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final coordinator = coordinatorAsync.value!;
                final turns = coordinator.getHistory();

                if (turns.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.face_retouching_natural, size: 60, color: AppColors.lightPink),
                          const SizedBox(height: 16),
                          const Text('How can we pamper you today?', style: TextStyle(fontSize: 18, color: Colors.black54)),
                          const SizedBox(height: 24),
                          _buildSuggestionChip('Recommend a facial for oily skin'),
                          _buildSuggestionChip('Price of hydrafacial'),
                          _buildSuggestionChip('Compare cleanup and hydrafacial'),
                          _buildSuggestionChip('I am stressed, need to relax'),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: turns.length,
                  itemBuilder: (context, index) {
                    final turn = turns[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User message bubble
                        _ChatBubble(text: turn.userMessage, isBot: false),
                        const SizedBox(height: 12),
                        // Bot message bubble + interactive elements
                        _ChatBubble(
                          text: turn.reply.message, 
                          isBot: true,
                          action: turn.reply.action,
                          onActionTap: () => _handleAction(turn.reply.action, servicesAsync.value ?? []),
                        ),
                        // Recommendation Cards if any
                        if (turn.reply.recommendedServices.isNotEmpty)
                           _buildRecommendations(turn.reply.recommendedServices, servicesAsync.value ?? []),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (_isTyping)
            FadeIn(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.vibrantPink)),
                    ),
                    const SizedBox(width: 12),
                    Text('GlamBot is thinking...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white, 
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (val) => _sendMessage(val),
                    decoration: InputDecoration(
                      hintText: 'Type your beauty query...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _sendMessage(_messageController.text.trim()),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.vibrantPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.deepMagenta)),
        backgroundColor: AppColors.lightPink.withOpacity(0.3),
        side: const BorderSide(color: AppColors.lightPink),
        onPressed: () {
          _messageController.text = text;
          _sendMessage(text);
        },
      ),
    );
  }

  Widget _buildRecommendations(List<RecommendedServiceResult> recs, List<ServiceModel> allServices) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16),
        itemCount: recs.length,
        itemBuilder: (context, index) {
          final rec = recs[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rec.service.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(rec.service.imageUrl, height: 80, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(height: 80, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey))),
                  )
                else
                  Container(height: 80, decoration: const BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.vertical(top: Radius.circular(16)))),
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rec.service.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('PKR ${rec.service.price.toInt()} • ${rec.service.durationMinutes} mins', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Score: ${(rec.score).toInt()}', style: TextStyle(fontSize: 10, color: Colors.green[700], fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(service: rec.service)));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.deepMagenta, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final AiAssistantAction? action;
  final VoidCallback? onActionTap;

  const _ChatBubble({required this.text, required this.isBot, this.action, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      from: 10,
      child: Align(
        alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isBot ? Colors.white : AppColors.vibrantPink,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isBot ? 0 : 20),
              bottomRight: Radius.circular(isBot ? 20 : 0),
            ),
            boxShadow: [
              if (isBot) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4)),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isBot ? Colors.black87 : Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                if (action != null && action!.type != AiActionType.none && action!.type != AiActionType.showRecommendations)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepMagenta,
                        side: const BorderSide(color: AppColors.deepMagenta),
                        minimumSize: const Size(double.infinity, 36),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: onActionTap,
                      child: Text(action!.type == AiActionType.openBookingSheet ? 'Book Appoinment' : 'View Details'),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
