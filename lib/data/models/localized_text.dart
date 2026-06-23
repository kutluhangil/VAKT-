/// A piece of content text carried in both languages.
/// One data model, two languages — switches instantly with the locale (§1).
class LocalizedText {
  final String tr;
  final String en;

  const LocalizedText({required this.tr, required this.en});

  /// Returns the string for the given language code ('tr' or anything else -> en).
  String of(String languageCode) => languageCode == 'tr' ? tr : en;

  factory LocalizedText.fromJson(Map<String, dynamic> j) =>
      LocalizedText(tr: j['tr'] as String, en: j['en'] as String);

  Map<String, dynamic> toJson() => {'tr': tr, 'en': en};
}
