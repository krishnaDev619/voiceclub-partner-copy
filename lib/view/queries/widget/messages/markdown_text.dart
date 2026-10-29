import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

/// A custom markdown renderer that works with IntrinsicWidth
/// and doesn't use scrollable viewports
class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const MarkdownText({super.key, required this.text, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        baseStyle ??
        TextStyle(
          color: Colors.black87,
          fontFamily: GoogleFonts.mulish().fontFamily,
          fontSize: 13.0,
        );

    final blocks = _parseMarkdown(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:
          blocks.map((block) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: _buildBlock(block, defaultStyle),
            );
          }).toList(),
    );
  }

  Widget _buildBlock(MarkdownBlock block, TextStyle defaultStyle) {
    switch (block.type) {
      case BlockType.paragraph:
        return RichText(
          text: TextSpan(
            children: _parseInlineStyles(block.content, defaultStyle),
            style: defaultStyle,
          ),
        );
      case BlockType.heading:
        return RichText(
          text: TextSpan(
            children: _parseInlineStyles(block.content, defaultStyle),
            style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      case BlockType.codeBlock:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            block.content,
            style: defaultStyle.copyWith(
              fontFamily: 'monospace',
              fontSize: (defaultStyle.fontSize ?? FontSize.M) - 1,
            ),
          ),
        );
      case BlockType.listItem:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: defaultStyle),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: _parseInlineStyles(block.content, defaultStyle),
                  style: defaultStyle,
                ),
              ),
            ),
          ],
        );
      case BlockType.blockquote:
        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: ApplicationColors.primaryRed, width: 4.0),
            ),
          ),
          padding: const EdgeInsets.only(left: 12.0),
          child: RichText(
            text: TextSpan(
              children: _parseInlineStyles(block.content, defaultStyle),
              style: defaultStyle.copyWith(
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
    }
  }

  List<MarkdownBlock> _parseMarkdown(String text) {
    final blocks = <MarkdownBlock>[];
    final lines = text.split('\n');
    final paragraphBuffer = <String>[];

    void flushParagraph() {
      if (paragraphBuffer.isNotEmpty) {
        blocks.add(
          MarkdownBlock(
            type: BlockType.paragraph,
            content: paragraphBuffer.join('\n'),
          ),
        );
        paragraphBuffer.clear();
      }
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Empty line indicates paragraph break
      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }

      // Check for headings
      if (line.startsWith('#')) {
        final match = RegExp(r'^(#{1,6})\s+(.+)').firstMatch(line);
        if (match != null) {
          flushParagraph();
          blocks.add(
            MarkdownBlock(
              type: BlockType.heading,
              content: match.group(2)!,
              level: match.group(1)!.length,
            ),
          );
          continue;
        }
      }

      // Check for code blocks
      // Remove zero-width spaces and other invisible characters
      final cleanLine =
          line.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '').trim();
      if (cleanLine.startsWith('```')) {
        flushParagraph();
        final codeLines = <String>[];
        i++; // Skip the opening ```
        while (i < lines.length) {
          final cleanEndLine =
              lines[i].replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '').trim();
          if (cleanEndLine.startsWith('```')) {
            break;
          }
          codeLines.add(lines[i]);
          i++;
        }
        blocks.add(
          MarkdownBlock(
            type: BlockType.codeBlock,
            content: codeLines.join('\n'),
          ),
        );
        continue;
      }

      // Check for list items
      if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
        flushParagraph();
        blocks.add(
          MarkdownBlock(
            type: BlockType.listItem,
            content: line.trim().substring(2),
          ),
        );
        continue;
      }

      // Check for blockquotes
      if (line.trim().startsWith('>')) {
        flushParagraph();
        blocks.add(
          MarkdownBlock(
            type: BlockType.blockquote,
            content: line.trim().substring(1).trim(),
          ),
        );
        continue;
      }

      // Accumulate lines for paragraph
      paragraphBuffer.add(line);
    }

    // Flush any remaining paragraph
    flushParagraph();

    return blocks;
  }

  List<InlineSpan> _parseInlineStyles(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final patterns = [
      // Bold: **text** or __text__ (must come before italic to match first)
      _InlinePattern(
        regex: RegExp(r'\*\*([^\*]+?)\*\*|__([^_]+?)__'),
        builder:
            (match, style) => TextSpan(
              text: match.group(1) ?? match.group(2),
              style: style.copyWith(fontWeight: FontWeight.bold),
            ),
      ),
      // Inline code: `code` (must come before italic to avoid conflicts)
      _InlinePattern(
        regex: RegExp(r'`([^`]+?)`'),
        builder:
            (match, style) => TextSpan(
              text: match.group(1),
              style: style.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
      ),
      // Italic: *text* or _text_
      _InlinePattern(
        regex: RegExp(r'(?<!\*)\*([^\*]+?)\*(?!\*)|(?<!_)_([^_]+?)_(?!_)'),
        builder:
            (match, style) => TextSpan(
              text: match.group(1) ?? match.group(2),
              style: style.copyWith(fontStyle: FontStyle.italic),
            ),
      ),
    ];

    int lastIndex = 0;
    final allMatches = <_Match>[];

    // Find all matches for all patterns
    for (final pattern in patterns) {
      for (final match in pattern.regex.allMatches(text)) {
        allMatches.add(_Match(match, pattern));
      }
    }

    // Sort matches by start position
    allMatches.sort((a, b) => a.match.start.compareTo(b.match.start));

    // Process matches, avoiding overlaps
    for (final item in allMatches) {
      final match = item.match;

      // Skip if this match overlaps with already processed text
      if (match.start < lastIndex) continue;

      // Add plain text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      // Add styled text
      spans.add(item.pattern.builder(match, baseStyle));
      lastIndex = match.end;
    }

    // Add remaining plain text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }
}

enum BlockType { paragraph, heading, codeBlock, listItem, blockquote }

class MarkdownBlock {
  final BlockType type;
  final String content;
  final int level; // For headings

  MarkdownBlock({required this.type, required this.content, this.level = 1});
}

class _InlinePattern {
  final RegExp regex;
  final InlineSpan Function(RegExpMatch match, TextStyle style) builder;

  _InlinePattern({required this.regex, required this.builder});
}

class _Match {
  final RegExpMatch match;
  final _InlinePattern pattern;

  _Match(this.match, this.pattern);
}
