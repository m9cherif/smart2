part of 'revision_screen.dart';

const List<RevisionQuestion> _extraQuestionBank = <RevisionQuestion>[
  RevisionQuestion(
    questionId: 'math_divide_144_by_12',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'What is 144 divided by 12?',
      fr: 'Combien font 144 divise par 12 ?',
      ar: 'كم يساوي 144 مقسوما على 12؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['12'],
      fr: <String>['12'],
      ar: <String>['12'],
    ),
    tip: LocalizedText(
      en: 'Think of the multiplication fact 12 x 12.',
      fr: 'Pense au calcul 12 x 12.',
      ar: 'فكر في عملية 12 × 12.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_perimeter_rectangle',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'A rectangle is 9 cm long and 4 cm wide. What is its perimeter?',
      fr: 'Un rectangle mesure 9 cm sur 4 cm. Quel est son perimetre ?',
      ar: 'مستطيل طوله 9 سم وعرضه 4 سم. ما محيطه؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['26', '26 cm'],
      fr: <String>['26', '26 cm'],
      ar: <String>['26', '26 سم'],
    ),
    tip: LocalizedText(
      en: 'Add all four sides together.',
      fr: 'Additionne les quatre cotes.',
      ar: 'اجمع الأضلاع الأربعة معا.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_area_rectangle',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'What is the area of a rectangle that is 6 cm by 5 cm?',
      fr: 'Quelle est l aire d un rectangle de 6 cm sur 5 cm ?',
      ar: 'ما مساحة مستطيل أبعاده 6 سم و5 سم؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['30', '30 cm2'],
      fr: <String>['30', '30 cm2'],
      ar: <String>['30', '30 سم2'],
    ),
    tip: LocalizedText(
      en: 'Area is length x width.',
      fr: 'L aire est longueur x largeur.',
      ar: 'المساحة تساوي الطول × العرض.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_percentage_35_of_200',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'What is 35% of 200?',
      fr: 'Combien font 35 % de 200 ?',
      ar: 'كم يساوي 35% من 200؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['70'],
      fr: <String>['70'],
      ar: <String>['70'],
    ),
    tip: LocalizedText(
      en: 'Find 10% first, then build to 35%.',
      fr: 'Trouve 10 % puis arrive a 35 %.',
      ar: 'احسب 10% أولا ثم كوّن 35%.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_round_487',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'Round 487 to the nearest ten.',
      fr: 'Arrondis 487 a la dizaine la plus proche.',
      ar: 'قرب العدد 487 إلى أقرب عشرة.',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['490'],
      fr: <String>['490'],
      ar: <String>['490'],
    ),
    tip: LocalizedText(
      en: 'Check the ones digit.',
      fr: 'Regarde le chiffre des unites.',
      ar: 'انظر إلى رقم الآحاد.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_decimal_addition',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'What is 2.4 + 3.75?',
      fr: 'Combien font 2,4 + 3,75 ?',
      ar: 'كم يساوي 2.4 + 3.75؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['6.15'],
      fr: <String>['6,15', '6.15'],
      ar: <String>['6.15'],
    ),
    tip: LocalizedText(
      en: 'Line up the decimal points.',
      fr: 'Aligne les virgules.',
      ar: 'رتب الفواصل العشرية.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_fraction_subtraction',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'What is 5/6 - 1/3?',
      fr: 'Combien font 5/6 - 1/3 ?',
      ar: 'كم يساوي 5/6 - 1/3؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['1/2'],
      fr: <String>['1/2'],
      ar: <String>['1/2', 'نصف'],
    ),
    tip: LocalizedText(
      en: 'Turn thirds into sixths first.',
      fr: 'Transforme les tiers en sixiemes.',
      ar: 'حوّل الثلث إلى أسداس أولا.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_ratio_parts',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'A ratio is 3:1 and the total is 16. What is the smaller part?',
      fr: 'Le rapport est 3:1 et le total est 16. Quelle est la plus petite part ?',
      ar: 'النسبة 3:1 والمجموع 16. ما الجزء الأصغر؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['4'],
      fr: <String>['4'],
      ar: <String>['4'],
    ),
    tip: LocalizedText(
      en: 'There are 4 equal parts in total.',
      fr: 'Il y a 4 parts egales au total.',
      ar: 'هناك 4 أجزاء متساوية في المجموع.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_decimal_to_percent',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'Write 0.8 as a percentage.',
      fr: 'Ecris 0,8 sous forme de pourcentage.',
      ar: 'اكتب 0.8 على شكل نسبة مئوية.',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['80', '80%'],
      fr: <String>['80', '80 %', '80%'],
      ar: <String>['80', '80%'],
    ),
    tip: LocalizedText(
      en: 'Multiply the decimal by 100.',
      fr: 'Multiplie le decimal par 100.',
      ar: 'اضرب العدد العشري في 100.',
    ),
  ),
  RevisionQuestion(
    questionId: 'math_square_number',
    subjectKey: 'math',
    prompt: LocalizedText(
      en: 'What is 6 squared?',
      fr: 'Combien font 6 au carre ?',
      ar: 'كم يساوي 6 تربيع؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['36'],
      fr: <String>['36'],
      ar: <String>['36'],
    ),
    tip: LocalizedText(
      en: 'Square means multiply the number by itself.',
      fr: 'Au carre signifie multiplier le nombre par lui-meme.',
      ar: 'التربيع يعني ضرب العدد في نفسه.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_lungs',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'Which organs help us breathe?',
      fr: 'Quels organes nous aident a respirer ?',
      ar: 'ما الأعضاء التي تساعدنا على التنفس؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['lungs', 'the lungs'],
      fr: <String>['poumons', 'les poumons'],
      ar: <String>['الرئتان', 'الرئة'],
    ),
    tip: LocalizedText(
      en: 'They fill with air inside the chest.',
      fr: 'Ils se remplissent d air dans la poitrine.',
      ar: 'تمتلئ بالهواء داخل الصدر.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_photosynthesis',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'What process lets plants make their own food?',
      fr: 'Quel processus permet aux plantes de fabriquer leur nourriture ?',
      ar: 'ما العملية التي تسمح للنباتات بصنع غذائها؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['photosynthesis'],
      fr: <String>['photosynthese', 'la photosynthese'],
      ar: <String>['البناء الضوئي', 'التمثيل الضوئي'],
    ),
    tip: LocalizedText(
      en: 'It uses sunlight, water, and carbon dioxide.',
      fr: 'Elle utilise la lumiere, l eau et le dioxyde de carbone.',
      ar: 'تستخدم ضوء الشمس والماء وثاني أكسيد الكربون.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_carbon_dioxide',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'Which gas do plants take in from the air?',
      fr: 'Quel gaz les plantes absorbent-elles dans l air ?',
      ar: 'ما الغاز الذي تمتصه النباتات من الهواء؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['carbon dioxide'],
      fr: <String>['dioxyde de carbone'],
      ar: <String>['ثاني أكسيد الكربون'],
    ),
    tip: LocalizedText(
      en: 'Plants use it during photosynthesis.',
      fr: 'Les plantes l utilisent pendant la photosynthese.',
      ar: 'تستعمله النباتات أثناء البناء الضوئي.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_condensation',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'What is the change from water vapor to liquid water called?',
      fr: 'Comment s appelle le passage de la vapeur d eau a l eau liquide ?',
      ar: 'ما اسم تحول بخار الماء إلى ماء سائل؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['condensation'],
      fr: <String>['condensation'],
      ar: <String>['التكاثف'],
    ),
    tip: LocalizedText(
      en: 'It happens when warm vapor cools.',
      fr: 'Cela arrive quand la vapeur se refroidit.',
      ar: 'يحدث عندما يبرد البخار.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_gravity',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'What force pulls objects toward Earth?',
      fr: 'Quelle force attire les objets vers la Terre ?',
      ar: 'ما القوة التي تسحب الأشياء نحو الأرض؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['gravity'],
      fr: <String>['gravite'],
      ar: <String>['الجاذبية'],
    ),
    tip: LocalizedText(
      en: 'It keeps your feet on the ground.',
      fr: 'Elle garde tes pieds au sol.',
      ar: 'هي التي تبقيك على الأرض.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_red_planet',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'Which planet is called the Red Planet?',
      fr: 'Quelle planete est appelee la planete rouge ?',
      ar: 'ما الكوكب الذي يسمى الكوكب الأحمر؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['mars'],
      fr: <String>['mars'],
      ar: <String>['المريخ'],
    ),
    tip: LocalizedText(
      en: 'It is the fourth planet from the Sun.',
      fr: 'C est la quatrieme planete a partir du Soleil.',
      ar: 'هو الكوكب الرابع من الشمس.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_skull',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'Which bone structure protects the brain?',
      fr: 'Quelle structure osseuse protege le cerveau ?',
      ar: 'ما التركيب العظمي الذي يحمي الدماغ؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['skull', 'the skull'],
      fr: <String>['crane', 'le crane'],
      ar: <String>['الجمجمة'],
    ),
    tip: LocalizedText(
      en: 'It surrounds the head.',
      fr: 'Elle entoure la tete.',
      ar: 'تحيط بالرأس.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_melting',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'What do we call the change from solid to liquid?',
      fr: 'Comment appelle-t-on le passage du solide au liquide ?',
      ar: 'ماذا نسمي تحول المادة من صلب إلى سائل؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['melting'],
      fr: <String>['fusion'],
      ar: <String>['الانصهار'],
    ),
    tip: LocalizedText(
      en: 'Ice does this when it gets warm.',
      fr: 'La glace fait cela quand elle se rechauffe.',
      ar: 'يحدث هذا للجليد عندما يسخن.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_vertebrates',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'What do we call animals that have a backbone?',
      fr: 'Comment appelle-t-on les animaux qui ont une colonne vertebrale ?',
      ar: 'ماذا نسمي الحيوانات التي لها عمود فقري؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['vertebrates'],
      fr: <String>['vertebres'],
      ar: <String>['الفقاريات', 'فقاريات'],
    ),
    tip: LocalizedText(
      en: 'Fish, birds, and mammals are in this group.',
      fr: 'Les poissons, oiseaux et mammiferes sont dans ce groupe.',
      ar: 'الأسماك والطيور والثدييات من هذه المجموعة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'science_sun_energy',
    subjectKey: 'science',
    prompt: LocalizedText(
      en: 'What is the main source of energy for Earth?',
      fr: 'Quelle est la principale source d energie pour la Terre ?',
      ar: 'ما المصدر الرئيسي للطاقة على الأرض؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['sun', 'the sun'],
      fr: <String>['soleil', 'le soleil'],
      ar: <String>['الشمس'],
    ),
    tip: LocalizedText(
      en: 'It gives light and heat each day.',
      fr: 'Il donne lumiere et chaleur chaque jour.',
      ar: 'تعطي الضوء والحرارة كل يوم.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_sahara',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'What is the name of the largest hot desert in Africa?',
      fr: 'Quel est le nom du plus grand desert chaud d Afrique ?',
      ar: 'ما اسم أكبر صحراء حارة في أفريقيا؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['sahara', 'sahara desert'],
      fr: <String>['sahara', 'desert du sahara'],
      ar: <String>['الصحراء الكبرى'],
    ),
    tip: LocalizedText(
      en: 'It stretches across North Africa.',
      fr: 'Il s etend a travers l Afrique du Nord.',
      ar: 'تمتد عبر شمال أفريقيا.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_nile',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'Which river flows through Egypt?',
      fr: 'Quel fleuve traverse l Egypte ?',
      ar: 'ما النهر الذي يمر عبر مصر؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['nile', 'the nile'],
      fr: <String>['nil', 'le nil'],
      ar: <String>['النيل'],
    ),
    tip: LocalizedText(
      en: 'It is one of the longest rivers in the world.',
      fr: 'C est l un des plus longs fleuves du monde.',
      ar: 'هو من أطول الأنهار في العالم.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_east',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'On a compass, which direction is where the sun rises?',
      fr: 'Sur une boussole, dans quelle direction le soleil se leve-t-il ?',
      ar: 'على البوصلة، في أي اتجاه تشرق الشمس؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['east'],
      fr: <String>['est'],
      ar: <String>['الشرق'],
    ),
    tip: LocalizedText(
      en: 'It is opposite to west.',
      fr: 'C est l oppose de l ouest.',
      ar: 'هو عكس الغرب.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_mediterranean',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'Which sea lies to the north of Tunisia?',
      fr: 'Quelle mer se trouve au nord de la Tunisie ?',
      ar: 'ما البحر الذي يقع شمال تونس؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['mediterranean sea', 'mediterranean'],
      fr: <String>['mer mediterranee', 'mediterranee'],
      ar: <String>['البحر الأبيض المتوسط', 'البحر المتوسط'],
    ),
    tip: LocalizedText(
      en: 'Many countries in southern Europe touch it.',
      fr: 'De nombreux pays du sud de l Europe la bordent.',
      ar: 'تطل عليه دول كثيرة في جنوب أوروبا.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_latitude',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'Which lines measure distance north or south of the Equator?',
      fr: 'Quelles lignes mesurent la distance au nord ou au sud de l Equateur ?',
      ar: 'ما الخطوط التي تقيس المسافة شمال أو جنوب خط الاستواء؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['latitude', 'lines of latitude'],
      fr: <String>['latitude', 'lignes de latitude'],
      ar: <String>['دوائر العرض', 'خطوط العرض'],
    ),
    tip: LocalizedText(
      en: 'They run east to west around Earth.',
      fr: 'Elles vont d est en ouest autour de la Terre.',
      ar: 'تمتد من الشرق إلى الغرب حول الأرض.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_map_key',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'What do we call the guide that explains the symbols on a map?',
      fr: 'Comment appelle-t-on le guide qui explique les symboles d une carte ?',
      ar: 'ماذا نسمي الدليل الذي يشرح رموز الخريطة؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['key', 'legend', 'map key'],
      fr: <String>['legende', 'cle'],
      ar: <String>['مفتاح الخريطة', 'المفتاح'],
    ),
    tip: LocalizedText(
      en: 'It helps you read map symbols correctly.',
      fr: 'Il aide a lire correctement les symboles.',
      ar: 'يساعدك على فهم رموز الخريطة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_south',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'Which compass direction is opposite to north?',
      fr: 'Quelle direction est l oppose du nord ?',
      ar: 'ما الاتجاه المعاكس للشمال؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['south'],
      fr: <String>['sud'],
      ar: <String>['الجنوب'],
    ),
    tip: LocalizedText(
      en: 'Look at a four-point compass.',
      fr: 'Regarde une boussole a quatre points.',
      ar: 'انظر إلى البوصلة ذات الجهات الأربع.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_atlantic',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'Which ocean lies to the west of Africa?',
      fr: 'Quel ocean se trouve a l ouest de l Afrique ?',
      ar: 'ما المحيط الذي يقع غرب أفريقيا؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['atlantic ocean', 'atlantic'],
      fr: <String>['ocean atlantique', 'atlantique'],
      ar: <String>['المحيط الأطلسي', 'الأطلسي'],
    ),
    tip: LocalizedText(
      en: 'Europe and Africa share this ocean on their western side.',
      fr: 'L Europe et l Afrique ont cet ocean a l ouest.',
      ar: 'تقع أوروبا وأفريقيا على هذا المحيط من جهة الغرب.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_equator_climate',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'What kind of climate is common near the Equator?',
      fr: 'Quel climat est courant pres de l Equateur ?',
      ar: 'ما نوع المناخ الشائع قرب خط الاستواء؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['hot', 'warm', 'hot and wet'],
      fr: <String>['chaud', 'chaud et humide'],
      ar: <String>['حار', 'حار ورطب'],
    ),
    tip: LocalizedText(
      en: 'These places receive strong sunlight all year.',
      fr: 'Ces lieux recoivent un fort ensoleillement toute l annee.',
      ar: 'تتلقى هذه المناطق ضوء شمس قوي طوال السنة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'geography_scale',
    subjectKey: 'geography',
    prompt: LocalizedText(
      en: 'What tells you how distances on a map compare to real distances?',
      fr: 'Qu est-ce qui montre comment les distances sur une carte correspondent aux distances reelles ?',
      ar: 'ما الذي يبين كيف تقارن المسافات على الخريطة بالمسافات الحقيقية؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['scale', 'map scale'],
      fr: <String>['echelle', 'echelle de la carte'],
      ar: <String>['مقياس الرسم', 'المقياس'],
    ),
    tip: LocalizedText(
      en: 'It can be shown with numbers or a bar.',
      fr: 'Elle peut etre montree par des nombres ou une barre.',
      ar: 'يمكن أن يظهر بأرقام أو بشريط.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_pronoun',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What type of word replaces a noun?',
      fr: 'Quel type de mot remplace un nom ?',
      ar: 'ما نوع الكلمة التي تحل محل الاسم؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['pronoun'],
      fr: <String>['pronom'],
      ar: <String>['ضمير'],
    ),
    tip: LocalizedText(
      en: 'Words like he, she, and they are examples.',
      fr: 'Des mots comme il, elle et ils en sont des exemples.',
      ar: 'كلمات مثل هو وهي وهم أمثلة على ذلك.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_comma',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'Which punctuation mark separates items in a list?',
      fr: 'Quel signe de ponctuation separe les elements d une liste ?',
      ar: 'ما علامة الترقيم التي تفصل عناصر القائمة؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['comma', ','],
      fr: <String>['virgule', ','],
      ar: <String>['الفاصلة', '،'],
    ),
    tip: LocalizedText(
      en: 'It is small and curves below the line.',
      fr: 'Elle est petite et se place sous la ligne.',
      ar: 'هي صغيرة وتنزل أسفل السطر.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_past_tense_go',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What is the past tense of "go"?',
      fr: 'Quel est le passe du verbe "go" ?',
      ar: 'ما الماضي من الفعل "go"؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['went'],
      fr: <String>['went'],
      ar: <String>['went'],
    ),
    tip: LocalizedText(
      en: 'It is an irregular verb.',
      fr: 'C est un verbe irregulier.',
      ar: 'إنه فعل غير منتظم.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_proper_noun',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'Is "Tunisia" a common noun or a proper noun?',
      fr: '"Tunisia" est-il un nom commun ou un nom propre ?',
      ar: 'هل "Tunisia" اسم عام أم اسم علم؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['proper noun', 'proper'],
      fr: <String>['nom propre', 'propre'],
      ar: <String>['اسم علم'],
    ),
    tip: LocalizedText(
      en: 'Names of countries use capital letters.',
      fr: 'Les noms de pays prennent une majuscule.',
      ar: 'أسماء البلدان تكتب بحرف كبير في الإنجليزية.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_verb',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What type of word shows an action?',
      fr: 'Quel type de mot montre une action ?',
      ar: 'ما نوع الكلمة الذي يدل على فعل أو حركة؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['verb'],
      fr: <String>['verbe'],
      ar: <String>['فعل'],
    ),
    tip: LocalizedText(
      en: 'Run, write, and jump are examples.',
      fr: 'Courir, ecrire et sauter en sont des exemples.',
      ar: 'مثل: يركض ويكتب ويقفز.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_children_plural',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What is the plural of "child"?',
      fr: 'Quel est le pluriel de "child" ?',
      ar: 'ما جمع كلمة "child"؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['children'],
      fr: <String>['children'],
      ar: <String>['children'],
    ),
    tip: LocalizedText(
      en: 'This plural does not end with just s.',
      fr: 'Ce pluriel ne prend pas seulement un s.',
      ar: 'هذا الجمع لا يضيف فقط الحرف s.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_synonym_fast',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What is a synonym for "fast"?',
      fr: 'Quel est un synonyme de "fast" ?',
      ar: 'ما المرادف لكلمة "fast"؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['quick', 'rapid'],
      fr: <String>['rapide'],
      ar: <String>['سريع'],
    ),
    tip: LocalizedText(
      en: 'A synonym has a similar meaning.',
      fr: 'Un synonyme a un sens proche.',
      ar: 'المرادف له معنى مشابه.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_antonym_quiet',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What is the antonym of "quiet"?',
      fr: 'Quel est l antonyme de "quiet" ?',
      ar: 'ما ضد كلمة "quiet"؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['loud', 'noisy'],
      fr: <String>['bruyant'],
      ar: <String>['صاخب', 'مزعج'],
    ),
    tip: LocalizedText(
      en: 'An antonym means the opposite.',
      fr: 'Un antonyme signifie le contraire.',
      ar: 'الكلمة المضادة تعني العكس.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_exclamation_mark',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'Which punctuation mark shows strong feeling?',
      fr: 'Quel signe de ponctuation montre une emotion forte ?',
      ar: 'ما علامة الترقيم التي تدل على شعور قوي؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['exclamation mark', '!'],
      fr: <String>['point d exclamation', '!'],
      ar: <String>['علامة التعجب', '!'],
    ),
    tip: LocalizedText(
      en: 'You often see it at the end of excited sentences.',
      fr: 'On le voit souvent a la fin de phrases expressives.',
      ar: 'تراها غالبا في نهاية الجمل المتحمسة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'language_paragraph',
    subjectKey: 'language',
    prompt: LocalizedText(
      en: 'What do we call a group of sentences about one main idea?',
      fr: 'Comment appelle-t-on un groupe de phrases sur une idee principale ?',
      ar: 'ماذا نسمي مجموعة جمل تتحدث عن فكرة رئيسية واحدة؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['paragraph'],
      fr: <String>['paragraphe'],
      ar: <String>['فقرة'],
    ),
    tip: LocalizedText(
      en: 'A long piece of writing is built from several of these.',
      fr: 'Un texte long est construit avec plusieurs de ceux-ci.',
      ar: 'النص الطويل يتكوّن من عدة فقرات.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_keyboard',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'Which computer part do you use to type letters and numbers?',
      fr: 'Quelle partie de l ordinateur utilises-tu pour taper des lettres et des nombres ?',
      ar: 'أي جزء من الحاسوب تستعمله لكتابة الحروف والأرقام؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['keyboard', 'the keyboard'],
      fr: <String>['clavier', 'le clavier'],
      ar: <String>['لوحة المفاتيح'],
    ),
    tip: LocalizedText(
      en: 'It has many keys arranged in rows.',
      fr: 'Il a beaucoup de touches alignees en rangees.',
      ar: 'يحتوي على مفاتيح كثيرة مرتبة في صفوف.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_mouse',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'What device lets you point, click, and drag on a computer?',
      fr: 'Quel appareil permet de pointer, cliquer et glisser sur un ordinateur ?',
      ar: 'ما الجهاز الذي يسمح لك بالإشارة والنقر والسحب على الحاسوب؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['mouse', 'computer mouse'],
      fr: <String>['souris', 'la souris'],
      ar: <String>['الفأرة', 'الماوس'],
    ),
    tip: LocalizedText(
      en: 'You move it with your hand on the desk.',
      fr: 'Tu la deplaces avec la main sur le bureau.',
      ar: 'تحركه بيدك على الطاولة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_internet',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'What is the worldwide network that connects computers called?',
      fr: 'Comment appelle-t-on le reseau mondial qui connecte les ordinateurs ?',
      ar: 'ما اسم الشبكة العالمية التي تربط الحواسيب؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['internet', 'the internet'],
      fr: <String>['internet', 'l internet'],
      ar: <String>['الإنترنت', 'الانترنت'],
    ),
    tip: LocalizedText(
      en: 'Websites and online videos use it.',
      fr: 'Les sites web et les videos en ligne l utilisent.',
      ar: 'تستخدمه المواقع والفيديوهات على الشبكة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_browser',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'What type of program do you use to open websites?',
      fr: 'Quel type de programme utilises-tu pour ouvrir des sites web ?',
      ar: 'ما نوع البرنامج الذي تستخدمه لفتح المواقع الإلكترونية؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['browser', 'web browser'],
      fr: <String>['navigateur', 'navigateur web'],
      ar: <String>['المتصفح', 'متصفح الإنترنت'],
    ),
    tip: LocalizedText(
      en: 'Chrome and Edge are examples.',
      fr: 'Chrome et Edge sont des exemples.',
      ar: 'كروم وإيدج مثالان على ذلك.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_password',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'What do we call a secret word or code used to protect an account?',
      fr: 'Comment appelle-t-on un mot secret ou un code qui protege un compte ?',
      ar: 'ماذا نسمي الكلمة أو الرمز السري الذي يحمي الحساب؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['password'],
      fr: <String>['mot de passe'],
      ar: <String>['كلمة المرور'],
    ),
    tip: LocalizedText(
      en: 'It should be strong and private.',
      fr: 'Il doit etre solide et prive.',
      ar: 'يجب أن تكون قوية وخاصة.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_folder',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'What do we use to organize files on a computer?',
      fr: 'Qu utilise-t-on pour organiser les fichiers sur un ordinateur ?',
      ar: 'ماذا نستخدم لتنظيم الملفات على الحاسوب؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['folder', 'folders'],
      fr: <String>['dossier', 'dossiers'],
      ar: <String>['مجلد', 'المجلد'],
    ),
    tip: LocalizedText(
      en: 'It works like a digital container.',
      fr: 'Cela fonctionne comme un contenant numerique.',
      ar: 'يعمل مثل حافظة رقمية.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_printer',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'Which device puts your work onto paper?',
      fr: 'Quel appareil met ton travail sur papier ?',
      ar: 'ما الجهاز الذي يطبع عملك على الورق؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['printer', 'a printer'],
      fr: <String>['imprimante', 'une imprimante'],
      ar: <String>['الطابعة'],
    ),
    tip: LocalizedText(
      en: 'It produces a hard copy.',
      fr: 'Il produit une copie papier.',
      ar: 'ينتج نسخة ورقية.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_speakers',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'Which output device lets you hear sound from a computer?',
      fr: 'Quel peripherique de sortie permet d entendre le son d un ordinateur ?',
      ar: 'ما جهاز الإخراج الذي يمكنك من سماع صوت الحاسوب؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['speakers', 'headphones'],
      fr: <String>['haut-parleurs', 'casque'],
      ar: <String>['مكبرات الصوت', 'سماعات'],
    ),
    tip: LocalizedText(
      en: 'Music and video sound come through it.',
      fr: 'La musique et le son des videos passent par lui.',
      ar: 'يخرج من خلاله صوت الموسيقى والفيديو.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_spacebar',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'Which keyboard key creates a gap between words?',
      fr: 'Quelle touche du clavier cree un espace entre les mots ?',
      ar: 'أي مفتاح في لوحة المفاتيح ينشئ فراغا بين الكلمات؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['space bar', 'spacebar'],
      fr: <String>['barre d espace', 'espace'],
      ar: <String>['مفتاح المسافة', 'زر المسافة'],
    ),
    tip: LocalizedText(
      en: 'It is usually the long key at the bottom.',
      fr: 'C est souvent la longue touche en bas.',
      ar: 'غالبا يكون المفتاح الطويل في الأسفل.',
    ),
  ),
  RevisionQuestion(
    questionId: 'technology_save_icon',
    subjectKey: 'technology',
    prompt: LocalizedText(
      en: 'What command do you use to keep your changes in a file?',
      fr: 'Quelle commande utilises-tu pour garder tes modifications dans un fichier ?',
      ar: 'ما الأمر الذي تستخدمه للاحتفاظ بتعديلاتك في الملف؟',
    ),
    answers: LocalizedAnswerSet(
      en: <String>['save', 'save file'],
      fr: <String>['enregistrer', 'sauvegarder'],
      ar: <String>['حفظ', 'احفظ'],
    ),
    tip: LocalizedText(
      en: 'Use it before closing your work.',
      fr: 'Utilise-la avant de fermer ton travail.',
      ar: 'استخدمه قبل إغلاق عملك.',
    ),
  ),
];
