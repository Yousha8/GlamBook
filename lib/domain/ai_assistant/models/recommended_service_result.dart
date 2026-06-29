import '../../../data/models/service_model.dart';

class RecommendedServiceResult {
  final ServiceModel service;
  final double score;
  final List<String> reasons;
  final List<String> warnings;
  final List<String> matchedConcerns;
  final List<String> matchedProfileAttributes;

  RecommendedServiceResult({
    required this.service,
    required this.score,
    this.reasons = const [],
    this.warnings = const [],
    this.matchedConcerns = const [],
    this.matchedProfileAttributes = const [],
  });
}
