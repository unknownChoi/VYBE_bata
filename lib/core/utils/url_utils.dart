/// 인스타그램 URL → 핸들 (예: "https://instagram.com/awesomered" → "@awesomered")
String instagramHandle(String url) {
  if (url.isEmpty) return '';
  final cleaned = url
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'^(www\.)?instagram\.com/'), '')
      .replaceAll(RegExp(r'/+$'), '');
  return cleaned.isEmpty ? '' : '@$cleaned';
}

/// URL 표시용 — http(s) 스킴 제거
String stripScheme(String url) => url.replaceFirst(RegExp(r'^https?://'), '');
