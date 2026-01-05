import '../linkify.dart';

class HashUrlLinkifier extends Linkifier {
  const HashUrlLinkifier();

  // Original inline pattern: #https://...#Some Title#
  static final _inlineResourceRegex = RegExp(r'#(https?://[^\s#]+)#([^#]+)#');

  // List item pattern - matches the link anywhere
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
          // First, check if this text contains multiple hash links in a list format
          final allMatches = _listItemCoreRegex.allMatches(remaining).toList();

          if (allMatches.length < 2) {
            // Less than 2 links, use inline parsing
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
            continue;
          }

          // Check if links are consecutive (separated only by whitespace, newlines, or commas)
          bool isConsecutiveList = true;
          for (int i = 0; i < allMatches.length - 1; i++) {
            final currentEnd = allMatches[i].end;
            final nextStart = allMatches[i + 1].start;
            final textBetween =
                remaining.substring(currentEnd, nextStart).trim();

            // Links should be separated by nothing, comma, or just whitespace/newlines
            if (textBetween.isNotEmpty && textBetween != ',') {
              isConsecutiveList = false;
              break;
            }
          }

          // If not a consecutive list, use inline parsing
          if (!isConsecutiveList) {
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
            continue;
          }

          // We have multiple consecutive links, process as a list
          while (remaining.isNotEmpty) {
            // Find the next newline
            final nextNewline = remaining.indexOf('\n');
            final line = nextNewline >= 0
                ? remaining.substring(0, nextNewline)
                : remaining;

            // Find ALL link patterns in this line
            final lineMatches = _listItemCoreRegex.allMatches(line).toList();

            if (lineMatches.isNotEmpty) {
              var lineIndex = 0;

              for (final coreMatch in lineMatches) {
                final beforeLink =
                    line.substring(lineIndex, coreMatch.start).trim();
                final url = coreMatch.group(1)!;
                final rawTitle = coreMatch.group(2)!;
                final title = rawTitle.trim();

                // Add text before the link (if any) - skip commas
                if (beforeLink.isNotEmpty && beforeLink != ',') {
                  list.add(TextElement(beforeLink));
                  list.add(TextElement('\n'));
                }

                // Add the bullet and link
                list.add(TextElement('• '));
                list.add(HashUrlElement(
                  url,
                  title.isNotEmpty ? title : url,
                ));
                list.add(TextElement('\n'));

                lineIndex = coreMatch.end;
              }

              // Handle text after all links on this line
              final afterLinks = line.substring(lineIndex).trim();
              if (afterLinks.isNotEmpty) {
                // Skip comma for bullet points, but keep other punctuation
                if (afterLinks == ',') {
                  // Don't add comma in bullet list
                } else if (afterLinks == '.' || afterLinks == ';') {
                  list.add(TextElement(afterLinks));
                  list.add(TextElement('\n'));
                } else {
                  // It's substantial text, put it on next line
                  list.add(TextElement(afterLinks));
                  list.add(TextElement('\n'));
                }
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
