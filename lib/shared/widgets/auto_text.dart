// AutoText widget that automatically translates text based on selected language
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/translate_service.dart';

class AutoText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final targetLang = languageProvider.currentLanguage;

    // If English, return original text immediately
    if (targetLang == 'en') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // Use FutureBuilder to translate text
    return FutureBuilder<String>(
      future: TranslateService.translate(text, targetLang),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? text, // Fallback to original if translation fails
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
