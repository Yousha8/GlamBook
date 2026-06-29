enum AiActionType {
  none,
  openServiceDetails,
  openBookingSheet,
  showRecommendations,
  askClarifyingQuestion,
  showSafetyNotice,
}

class AiAssistantAction {
  final AiActionType type;
  final Map<String, dynamic>? payload;

  AiAssistantAction({
    required this.type,
    this.payload,
  });

  factory AiAssistantAction.none() => AiAssistantAction(type: AiActionType.none);
}
