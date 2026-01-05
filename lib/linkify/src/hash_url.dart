import '../linkify.dart';

class HashUrlLinkifier extends Linkifier {
  const HashUrlLinkifier();

  // Original inline pattern: #https://...#Some Title#
  static final _inlineResourceRegex = RegExp(r'#(https?://[^\s#]+)#([^#]+)#');

  // List item pattern - matches the link anywhere (no anchor at start/end)
  static final _listItemCoreRegex = RegExp(
    r'#(https?://[^#\s]+)#\s*([^#]+?)\s*#',
    caseSensitive: false,
  );

  @override
  List<LinkifyElement> parse(
      List<LinkifyElement> elements, LinkifyOptions options) {
    final list = <LinkifyElement>[];

    for (var element in elements) {
      if (element is TextElement) {
        String remaining = element.text;

        // === Bullet List Mode ===
        if (options.linkAsList) {
          while (remaining.isNotEmpty) {
            // Find the next newline
            final nextNewline = remaining.indexOf('\n');
            final line = nextNewline >= 0
                ? remaining.substring(0, nextNewline)
                : remaining;

            // Try to find a link pattern in this line
            final coreMatch = _listItemCoreRegex.firstMatch(line);

            if (coreMatch != null) {
              final beforeLink = line.substring(0, coreMatch.start);
              final url = coreMatch.group(1)!;
              final rawTitle = coreMatch.group(2)!;
              final title = rawTitle.trim();
              final afterLink = line.substring(coreMatch.end);

              // Add text before the link (if any)
              if (beforeLink.trim().isNotEmpty) {
                list.add(TextElement(beforeLink));
                if (afterLink.trim().isNotEmpty || nextNewline >= 0) {
                  list.add(TextElement('\n'));
                }
              }

              // Add the bullet and link
              list.add(TextElement('• '));
              list.add(HashUrlElement(
                url,
                title.isNotEmpty ? title : url,
              ));

              // Handle text after the link
              final trimmedAfter = afterLink.trim();
              if (trimmedAfter.isNotEmpty) {
                // Check if it's just punctuation (comma, period, etc.)
                if (trimmedAfter == ',' ||
                    trimmedAfter == '.' ||
                    trimmedAfter == ';') {
                  list.add(TextElement(trimmedAfter));
                } else {
                  // It's actual text content, put it on a new line
                  list.add(TextElement('\n'));
                  list.add(TextElement(afterLink));
                  list.add(TextElement('\n'));
                }
              }

              // Add newline after bullet point (if no text after was added)
              if (trimmedAfter.isEmpty ||
                  trimmedAfter == ',' ||
                  trimmedAfter == '.' ||
                  trimmedAfter == ';') {
                list.add(TextElement('\n'));
              }

              // Advance remaining
              remaining =
                  nextNewline >= 0 ? remaining.substring(nextNewline + 1) : '';
            } else {
              // No link found in this line, add it as-is
              list.add(TextElement(line));
              if (nextNewline >= 0) {
                list.add(TextElement('\n'));
                remaining = remaining.substring(nextNewline + 1);
              } else {
                remaining = '';
              }
            }
          }
          continue;
        }

        // === Fallback: Original Inline #url#text# Parsing ===
        final matches = _inlineResourceRegex.allMatches(remaining);

        if (matches.isEmpty) {
          list.add(TextElement(remaining));
        } else {
          var currentIndex = 0;
          for (final match in matches) {
            final prefix = remaining.substring(currentIndex, match.start);
            if (prefix.isNotEmpty) {
              list.add(TextElement(prefix));
            }

            list.add(HashUrlElement(match.group(1)!, match.group(2)!));

            currentIndex = match.end;
          }

          final suffix = remaining.substring(currentIndex);
          if (suffix.isNotEmpty) {
            list.add(TextElement(suffix));
          }
        }
      } else {
        list.add(element);
      }
    }

    return list;
  }
}

/// Represents an element containing a hash link
class HashUrlElement extends LinkableElement {
  HashUrlElement(String url, String text) : super(text, url);

  @override
  String toString() {
    return "HashUrlElement: '$url' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => Object.hash(text, url);

  @override
  bool equals(other) => other is HashUrlElement && super.equals(other);
}
