import 'ai_assistant_intent.dart';

class ParsedAiQuery {
  final AiAssistantIntent intent;
  final String rawQuery;
  final List<String> normalizedTokens;
  final List<String> serviceNames;
  final List<String> categoryHints;
  final List<String> skinConcerns;
  final List<String> hairConcerns;
  final double? budgetMin;
  final double? budgetMax;
  final bool wantsBooking;
  final bool wantsComparison;
  final double confidence;

  ParsedAiQuery({
    required this.intent,
    required this.rawQuery,
    required this.normalizedTokens,
    this.serviceNames = const [],
    this.categoryHints = const [],
    this.skinConcerns = const [],
    this.hairConcerns = const [],
    this.budgetMin,
    this.budgetMax,
    this.wantsBooking = false,
    this.wantsComparison = false,
    required this.confidence,
  });
}
