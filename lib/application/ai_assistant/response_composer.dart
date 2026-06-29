import '../../domain/ai_assistant/models/ai_assistant_intent.dart';
import '../../domain/ai_assistant/models/ai_assistant_reply.dart';
import '../../domain/ai_assistant/models/ai_assistant_action.dart';
import '../../domain/ai_assistant/models/recommended_service_result.dart';
import '../../domain/ai_assistant/models/parsed_ai_query.dart';

class ResponseComposer {
  AiAssistantReply composeGreeting(String? userName) {
    return AiAssistantReply(
      intent: AiAssistantIntent.greeting,
      message: "Hello${userName != null ? ' $userName' : ''}! ✨ I am your GlamBook Assistant. I can help you find the perfect treatment, answer questions about our services, or help you book an appointment. How can I pamper you today?",
      confidence: 1.0,
      action: AiAssistantAction.none(),
    );
  }

  AiAssistantReply composeRecommendation(ParsedAiQuery query, List<RecommendedServiceResult> results) {
    if (results.isEmpty) {
      return composeUnknownFallback(query);
    }

    final top = results.first;
    String message = "Based on what you told me, I highly recommend the **${top.service.name}**.";
    
    if (top.reasons.isNotEmpty) {
      message += " ${top.reasons.first}";
    }
    
    if (top.warnings.isNotEmpty) {
      message += "\n\n⚠️ ${top.warnings.first}";
    }
    
    return AiAssistantReply(
      intent: query.intent,
      message: message,
      confidence: 0.9,
      recommendedServices: results,
      warnings: top.warnings,
      action: AiAssistantAction(
        type: AiActionType.showRecommendations,
        payload: {'serviceId': top.service.id},
      ),
    );
  }

  AiAssistantReply composePriceAnswer(ParsedAiQuery query, List<RecommendedServiceResult> results) {
    if (results.isEmpty) {
      return composeUnknownFallback(query);
    }
    final top = results.first;
    final price = top.service.price.toInt();
    
    return AiAssistantReply(
      intent: AiAssistantIntent.priceInquiry,
      message: "The **${top.service.name}** is priced at PKR $price. It's a fantastic ${top.service.durationMinutes}-minute treatment. Would you like me to help you book it?",
      confidence: 0.9,
      recommendedServices: [top],
      warnings: top.warnings,
      action: AiAssistantAction(
        type: AiActionType.openServiceDetails,
        payload: {'serviceId': top.service.id},
      ),
    );
  }

  AiAssistantReply composeComparison(ParsedAiQuery query, List<RecommendedServiceResult> results) {
    if (results.length < 2) {
      return composeUnknownFallback(query);
    }
    
    final s1 = results[0].service;
    final s2 = results[1].service;

    String msg = "Let's compare them:\n\n";
    msg += "**${s1.name}**: PKR ${s1.price.toInt()} (${s1.durationMinutes} mins).\n*Best for:* ${s1.suitabilityTags.isNotEmpty ? s1.suitabilityTags.join(', ') : 'Overall care'}.\n\n";
    msg += "**${s2.name}**: PKR ${s2.price.toInt()} (${s2.durationMinutes} mins).\n*Best for:* ${s2.suitabilityTags.isNotEmpty ? s2.suitabilityTags.join(', ') : 'Overall care'}.";

    return AiAssistantReply(
      intent: AiAssistantIntent.compareServices,
      message: msg,
      confidence: 0.85,
      recommendedServices: [results[0], results[1]],
      action: AiAssistantAction.none(),
    );
  }

  AiAssistantReply composeBookingPrompt(List<RecommendedServiceResult>? contextServices) {
    if (contextServices == null || contextServices.isEmpty) {
      return AiAssistantReply(
        intent: AiAssistantIntent.bookingRequest,
        message: "I'd love to help you book! Which service were you thinking of? You can name a specific treatment or just tell me what you need, like 'a haircut' or 'something for dry skin'.",
        confidence: 0.8,
        action: AiAssistantAction.none(),
      );
    }
    
    final topId = contextServices.first.service.id;
    return AiAssistantReply(
      intent: AiAssistantIntent.bookingRequest,
      message: "Great! Let's get you booked for the **${contextServices.first.service.name}**. Tap the button below to pick your preferred time.",
      confidence: 0.95,
      recommendedServices: contextServices,
      action: AiAssistantAction(
        type: AiActionType.openBookingSheet,
        payload: {'serviceId': topId},
      ),
    );
  }

  AiAssistantReply composeUnknownFallback(ParsedAiQuery query) {
    return AiAssistantReply(
      intent: AiAssistantIntent.fallbackUnknown,
      message: "I'm not completely sure I understood that. Could you tell me a bit more about what you're looking for? (e.g., 'What facials do you have?' or 'Price of Swedish Massage')",
      confidence: 0.1,
      action: AiAssistantAction.none(),
    );
  }
}
