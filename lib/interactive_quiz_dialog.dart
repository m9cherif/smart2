import 'package:flutter/material.dart';

class InteractiveQuizDialog extends StatefulWidget {
  const InteractiveQuizDialog({
    super.key,
    required this.questions,
    required this.onClose,
  });

  final List<Map<String, dynamic>> questions;
  final VoidCallback onClose;

  @override
  State<InteractiveQuizDialog> createState() => _InteractiveQuizDialogState();
}

class _InteractiveQuizDialogState extends State<InteractiveQuizDialog> {
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  bool _showAnswerForCurrent = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    // Initialize user answers array with null values for each question
    _userAnswers = List<int?>.filled(widget.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= widget.questions.length) {
      return _buildQuizCompleteDialog();
    }

    final currentQuestion = widget.questions[_currentQuestionIndex];
    final question = currentQuestion['question'] as String;
    final options = List<String>.from(currentQuestion['options'] as List);
    final correctAnswer = currentQuestion['correct_answer'] as int;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Score: $_score/${widget.questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Question
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(
                      widget
                              .questions[_currentQuestionIndex]['options']
                              ?.length ??
                          0,
                      (index) {
                        final isSelected =
                            _userAnswers[_currentQuestionIndex] == index;
                        final isCorrectOption = index == correctAnswer;

                        // Determine colors based on state
                        Color borderColor = Colors.grey.shade300;
                        Color backgroundColor = Colors.white;
                        Color textColor = Colors.black87;
                        IconData? trailIcon;
                        Color? iconColor;

                        if (!_showAnswerForCurrent) {
                          // Phase 1: Choosing an answer
                          if (isSelected) {
                            borderColor = Theme.of(context).colorScheme.primary;
                            backgroundColor = Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1);
                            textColor = Theme.of(context).colorScheme.primary;
                          }
                        } else {
                          // Phase 2: Showing the true answer
                          if (isCorrectOption) {
                            // Always show the correct option highlighted in green
                            borderColor = Colors.green;
                            backgroundColor = Colors.green.withValues(alpha: 0.1);
                            textColor = Colors.green.shade700;
                            trailIcon = Icons.check_circle;
                            iconColor = Colors.green.shade600;
                          } else if (isSelected) {
                            // The user selected this wrong option
                            borderColor = Colors.red;
                            backgroundColor = Colors.red.withValues(alpha: 0.1);
                            textColor = Colors.red.shade700;
                            trailIcon = Icons.cancel;
                            iconColor = Colors.red.shade600;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _showAnswerForCurrent
                                  ? null
                                  : () => _selectAnswer(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: backgroundColor,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      String.fromCharCode(
                                        65 + index,
                                      ), // A, B, C, D
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        options[index],
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight:
                                              (_showAnswerForCurrent &&
                                                  (isCorrectOption ||
                                                      isSelected))
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (trailIcon != null)
                                      Icon(
                                        trailIcon,
                                        color: iconColor,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        // Next/Check Button
                        Expanded(
                          child: FilledButton(
                            onPressed: _canSubmit() ? _handleNextAction : null,
                            child: Text(
                              !_showAnswerForCurrent
                                  ? 'Check Answer'
                                  : (_currentQuestionIndex ==
                                            widget.questions.length - 1
                                        ? 'Finish'
                                        : 'Next Question'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCompleteDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Quiz Complete!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your Score: $_score out of ${widget.questions.length}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              _score == widget.questions.length
                  ? 'Perfect! You got all questions correct! 🎉'
                  : _score >= widget.questions.length * 0.8
                  ? 'Great job! 🌟'
                  : _score >= widget.questions.length * 0.6
                  ? 'Good effort! 👍'
                  : 'Keep practicing! 📚',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onClose,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  bool _canSubmit() {
    return _userAnswers[_currentQuestionIndex] != null;
  }

  void _handleNextAction() {
    if (!_canSubmit()) return;

    if (!_showAnswerForCurrent) {
      // Transition to showing answer
      final currentQuestion = widget.questions[_currentQuestionIndex];
      final correctAnswer = currentQuestion['correct_answer'] as int;
      final userAnswer = _userAnswers[_currentQuestionIndex];

      setState(() {
        _showAnswerForCurrent = true;
        if (userAnswer == correctAnswer) {
          _score++;
        }
      });
    } else {
      // Transition to next question
      setState(() {
        _currentQuestionIndex++;
        _showAnswerForCurrent = false;
      });
    }
  }
}
