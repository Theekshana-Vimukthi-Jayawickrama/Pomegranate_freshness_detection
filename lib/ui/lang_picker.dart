import 'package:flutter/material.dart';
import 'app_lang.dart';

class LangPicker {
  static Future<AppLang?> show(BuildContext context) async {
    return showModalBottomSheet<AppLang>(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select language / භාෂාව තෝරන්න",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _tile(ctx, AppLang.en),
              _tile(ctx, AppLang.si),
              _tile(ctx, AppLang.sg),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Widget _tile(BuildContext ctx, AppLang lang) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(lang.label),
      subtitle: Text(lang == AppLang.sg
          ? "English + Sinhala (roman) mix"
          : (lang == AppLang.si ? "සිංහල" : "English")),
      onTap: () => Navigator.pop(ctx, lang),
    );
  }
}
