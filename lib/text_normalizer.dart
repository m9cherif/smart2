class TextNormalizer {
  static const Map<String, String> _characterMap = <String, String>{
    // Latin diacritics
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'œ': 'oe',
    'æ': 'ae',
    
    // Arabic character normalization
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ى': 'ي',
    'ؤ': 'و',
    'ئ': 'ي',
    'ة': 'ه',
    
    // Additional Arabic normalization for better comparison
    'ك': 'ک', // Normalize different forms of Kaf
    'گ': 'ک', // Normalize Gaf to Kaf
    'ی': 'ي', // Normalize different forms of Ya
  };

  static String normalizeForComparison(String value) {
    var normalized = value.trim().toLowerCase();
    
    // Apply character mappings
    _characterMap.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });

    // Remove Arabic diacritics (harakat) and tatweel
    normalized = normalized
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '') // Diacritics and tatweel
        .replaceAll(
          RegExp(r"[^a-z0-9\u00C0-\u024F\u0600-\u06FF\u0750-\u077F ]"),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalized;
  }

  static List<String> tokenize(String value) {
    final normalized = normalizeForComparison(value);
    if (normalized.isEmpty) {
      return const <String>[];
    }

    return normalized.split(' ');
  }
}
