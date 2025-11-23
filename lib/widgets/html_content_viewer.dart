import 'package:flutter/material.dart';

/// Widget to render HTML content with rich formatting support
/// Parses HTML tags and displays them with appropriate styling
/// Supports: h1-h3, p, strong, em, ul, ol, li, br
class HtmlContentViewer extends StatelessWidget {
  final String htmlContent;
  final TextStyle? baseStyle;

  const HtmlContentViewer({
    super.key,
    required this.htmlContent,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextStyle = baseStyle ?? theme.textTheme.bodyLarge!;

    // Parse HTML and convert to list of styled widgets
    final widgets = _parseHtmlToWidgets(htmlContent, theme, baseTextStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _parseHtmlToWidgets(
    String html,
    ThemeData theme,
    TextStyle baseStyle,
  ) {
    final widgets = <Widget>[];
    final colorScheme = theme.colorScheme;

    // Clean up HTML: fix unclosed tags, normalize spacing
    html = _cleanHtml(html);

    // Split by block-level tags
    final blockParts = _splitByBlockTags(html);

    for (final part in blockParts) {
      if (part.trim().isEmpty) continue;

      if (_isBlockTag(part, 'h1')) {
        final spans = _parseInlineTags(part, theme, baseStyle, isHeader: true);
        if (spans.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Text.rich(
                TextSpan(children: spans),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else if (_isBlockTag(part, 'h2')) {
        final spans = _parseInlineTags(part, theme, baseStyle, isHeader: true);
        if (spans.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Text.rich(
                TextSpan(children: spans),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else if (_isBlockTag(part, 'h3')) {
        final spans = _parseInlineTags(part, theme, baseStyle, isHeader: true);
        if (spans.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Text.rich(
                TextSpan(children: spans),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else if (_isBlockTag(part, 'h4')) {
        final spans = _parseInlineTags(part, theme, baseStyle, isHeader: true);
        if (spans.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text.rich(
                TextSpan(children: spans),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else if (_isBlockTag(part, 'p')) {
        final spans = _parseInlineTags(part, theme, baseStyle);
        if (spans.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text.rich(
                TextSpan(children: spans),
                style: baseStyle.copyWith(
                  height: 1.6,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else if (_isBlockTag(part, 'ul') || _isBlockTag(part, 'ol')) {
        final liItems = _extractListItems(part);
        final isOrdered = _isBlockTag(part, 'ol');

        for (int i = 0; i < liItems.length; i++) {
          final liText = liItems[i];
          final spans = _parseInlineTags(liText, theme, baseStyle);

          final bullet = isOrdered ? '${i + 1}. ' : '• ';

          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bullet,
                    style: baseStyle.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: spans),
                      style: baseStyle.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else if (part.trim().isNotEmpty && !part.trim().startsWith('<')) {
        // Plain text
        final text = _stripTags(part).trim();
        if (text.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                text,
                style: baseStyle.copyWith(
                  height: 1.6,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  /// Parse inline tags (strong, em, br, etc) and return TextSpans
  List<InlineSpan> _parseInlineTags(
    String text,
    ThemeData theme,
    TextStyle baseStyle, {
    bool isHeader = false,
  }) {
    final spans = <InlineSpan>[];

    // Remove outer tags
    text = _stripOuterTag(text);

    // Split by inline tags
    final parts = _splitByInlineTags(text);

    for (final part in parts) {
      if (part.isEmpty) continue;

      if (part.startsWith('<strong>') ||
          part.startsWith('<b>') ||
          part.startsWith('<strong ')) {
        final innerText = _stripTags(part);
        if (innerText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: innerText,
              style: baseStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }
      } else if (part.startsWith('<em>') ||
          part.startsWith('<i>') ||
          part.startsWith('<em ')) {
        final innerText = _stripTags(part);
        if (innerText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: innerText,
              style: baseStyle.copyWith(fontStyle: FontStyle.italic),
            ),
          );
        }
      } else if (part.startsWith('<br') || part == '<br/>') {
        spans.add(const TextSpan(text: '\n'));
      } else if (!part.startsWith('<')) {
        // Plain text - decode entities
        final decodedText = _decodeHtmlEntities(part);
        if (decodedText.isNotEmpty) {
          spans.add(TextSpan(text: decodedText));
        }
      }
    }

    return spans.isEmpty
        ? [TextSpan(text: text)]
        : spans;
  }

  /// Extract list items from ul or ol tag
  List<String> _extractListItems(String html) {
    final items = <String>[];
    final liRegex = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true);

    for (final match in liRegex.allMatches(html)) {
      final content = match.group(1) ?? '';
      items.add(content.trim());
    }

    return items;
  }

  /// Split HTML by block-level tags
  List<String> _splitByBlockTags(String html) {
    final blockTagPattern = RegExp(
      r'<(h[1-6]|p|ul|ol|div|blockquote)[^>]*>.*?</\1>',
      dotAll: true,
      caseSensitive: false,
    );

    final matches = blockTagPattern.allMatches(html).toList();

    if (matches.isEmpty) {
      return [html];
    }

    final result = <String>[];
    var lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        final between = html.substring(lastEnd, match.start).trim();
        if (between.isNotEmpty) {
          result.add(between);
        }
      }
      result.add(match.group(0)!);
      lastEnd = match.end;
    }

    if (lastEnd < html.length) {
      final remaining = html.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        result.add(remaining);
      }
    }

    return result;
  }

  /// Split by inline tags (strong, em, br, etc)
  List<String> _splitByInlineTags(String text) {
    final result = <String>[];
    final tagPattern = RegExp(
      r'<(strong|b|em|i|br)(?:\s[^>]*)?>(?:(.*?)</\1>)?',
      caseSensitive: false,
    );

    var lastEnd = 0;

    for (final match in tagPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        final plainText = text.substring(lastEnd, match.start);
        if (plainText.isNotEmpty) {
          result.add(plainText);
        }
      }
      result.add(match.group(0)!);
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      result.add(text.substring(lastEnd));
    }

    return result.where((s) => s.isNotEmpty).toList();
  }

  /// Check if HTML part is a block tag
  bool _isBlockTag(String html, String tagName) {
    final pattern = RegExp(
      '<$tagName(?:\\s[^>]*)?>',
      caseSensitive: false,
    );
    return pattern.hasMatch(html);
  }

  /// Strip outer tag from HTML
  String _stripOuterTag(String html) {
    final match = RegExp(r'^<[^>]+>(.*)</[^>]+>$', dotAll: true).firstMatch(html);
    return match?.group(1) ?? html;
  }

  /// Clean HTML: remove extra spaces, normalize tags
  String _cleanHtml(String html) {
    // Replace multiple spaces
    html = html.replaceAll(RegExp(r'\s+'), ' ');
    // Fix common issues
    html = html.replaceAll('</p> <p>', '</p><p>');
    return html;
  }

  /// Decode HTML entities
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&hellip;', '…')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''');
  }

  /// Remove all HTML tags
  String _stripTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

