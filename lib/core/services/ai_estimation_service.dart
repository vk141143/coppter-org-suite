import 'dart:convert';
import 'package:http/http.dart' as http;

class AIEstimationService {
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with your API key
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<Map<String, dynamic>> estimatePrice({
    required String category,
    required String description,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a waste management pricing expert. Provide price estimates in GBP (£) based on waste type, description, and location. Return ONLY a JSON object with keys: recommended_price (number), estimated_price_min (number), estimated_price_max (number), reasoning (string).'
            },
            {
              'role': 'user',
              'content': 'Estimate pickup price for:\nCategory: $category\nDescription: $description\nLocation: $location'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final priceData = jsonDecode(content);
        return priceData;
      } else {
        return _getFallbackPrice(category);
      }
    } catch (e) {
      return _getFallbackPrice(category);
    }
  }

  static Map<String, dynamic> _getFallbackPrice(String category) {
    final prices = {
      'Household Waste': {'min': 300, 'max': 500, 'rec': 400},
      'Plastic Waste': {'min': 350, 'max': 550, 'rec': 450},
      'E-Waste': {'min': 500, 'max': 800, 'rec': 650},
      'Organic Waste': {'min': 250, 'max': 400, 'rec': 325},
      'Metal Waste': {'min': 400, 'max': 700, 'rec': 550},
      'Glass Waste': {'min': 300, 'max': 500, 'rec': 400},
      'Paper Waste': {'min': 200, 'max': 350, 'rec': 275},
    };

    final price = prices[category] ?? {'min': 300, 'max': 500, 'rec': 400};
    return {
      'recommended_price': price['rec'],
      'estimated_price_min': price['min'],
      'estimated_price_max': price['max'],
      'reasoning': 'Based on standard rates for $category in your area.'
    };
  }
}
