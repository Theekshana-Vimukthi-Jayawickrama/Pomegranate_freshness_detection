enum AppLang { en, si, sg }

extension AppLangX on AppLang {
  String get code {
    switch (this) {
      case AppLang.en:
        return "en";
      case AppLang.si:
        return "si";
      case AppLang.sg:
        return "sg"; // singlish
    }
  }

  String get label {
    switch (this) {
      case AppLang.en:
        return "English";
      case AppLang.si:
        return "සිංහල";
      case AppLang.sg:
        return "Singlish";
    }
  }

  String get title {
    switch (this) {
      case AppLang.en:
        return "Pomegranate Chat";
      case AppLang.si:
        return "දෙළුම් Chat";
      case AppLang.sg:
        return "Pomegranate Chat (Singlish)";
    }
  }

  String get hint {
    switch (this) {
      case AppLang.en:
        return "Ask about this pomegranate...";
      case AppLang.si:
        return "දෙළුම් ගැන අහන්න...";
      case AppLang.sg:
        return "Ask karanna... (singlish)";
    }
  }
}
