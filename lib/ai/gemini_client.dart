import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiClient {
  final String apiKey;

  /// If this fails for your account, try:
  /// "gemini-1.5-flash" or "gemini-1.5-pro"
  final String modelName;

  GeminiClient({
    required this.apiKey,
    this.modelName = "gemini-2.5-flash",
  });

  Uri get _url => Uri.parse(
    "https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent",
  );

  Future<String> ping() async {
    return generate(
      contents: const [
        {
          "role": "user",
          "parts": [
            {"text": "Reply with only: OK"}
          ]
        }
      ],
      temperature: 0.0,
      maxOutputTokens: 16,
    );
  }

  Future<String> generate({
    required List<Map<String, dynamic>> contents,
    double temperature = 0.3,
    int maxOutputTokens = 512,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception("GEMINI_API_KEY is empty");
    }

    final body = {
      "contents": contents,
      "generationConfig": {
        "temperature": temperature,
        "maxOutputTokens": maxOutputTokens,
      }
    };

    final resp = await http.post(
      _url,
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      // Provide readable error
      throw Exception(_prettyHttpError(resp.statusCode, resp.body));
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;

    final candidates = (decoded["candidates"] as List?) ?? [];
    if (candidates.isEmpty) return "No candidates";

    final content = candidates[0]["content"] as Map<String, dynamic>?;
    final parts = (content?["parts"] as List?) ?? [];
    if (parts.isEmpty) return "No parts";

    final text = parts[0]["text"]?.toString();
    return text ?? "No text";
  }

  String _prettyHttpError(int code, String body) {
    // Common cases:
    // 401 -> bad key
    // 403 -> blocked/restricted
    // 429 -> quota
    // 5xx -> server
    if (code == 401) {
      return "401 Unauthorized: API key is wrong / missing.\n$body";
    }
    if (code == 403) {
      return "403 Forbidden: API key blocked or API not enabled.\n$body";
    }
    if (code == 429) {
      return "429 Too Many Requests: Quota exceeded / rate limited.\n$body";
    }
    if (code >= 500) {
      return "$code Server error from Google.\n$body";
    }
    return "$code Error.\n$body";
  }
}
