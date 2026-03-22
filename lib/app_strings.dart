import 'package:flutter/widgets.dart';

import 'app_controller.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  static AppStrings of(BuildContext context) {
    return AppStrings(AppScope.of(context).language);
  }

  String get appName => _pick(
    en: 'Smart Student AI',
    fr: 'IA Étudiant Intelligent',
    ar: 'طالب ذكي ذكاء اصطناعي',
  );

  String get heroBadge => _pick(
    en: '',
    fr: '',
    ar: '',
  );

  String get heroTitle => _pick(en: 'Smart Student AI', fr: 'IA Étudiant Intelligent', ar: 'طالب ذكي ذكاء اصطناعي');

  String get heroSubtitle => _pick(
    en: 'Your intelligent companion for academic success.',
    fr: 'Votre compagnon intelligent pour le succès académique.',
    ar: 'رفيقك الذكي للنجاح الأكاديمي.',
  );

  String get metricModules => _pick(
    en: '3 learning modules',
    fr: '3 modules d apprentissage',
    ar: '3 وحدات تعلم',
  );

  String get metricThemes =>
      _pick(en: '3 bold themes', fr: '3 themes forts', ar: '3 سمات قوية');

  String get metricLanguages =>
      _pick(en: '3 app languages', fr: '3 langues', ar: '3 لغات');

  String get customizeWorkspaceTitle => _pick(
    en: 'Shape the workspace',
    fr: 'Personnalise l espace',
    ar: 'خصص مساحة التعلم',
  );

  String get customizeWorkspaceSubtitle => _pick(
    en: 'Switch theme, brightness and language instantly. Your choices stay saved for the next launch.',
    fr: 'Change le theme, la luminosite et la langue instantanement. Les choix restent enregistres.',
    ar: 'بدّل السمة والسطوع واللغة فوراً. يتم حفظ اختياراتك للمرة القادمة.',
  );

  String get themeSectionTitle =>
      _pick(en: 'Themes', fr: 'Themes', ar: 'السمات');

  String get brightnessSectionTitle =>
      _pick(en: 'Brightness', fr: 'Luminosite', ar: 'السطوع');

  String get brightnessLightLabel =>
      _pick(en: 'Light', fr: 'Clair', ar: 'فاتح');

  String get brightnessDarkLabel =>
      _pick(en: 'Dark', fr: 'Sombre', ar: 'داكن');

  String get languageSectionTitle =>
      _pick(en: 'Languages', fr: 'Langues', ar: 'اللغات');

  String get settingsTooltip => _pick(
    en: 'Theme, brightness and language',
    fr: 'Theme, luminosite et langue',
    ar: 'السمة والسطوع واللغة',
  );


  String get accountLabel =>
      _pick(en: 'Account', fr: 'Compte', ar: '??????');

  String get accountGuest => _pick(
    en: 'Anonymous user',
    fr: 'Utilisateur anonyme',
    ar: '?????? ?????',
  );

  String get logoutLabel => _pick(
    en: 'Logout',
    fr: 'Se deconnecter',
    ar: '????? ??????',
  );



  String get launchModuleTitle =>
      _pick(en: 'Launch a module', fr: 'Lance un module', ar: 'افتح وحدة');

  String get launchModuleSubtitle => _pick(
    en: 'Each module is tuned for a different part of the Primary 7 study cycle.',
    fr: 'Chaque module cible une etape differente du travail en 7e primaire.',
    ar: 'كل وحدة مهيأة لجزء مختلف من دورة الدراسة في الصف السابع.',
  );

  String get progressTitle =>
      _pick(en: 'Level and XP', fr: 'Niveau et XP', ar: 'المستوى وXP');

  String get progressSubtitle => _pick(
    en: 'Revision questions and dictation sessions now build saved progress automatically.',
    fr: 'Les questions de revision et les dictees alimentent maintenant une progression sauvegardee.',
    ar: 'أسئلة المراجعة وجلسات الإملاء تبني الآن تقدماً محفوظاً تلقائياً.',
  );

  String progressLevelLabel(int level) =>
      _pick(en: 'Level $level', fr: 'Niveau $level', ar: 'المستوى $level');

  String progressXpLabel(int xp) =>
      _pick(en: '$xp XP total', fr: '$xp XP au total', ar: '$xp XP إجمالي');

  String progressNextLevelLabel(int current, int target) => _pick(
    en: 'Next level: $current / $target XP',
    fr: 'Niveau suivant : $current / $target XP',
    ar: 'المستوى التالي: $current / $target XP',
  );

  String get progressQuestionsLabel => _pick(
    en: 'Questions saved',
    fr: 'Questions sauvegardees',
    ar: 'الأسئلة المحفوظة',
  );

  String get progressDictationsLabel => _pick(
    en: 'Dictations saved',
    fr: 'Dictees sauvegardees',
    ar: 'الإملاءات المحفوظة',
  );

  String get progressUnavailable => _pick(
    en: 'Saved progress is unavailable on this device right now.',
    fr: 'La progression sauvegardee est indisponible sur cet appareil pour le moment.',
    ar: 'التقدم المحفوظ غير متاح على هذا الجهاز حالياً.',
  );

  String get progressLoading => _pick(
    en: 'Loading progress...',
    fr: 'Chargement de la progression...',
    ar: 'جاري تحميل التقدم...',
  );

  String progressXpSavedMessage(int xp, int level) => _pick(
    en: '+$xp XP saved. Level $level.',
    fr: '+$xp XP sauvegardes. Niveau $level.',
    ar: '+$xp XP تم حفظها. المستوى $level.',
  );

  String progressLevelUpMessage(int xp, int level) => _pick(
    en: '+$xp XP. Level up to $level.',
    fr: '+$xp XP. Passage au niveau $level.',
    ar: '+$xp XP. وصلت إلى المستوى $level.',
  );

  String get progressSaveFailed => _pick(
    en: 'Progress could not be saved right now.',
    fr: 'La progression n a pas pu etre sauvegardee pour le moment.',
    ar: 'تعذر حفظ التقدم الآن.',
  );

  String get plannerTitle => _pick(
    en: 'Study Planner',
    fr: 'Planificateur d etude',
    ar: 'مخطط الدراسة',
  );

  String get plannerSubtitle => _pick(
    en: 'Capture homework, set deadlines, and keep the week under control.',
    fr: 'Ajoute les devoirs, fixe des dates limites et garde la semaine maitrisee.',
    ar: 'سجل الواجبات، وحدد المواعيد، وسيطر على اسبوعك الدراسي.',
  );

  String get plannerBadge => _pick(
    en: 'Persistent tasks',
    fr: 'Taches sauvegardees',
    ar: 'مهام محفوظة',
  );

  String get revisionTitle =>
      _pick(en: 'Revision Coach', fr: 'Coach de revision', ar: 'مدرب المراجعة');

  String get revisionSubtitle => _pick(
    en: 'Practice Primary 7 questions, track scores, and build revision rhythm.',
    fr: 'Entraine toi avec des questions de 7e primaire et suis tes scores.',
    ar: 'تدرّب على اسئلة الصف السابع وتابع تقدمك في المراجعة.',
  );

  String get revisionBadge => _pick(
    en: 'Primary 7 bank',
    fr: 'Banque 7e primaire',
    ar: 'بنك الصف السابع',
  );

  String get dictationTitle => _pick(
    en: 'Dictation Lab',
    fr: 'Laboratoire de dictee',
    ar: 'مختبر الاملاء',
  );

  String get dictationSubtitle => _pick(
    en: 'Scan a passage, record the learner, and inspect accuracy word by word.',
    fr: 'Scanne un texte, enregistre l eleve et verifie la precision mot par mot.',
    ar: 'امسح النص، وسجل التلميذ، ثم راجع الدقة كلمة بكلمة.',
  );

  String get dictationBadge =>
      _pick(en: 'OCR + speech', fr: 'OCR + voix', ar: 'OCR + صوت');

  String get dictationFileNotFound => _pick(
    en: 'Selected file not found',
    fr: 'Fichier sélectionné introuvable',
    ar: 'الملف المحدد غير موجود',
  );

  String get dictationProcessingCancelled => _pick(
    en: 'Processing cancelled',
    fr: 'Traitement annulé',
    ar: 'تم إلغاء المعالجة',
  );

  String get dictationCancel => _pick(
    en: 'Cancel',
    fr: 'Annuler',
    ar: 'إلغاء',
  );

  String get dictationImagePickerFailed => _pick(
    en: 'Failed to pick image',
    fr: 'Échec de la sélection d\'image',
    ar: 'فشل في اختيار الصورة',
  );

  String get dictationFilePickerFailed => _pick(
    en: 'Failed to pick file',
    fr: 'Échec de la sélection de fichier',
    ar: 'فشل في اختيار الملف',
  );

  String themeName(AppThemeOption option) {
    return switch (option) {
      AppThemeOption.ocean => _pick(en: 'Ocean', fr: 'Ocean', ar: 'بحر'),
      AppThemeOption.sunrise => _pick(en: 'Sunrise', fr: 'Aube', ar: 'فجر'),
      AppThemeOption.forest => _pick(en: 'Forest', fr: 'Foret', ar: 'غابة'),
    };
  }

  String get settingsResetData => _pick(
    en: 'Reset all data',
    fr: 'Réinitialiser les données',
    ar: 'إعادة تعيين البيانات',
  );

  String get settingsResetDataConfirmTitle => _pick(
    en: 'Clear everything?',
    fr: 'Tout effacer ?',
    ar: 'مسح الكل؟',
  );

  String get settingsResetDataConfirmMessage => _pick(
    en: 'This will delete all stored progress and tasks. This action cannot be undone.',
    fr: 'Cela supprimera toutes les progressions et tâches enregistrées. Cette action est irréversible.',
    ar: 'سيؤدي هذا إلى حذف كل التقدّم والمهام المخزنة. لا يمكن التراجع عن هذا الإجراء.',
  );

  String get settingsResetDataConfirmAction => _pick(
    en: 'Reset',
    fr: 'Réinitialiser',
    ar: 'إعادة',
  );

  String languageName(AppLanguage option) {
    return switch (option) {
      AppLanguage.english => _pick(
        en: 'English',
        fr: 'Anglais',
        ar: 'الانجليزية',
      ),
      AppLanguage.french => _pick(en: 'French', fr: 'Francais', ar: 'الفرنسية'),
      AppLanguage.arabic => _pick(en: 'Arabic', fr: 'Arabe', ar: 'العربية'),
    };
  }

  String get plannerClearCompletedTooltip => _pick(
    en: 'Clear completed',
    fr: 'Supprimer les terminees',
    ar: 'حذف المهام المكتملة',
  );

  String get plannerCaptureTitle => _pick(
    en: 'Capture the next task',
    fr: 'Ajoute la prochaine tache',
    ar: 'اضف المهمة التالية',
  );

  String get plannerCaptureSubtitle => _pick(
    en: 'Add a task, set its priority, and attach a due date when needed.',
    fr: 'Ajoute une tache, choisis sa priorite et fixe une date si besoin.',
    ar: 'اضف مهمة وحدد اولويتها وتاريخها عند الحاجة.',
  );

  String get plannerTaskTitleLabel =>
      _pick(en: 'Task title', fr: 'Titre de la tache', ar: 'عنوان المهمة');

  String get plannerTaskTitleHint => _pick(
    en: 'Finish algebra worksheet',
    fr: 'Finir la fiche d algebre',
    ar: 'انهاء ورقة الجبر',
  );

  String get plannerPriorityLabel =>
      _pick(en: 'Priority', fr: 'Priorite', ar: 'الاولوية');

  String get plannerNoDueDate =>
      _pick(en: 'No due date', fr: 'Pas de date', ar: 'بدون تاريخ');

  String get plannerAddTask =>
      _pick(en: 'Add task', fr: 'Ajouter', ar: 'اضف المهمة');

  String get plannerSaving =>
      _pick(en: 'Saving...', fr: 'Enregistrement...', ar: 'جارٍ الحفظ...');

  String get plannerOpen => _pick(en: 'Open', fr: 'Ouvertes', ar: 'مفتوحة');

  String get plannerDone => _pick(en: 'Done', fr: 'Terminees', ar: 'منجزة');

  String get plannerDueSoon =>
      _pick(en: 'Due soon', fr: 'Bientot dues', ar: 'قريبة');

  String get plannerTaskBoard =>
      _pick(en: 'Task board', fr: 'Tableau des taches', ar: 'لوحة المهام');

  String get plannerTaskBoardSubtitle => _pick(
    en: 'Pull to refresh after external changes.',
    fr: 'Tire pour actualiser apres des changements externes.',
    ar: 'اسحب للتحديث بعد اي تغييرات خارجية.',
  );

  String get plannerEmptyTitle => _pick(
    en: 'Your planner is clear.',
    fr: 'Le planning est vide.',
    ar: 'مخططك فارغ.',
  );

  String get plannerEmptySubtitle => _pick(
    en: 'Add the first task above to start structuring the week.',
    fr: 'Ajoute la premiere tache ci-dessus pour organiser la semaine.',
    ar: 'اضف اول مهمة في الاعلى لبدء تنظيم الاسبوع.',
  );

  String get plannerDeleteTaskTooltip =>
      _pick(en: 'Delete task', fr: 'Supprimer la tache', ar: 'حذف المهمة');

  String get plannerErrorTitle => _pick(
    en: 'Planner unavailable',
    fr: 'Planning indisponible',
    ar: 'المخطط غير متاح',
  );

  String plannerErrorMessage(String details) => _pick(
    en: 'The planner storage could not start. $details',
    fr: 'Le stockage du planning n a pas pu demarrer. $details',
    ar: 'تعذر تشغيل تخزين المخطط. $details',
  );

  String get retryAction =>
      _pick(en: 'Retry', fr: 'Reessayer', ar: 'اعادة المحاولة');

  String plannerTaskAddedMessage() => _pick(
    en: 'Task added to your planner.',
    fr: 'La tache a ete ajoutee au planning.',
    ar: 'تمت اضافة المهمة الى المخطط.',
  );

  String plannerTaskRemovedMessage(String taskTitle) => _pick(
    en: 'Removed "$taskTitle" from the planner.',
    fr: '"$taskTitle" a ete retire du planning.',
    ar: 'تم حذف "$taskTitle" من المخطط.',
  );

  String plannerClearedCompletedMessage(int count) => _pick(
    en: 'Cleared $count completed task(s).',
    fr: '$count tache(s) terminee(s) supprimee(s).',
    ar: 'تم حذف $count مهمة مكتملة.',
  );

  String plannerDeadlineLabel(String date) =>
      _pick(en: 'Due $date', fr: 'Pour $date', ar: 'الاستحقاق $date');

  String plannerAddedLabel(String date) =>
      _pick(en: 'Added $date', fr: 'Ajoutee $date', ar: 'اضيفت $date');

  String get plannerNoDeadline =>
      _pick(en: 'No deadline', fr: 'Sans date limite', ar: 'بدون موعد');

  String priorityLabel(String priority) {
    return switch (priority) {
      'High' => _pick(en: 'High', fr: 'Haute', ar: 'عالية'),
      'Low' => _pick(en: 'Low', fr: 'Faible', ar: 'منخفضة'),
      _ => _pick(en: 'Medium', fr: 'Moyenne', ar: 'متوسطة'),
    };
  }

  String get revisionRestartTooltip => _pick(
    en: 'Restart session',
    fr: 'Redemarrer la session',
    ar: 'اعادة الجلسة',
  );

  String get revisionActiveSessionTitle => _pick(
    en: 'Active revision session',
    fr: 'Session de revision active',
    ar: 'جلسة مراجعة نشطة',
  );

  String get revisionActiveSessionSubtitle => _pick(
    en: 'Switch subjects, answer Primary 7 questions, and keep an eye on your score.',
    fr: 'Change de matiere, reponds aux questions de 7e primaire et suis ton score.',
    ar: 'بدّل المواد، واجب عن اسئلة الصف السابع، وراقب نتيجتك.',
  );

  String revisionQuestionCounter(int current, int total) => _pick(
    en: 'Question $current of $total',
    fr: 'Question $current sur $total',
    ar: 'السؤال $current من $total',
  );

  String get revisionSessionScore =>
      _pick(en: 'Session score', fr: 'Score session', ar: 'نتيجة الجلسة');

  String get revisionBestScore =>
      _pick(en: 'Best score', fr: 'Meilleur score', ar: 'افضل نتيجة');

  String get revisionSessions =>
      _pick(en: 'Sessions', fr: 'Sessions', ar: 'الجلسات');

  String get revisionSubjectFocus =>
      _pick(en: 'Subject focus', fr: 'Matiere', ar: 'تركيز المادة');

  String get revisionNoQuestionsTitle => _pick(
    en: 'No questions loaded',
    fr: 'Aucune question chargee',
    ar: 'لا توجد أسئلة محملة',
  );

  String get revisionNoQuestionsSubtitle => _pick(
    en: 'Reset the session or change the subject to load a fresh set of questions.',
    fr: 'Redemarre la session ou change de matiere pour charger de nouvelles questions.',
    ar: 'أعد تشغيل الجلسة أو غيّر المادة لتحميل مجموعة أسئلة جديدة.',
  );

  String get revisionLoadQuestions =>
      _pick(en: 'Load questions', fr: 'Charger', ar: 'حمّل الأسئلة');

  String get revisionAnswerLabel =>
      _pick(en: 'Your answer', fr: 'Ta reponse', ar: 'اجابتك');

  String get revisionAnswerHint => _pick(
    en: 'Type your response here',
    fr: 'Ecris ta reponse ici',
    ar: 'اكتب اجابتك هنا',
  );

  String get revisionCheckAnswer =>
      _pick(en: 'Check answer', fr: 'Verifier', ar: 'تحقق من الاجابة');

  String get revisionRevealAnswer =>
      _pick(en: 'Reveal answer', fr: 'Voir la reponse', ar: 'اكشف الاجابة');

  String get revisionFinishSession =>
      _pick(en: 'Finish session', fr: 'Terminer', ar: 'انهاء الجلسة');

  String get revisionNextQuestion =>
      _pick(en: 'Next question', fr: 'Question suivante', ar: 'السؤال التالي');

  String revisionCorrectFeedback(String tip) =>
      _pick(en: 'Correct. $tip', fr: 'Correct. $tip', ar: 'اجابة صحيحة. $tip');

  String revisionIncorrectFeedback(String answer, String tip) => _pick(
    en: 'Not quite. The expected answer is "$answer". $tip',
    fr: 'Pas encore. La reponse attendue est "$answer". $tip',
    ar: 'ليست صحيحة بعد. الاجابة المتوقعة هي "$answer". $tip',
  );

  String revisionRevealFeedback(String answer, String tip) => _pick(
    en: 'Answer revealed: "$answer". $tip',
    fr: 'Reponse affichee : "$answer". $tip',
    ar: 'تم كشف الاجابة: "$answer". $tip',
  );

  String revisionSessionCompleteMessage(int score, int total) => _pick(
    en: 'Session complete: $score/$total correct.',
    fr: 'Session terminee : $score/$total correct.',
    ar: 'انتهت الجلسة: $score من $total صحيحة.',
  );

  String get revisionAllSubjects => _pick(en: 'All', fr: 'Toutes', ar: 'الكل');

  String subjectLabel(String key) {
    return switch (key) {
      'math' => _pick(en: 'Math', fr: 'Maths', ar: 'رياضيات'),
      'science' => _pick(en: 'Science', fr: 'Sciences', ar: 'علوم'),
      'geography' => _pick(en: 'Geography', fr: 'Geographie', ar: 'جغرافيا'),
      'language' => _pick(en: 'Language', fr: 'Langue', ar: 'لغة'),
      'technology' => _pick(
        en: 'Technology',
        fr: 'Technologie',
        ar: 'تكنولوجيا',
      ),
      _ => revisionAllSubjects,
    };
  }

  String get dictationResetTooltip =>
      _pick(en: 'Reset', fr: 'Reinitialiser', ar: 'اعادة');

  String get dictationCardTitle => _pick(
    en: 'Capture and assess dictation',
    fr: 'Capturer et evaluer la dictee',
    ar: 'التقاط الاملاء وتقييمه',
  );

  String get dictationInitialStatus => _pick(
    en: 'Import a printed passage first, then record the learner reading it aloud.',
    fr: 'Importe d abord un texte imprime, puis enregistre la lecture de l eleve.',
    ar: 'حمّل نصاً مطبوعاً اولاً، ثم سجل قراءة التلميذ بصوت مرتفع.',
  );

  String get dictationReadingImage => _pick(
    en: 'Reading text from the selected image...',
    fr: 'Lecture du texte depuis l image selectionnee...',
    ar: 'جار قراءة النص من الصورة المختارة...',
  );

  String get dictationReadingFile => _pick(
    en: 'Loading text from the selected file...',
    fr: 'Chargement du texte depuis le fichier selectionne...',
    ar: 'جار تحميل النص من الملف المحدد...',
  );

  String get dictationNoTextDetected => _pick(
    en: 'No readable text was detected. Try a clearer image.',
    fr: 'Aucun texte lisible n a ete detecte. Essaie une image plus nette.',
    ar: 'لم يتم العثور على نص واضح. جرّب صورة اوضح.',
  );

  String get dictationPassageLoaded => _pick(
    en: 'Passage loaded. You can now record the learner.',
    fr: 'Texte charge. Tu peux maintenant enregistrer l eleve.',
    ar: 'تم تحميل النص. يمكنك الان تسجيل التلميذ.',
  );

  String get dictationRecognitionFailed => _pick(
    en: 'Text recognition failed. Try again with a sharper, well-lit image.',
    fr: 'La reconnaissance du texte a echoue. Essaie avec une image plus nette.',
    ar: 'فشل التعرف على النص. حاول بصورة اوضح واضاءة افضل.',
  );

  String get dictationUnsupportedFile => _pick(
    en: 'This file type is not supported yet. Use an image or a plain text file.',
    fr: 'Ce type de fichier n est pas encore pris en charge. Utilise une image ou un fichier texte.',
    ar: 'هذا النوع من الملفات غير مدعوم حاليا. استخدم صورة أو ملفا نصيا عاديا.',
  );

  String get dictationOcrSupportNote => _pick(
    en: 'Image OCR works best with clear, high‑contrast text. The app first tries ML Kit and then falls back to Tesseract if needed; if recognition still fails you can type or load a text file instead.',
    fr: 'La reconnaissance d image fonctionne mieux avec un texte clair et contrasté. L app utilise d abord ML Kit puis Tesseract en secours ; si cela échoue toujours, tu peux taper ou charger un fichier texte.',
    ar: 'يعمل OCR على الصور بشكل أفضل مع نص واضح وعالي التباين. يحاول التطبيق أولاً ML Kit ثم ينتقل إلى Tesseract إذا لزم الأمر؛ إذا فشلت العملية، يمكنك كتابة النص أو تحميل ملف نصي.',
  );

  String get dictationLoadBeforeRecording => _pick(
    en: 'Load a passage before recording.',
    fr: 'Charge un texte avant d enregistrer.',
    ar: 'حمّل نصاً قبل التسجيل.',
  );

  String get dictationListening => _pick(
       en: 'Listening for up to 60 seconds (will stop after 2s silence)...',
        fr: 'Écoute (jusqu\'à 60s, s\'arrêtera après 2s de silence)...',
        ar: 'جارٍ الاستماع حتى 60 ثانية (يتوقف بعد ثانيتين صمت)...',
      );

  String get dictationNoSpeech => _pick(
    en: 'No speech was captured. Try again in a quieter environment.',
    fr: 'Aucune voix capturee. Reessaie dans un endroit plus calme.',
    ar: 'لم يتم التقاط صوت. حاول مجدداً في مكان اكثر هدوءاً.',
  );

  String get dictationAnalysisReady => _pick(
    en: 'Analysis ready. Review the summary below.',
    fr: 'Analyse prete. Consulte le resume ci-dessous.',
    ar: 'التحليل جاهز. راجع الملخص في الاسفل.',
  );

  String get dictationSpeechFailed => _pick(
    en: 'Speech capture failed. Check microphone permissions and retry.',
    fr: 'La capture vocale a echoue. Verifie le micro puis reessaie.',
    ar: 'فشل تسجيل الصوت. تحقق من صلاحيات الميكروفون ثم حاول مجدداً.',
  );

  String get dictationCamera =>
      _pick(en: 'Use camera', fr: 'Camera', ar: 'استخدم الكاميرا');

  String get dictationGallery =>
      _pick(en: 'Use gallery', fr: 'Galerie', ar: 'استخدم المعرض');

  String get dictationFile =>
      _pick(en: 'Use file', fr: 'Fichier', ar: 'استخدم ملفا');

  String get dictationManualEntry =>
      _pick(en: 'Type text', fr: 'Saisir', ar: 'اكتب النص');

  String get dictationManualEntryTitle => _pick(
    en: 'Type or paste the passage',
    fr: 'Saisis ou colle le texte',
    ar: 'اكتب النص أو الصقه',
  );

  String get dictationManualEntryHint => _pick(
    en: 'Paste the expected passage here',
    fr: 'Colle ici le texte attendu',
    ar: 'الصق النص المتوقع هنا',
  );

  String get dictationManualEntryAction =>
      _pick(en: 'Load text', fr: 'Charger le texte', ar: 'حمّل النص');

  String get dictationRecord =>
      _pick(en: 'Record', fr: 'Enregistrer', ar: 'سجل');

  String get dictationRecording =>
      _pick(en: 'Recording...', fr: 'Enregistrement...', ar: 'جار التسجيل...');

  String get dictationStopRecording =>
      _pick(en: 'Stop', fr: 'Arrêter', ar: 'إيقاف');

  String get dictationExpectedPassage =>
      _pick(en: 'Expected passage', fr: 'Texte attendu', ar: 'النص المتوقع');

  String get plannerReminderLabel =>
      _pick(en: 'Remind me', fr: 'Rappelle-moi', ar: 'ذكرني');

  String reminderIntervalLabel(int? minutes) {
    if (minutes == null) {
      return _pick(en: 'None', fr: 'Aucun', ar: 'لا يوجد');
    }
    if (minutes == 60) {
      return _pick(en: '1 hour before', fr: '1 heure avant', ar: 'قبل ساعة');
    }
    if (minutes == 120) {
      return _pick(en: '2 hours before', fr: '2 heures avant', ar: 'قبل ساعتين');
    }
    if (minutes == 180) {
      return _pick(en: '3 hours before', fr: '3 heures avant', ar: 'قبل 3 ساعات');
    }
    if (minutes == 1440) {
      return _pick(en: '1 day before', fr: '1 jour avant', ar: 'قبل يوم');
    }
    if (minutes == 2880) {
      return _pick(en: '2 days before', fr: '2 jours avant', ar: 'قبل يومين');
    }
    if (minutes == 4320) {
      return _pick(en: '3 days before', fr: '3 jours avant', ar: 'قبل 3 أيام');
    }
    return '$minutes min';
  }

  String get dictationCapturedSpeech =>
      _pick(en: 'Captured speech', fr: 'Parole capturee', ar: 'الكلام الملتقط');

  String get dictationEmptyPassage => _pick(
    en: 'No passage loaded yet.',
    fr: 'Aucun texte charge pour le moment.',
    ar: 'لم يتم تحميل نص بعد.',
  );

  String get dictationEmptySpeech => _pick(
    en: 'No learner speech recorded yet.',
    fr: 'Aucune lecture eleve enregistree pour le moment.',
    ar: 'لم يتم تسجيل قراءة التلميذ بعد.',
  );

  String get dictationPerformanceSummary => _pick(
    en: 'Performance summary',
    fr: 'Resume de performance',
    ar: 'ملخص الاداء',
  );

  String get dictationAccuracy =>
      _pick(en: 'Accuracy', fr: 'Precision', ar: 'الدقة');

  String get dictationMatched =>
      _pick(en: 'Matched', fr: 'Corrects', ar: 'مطابقة');

  String get dictationMissed =>
      _pick(en: 'Missed', fr: 'Manques', ar: 'مفقودة');

  String get dictationExtra => _pick(en: 'Extra', fr: 'Ajoutes', ar: 'زائدة');

  String get dictationChangedWords =>
      _pick(en: 'Changed words', fr: 'Mots modifies', ar: 'كلمات متغيرة');

  String get dictationMissedWords =>
      _pick(en: 'Missed words', fr: 'Mots oublies', ar: 'كلمات ناقصة');

  String get dictationExtraWords =>
      _pick(en: 'Extra words', fr: 'Mots en plus', ar: 'كلمات زائدة');

  String get dictationResult =>
      _pick(en: 'Result', fr: 'Resultat', ar: 'النتيجة');

  String get dictationPerfectMatch => _pick(
    en: 'Strong read-through. The spoken passage matches cleanly.',
    fr: 'Lecture solide. Le texte lu correspond clairement au texte attendu.',
    ar: 'قراءة قوية. النص المنطوق يطابق النص المتوقع بشكل واضح.',
  );

  String _pick({required String en, required String fr, required String ar}) {
    return switch (language) {
      AppLanguage.english => en,
      AppLanguage.french => fr,
      AppLanguage.arabic => ar,
    };
  }
}
