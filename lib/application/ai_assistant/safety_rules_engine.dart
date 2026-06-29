import '../../data/models/user_model.dart';
import '../../data/models/service_model.dart';

class SafetyRulesEngine {
  
  /// Returns a list of warnings or contraindications based on the service and user profile.
  /// If the list is empty, the service is generally considered safe.
  List<String> evaluateSafety(ServiceModel service, UserModel? profile) {
    List<String> warnings = [];

    // Fallback if no profile is known and service has precautions
    if (profile == null) {
      if (service.precautions != null && service.precautions!.isNotEmpty) {
         warnings.add("Please note: ${service.precautions}");
      }
      if (service.requiresConsultation) {
        warnings.add("This service typically requires a consultation first.");
      }
      return warnings;
    }

    final lowerPrecautions = (service.precautions ?? '').toLowerCase();
    final lowerContra = service.contraindicationTags.map((e) => e.toLowerCase()).toList();
    final lowerNotRec = service.notRecommendedFor.map((e) => e.toLowerCase()).toList();

    // 1. Sensitivity Check
    if (profile.skinSensitivity?.toLowerCase() == 'high') {
      if (lowerPrecautions.contains('sensitive') || 
          lowerContra.contains('sensitive skin') || 
          lowerNotRec.contains('sensitive skin')) {
        warnings.add("Warning: This treatment may be too harsh for sensitive skin.");
      }
    }

    // 2. Allergy Check
    final allergies = profile.allergies?.toLowerCase() ?? '';
    if (allergies.isNotEmpty && allergies != 'none') {
       warnings.add("Please remind your therapist about your allergies ($allergies) before starting.");
    }

    // 3. Acne Check
    final skinConcerns = profile.skinConcerns?.toLowerCase() ?? '';
    final skinType = profile.skinType?.toLowerCase() ?? '';
    if (skinConcerns.contains('acne') || skinType.contains('acne')) {
        if (lowerNotRec.contains('active acne') || lowerPrecautions.contains('active acne')) {
          warnings.add("Caution: Not recommended to perform over active acne breakouts.");
        }
    }

    if (service.requiresConsultation) {
      warnings.add("A quick consultation is required before we book this exact treatment.");
    }

    return warnings;
  }

  /// Calculates a penalty score (0 to 100) to down-rank unsafe services.
  double calculateSafetyPenalty(ServiceModel service, UserModel? profile) {
    if (profile == null) return 0.0;
    
    double penalty = 0.0;
    final warnings = evaluateSafety(service, profile);

    if (warnings.isNotEmpty) {
      penalty += 30.0; // Base penalty for having any warning
    }

    if (warnings.any((w) => w.contains('too harsh') || w.contains('Not recommended'))) {
      penalty += 50.0; // Severe penalty
    }

    return penalty;
  }
}
