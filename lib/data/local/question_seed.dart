import '../models/quiz_model.dart';

/// Seed questions for MVP — 30 total
/// Easy: 10 | Medium: 10 | Hard: 10
const List<Question> kSeedQuestions = [

  Question(
    id: 'e001',
    text: 'How many pillars of Islam are there?',
    arabicText: 'كم عدد أركان الإسلام؟',
    options: ['Three', 'Four', 'Five', 'Six'],
    correctIndex: 2,
    difficulty: Difficulty.easy,
    category: QuestionCategory.pillars,
    explanation: 'The Five Pillars are: Shahada, Salah, Zakat, Sawm, and Hajj.',
    coinReward: 10,
  ),

  Question(
    id: 'e002',
    text: 'How many times a day do Muslims pray?',
    arabicText: 'كم مرة يصلي المسلمون في اليوم؟',
    options: ['Three', 'Four', 'Five', 'Seven'],
    correctIndex: 2,
    difficulty: Difficulty.easy,
    category: QuestionCategory.pillars,
    explanation: 'Muslims pray Fajr, Dhuhr, Asr, Maghrib, and Isha — five times daily.',
    coinReward: 10,
  ),

  Question(
    id: 'e003',
    text: 'What is the first surah of the Quran?',
    arabicText: 'ما هي أول سورة في القرآن الكريم؟',
    options: ['Al-Baqarah', 'Al-Fatiha', 'Al-Ikhlas', 'Al-Nas'],
    correctIndex: 1,
    difficulty: Difficulty.easy,
    category: QuestionCategory.quran,
    explanation: 'Al-Fatiha (The Opening) is the first surah and is recited in every unit of prayer.',
    coinReward: 10,
  ),

  Question(
    id: 'e004',
    text: 'Who was the last Prophet of Islam?',
    arabicText: 'من هو آخر نبي في الإسلام؟',
    options: ['Prophet Isa (AS)', 'Prophet Musa (AS)', 'Prophet Ibrahim (AS)', 'Prophet Muhammad (SAW)'],
    correctIndex: 3,
    difficulty: Difficulty.easy,
    category: QuestionCategory.prophets,
    explanation: 'Prophet Muhammad (SAW) is the seal of all prophets and the last messenger of Allah.',
    coinReward: 10,
  ),

  Question(
    id: 'e005',
    text: 'In which month do Muslims fast?',
    arabicText: 'في أي شهر يصوم المسلمون؟',
    options: ['Rajab', 'Shaban', 'Ramadan', 'Muharram'],
    correctIndex: 2,
    difficulty: Difficulty.easy,
    category: QuestionCategory.pillars,
    explanation: 'Ramadan is the ninth month of the Islamic calendar and the month of obligatory fasting.',
    coinReward: 10,
  ),

  Question(
    id: 'e006',
    text: 'What is the holy book of Islam?',
    arabicText: 'ما هو الكتاب المقدس في الإسلام؟',
    options: ['Torah', 'Bible', 'Quran', 'Injeel'],
    correctIndex: 2,
    difficulty: Difficulty.easy,
    category: QuestionCategory.quran,
    explanation: 'The Quran is the final revelation from Allah, revealed to Prophet Muhammad (SAW).',
    coinReward: 10,
  ),

  Question(
    id: 'e007',
    text: 'What does "Islam" mean in Arabic?',
    arabicText: 'ماذا تعني كلمة "إسلام" باللغة العربية؟',
    options: ['Peace', 'Submission', 'Faith', 'Prayer'],
    correctIndex: 1,
    difficulty: Difficulty.easy,
    category: QuestionCategory.aqeedah,
    explanation: 'Islam means "submission to the will of Allah." It shares its root with "salam" (peace).',
    coinReward: 10,
  ),

  Question(
    id: 'e008',
    text: 'In which city was the Prophet Muhammad (SAW) born?',
    arabicText: 'في أي مدينة وُلد النبي محمد صلى الله عليه وسلم؟',
    options: ['Madinah', 'Jerusalem', 'Makkah', 'Taif'],
    correctIndex: 2,
    difficulty: Difficulty.easy,
    category: QuestionCategory.history,
    explanation: 'The Prophet (SAW) was born in Makkah (Mecca) in the Year of the Elephant, 570 CE.',
    coinReward: 10,
  ),

  Question(
    id: 'e009',
    text: 'How many surahs are in the Quran?',
    arabicText: 'كم عدد سور القرآن الكريم؟',
    options: ['110', '114', '120', '99'],
    correctIndex: 1,
    difficulty: Difficulty.easy,
    category: QuestionCategory.quran,
    explanation: 'The Quran contains 114 surahs (chapters), starting with Al-Fatiha and ending with An-Nas.',
    coinReward: 10,
  ),

  Question(
    id: 'e010',
    text: 'What is the direction Muslims face when praying?',
    arabicText: 'ما هو الاتجاه الذي يواجهه المسلمون أثناء الصلاة؟',
    options: ['Jerusalem', 'Madinah', 'Makkah (Qibla)', 'East'],
    correctIndex: 2,
    difficulty: Difficulty.easy,
    category: QuestionCategory.pillars,
    explanation: 'Muslims face the Kaaba in Makkah — this direction is called the Qibla.',
    coinReward: 10,
  ),

  // ─────────────────────────────────────────────
  // MEDIUM (10)
  // ─────────────────────────────────────────────

  Question(
    id: 'm001',
    text: 'Which angel is responsible for delivering revelation?',
    arabicText: 'أي ملاك مسؤول عن تبليغ الوحي؟',
    options: ['Israfil (AS)', 'Mikail (AS)', 'Jibreel (AS)', 'Azrael (AS)'],
    correctIndex: 2,
    difficulty: Difficulty.medium,
    category: QuestionCategory.aqeedah,
    explanation: 'Angel Jibreel (Gabriel) delivered the revelations of the Quran to Prophet Muhammad (SAW).',
    coinReward: 10,
  ),

  Question(
    id: 'm002',
    text: 'What is the minimum amount of Zakat payable (Nisab in gold terms)?',
    options: ['75 grams', '85 grams', '100 grams', '50 grams'],
    correctIndex: 1,
    difficulty: Difficulty.medium,
    category: QuestionCategory.pillars,
    explanation: 'The Nisab threshold for gold is 85 grams. Zakat is 2.5% of wealth held for one lunar year.',
    coinReward: 10,
  ),

  Question(
    id: 'm003',
    text: 'In which year did the Hijra (migration to Madinah) take place?',
    options: ['610 CE', '615 CE', '622 CE', '630 CE'],
    correctIndex: 2,
    difficulty: Difficulty.medium,
    category: QuestionCategory.history,
    explanation: 'The Hijra took place in 622 CE. This event marks the beginning of the Islamic calendar.',
    coinReward: 10,
  ),

  Question(
    id: 'm004',
    text: 'Which surah is known as the "Heart of the Quran"?',
    arabicText: 'أي سورة تُعرف بـ"قلب القرآن"؟',
    options: ['Surah Al-Kahf', 'Surah Yasin', 'Surah Al-Mulk', 'Surah Ar-Rahman'],
    correctIndex: 1,
    difficulty: Difficulty.medium,
    category: QuestionCategory.quran,
    explanation: 'Surah Yasin (Chapter 36) is referred to as the heart of the Quran in several hadith.',
    coinReward: 10,
  ),

  Question(
    id: 'm005',
    text: 'How many rakats are in the Fajr (dawn) prayer?',
    arabicText: 'كم عدد ركعات صلاة الفجر؟',
    options: ['2', '3', '4', '1'],
    correctIndex: 0,
    difficulty: Difficulty.medium,
    category: QuestionCategory.pillars,
    explanation: 'Fajr prayer consists of 2 obligatory (fard) rakats. It is prayed between dawn and sunrise.',
    coinReward: 10,
  ),

  Question(
    id: 'm006',
    text: 'What does "Inshallah" mean?',
    arabicText: 'ماذا تعني "إن شاء الله"؟',
    options: [
      'Praise be to Allah',
      'If Allah wills',
      'In the name of Allah',
      'Allah is the Greatest',
    ],
    correctIndex: 1,
    difficulty: Difficulty.medium,
    category: QuestionCategory.morals,
    explanation: '"Inshallah" (إن شاء الله) means "If Allah wills." Muslims say it when referring to future events.',
    coinReward: 10,
  ),

  Question(
    id: 'm007',
    text: 'Which Prophet is known as Khalilullah (Friend of Allah)?',
    arabicText: 'أي نبي يُعرف بخليل الله؟',
    options: ['Prophet Musa (AS)', 'Prophet Isa (AS)', 'Prophet Ibrahim (AS)', 'Prophet Nuh (AS)'],
    correctIndex: 2,
    difficulty: Difficulty.medium,
    category: QuestionCategory.prophets,
    explanation: 'Prophet Ibrahim (Abraham) AS was given the title Khalilullah — the intimate friend of Allah.',
    coinReward: 10,
  ),

  Question(
    id: 'm008',
    text: 'What is the name of the night journey of the Prophet (SAW)?',
    arabicText: 'ما اسم رحلة الإسراء والمعراج للنبي صلى الله عليه وسلم؟',
    options: ['Al-Hijra', 'Al-Isra wal Miraj', 'Laylat al-Qadr', 'Badr'],
    correctIndex: 1,
    difficulty: Difficulty.medium,
    category: QuestionCategory.history,
    explanation: 'Al-Isra wal Miraj — the night journey from Makkah to Jerusalem and ascension to the heavens.',
    coinReward: 10,
  ),

  Question(
    id: 'm009',
    text: 'Which surah contains Ayat al-Kursi (the Throne Verse)?',
    arabicText: 'أي سورة تحتوي على آية الكرسي؟',
    options: ['Surah Al-Imran', 'Surah An-Nisa', 'Surah Al-Baqarah', 'Surah Al-Maidah'],
    correctIndex: 2,
    difficulty: Difficulty.medium,
    category: QuestionCategory.quran,
    explanation: 'Ayat al-Kursi is verse 255 of Surah Al-Baqarah. It is the greatest verse in the Quran.',
    coinReward: 10,
  ),

  Question(
    id: 'm010',
    text: 'What is the name of the well in Makkah associated with Hajar (AS)?',
    arabicText: 'ما اسم البئر في مكة المرتبطة بهاجر عليها السلام؟',
    options: ['Zamzam', 'Kawthar', 'Salsabil', 'Tasnim'],
    correctIndex: 0,
    difficulty: Difficulty.medium,
    category: QuestionCategory.history,
    explanation: 'The Zamzam well miraculously appeared for Hajar and her son Ismail (AS). It still flows today.',
    coinReward: 10,
  ),

  // ─────────────────────────────────────────────
  // HARD (10)
  // ─────────────────────────────────────────────

  Question(
    id: 'h001',
    text: 'How many Prophets are mentioned by name in the Quran?',
    options: ['20', '25', '28', '30'],
    correctIndex: 1,
    difficulty: Difficulty.hard,
    category: QuestionCategory.prophets,
    explanation: '25 Prophets are mentioned by name in the Quran, from Adam (AS) to Muhammad (SAW).',
    coinReward: 10,
  ),

  Question(
    id: 'h002',
    text: 'What is the longest surah in the Quran?',
    arabicText: 'ما هي أطول سورة في القرآن الكريم؟',
    options: ['Surah Al-Imran', 'Surah An-Nisa', 'Surah Al-Baqarah', 'Surah Al-Maidah'],
    correctIndex: 2,
    difficulty: Difficulty.hard,
    category: QuestionCategory.quran,
    explanation: 'Surah Al-Baqarah (Chapter 2) is the longest surah with 286 verses.',
    coinReward: 10,
  ),

  Question(
    id: 'h003',
    text: 'In Islamic jurisprudence, what is "Ijma"?',
    options: [
      'Personal reasoning by a scholar',
      'Scholarly consensus on a legal matter',
      'A Quranic verse about law',
      'The ruling of a single Caliph',
    ],
    correctIndex: 1,
    difficulty: Difficulty.hard,
    category: QuestionCategory.fiqh,
    explanation: 'Ijma (إجماع) is the consensus of qualified Islamic scholars on a legal ruling. It is the third source of Islamic law after Quran and Sunnah.',
    coinReward: 10,
  ),

  Question(
    id: 'h004',
    text: 'Which companion of the Prophet (SAW) is known as "The Trustworthy" (Al-Amin)?',
    options: ['Abu Bakr (RA)', 'Umar ibn al-Khattab (RA)', 'Ali ibn Abi Talib (RA)', 'The Prophet himself (SAW)'],
    correctIndex: 3,
    difficulty: Difficulty.hard,
    category: QuestionCategory.history,
    explanation: 'The Prophet Muhammad (SAW) himself was called Al-Amin (The Trustworthy) by the Quraysh before prophethood.',
    coinReward: 10,
  ),

  Question(
    id: 'h005',
    text: 'What is "Laylat al-Qadr" (The Night of Power) better than?',
    arabicText: 'ليلة القدر خير من؟',
    options: ['100 nights', '500 nights', '1000 months', '1000 years'],
    correctIndex: 2,
    difficulty: Difficulty.hard,
    category: QuestionCategory.quran,
    explanation: 'Allah says in Surah Al-Qadr: "The Night of Power is better than a thousand months." (97:3)',
    coinReward: 10,
  ),

  Question(
    id: 'h006',
    text: 'What is the ruling (hukm) on fasting on Eid al-Fitr?',
    options: ['Mustahabb (recommended)', 'Makruh (disliked)', 'Haram (forbidden)', 'Fard (obligatory)'],
    correctIndex: 2,
    difficulty: Difficulty.hard,
    category: QuestionCategory.fiqh,
    explanation: 'It is haram (forbidden) to fast on both Eid al-Fitr and Eid al-Adha. These are days of celebration and eating.',
    coinReward: 10,
  ),

  Question(
    id: 'h007',
    text: 'Which battle is referred to as "Yawm al-Furqan" (Day of Distinction) in the Quran?',
    options: ['Battle of Uhud', 'Battle of Badr', 'Battle of Khandaq', 'Battle of Hunayn'],
    correctIndex: 1,
    difficulty: Difficulty.hard,
    category: QuestionCategory.history,
    explanation: 'The Battle of Badr (624 CE) is called Yawm al-Furqan in Surah Al-Anfal. It was the first major battle of Islam.',
    coinReward: 10,
  ),

  Question(
    id: 'h008',
    text: 'In the science of hadith, what is a "Hadith Mutawatir"?',
    options: [
      'A hadith narrated by one person only',
      'A weak hadith with broken chain',
      'A hadith narrated by so many people that fabrication is impossible',
      'A hadith verified by Imam Bukhari alone',
    ],
    correctIndex: 2,
    difficulty: Difficulty.hard,
    category: QuestionCategory.hadith,
    explanation: 'A Hadith Mutawatir is narrated by such a large number of people at every level that it is considered impossible to fabricate.',
    coinReward: 10,
  ),

  Question(
    id: 'h009',
    text: 'Which Prophet was thrown into the fire by Nimrod and emerged unharmed?',
    arabicText: 'أي نبي ألقاه نمرود في النار وخرج سالماً؟',
    options: ['Prophet Musa (AS)', 'Prophet Yusuf (AS)', 'Prophet Ibrahim (AS)', 'Prophet Ismail (AS)'],
    correctIndex: 2,
    difficulty: Difficulty.hard,
    category: QuestionCategory.prophets,
    explanation: 'Nimrod threw Prophet Ibrahim (AS) into a massive fire. Allah commanded the fire: "Be cool and safe for Ibrahim." (Quran 21:69)',
    coinReward: 10,
  ),

  Question(
    id: 'h010',
    text: 'What is the meaning of "Taqwa"?',
    arabicText: 'ما معنى "التقوى"؟',
    options: [
      'Performing Hajj with sincerity',
      'God-consciousness and piety — fearing Allah and obeying Him',
      'Giving charity in secret',
      'Memorising the Quran fully',
    ],
    correctIndex: 1,
    difficulty: Difficulty.hard,
    category: QuestionCategory.aqeedah,
    explanation: 'Taqwa is often translated as God-consciousness or piety — being aware of Allah in all your actions and striving to please Him.',
    coinReward: 10,
  ),
];