import '../linkify.dart';

class HashUrlLinkifier extends Linkifier {
  const HashUrlLinkifier();

  // Original inline pattern: #https://...#Some Title#
  static final _inlineResourceRegex = RegExp(r'#(https?://[^\s#]+)#([^#]+)#');

  // List item core pattern (matches the link part, including optional trailing comma and whitespace)
  static final _listItemCoreRegex = RegExp(
    r'#(https?://[^#\s]+)#\s*([^#]+?)\s*#(?:,\s*)?\s*$',
    caseSensitive: false,
  );

  // Regex to match line starts (for checking if a list item is at the beginning of remaining text or after a newline)
  static final _lineStartRegex = RegExp(r'(^|\r?\n)[ \t]*');

  @override
  List<LinkifyElement> parse(
      List<LinkifyElement> elements, LinkifyOptions options) {
    final list = <LinkifyElement>[];

    for (var element in elements) {
      if (element is TextElement) {
        String remaining = element.text;

        // === Bullet List Mode ===
        if (options.linkAsList) {
          bool processedAny = false;

          while (remaining.isNotEmpty) {
            final lineStartMatch = _lineStartRegex.firstMatch(remaining);

            if (lineStartMatch == null) {
              // Fallback to inline parsing for the rest
              list.addAll(parse([TextElement(remaining)],
                  options.copyWith(linkAsList: false)));
              break;
            }

            final lineStartEnd = lineStartMatch.end;
            final potentialLine = remaining.substring(lineStartEnd);

            final lineEndIndex = potentialLine.indexOf('\n');
            final line = lineEndIndex >= 0
                ? potentialLine.substring(0, lineEndIndex)
                : potentialLine;

            final coreMatch = _listItemCoreRegex.matchAsPrefix(line);

            final thisLineEnd = lineStartEnd +
                (lineEndIndex >= 0 ? lineEndIndex + 1 : potentialLine.length);

            if (coreMatch != null && coreMatch.end == line.length) {
              processedAny = true;
              final url = coreMatch.group(1)!;
              final rawTitle = coreMatch.group(2)!;
              final title = rawTitle.trim();

              // Skip the lineStart whitespace/newline, add bullet and link
              list.add(TextElement('• '));
              list.add(HashUrlElement(
                url,
                title.isNotEmpty ? title : url,
              ));
              list.add(TextElement('\n'));

              // Advance remaining past this item (full line including \n)
              remaining = remaining.substring(thisLineEnd);
              continue;
            } else {
              final fullLine = remaining.substring(0, thisLineEnd);
              list.addAll(parse([TextElement(fullLine)],
                  options.copyWith(linkAsList: false)));
              // Advance remaining
              remaining = remaining.substring(thisLineEnd);
            }
          }

          if (processedAny) {
            // Process any leftover text recursively (with list mode, but it will fallback if needed)
            if (remaining.isNotEmpty) {
              list.addAll(parse([TextElement(remaining)], options));
            }
            continue; // Skip inline parsing for this element
          } else {}
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
