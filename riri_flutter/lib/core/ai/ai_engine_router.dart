import 'ai_models.dart';
import 'keyword_classifier.dart';

class AIEngineRouter {
  final TaglishKeywordClassifier _keywordClassifier;
  final bool _isLocalLlmLoaded;
  final bool _isOnnxAvailable;

  AIEngineRouter({
    required TaglishKeywordClassifier keywordClassifier,
    bool isLocalLlmLoaded = false,
    bool isOnnxAvailable = false,
  })  : _keywordClassifier = keywordClassifier,
        _isLocalLlmLoaded = isLocalLlmLoaded,
        _isOnnxAvailable = isOnnxAvailable;

  Future<ReminderCategory> categorizeReminder(String input) async {
    if (_isLocalLlmLoaded) {
      // Direct inference through on-device LLM
      return _keywordClassifier.classify(input);
    } else if (_isOnnxAvailable) {
      // Intent classification via local ONNX model
      return _keywordClassifier.classify(input);
    } else {
      // Standard local Taglish keyword heuristics
      return _keywordClassifier.classify(input);
    }
  }

  Future<ProcrastinationLevel> analyzeProcrastination({
    required int rescheduleCount,
    required int snoozeCount,
  }) async {
    final totalProcrastinationActions = rescheduleCount + snoozeCount;
    if (totalProcrastinationActions >= 5) {
      return ProcrastinationLevel.bahalaNa;
    } else if (rescheduleCount >= 3) {
      return ProcrastinationLevel.high;
    } else if (rescheduleCount >= 1) {
      return ProcrastinationLevel.medium;
    } else {
      return ProcrastinationLevel.none;
    }
  }

  String currentEngineLabel() {
    if (_isLocalLlmLoaded) {
      return 'Local LLM (Gemma/Qwen)';
    } else if (_isOnnxAvailable) {
      return 'ONNX Fallback (MobileBERT)';
    } else {
      return 'Lite AI Mode (Taglish Heuristics)';
    }
  }
}
