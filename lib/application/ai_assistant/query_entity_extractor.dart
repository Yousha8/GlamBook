import '../../domain/ai_assistant/models/ai_assistant_intent.dart';
import '../../domain/ai_assistant/models/parsed_ai_query.dart';

class QueryEntityExtractor {
  ParsedAiQuery extract(String rawQuery, AiAssistantIntent intent) {
    final normalizedTokens = rawQuery.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ');
    final normalizedQuery = rawQuery.toLowerCase();

    List<String> skinConcerns = [];
    List<String> hairConcerns = [];
    List<String> categoryHints = [];
    List<String> serviceNames = [];
    bool wantsComparison = false;
    bool wantsBooking = false;

    // Skin concerns
    final skinKeywords = ['acne', 'oily', 'dry', 'sensitive', 'redness', 'anti-aging', 'wrinkles', 'glow', 'dull', 'pores'];
    for (var k in skinKeywords) {
      if (normalizedQuery.contains(k)) skinConcerns.add(k);
    }

    // Hair concerns
    final hairKeywords = ['frizz', 'dry', 'damage', 'color', 'dandruff', 'loss', 'thinning', 'volume'];
    for (var k in hairKeywords) {
      if (normalizedQuery.contains(k)) hairConcerns.add(k);
    }

    // Category hints
    if (normalizedQuery.contains('hair') || normalizedQuery.contains('cut')) categoryHints.add('hair');
    if (normalizedQuery.contains('face') || normalizedQuery.contains('facial')) categoryHints.add('facials');
    if (normalizedQuery.contains('body') || normalizedQuery.contains('massage') || normalizedQuery.contains('relax')) categoryHints.add('massage');

    // Simple service name extraction (just looking for common keywords, exact matching is done in recommendation engine)
    final serviceKeywords = ['hydrafacial', 'cleanup', 'keratin', 'balayage', 'swedish', 'peel', 'detox'];
    for (var k in serviceKeywords) {
      if (normalizedQuery.contains(k)) serviceNames.add(k);
    }

    if (normalizedQuery.contains('compare') || normalizedQuery.contains('vs') || serviceNames.length >= 2) {
      wantsComparison = true;
    }

    if (intent == AiAssistantIntent.bookingRequest || normalizedQuery.contains('book')) {
      wantsBooking = true;
    }

    // Very basic budget extractor
    double? budgetMax;
    final match = RegExp(r'(under|cheap|less than|max)\s*(\d+)').firstMatch(normalizedQuery);
    if (match != null && match.groupCount >= 2) {
      budgetMax = double.tryParse(match.group(2) ?? '');
    }

    return ParsedAiQuery(
      intent: intent,
      rawQuery: rawQuery,
      normalizedTokens: normalizedTokens,
      skinConcerns: skinConcerns,
      hairConcerns: hairConcerns,
      categoryHints: categoryHints,
      serviceNames: serviceNames,
      wantsComparison: wantsComparison,
      wantsBooking: wantsBooking,
      budgetMax: budgetMax,
      confidence: 0.8, // placeholder
    );
  }
}
