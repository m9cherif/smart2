import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_student_ai/app_controller.dart';
import 'package:smart_student_ai/app_strings.dart';
import 'package:smart_student_ai/text_normalizer.dart';
import 'package:smart_student_ai/database_service.dart';
import 'package:smart_student_ai/app_customization_panel.dart';
import 'package:smart_student_ai/student_progress_card.dart';

part 'revision_question_bank.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  static const String _bestScoreKey = 'revision_best_score';
  static const String _sessionsKey = 'revision_sessions_completed';
  static const int _questionsPerSession = 10;

  static const List<RevisionQuestion> _questionBank = <RevisionQuestion>[
    RevisionQuestion(
      questionId: 'math_multiply_18x7',
      subjectKey: 'math',
      prompt: LocalizedText(
        en: 'Solve 18 x 7.',
        fr: 'Calcule 18 x 7.',
        ar: 'احسب 18 × 7.',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['126'],
        fr: <String>['126'],
        ar: <String>['126'],
      ),
      tip: LocalizedText(
        en: 'Use 10 x 7 plus 8 x 7.',
        fr: 'Utilise 10 x 7 puis 8 x 7.',
        ar: 'فكر في 10 × 7 ثم 8 × 7.',
      ),
    ),
    RevisionQuestion(
      questionId: 'math_fraction_addition',
      subjectKey: 'math',
      prompt: LocalizedText(
        en: 'What is 3/4 + 1/2?',
        fr: 'Combien font 3/4 + 1/2 ?',
        ar: 'كم يساوي 3/4 + 1/2؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['1 1/4', '5/4', '1.25'],
        fr: <String>['1 1/4', '5/4', '1,25', '1.25'],
        ar: <String>['1 1/4', '5/4', '1.25'],
      ),
      tip: LocalizedText(
        en: 'Turn the fractions into fourths before you add them.',
        fr: 'Transforme les fractions en quarts avant de les additionner.',
        ar: 'حوّل الكسرين إلى ارباع قبل الجمع.',
      ),
    ),
    RevisionQuestion(
      questionId: 'science_heart',
      subjectKey: 'science',
      prompt: LocalizedText(
        en: 'Which organ pumps blood around the body?',
        fr: 'Quel organe pompe le sang dans le corps ?',
        ar: 'ما العضو الذي يضخ الدم في الجسم؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['heart', 'the heart'],
        fr: <String>['coeur', 'le coeur'],
        ar: <String>['القلب'],
      ),
      tip: LocalizedText(
        en: 'It beats all day without stopping.',
        fr: 'Il bat toute la journee sans s arreter.',
        ar: 'ينبض طوال اليوم دون توقف.',
      ),
    ),
    RevisionQuestion(
      questionId: 'science_evaporation',
      subjectKey: 'science',
      prompt: LocalizedText(
        en: 'What process changes liquid water into water vapor?',
        fr: 'Quel processus transforme l eau liquide en vapeur ?',
        ar: 'ما العملية التي تحول الماء السائل إلى بخار؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['evaporation'],
        fr: <String>['evaporation', 'l evaporation'],
        ar: <String>['التبخر', 'تبخر'],
      ),
      tip: LocalizedText(
        en: 'Heat makes the water rise into the air.',
        fr: 'La chaleur aide l eau a monter dans l air.',
        ar: 'الحرارة تجعل الماء يرتفع إلى الهواء.',
      ),
    ),
    RevisionQuestion(
      questionId: 'geography_tunisia_continent',
      subjectKey: 'geography',
      prompt: LocalizedText(
        en: 'Which continent is Tunisia in?',
        fr: 'Dans quel continent se trouve la Tunisie ?',
        ar: 'في اي قارة تقع تونس؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['africa'],
        fr: <String>['afrique'],
        ar: <String>['افريقيا', 'إفريقيا'],
      ),
      tip: LocalizedText(
        en: 'Think about North Africa.',
        fr: 'Pense a l Afrique du Nord.',
        ar: 'فكر في شمال افريقيا.',
      ),
    ),
    RevisionQuestion(
      questionId: 'geography_equator',
      subjectKey: 'geography',
      prompt: LocalizedText(
        en: 'What imaginary line divides Earth into the Northern and Southern Hemispheres?',
        fr: 'Quelle ligne imaginaire partage la Terre en hemispheres nord et sud ?',
        ar: 'ما الخط الوهمي الذي يقسم الارض إلى نصفين شمالي وجنوبي؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['equator', 'the equator'],
        fr: <String>['equateur', 'l equateur'],
        ar: <String>['خط الاستواء', 'الاستواء'],
      ),
      tip: LocalizedText(
        en: 'It sits halfway between the North Pole and South Pole.',
        fr: 'Elle se trouve a mi-chemin entre les deux poles.',
        ar: 'يقع في منتصف المسافة بين القطبين.',
      ),
    ),
    RevisionQuestion(
      questionId: 'geography_egypt_capital',
      subjectKey: 'geography',
      prompt: LocalizedText(
        en: 'What is the capital city of Egypt?',
        fr: 'Quelle est la capitale de l Egypte ?',
        ar: 'ما عاصمة مصر؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['cairo'],
        fr: <String>['le caire', 'caire'],
        ar: <String>['القاهرة'],
      ),
      tip: LocalizedText(
        en: 'It is one of the largest cities in North Africa.',
        fr: 'C est l une des plus grandes villes d Afrique du Nord.',
        ar: 'هي من اكبر مدن شمال افريقيا.',
      ),
    ),
    RevisionQuestion(
      questionId: 'language_adjective',
      subjectKey: 'language',
      prompt: LocalizedText(
        en: 'What type of word describes a noun?',
        fr: 'Quel type de mot decrit un nom ?',
        ar: 'ما نوع الكلمة التي تصف الاسم؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['adjective'],
        fr: <String>['adjectif'],
        ar: <String>['صفة', 'نعت'],
      ),
      tip: LocalizedText(
        en: 'It gives more detail about a person, place, or thing.',
        fr: 'Il donne plus de details sur une personne, un lieu ou une chose.',
        ar: 'هي كلمة تضيف وصفاً للاسم.',
      ),
    ),
    RevisionQuestion(
      questionId: 'language_question_mark',
      subjectKey: 'language',
      prompt: LocalizedText(
        en: 'What punctuation mark ends a direct question?',
        fr: 'Quel signe termine une question directe ?',
        ar: 'ما علامة الترقيم التي تنهي السؤال المباشر؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['question mark', '?'],
        fr: <String>['point d interrogation', '?'],
        ar: <String>['علامة استفهام', '؟'],
      ),
      tip: LocalizedText(
        en: 'It curves above a dot.',
        fr: 'Il a une courbe avec un point.',
        ar: 'لها شكل منحني مع نقطة.',
      ),
    ),
    RevisionQuestion(
      questionId: 'technology_screen',
      subjectKey: 'technology',
      prompt: LocalizedText(
        en: 'Which part of a computer shows images and text?',
        fr: 'Quelle partie de l ordinateur affiche les images et le texte ?',
        ar: 'ما الجزء في الحاسوب الذي يعرض الصور والنصوص؟',
      ),
      answers: LocalizedAnswerSet(
        en: <String>['screen', 'monitor'],
        fr: <String>['ecran', 'moniteur'],
        ar: <String>['الشاشة'],
      ),
      tip: LocalizedText(
        en: 'You look at it while typing or reading.',
        fr: 'Tu la regardes pendant que tu lis ou ecris.',
        ar: 'تنظر إليه عند القراءة والكتابة.',
      ),
    ),
    ..._extraQuestionBank,
  ];

  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();

  List<RevisionQuestion> _sessionQuestions = <RevisionQuestion>[];
  String _selectedSubject = 'all';
  int _currentIndex = 0;
  int _score = 0;
  int _bestScore = 0;
  int _sessionsCompleted = 0;
  StudentProgress? _progress;
  bool _answered = false;
  bool _showingAnswer = false;
  String _feedback = '';
  bool _isLoadingStats = true;
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    _resetSession();
    _loadStats();
    _loadProgress();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _bestScore = preferences.getInt(_bestScoreKey) ?? 0;
      _sessionsCompleted = preferences.getInt(_sessionsKey) ?? 0;
      _isLoadingStats = false;
    });
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await DatabaseService.instance.getStudentProgress();
      if (!mounted) {
        return;
      }

      setState(() {
        _progress = progress;
        _isLoadingProgress = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProgress = false;
      });
    }
  }

  void _resetSession() {
    final pool = _selectedSubject == 'all'
        ? List<RevisionQuestion>.from(_questionBank)
        : _questionBank
              .where((question) => question.subjectKey == _selectedSubject)
              .toList();

    pool.shuffle(_random);

    setState(() {
      _sessionQuestions = pool
          .take(
            pool.length > _questionsPerSession
                ? _questionsPerSession
                : pool.length,
          )
          .toList(growable: false);
      _currentIndex = 0;
      _score = 0;
      _answered = false;
      _showingAnswer = false;
      _feedback = '';
      _controller.clear();
    });
  }

  Future<void> _changeSubject(String subject) async {
    if (_selectedSubject == subject) {
      return;
    }

    setState(() {
      _selectedSubject = subject;
    });
    _resetSession();
  }

  Future<void> _checkAnswer() async {
    if (_answered || _sessionQuestions.isEmpty) {
      return;
    }

    final strings = AppStrings.of(context);
    final currentQuestion = _sessionQuestions[_currentIndex];
    final userAnswer = _controller.text;
    final isCorrect = currentQuestion.matches(userAnswer);

    setState(() {
      _answered = true;
      _showingAnswer = false;
      if (isCorrect) {
        _score += 1;
        _feedback = strings.revisionCorrectFeedback(
          currentQuestion.tipFor(strings.language),
        );
      } else {
        _feedback = strings.revisionIncorrectFeedback(
          currentQuestion.displayAnswer(strings.language),
          currentQuestion.tipFor(strings.language),
        );
      }
    });

    await _saveRevisionAttempt(
      question: currentQuestion,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      revealed: false,
    );
  }

  Future<void> _revealAnswer() async {
    if (_answered || _sessionQuestions.isEmpty) {
      return;
    }

    final strings = AppStrings.of(context);
    final currentQuestion = _sessionQuestions[_currentIndex];
    setState(() {
      _answered = true;
      _showingAnswer = true;
      _feedback = strings.revisionRevealFeedback(
        currentQuestion.displayAnswer(strings.language),
        currentQuestion.tipFor(strings.language),
      );
    });

    await _saveRevisionAttempt(
      question: currentQuestion,
      userAnswer: _controller.text,
      isCorrect: false,
      revealed: true,
    );
  }

  Future<void> _saveRevisionAttempt({
    required RevisionQuestion question,
    required String userAnswer,
    required bool isCorrect,
    required bool revealed,
  }) async {
    final strings = AppStrings.of(context);

    try {
      final result = await DatabaseService.instance.recordRevisionAttempt(
        questionKey: question.questionId,
        subjectKey: question.subjectKey,
        prompt: question.promptFor(strings.language),
        expectedAnswer: question.displayAnswer(strings.language),
        userAnswer: userAnswer.trim(),
        isCorrect: isCorrect,
        revealed: revealed,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _progress = result.progress;
      });

      if (result.xpEarned > 0 || result.leveledUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.leveledUp
                  ? strings.progressLevelUpMessage(
                      result.xpEarned,
                      result.progress.level,
                    )
                  : strings.progressXpSavedMessage(
                      result.xpEarned,
                      result.progress.level,
                    ),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.progressSaveFailed)));
    }
  }

  Future<void> _nextQuestion() async {
    if (_sessionQuestions.isEmpty) {
      return;
    }

    final isLastQuestion = _currentIndex == _sessionQuestions.length - 1;
    if (isLastQuestion) {
      final preferences = await SharedPreferences.getInstance();
      final updatedBestScore = max(_bestScore, _score);
      final updatedSessions = _sessionsCompleted + 1;
      await preferences.setInt(_bestScoreKey, updatedBestScore);
      await preferences.setInt(_sessionsKey, updatedSessions);
      if (!mounted) {
        return;
      }

      setState(() {
        _bestScore = updatedBestScore;
        _sessionsCompleted = updatedSessions;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.of(
              context,
            ).revisionSessionCompleteMessage(_score, _sessionQuestions.length),
          ),
        ),
      );
      _resetSession();
      return;
    }

    setState(() {
      _currentIndex += 1;
      _answered = false;
      _showingAnswer = false;
      _feedback = '';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final subjects = <String>[
      'all',
      ...{for (final question in _questionBank) question.subjectKey},
    ];
    final totalQuestions = _sessionQuestions.isEmpty
        ? 1
        : _sessionQuestions.length;
    final progress = (_currentIndex + 1) / totalQuestions;
    final currentQuestion = _sessionQuestions.isEmpty
        ? null
        : _sessionQuestions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.revisionTitle),
        actions: <Widget>[
          const AppSettingsButton(),
          IconButton(
            onPressed: _resetSession,
            tooltip: strings.revisionRestartTooltip,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoadingStats || _isLoadingProgress
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          strings.revisionActiveSessionTitle,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.revisionActiveSessionSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings.revisionQuestionCounter(
                            _currentIndex + 1,
                            totalQuestions,
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (currentQuestion != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              strings.subjectLabel(currentQuestion.subjectKey),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQuestion.promptFor(strings.language),
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _controller,
                            enabled: !_answered,
                            minLines: 2,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: strings.revisionAnswerLabel,
                              hintText: strings.revisionAnswerHint,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              ElevatedButton.icon(
                                onPressed: _answered ? null : _checkAnswer,
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(strings.revisionCheckAnswer),
                              ),
                              OutlinedButton.icon(
                                onPressed: _answered ? null : _revealAnswer,
                                icon: const Icon(Icons.visibility_outlined),
                                label: Text(strings.revisionRevealAnswer),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: _answered ? _nextQuestion : null,
                                icon: Icon(
                                  _currentIndex == totalQuestions - 1
                                      ? Icons.flag_rounded
                                      : Icons.arrow_forward_rounded,
                                ),
                                label: Text(
                                  _currentIndex == totalQuestions - 1
                                      ? strings.revisionFinishSession
                                      : strings.revisionNextQuestion,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (currentQuestion == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            strings.revisionNoQuestionsTitle,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.revisionNoQuestionsSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _resetSession,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(strings.revisionLoadQuestions),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  strings.revisionSubjectFocus,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subjects
                      .map(
                        (subject) => ChoiceChip(
                          label: Text(
                            subject == 'all'
                                ? strings.revisionAllSubjects
                                : strings.subjectLabel(subject),
                          ),
                          selected: _selectedSubject == subject,
                          onSelected: (_) => _changeSubject(subject),
                        ),
                      )
                      .toList(growable: false),
                ),
                if (_feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              _showingAnswer
                                  ? Icons.info_outline_rounded
                                  : Icons.lightbulb_outline_rounded,
                              color: _showingAnswer
                                  ? theme.colorScheme.secondary
                                  : const Color(0xFF2A7F62),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _feedback,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_progress != null) ...<Widget>[
                  const SizedBox(height: 18),
                  StudentProgressCard(
                    progress: _progress!,
                    strings: strings,
                    title: strings.progressTitle,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _RevisionStatCard(
                        label: strings.revisionSessionScore,
                        value: '$_score/$totalQuestions',
                        accent: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RevisionStatCard(
                        label: strings.revisionBestScore,
                        value: '$_bestScore',
                        accent: const Color(0xFF2A7F62),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RevisionStatCard(
                        label: strings.revisionSessions,
                        value: '$_sessionsCompleted',
                        accent: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _RevisionStatCard extends StatelessWidget {
  const _RevisionStatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class RevisionQuestion {
  const RevisionQuestion({
    required this.questionId,
    required this.subjectKey,
    required this.prompt,
    required this.answers,
    required this.tip,
  });

  final String questionId;
  final String subjectKey;
  final LocalizedText prompt;
  final LocalizedAnswerSet answers;
  final LocalizedText tip;

  String promptFor(AppLanguage language) => prompt.resolve(language);

  String tipFor(AppLanguage language) => tip.resolve(language);

  String displayAnswer(AppLanguage language) => answers.resolve(language).first;

  bool matches(String input) {
    final normalizedInput = TextNormalizer.normalizeForComparison(input);
    return answers.allAnswers.any(
      (answer) =>
          TextNormalizer.normalizeForComparison(answer) == normalizedInput,
    );
  }
}

class LocalizedText {
  const LocalizedText({required this.en, required this.fr, required this.ar});

  final String en;
  final String fr;
  final String ar;

  String resolve(AppLanguage language) {
    return switch (language) {
      AppLanguage.english => en,
      AppLanguage.french => fr,
      AppLanguage.arabic => ar,
    };
  }
}

class LocalizedAnswerSet {
  const LocalizedAnswerSet({
    required this.en,
    required this.fr,
    required this.ar,
  });

  final List<String> en;
  final List<String> fr;
  final List<String> ar;

  List<String> resolve(AppLanguage language) {
    return switch (language) {
      AppLanguage.english => en,
      AppLanguage.french => fr,
      AppLanguage.arabic => ar,
    };
  }

  Iterable<String> get allAnswers sync* {
    yield* en;
    yield* fr;
    yield* ar;
  }
}
