/// Normalize / parse RFC Message-ID values for threading lookups.
class MessageIdUtil {
  MessageIdUtil._();

  /// Strip whitespace and surrounding `<>`; lowercase for comparison.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    var s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s.startsWith('<') && s.endsWith('>') && s.length >= 2) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s.isEmpty ? null : s;
  }

  /// Extract Message-IDs from In-Reply-To or References header text.
  static List<String> parseHeaderIds(String? header) {
    if (header == null || header.trim().isEmpty) return const [];
    final re = RegExp(r'<[^>]+>|[^\s<>]+@[^\s<>]+');
    final out = <String>[];
    final seen = <String>{};
    for (final m in re.allMatches(header)) {
      final n = normalize(m.group(0));
      if (n != null && seen.add(n)) out.add(n);
    }
    return out;
  }

  /// All IDs that link this message into a thread graph.
  static Set<String> linkIds({
    String? messageId,
    String? inReplyTo,
    String? referencesHeader,
  }) {
    final ids = <String>{
      ...parseHeaderIds(inReplyTo),
      ...parseHeaderIds(referencesHeader),
    };
    final own = normalize(messageId);
    if (own != null) ids.add(own);
    return ids;
  }
}
