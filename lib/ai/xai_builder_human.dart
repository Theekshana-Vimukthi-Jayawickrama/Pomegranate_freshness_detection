import 'pipeline_predictor.dart';

class XaiBuilderHuman {
  static String buildHuman({
    required PipelineResult r,
    required String lang, // "en" | "si" | "sg"
    String? userQuestion,
  }) {
    final buffer = StringBuffer();
    String q = userQuestion?.toLowerCase() ?? "";

    String tr(String en, String si, String sg) {
      if (lang == "si") return si;
      if (lang == "sg") return sg;
      return en;
    }

    void section(String en, String si, String sg) {
      buffer.writeln(tr(en, si, sg));
      buffer.writeln("");
    }

    void tip(String en, String si, String sg) {
      buffer.writeln(tr(en, si, sg));
      buffer.writeln("");
    }

    // ==========================
    // HEADER
    // ==========================
    section(
      "🔍 AI Decision Explanation",
      "🔍 AI තීරණ විස්තරය",
      "🔍 AI decision explain eka",
    );

    // ==========================
    // NOT POMEGRANATE
    // ==========================
    if (r.stage == PipelineStage.notPomegranate) {
      tip(
        "The system did not confirm a pomegranate.",
        "දෙළුම් බව තහවුරු කර නොමැත.",
        "Delum ekak kiyala confirm une naha.",
      );
      return buffer.toString();
    }

    // ==========================
    // DISTANCE STAGE
    // ==========================
    if (r.stage == PipelineStage.far) {
      tip(
        "Image quality insufficient. Please capture the fruit closer.",
        "රූපය ප්‍රමාණවත් නොවේ. කරුණාකර ලඟින් ඡායාරූපයක් ගන්න.",
        "Photo eka lagnin ganna.",
      );
      return buffer.toString();
    }

    // ==========================
    // FRESHNESS STAGE
    // ==========================
    bool isFresh = false;
    double confF = 0.0;
    if (r.f != null && r.stage == PipelineStage.closeFreshnessDone) {
      confF = (r.f!.confidence * 100);
      isFresh = r.f!.label.toLowerCase() == "fresh";

      section(
        "Freshness Prediction: ${r.f!.label} (~${confF.toStringAsFixed(1)}%)",
        "නැවුම්භාවය: ${r.f!.label} (~${confF.toStringAsFixed(1)}%)",
        "Freshness: ${r.f!.label} (~${confF.toStringAsFixed(1)}%)",
      );

      if (isFresh) {
        tip(
          "The fruit appears firm with even color. Few or no soft spots are visible.",
          "පලතුර තද සහ වර්ණය සමාන ලෙස පවතී. මෘදු තැන් අඩුයි හෝ නැත.",
          "Fruit firm saha color even. Soft spots athi natha.",
        );
      } else {
        tip(
          "The fruit shows soft spots, wrinkles, or uneven color — it may be overripe or starting to spoil.",
          "පලතුර මෘදු තැන්, හැකිළීම් හෝ වර්ණ වෙනස්වීම් පෙන්වයි — overripe හෝ නරක් විය හැක.",
          "Soft spots, wrinkles, color change pennanawa — overripe/rotten wenna puluwan.",
        );
      }
    }

    // ==========================
    // KNOWLEDGE ENGINE
    // ==========================
    // Fridge / storage
    if (q.contains("fridge") || q.contains("ෆ්‍රිජ්")) {
      if (isFresh) {
        tip(
          "Fresh whole pomegranates can be stored in the fridge up to 2 weeks.",
          "නැවුම් සම්පූර්ණ දෙළුම් ෆ්‍රිජ් එකේ සති 2ක් තබාගත හැක.",
          "Fresh whole delum fridge eke 2 week thiyaganna puluwan.",
        );
      } else {
        tip(
          "Non-fresh pomegranates should be consumed soon; refrigeration may slow further spoilage but quality is reduced.",
          "නැවුම් නොවන දෙළුම් ඉක්මනින් භාවිතා කළ යුතුයි; ෆ්‍රිජ් එක දූෂණය සැලකිය හැකි නමුත් ගුණාත්මකභාවය අඩුයි.",
          "Non-fresh delum eka ikmanin use karanna. Fridge thiyenawama spoil wena deyak slow wenawa but quality low.",
        );
      }
    }

    // Room temperature
    if (q.contains("room") || q.contains("outside")) {
      if (isFresh) {
        tip(
          "At room temperature, fresh pomegranates last about 5–7 days.",
          "කාමර උෂ්ණත්වයේදී නැවුම් දෙළුම් දින 5–7 පමණ තබාගත හැක.",
          "Fresh delum room temp eke 5-7 days thiyenawa.",
        );
      } else {
        tip(
          "Non-fresh pomegranates will spoil quickly at room temperature; consume immediately if edible.",
          "නැවුම් නොවන දෙළුම් කාමර උෂ්ණත්වයේදී ඉක්මනින් නරක වේ; හැකි නම් වහා භාවිතා කරන්න.",
          "Non-fresh delum room temp eke quick spoil wenawa; use karanna if edible.",
        );
      }
    }

    // Cutting / Seeds
    if (q.contains("cut") || q.contains("කප")) {
      if (isFresh) {
        tip(
          "After cutting, store seeds in an airtight container in the fridge for 3–5 days.",
          "කපාගත් පසු, වීජ වායු රහිත බඳුනක ෆ්‍රිජ් එකේ දින 3–5 තබාගන්න.",
          "Cut karala passe seeds airtight box ekak fridge eke 3-5 days.",
        );
      } else {
        tip(
          "Non-fresh seeds may spoil faster; consider discarding if soft or fermented.",
          "නැවුම් නොවන වීජ ඉක්මනින් නරක විය හැක; මෘදු හෝ අමුතු ගඳ ඇත්නම් පිටව දමන්න.",
          "Non-fresh seeds fast spoil wenawa; soft/fermented nam discard karanna.",
        );
      }
    }

    // Juice
    if (q.contains("juice")) {
      if (isFresh) {
        tip(
          "Seeds from fresh pomegranate can be blended to make juice.",
          "නැවුම් දෙළුම්වල වීජ blend කර juice සාදා ගත හැක.",
          "Fresh seeds blend karala juice hadanna puluwan.",
        );
      } else {
        tip(
          "Juice from non-fresh fruit may taste off and could be unsafe.",
          "නැවුම් නොවන දෙළුම් වල juice රස අමුතු විය හැක සහ ආරක්ෂිත නොවිය හැක.",
          "Non-fresh juice taste off, unsafe wenna puluwan.",
        );
      }
    }

    // Freezing
    if (q.contains("freeze") || q.contains("අයිස්")) {
      tip(
        "Seeds from fresh pomegranates can be frozen up to 3 months.",
        "නැවුම් දෙළුම්වල වීජ මාස 3ක් දක්වා අයිස් කළ හැක.",
        "Fresh seeds 3 months freeze karanna puluwan.",
      );
    }

    // Ripeness check
    if (q.contains("ripe") || q.contains("පැර")) {
      if (isFresh) {
        tip(
          "Ripe pomegranates feel heavy and firm, with vibrant color.",
          "පැරියා දෙළුම් බර සහ තද ලෙස දැනේ, වර්ණය සජීවී වේ.",
          "Ripe delum heavy saha firm, color vibrant.",
        );
      } else {
        tip(
          "Non-fresh pomegranates may feel soft or lightweight.",
          "නැවුම් නොවන දෙළුම් මෘදු හෝ ලේසි හැඟවිය හැක.",
          "Non-fresh delum soft/low weight.",
        );
      }
    }

    // Soft spots
    if (q.contains("soft") || q.contains("මෘදු")) {
      if (isFresh) {
        tip(
          "Few soft spots are acceptable; fruit is still good.",
          "අඩු මෘදු තැන් වලින් පලතුර තවමත් හොඳයි.",
          "Few soft spots thiyenawama fruit still good.",
        );
      } else {
        tip(
          "Soft spots indicate overripeness or spoilage; handle with care.",
          "මෘදු තැන් overripe හෝ නරක් වීම දැක්වයි; සැලකිලිමත් වන්න.",
          "Soft spots = overripe/rotten; careful handling.",
        );
      }
    }

    // Mold
    if (q.contains("mold") || q.contains("fungus") || q.contains("පැළ")) {
      tip(
        "If mold is visible, do not consume.",
        "මෝල්ඩ් පෙනේ නම් භාවිතා නොකරන්න.",
        "Mold thiyenawa nam kanna epa.",
      );
    }

    // Smell
    if (q.contains("smell") || q.contains("ගඳ")) {
      if (isFresh) {
        tip(
          "Fresh fruit should smell neutral or sweet.",
          "නැවුම් දෙළුම් සාමාන්‍ය හෝ මදරස වර්ග ගඳක් ඇතිවිය හැක.",
          "Fresh fruit smell neutral/sweet.",
        );
      } else {
        tip(
          "A sour or fermented smell indicates spoilage.",
          "ඇඹුල් ගඳක් නම් නරක් විය හැක.",
          "Sour/fermented smell = spoil.",
        );
      }
    }

    // Color change
    if (q.contains("color") || q.contains("වර්ණ")) {
      if (isFresh) {
        tip(
          "Even color indicates freshness.",
          "සම වර්ණය නැවුම්භාවය පෙන්වයි.",
          "Even color = fresh.",
        );
      } else {
        tip(
          "Uneven color or dark patches may indicate aging or spoilage.",
          "අසම වර්ණය හෝ අඳුරු තැන් වයස යාම හෝ නරක වීම දැක්වයි.",
          "Uneven color/dark patches = old/spoil.",
        );
      }
    }

    // Shelf life
    if (q.contains("how long") || q.contains("කල්")) {
      if (isFresh) {
        tip(
          "Fresh whole fruit lasts 1–2 weeks depending on storage.",
          "නැවුම් සම්පූර්ණ පලතුර සති 1–2 පමණ පවතී.",
          "Fresh whole fruit 1-2 week thiyenawa.",
        );
      } else {
        tip(
          "Non-fresh fruit should be consumed immediately if edible; shelf life is limited.",
          "නැවුම් නොවන පලතුර වහා භාවිතා කළ යුතුය; කල් පවතින්නේ සීමිතයි.",
          "Non-fresh fruit use immediately; shelf life short.",
        );
      }
    }

    return buffer.toString();
  }
}