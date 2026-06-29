import '../../domain/ai_assistant/models/ai_assistant_intent.dart';

class IntentClassifier {
  AiAssistantIntent classify(String query, AiAssistantIntent? lastIntent) {
    final normalized = query.toLowerCase().trim();

    if (_matchesAny(normalized, ['hi', 'hello', 'hey', 'start', 'greetings', 'morning', 'afternoon'])) {
      return AiAssistantIntent.greeting;
    }

    if (_matchesAny(normalized, ['book', 'schedule', 'appointment', 'reserve', 'get me in', 'book me'])) {
      if (lastIntent == AiAssistantIntent.serviceRecommendation) {
        // "book the first one"
        return AiAssistantIntent.bookingRequest;
      }
      return AiAssistantIntent.bookingRequest;
    }

    if (_matchesAny(normalized, ['price', 'cost', 'how much', 'charge', 'expensive', 'cheap', 'pricing'])) {
      return AiAssistantIntent.priceInquiry;
    }

    if (_matchesAny(normalized, ['duration', 'how long', 'take', 'minutes', 'hours', 'time'])) {
      if (!normalized.contains('long hair') && !normalized.contains('long time no see')) {
        return AiAssistantIntent.durationInquiry;
      }
    }

    if (_matchesAny(normalized, ['compare', 'vs', 'difference', 'better for', 'or'])) {
      return AiAssistantIntent.compareServices;
    }

    if (_matchesAny(normalized, ['safe', 'allergy', 'pregnant', 'sensitive', 'downtime', 'redness', 'pain', 'hurt'])) {
      if (normalized.contains('after') || normalized.contains('before')) {
        return AiAssistantIntent.postTreatmentAdvice;
      }
      return AiAssistantIntent.salonPolicyQuestion; 
    }

    if (_matchesAny(normalized, ['recommend', 'suggest', 'best for', 'what should', 'need something'])) {
      if (_matchesAny(normalized, ['my profile', 'my skin', 'my hair'])) {
        return AiAssistantIntent.profileBasedRecommendation;
      } else if (_matchesAny(normalized, ['acne', 'oily', 'dry', 'frizzy', 'stress', 'relax', 'pain', 'damage'])) {
        return AiAssistantIntent.concernBasedAdvice;
      }
      return AiAssistantIntent.serviceRecommendation;
    }

    // Implicit concern based
    if (_matchesAny(normalized, ['acne', 'oily', 'dry', 'frizzy', 'stress', 'relax', 'damage', 'dandruff', 'wedding', 'event'])) {
       return AiAssistantIntent.concernBasedAdvice;
    }

    // Default to a general recommendation if they just mentioned a service type
    if (_matchesAny(normalized, ['facial', 'massage', 'haircut', 'color', 'spa'])) {
      return AiAssistantIntent.serviceRecommendation; 
    }

    return AiAssistantIntent.fallbackUnknown;
  }

  bool _matchesAny(String query, List<String> keywords) {
    // using regex for word boundaries ensures 'or' doesn't match 'color'
    for (var keyword in keywords) {
      if (RegExp(r'\b' + keyword + r'\b').hasMatch(query)) {
        return true;
      }
      // fallback for exact substring if regex fails on weird chars
      if (query.contains(keyword) && keyword.length > 3) {
         return true;
      }
    }
    return false;
  }
}
