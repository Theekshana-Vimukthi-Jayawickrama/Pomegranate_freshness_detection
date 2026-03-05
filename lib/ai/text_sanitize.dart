class TextSanitize {
  static String stripMarkdown(String s) {
    var out = s;

    // Remove **bold** and *italic*
    out = out.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    out = out.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');

    // Remove headings like ## Title
    out = out.replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '');

    // Remove backticks
    out = out.replaceAll('`', '');

    return out.trim();
  }
}
