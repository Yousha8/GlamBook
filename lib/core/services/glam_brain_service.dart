import '../../data/models/user_model.dart';
import '../../data/models/service_model.dart';
import '../../domain/ai_assistant/models/recommended_service_result.dart';

/// Response object from the Expert System Brain
class BrainResponse {
  final String message;
  final List<RecommendedServiceResult> topServices;
  
  BrainResponse(this.message, this.topServices);
}

/// A Robust Local Expert System for the GlamBook Assistant.
/// This system operates 100% offline using deterministic rule-based logic,
/// keyword scoring, and dynamic template generation.
class GlamBrainService {
  final List<ServiceModel> _services;
  final List<CategoryModel> _categories;

  GlamBrainService(this._services, this._categories);

  /// Generates a realistic, context-aware response AND ranked services using local logic rules.
  BrainResponse generateExpertReply(String query, UserModel? profile) {
    if (_services.isEmpty) return BrainResponse(_handleEmptyState(), []);

    final normalized = query.toLowerCase().trim();
    final tokens = normalized.split(RegExp(r'[^\w]')).where((t) => t.length > 2).toList();
    
    // 1. Identify Intent
    final intent = _detectIntent(normalized);
    
    // 2. Rank Services based on Query + Profile
    final scoredServices = _calculateServiceScores(tokens, profile);
    
    // Convert to domain models for consistency
    final topServices = scoredServices
        .take(3)
        .map((s) => RecommendedServiceResult(
              service: s.service,
              score: s.score,
              reasons: [s.score > 10 ? "Matches your query perfectly." : "Best match for your request."],
            ))
        .toList();

    // 3. Handle Special Comparison Intent
    if (intent == _BotIntent.comparison) {
      return BrainResponse(_generateComparisonResponse(tokens, scoredServices), topServices);
    }

    // 4. Assemble Final Response
    final message = _assembleResponse(intent, scoredServices, profile, normalized);
    return BrainResponse(message, topServices);
  }

  // --- Core Engine Logic ---

  _BotIntent _detectIntent(String query) {
    if (_containsAny(query, ['hi', 'hello', 'hey', 'start', 'greetings', 'morning', 'afternoon'])) return _BotIntent.greeting;
    if (_containsAny(query, ['price', 'cost', 'how much', 'charge', 'expensive', 'cheap', 'pkr'])) return _BotIntent.pricing;
    if (_containsAny(query, ['book', 'schedule', 'appointment', 'reserve', 'get me in'])) return _BotIntent.booking;
    if (_containsAny(query, ['vs', 'compare', 'difference', 'better than', 'or'])) return _BotIntent.comparison;
    if (_containsAny(query, ['skin', 'face', 'hair', 'massage', 'recommend', 'suggest', 'best for', 'need'])) return _BotIntent.recommendation;
    return _BotIntent.general;
  }

