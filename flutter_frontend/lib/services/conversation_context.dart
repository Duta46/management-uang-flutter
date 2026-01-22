class ConversationContext {
  String? lastIntent;
  DateTime? lastInteractionTime;
  Map<String, dynamic>? lastData;
  String? lastQuestion;
  String? expectedFollowUp;

  ConversationContext({
    this.lastIntent,
    this.lastInteractionTime,
    this.lastData,
    this.lastQuestion,
    this.expectedFollowUp,
  });

  void updateContext({
    String? intent,
    DateTime? interactionTime,
    Map<String, dynamic>? data,
    String? question,
    String? followUp,
  }) {
    lastIntent = intent ?? lastIntent;
    lastInteractionTime = interactionTime ?? lastInteractionTime;
    lastData = data ?? lastData;
    lastQuestion = question ?? lastQuestion;
    expectedFollowUp = followUp ?? expectedFollowUp;
  }

  void clearContext() {
    lastIntent = null;
    lastInteractionTime = null;
    lastData = null;
    lastQuestion = null;
    expectedFollowUp = null;
  }

  bool isContextValid(Duration maxDuration) {
    if (lastInteractionTime == null) return false;
    return DateTime.now().difference(lastInteractionTime!) < maxDuration;
  }
}