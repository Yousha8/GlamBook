import '../../domain/ai_assistant/models/parsed_ai_query.dart';
import '../../domain/ai_assistant/models/recommended_service_result.dart';
import '../../data/models/service_model.dart';
import '../../data/models/user_model.dart';
import 'safety_rules_engine.dart';

class ServiceRecommendationEngine {
  final SafetyRulesEngine _safetyRules;

  ServiceRecommendationEngine(this._safetyRules);

  List<RecommendedServiceResult> rankServices(
    ParsedAiQuery query, 
    List<ServiceModel> allServices, 
    UserModel? profile
  ) {
    if (allServices.isEmpty) return [];

    final results = allServices.map((service) {
      double score = 0.0;
      List<String> reasons = [];
      List<String> matchedConcerns = [];
      List<String> matchedProfile = [];

      final lowerName = service.name.toLowerCase();
      final catId = service.categoryId.toLowerCase();
      final tags = service.suitabilityTags.map((e) => e.toLowerCase()).toList();
      final targetConcerns = service.targetConcerns.map((e) => e.toLowerCase()).toList();

      final lowerNameNoSpace = lowerName.replaceAll(' ', '');

      // 1. Explicit Service Name Match (Highest priority)
      for (var sName in query.serviceNames) {
        final sNameNoSpace = sName.toLowerCase().replaceAll(' ', '');
        if (lowerName.contains(sName) || lowerNameNoSpace.contains(sNameNoSpace)) {
           score += 100.0;
           reasons.add("You specifically asked about this.");
        }
      }

      // 2. Category Match
      for (var cat in query.categoryHints) {
        if (catId.contains(cat) || lowerName.contains(cat)) {
          score += 20.0;
        }
      }

      // 3. Concern Match (Skin & Hair)
      for (var concern in query.skinConcerns) {
         if (targetConcerns.contains(concern) || tags.contains(concern) || lowerName.contains(concern)) {
           score += 30.0;
           matchedConcerns.add(concern);
         }
      }
      for (var concern in query.hairConcerns) {
         if (targetConcerns.contains(concern) || tags.contains(concern) || lowerName.contains(concern)) {
           score += 30.0;
           matchedConcerns.add(concern);
         }
      }
      if (matchedConcerns.isNotEmpty) {
        reasons.add("Matches your concern about ${matchedConcerns.join(', ')}.");
      }

      // 4. Fuzzy Token Match
      for (var token in query.normalizedTokens) {
        if (token.length < 3) continue;
        if (lowerNameNoSpace.contains(token)) score += 5.0;
        if (tags.any((t) => t.toLowerCase().contains(token))) score += 5.0;
        if (service.description.toLowerCase().contains(token)) score += 2.0;
      }

      // 5. User Profile Match
      if (profile != null) {
        final profileSkin = profile.skinType?.toLowerCase();
        final profileHair = profile.hairType?.toLowerCase();
        
        if (profileSkin != null && profileSkin.isNotEmpty) {
           if (service.recommendedSkinTypes.map((e)=>e.toLowerCase()).contains(profileSkin) || tags.contains(profileSkin)) {
             score += 25.0;
             if (!matchedProfile.contains(profileSkin)) matchedProfile.add(profileSkin);
           }
        }
        if (profileHair != null && profileHair.isNotEmpty) {
           if (service.recommendedHairTypes.map((e)=>e.toLowerCase()).contains(profileHair) || tags.contains(profileHair)) {
             score += 25.0;
             if (!matchedProfile.contains(profileHair)) matchedProfile.add(profileHair);
           }
        }
        if (matchedProfile.isNotEmpty) {
          reasons.add("Specially formulated for your ${matchedProfile.join(' and ')} type.");
        }
      }

      // 6. Budget constraint
      if (query.budgetMax != null) {
         if (service.price <= query.budgetMax!) {
            score += 10.0;
            reasons.add("Fits within your requested budget.");
         } else {
            score -= 50.0; // Heavy penalty if over budget
         }
      }

      // 7. General boosts
      if (service.isFeatured) score += 5.0;
      if (service.isPopular) score += 3.0;

      // 8. Safety & Contraindication Rules
      final safetyWarnings = _safetyRules.evaluateSafety(service, profile);
      final safetyPenalty = _safetyRules.calculateSafetyPenalty(service, profile);
      score -= safetyPenalty;

      return RecommendedServiceResult(
        service: service,
        score: score,
        reasons: reasons,
        warnings: safetyWarnings,
        matchedConcerns: matchedConcerns,
        matchedProfileAttributes: matchedProfile,
      );
    }).toList();

    // Sort descending
    results.sort((a, b) => b.score.compareTo(a.score));

    // Filter positive score
    var topMatches = results.where((r) => r.score > 0).take(3).toList();

    // If still empty but intent requires a service (like price inquiry or compare), return top featured/popular as fallback
    if (topMatches.isEmpty) {
       topMatches = results.where((r) => r.service.isFeatured || r.service.isPopular).take(2).toList();
       
       // Inject an explanation if we fell back
       for (var match in topMatches) {
          match.reasons.clear();
          match.reasons.add("I couldn't find an exact match, but this is one of our most popular treatments!");
       }
    } else {
       // Only add fallback reason text if no explicit reasons matched but score is ok
       for (var match in topMatches) {
         if (match.reasons.isEmpty) {
           if (match.service.isFeatured) match.reasons.add("One of our highly recommended treatments.");
           else match.reasons.add("A great overall treatment.");
         }
       }
    }

    return topMatches;
  }
}