  List<_ScoredService> _calculateServiceScores(List<String> tokens, UserModel? profile) {
    final results = _services.map((s) {
      double score = 0.0;
      final name = s.name.toLowerCase();
      final desc = s.description.toLowerCase();
      final tags = s.suitabilityTags.map((t) => t.toLowerCase()).toList();

      for (var token in tokens) {
        // High weight for name matches
        if (name.contains(token)) score += 10.0;
        // Moderate weight for tags
        if (tags.any((t) => t.contains(token))) score += 7.0;
        // Lower weight for description
        if (desc.contains(token)) score += 3.0;
      }

      // Profile Match Boost
      if (profile != null) {
        if (profile.skinType != null && tags.any((t) => t.contains(profile.skinType!.toLowerCase()))) score += 5.0;
        if (profile.hairType != null && tags.any((t) => t.contains(profile.hairType!.toLowerCase()))) score += 5.0;
        
        // Safety Penalty
        if (profile.skinSensitivity == 'High' && (s.precautions?.toLowerCase().contains('sensitive') ?? false)) {
          score -= 20.0;
        }
      }

      // Popularity/Featured Boost
      if (s.isFeatured) score += 2.0;

      return _ScoredService(s, score);
    }).toList();

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  // --- Response Assembly (NLG Templates) ---

  String _assembleResponse(_BotIntent intent, List<_ScoredService> scores, UserModel? profile, String raw) {
    final top = scores.first;
    final userName = profile?.fullName.split(' ').first ?? 'there';

    if (intent == _BotIntent.greeting) {
      return "Hello $userName! ✨ I am your GlamBot Expert System. I can help you find treatments, check prices, or compare different services. How can I pamper you today?";
    }

    if (scores.where((s) => s.score > 0).isEmpty && intent != _BotIntent.booking) {
      return "I couldn't find an exact match for your request, but I'd suggest our **${top.service.name}**—it's highly rated! Would you like to know more about it?";
    }

    switch (intent) {
      case _BotIntent.pricing:
        return "The **${top.service.name}** is currently priced at **PKR ${top.service.price.toInt()}**. It's a ${top.service.durationMinutes}-minute treatment. Shall I help you book it?";
      
      case _BotIntent.booking:
        return "Excellent choice! I can help you schedule a **${top.service.name}**. Simply tap 'Book Appointment' below to choose your favorite therapist and time slot.";
      
      case _BotIntent.recommendation:
        String reason = profile != null && top.service.suitabilityTags.any((t) => t.toLowerCase().contains(profile.skinType?.toLowerCase() ?? '')) 
            ? "Since you mentioned ${profile.skinType} skin, the " 
            : "Based on our menu, I highly recommend the ";
        return "$reason**${top.service.name}**. ${top.service.description} It's currently PKR ${top.service.price.toInt()}.";

      case _BotIntent.general:
      default:
        return "Looking at our current catalog, the **${top.service.name}** seems like a great fit! It costs PKR ${top.service.price.toInt()}. Would you like more details?";
    }
  }

  String _generateComparisonResponse(List<String> tokens, List<_ScoredService> scores) {
    final validMatches = scores.where((s) => s.score > 5).toList();
    if (validMatches.length < 2) {
      return "I can compare any two services for you! For example, try asking 'Compare Hydrafacial and Cleanup'.";
    }

    final s1 = validMatches[0].service;
    final s2 = validMatches[1].service;

    StringBuffer sb = StringBuffer();
    sb.writeln("Let's look at how they compare:");
    sb.writeln("\n**${s1.name}** (PKR ${s1.price.toInt()}): Best for ${s1.suitabilityTags.take(2).join(' & ')}. Takes ${s1.durationMinutes} mins.");
    sb.writeln("**${s2.name}** (PKR ${s2.price.toInt()}): Best for ${s2.suitabilityTags.take(2).join(' & ')}. Takes ${s2.durationMinutes} mins.");
    
    if (s1.price > s2.price) {
      sb.writeln("\nThe ${s2.name} is the more budget-friendly option, while ${s1.name} offers a more premium experience.");
    } else if (s1.price < s2.price) {
      sb.writeln("\nThe ${s1.name} is more economical, while ${s2.name} is our premium choice.");
    } else {
      sb.writeln("\nBoth are priced similarly, so your choice depends on whether you prefer ${_getCoreBenefit(s1)} or ${_getCoreBenefit(s2)}.");
    }
    
    return sb.toString();
  }

  String _getCoreBenefit(ServiceModel s) {
    if (s.suitabilityTags.isNotEmpty) return s.suitabilityTags.first.toLowerCase();
    return "relaxation";
  }

  String _handleEmptyState() {
    return "I'm currently updating our salon menu... ✨ Please try again in a moment!";
  }

  bool _containsAny(String query, List<String> keywords) {
    for (var k in keywords) {
      if (RegExp(r'\b' + k + r'\b').hasMatch(query)) return true;
    }
    return false;
  }
}

enum _BotIntent { greeting, pricing, recommendation, booking, comparison, general }

class _ScoredService {
  final ServiceModel service;
  final double score;
  _ScoredService(this.service, this.score);
}
