import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smart_student_ai/app_controller.dart';
import 'package:smart_student_ai/app_strings.dart';
import 'package:smart_student_ai/google_ocr_service.dart';
import 'package:smart_student_ai/text_normalizer.dart';
import 'package:smart_student_ai/database_service.dart';
import 'package:smart_student_ai/speech_service.dart';
import 'package:smart_student_ai/app_customization_panel.dart';
import 'package:smart_student_ai/ai_service.dart';

class DictationScreen extends StatefulWidget {
  const DictationScreen({super.key});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final GoogleOCRService _ocrService = GoogleOCRService();
  final SpeechService _speechService = SpeechService();
  final TextEditingController _manualTextController = TextEditingController();

  String _sourceText = '';
  String _spokenText = '';
  String _statusMessage = '';
  bool _isProcessingImage = false;
  bool _isRecording = false;
  DictationAnalysis? _analysis;
  Future<String>? _currentOCRTask;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _manualTextController.dispose();
    super.dispose();
  }

  Future<void> _loadTextFromImage(ImageSource source) async {
    final strings = AppStrings.of(context);

    try {
      final file = await _imagePicker
          .pickImage(source: source)
          .timeout(const Duration(seconds: 30), onTimeout: () => null);

      if (file == null || file.path.isEmpty) {
        return;
      }

      // Verify the file exists and is readable
      final fileObj = File(file.path);
      if (!await fileObj.exists()) {
        if (!mounted) return;
        setState(() {
          _statusMessage = strings.dictationFileNotFound;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.dictationFileNotFound)));
        return;
      }

      await _importTextFromPath(
        file.path,
        readingMessage: strings.dictationReadingImage,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = strings.dictationImagePickerFailed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.dictationImagePickerFailed)),
      );
    }
  }

  Future<void> _loadTextFromFile() async {
    final strings = AppStrings.of(context);

    try {
      final result = await FilePicker.platform
          .pickFiles(
            type: FileType.custom,
            allowedExtensions: <String>[
              'txt',
              'md',
              'csv',
              'json',
              'jpg',
              'jpeg',
              'png',
              'bmp',
              'webp',
              'heic',
              'pdf',
              'doc',
              'docx',
            ],
          )
          .timeout(const Duration(seconds: 30), onTimeout: () => null);

      final file = result == null || result.files.isEmpty
          ? null
          : result.files.first;
      final path = file?.path;
      if (path == null || path.isEmpty) {
        return;
      }

      // Verify the file exists and is readable
      final fileObj = File(path);
      if (!await fileObj.exists()) {
        if (!mounted) return;
        setState(() {
          _statusMessage = strings.dictationFileNotFound;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.dictationFileNotFound)));
        return;
      }

      await _importTextFromPath(
        path,
        readingMessage: strings.dictationReadingFile,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = strings.dictationFilePickerFailed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.dictationFilePickerFailed)),
      );
    }
  }

  Future<void> _importTextFromPath(
    String path, {
    required String readingMessage,
  }) async {
    final strings = AppStrings.of(context);

    setState(() {
      _isProcessingImage = true;
      _statusMessage = readingMessage;
    });

    try {
      final String text;
      final ext = path.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'bmp', 'webp', 'heic'].contains(ext);
      
      if (isImage) {
        debugPrint('Starting OCR for image: $path');
        _currentOCRTask = _ocrService.readText(path);
        text = await _currentOCRTask!;
      } else {
        debugPrint('Extracting text from document: $path');
        text = await AIService.extractTextFromFile(File(path));
      }
      
      debugPrint('Text extracted: "$text"');
      debugPrint('Text length: ${text.length}');
      if (!mounted) {
        return;
      }

      setState(() {
        _sourceText = text;
        _spokenText = '';
        _analysis = null;
        _statusMessage = text.isEmpty
            ? strings.dictationNoTextDetected
            : strings.dictationPassageLoaded;
      });
      if (text.isEmpty && mounted) {
        // also show a snack bar so the user notices immediately
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.dictationNoTextDetected)),
        );
      }
    } on UnsupportedError {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = strings.dictationUnsupportedFile;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = strings.dictationRecognitionFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
          _currentOCRTask = null;
        });
      }
    }
  }

  void _cancelOCRProcessing() {
    _currentOCRTask = null;
    setState(() {
      _isProcessingImage = false;
      _statusMessage = AppStrings.of(context).dictationProcessingCancelled;
    });
  }

  Future<void> _recordSpeech() async {
    final strings = AppStrings.of(context);
    if (_sourceText.trim().isEmpty || _isRecording) {
      if (_sourceText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.dictationLoadBeforeRecording)),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _analysis = null;
      _statusMessage = strings.dictationListening;
    });

    try {
      final controller = AppScope.of(context);
      final speech = await _speechService.record(
        duration: const Duration(seconds: 60),
        locale: controller.locale,
      );
      if (!mounted) {
        return;
      }

      final analysis = _buildAnalysis(_sourceText, speech);
      setState(() {
        _spokenText = speech;
        _analysis = analysis;
        _statusMessage = speech.isEmpty
            ? strings.dictationNoSpeech
            : strings.dictationAnalysisReady;
      });

      if (speech.trim().isNotEmpty) {
        await _saveDictationSession(analysis);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = error is StateError
            ? error.message
            : strings.dictationSpeechFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    await _speechService.stop();
  }

  void _resetSession() {
    setState(() {
      _sourceText = '';
      _spokenText = '';
      _analysis = null;
      _statusMessage = '';
    });
    _manualTextController.clear();
  }

  Future<void> _openManualTextEntry() async {
    final strings = AppStrings.of(context);
    _manualTextController.text = _sourceText;

    final submittedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.dictationManualEntryTitle),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: _manualTextController,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: strings.dictationManualEntryHint,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_manualTextController.text),
              child: Text(strings.dictationManualEntryAction),
            ),
          ],
        );
      },
    );

    if (!mounted || submittedText == null) {
      return;
    }

    final normalizedText = submittedText.trim();
    setState(() {
      _sourceText = normalizedText;
      _spokenText = '';
      _analysis = null;
      _statusMessage = normalizedText.isEmpty
          ? strings.dictationNoTextDetected
          : strings.dictationPassageLoaded;
    });
  }

  Future<void> _saveDictationSession(DictationAnalysis analysis) async {
    final strings = AppStrings.of(context);

    try {
      await DatabaseService.instance.recordDictationSession(
        sourceText: _sourceText.trim(),
        spokenText: _spokenText.trim(),
        accuracy: analysis.accuracy,
        matchedWordCount: analysis.matchedWordCount,
        missedWords: analysis.missedWords,
        extraWords: analysis.extraWords,
        mismatchedPairs: analysis.mismatchedPairs,
      );
      if (!mounted) {
        return;
      }

      // Progress is recorded but we no longer show XP/Level UI here
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.progressSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final analysis = _analysis;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.dictationTitle),
        actions: <Widget>[
          const AppSettingsButton(),
          IconButton(
            onPressed: _resetSession,
            tooltip: strings.dictationResetTooltip,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.dictationCardTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage.isEmpty
                        ? strings.dictationInitialStatus
                        : _statusMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_isProcessingImage || _isRecording) ...<Widget>[
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(child: LinearProgressIndicator(minHeight: 8)),
                        if (_isProcessingImage) ...<Widget>[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: _cancelOCRProcessing,
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: Text(strings.dictationCancel),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: _isProcessingImage
                            ? null
                            : _openManualTextEntry,
                        icon: const Icon(Icons.edit_note_rounded),
                        label: Text(strings.dictationManualEntry),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessingImage
                            ? null
                            : _loadTextFromFile,
                        icon: const Icon(Icons.folder_open_rounded),
                        label: Text(strings.dictationFile),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessingImage
                            ? null
                            : () => _loadTextFromImage(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(strings.dictationCamera),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessingImage
                            ? null
                            : () => _loadTextFromImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(strings.dictationGallery),
                      ),
                       FilledButton.tonalIcon(
                        onPressed: _isRecording ? _stopRecording : _recordSpeech,
                        icon: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                        ),
                        label: Text(
                          _isRecording
                              ? strings.dictationStopRecording
                              : strings.dictationRecord,
                        ),
                        style: _isRecording
                            ? FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.errorContainer,
                                foregroundColor: theme.colorScheme.onErrorContainer,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            strings.dictationOcrSupportNote,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _TextPanel(
            title: strings.dictationCapturedSpeech,
            text: _spokenText,
            emptyState: strings.dictationEmptySpeech,
          ),
          if (analysis != null) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              strings.dictationPerformanceSummary,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _AnalysisMetricCard(
                  label: strings.dictationAccuracy,
                  value: '${analysis.accuracy.toStringAsFixed(1)}%',
                  accent: theme.colorScheme.primary,
                ),
                _AnalysisMetricCard(
                  label: strings.dictationMatched,
                  value: '${analysis.matchedWordCount}',
                  accent: const Color(0xFF2A7F62),
                ),
                _AnalysisMetricCard(
                  label: strings.dictationMissed,
                  value: '${analysis.missedWords.length}',
                  accent: const Color(0xFFC63D2F),
                ),
                _AnalysisMetricCard(
                  label: strings.dictationExtra,
                  value: '${analysis.extraWords.length}',
                  accent: theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (analysis.mismatchedPairs.isNotEmpty)
              _FeedbackPanel(
                title: strings.dictationChangedWords,
                accent: theme.colorScheme.secondary,
                content: analysis.mismatchedPairs.join(', '),
              ),
            if (analysis.missedWords.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _FeedbackPanel(
                title: strings.dictationMissedWords,
                accent: const Color(0xFFC63D2F),
                content: analysis.missedWords.join(', '),
              ),
            ],
            if (analysis.extraWords.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _FeedbackPanel(
                title: strings.dictationExtraWords,
                accent: theme.colorScheme.secondary,
                content: analysis.extraWords.join(', '),
              ),
            ],
            if (analysis.missedWords.isEmpty &&
                analysis.extraWords.isEmpty &&
                analysis.mismatchedPairs.isEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _FeedbackPanel(
                title: strings.dictationResult,
                accent: const Color(0xFF2A7F62),
                content: strings.dictationPerfectMatch,
              ),
            ],
          ],
        ],
      ),
    );
  }




  DictationAnalysis _buildAnalysis(String expectedText, String spokenText) {
    final expectedWords = TextNormalizer.tokenize(expectedText);
    final spokenWords = TextNormalizer.tokenize(spokenText);

    if (expectedWords.isEmpty) {
      return const DictationAnalysis(
        accuracy: 0,
        matchedWordCount: 0,
        missedWords: <String>[],
        extraWords: <String>[],
        mismatchedPairs: <String>[],
      );
    }

    final rows = expectedWords.length + 1;
    final columns = spokenWords.length + 1;
    final matrix = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(columns, 0),
    );

    for (var row = 0; row < rows; row++) {
      matrix[row][0] = row;
    }
    for (var column = 0; column < columns; column++) {
      matrix[0][column] = column;
    }

    for (var row = 1; row < rows; row++) {
      for (var column = 1; column < columns; column++) {
        final substitutionCost =
            expectedWords[row - 1] == spokenWords[column - 1] ? 0 : 1;
        matrix[row][column] = min(
          matrix[row - 1][column] + 1,
          min(
            matrix[row][column - 1] + 1,
            matrix[row - 1][column - 1] + substitutionCost,
          ),
        );
      }
    }

    final missedWords = <String>[];
    final extraWords = <String>[];
    final mismatchedPairs = <String>[];
    var matchedWordCount = 0;
    var row = expectedWords.length;
    var column = spokenWords.length;

    while (row > 0 || column > 0) {
      if (row > 0 && column > 0) {
        final substitutionCost =
            expectedWords[row - 1] == spokenWords[column - 1] ? 0 : 1;
        if (matrix[row][column] ==
            matrix[row - 1][column - 1] + substitutionCost) {
          if (substitutionCost == 0) {
            matchedWordCount += 1;
          } else {
            mismatchedPairs.add(
              '${expectedWords[row - 1]} -> ${spokenWords[column - 1]}',
            );
          }
          row -= 1;
          column -= 1;
          continue;
        }
      }

      if (row > 0 && matrix[row][column] == matrix[row - 1][column] + 1) {
        missedWords.add(expectedWords[row - 1]);
        row -= 1;
        continue;
      }

      if (column > 0 && matrix[row][column] == matrix[row][column - 1] + 1) {
        extraWords.add(spokenWords[column - 1]);
        column -= 1;
      }
    }

    final denominator = max(expectedWords.length, spokenWords.length);
    final accuracy = denominator == 0
        ? 0.0
        : (matchedWordCount / denominator) * 100;

    return DictationAnalysis(
      accuracy: accuracy,
      matchedWordCount: matchedWordCount,
      missedWords: missedWords.reversed.toList(growable: false),
      extraWords: extraWords.reversed.toList(growable: false),
      mismatchedPairs: mismatchedPairs.reversed.toList(growable: false),
    );
  }
}

class _TextPanel extends StatelessWidget {
  const _TextPanel({
    required this.title,
    required this.text,
    required this.emptyState,
  });

  final String title;
  final String text;
  final String emptyState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            SelectableText(
              text.isEmpty ? emptyState : text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: text.isEmpty ? theme.colorScheme.onSurfaceVariant : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisMetricCard extends StatelessWidget {
  const _AnalysisMetricCard({
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

    return SizedBox(
      width: 156,
      child: Card(
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
                style: theme.textTheme.headlineSmall?.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.title,
    required this.accent,
    required this.content,
  });

  final String title;
  final Color accent;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(color: accent),
            ),
            const SizedBox(height: 10),
            Text(content, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class DictationAnalysis {
  const DictationAnalysis({
    required this.accuracy,
    required this.matchedWordCount,
    required this.missedWords,
    required this.extraWords,
    required this.mismatchedPairs,
  });

  final double accuracy;
  final int matchedWordCount;
  final List<String> missedWords;
  final List<String> extraWords;
  final List<String> mismatchedPairs;
}
