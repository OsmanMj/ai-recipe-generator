import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> generateRecipes(
      String ingredients, String cuisine, int? calories);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final Dio dio;

  RecipeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RecipeModel>> generateRecipes(
      String ingredients, String cuisine, int? calories) async {
    try {
      final calorieText =
          calories != null ? "Maximum Calories: $calories kcal." : "";
      final prompt = """
      Generate 3 unique recipes based on these ingredients: $ingredients.
      Preferred Cuisine: $cuisine.
      $calorieText
      
      IMPORTANT: Detect the language of the ingredients provided (e.g., Arabic, English, Spanish, etc.). 
      Generate the recipe names, ingredients, and instructions IN THE SAME LANGUAGE as the input ingredients.
      For example, if the ingredients are in Arabic, the entire response content (name, ingredients, instructions) MUST be in Arabic.

      Return the response in raw JSON format (NO MARKDOWN, NO CODE BLOCKS) as a list of objects with these fields:
      - name (String)
      - cuisine (String) - if 'Any' was requested, pick a suitable one for the recipe
      - difficulty (String) - Easy, Medium, or Hard
      - ingredients (List<String>)
      - instructions (List<String>)
      - prepTime (int) - in minutes
      - calories (int)
      """;

      const apiKey = AppConstants.geminiApiKey;

      // Get the correct endpoint with rotation
      final endpointUrl = await _getAndRotateEndpoint(apiKey);

      try {
        return await _makeRequest(endpointUrl, prompt);
      } on DioException catch (e) {
        if (e.response?.statusCode == 429) {
          // Rate limit exceeded, force rotate and retry once
          final newEndpointUrl =
              await _getAndRotateEndpoint(apiKey, forceRotate: true);
          return await _makeRequest(newEndpointUrl, prompt);
        }
        rethrow;
      }
    } catch (e) {
      print("API Error: $e");
      return _generateMockRecipes(ingredients, cuisine, calories);
    }
  }

  Future<List<RecipeModel>> _makeRequest(String url, String prompt) async {
    final response = await dio.post(
      url,
      options: Options(
        validateStatus: (status) => true,
      ),
      data: {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      String contentText = data['candidates'][0]['content']['parts'][0]['text'];

      contentText =
          contentText.replaceAll('```json', '').replaceAll('```', '').trim();

      final dynamic jsonResponse = jsonDecode(contentText);

      List<dynamic> jsonList;
      if (jsonResponse is List) {
        jsonList = jsonResponse;
      } else if (jsonResponse is Map && jsonResponse.containsKey('recipes')) {
        // Handle case where AI wraps it in {"recipes": [...]}
        jsonList = jsonResponse['recipes'];
      } else if (jsonResponse is Map) {
        // Try to find any list in values
        final entry = jsonResponse.values
            .firstWhere((v) => v is List, orElse: () => null);
        if (entry != null) {
          jsonList = entry;
        } else {
          throw FormatException(
              "Unexpected JSON format: not a list or object with list");
        }
      } else {
        throw FormatException(
            "Unexpected JSON type: ${jsonResponse.runtimeType}");
      }

      return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
    } else if (response.statusCode == 429) {
      // Rethrow to be caught by the outer loop for rotation
      throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse);
    } else {
      print("API Error Status: ${response.statusCode}");
      print("API Error Body: ${response.data}");
      throw Exception(
          'Failed to generate recipes: ${response.statusCode} - ${response.data}');
    }
  }

  Future<String> _getAndRotateEndpoint(String apiKey,
      {bool forceRotate = false}) async {
    // Open a box for tracking usage.
    // Lazily opening here to avoid main.dart clutter, though not ideal for tight loops (ok for user action).
    if (!Hive.isBoxOpen('api_usage')) {
      await Hive.openBox('api_usage');
    }
    final box = Hive.box('api_usage');

    int currentModelIndex =
        box.get('current_model_index', defaultValue: 0) as int;

    // Validate index against current list length (in case models were removed)
    if (currentModelIndex >= AppConstants.geminiModels.length) {
      currentModelIndex = 0;
      await box.put('current_model_index', currentModelIndex);
    }

    int requestCount = box.get('request_count', defaultValue: 0) as int;

    // Check rotation condition
    bool shouldRotate = forceRotate || requestCount >= 15;

    if (shouldRotate) {
      currentModelIndex =
          (currentModelIndex + 1) % AppConstants.geminiModels.length;
      requestCount = 0;
      await box.put('current_model_index', currentModelIndex);
      await box.put('request_count', requestCount);
      print(
          "Rotating API Model to index $currentModelIndex due to ${forceRotate ? '429 Error' : 'Limit Reached'}");
    }

    if (!forceRotate) {
      // Increment usage if not just forcing a new one for a retry
      // Actually we should increment ONLY on success, but incrementing on attempt is safer for rate limits.
      // But here we just want to know "when to switch next".
      // Let's increment now.
      await box.put('request_count', requestCount + 1);
    }

    final modelName = AppConstants.geminiModels[currentModelIndex];
    return '${AppConstants.geminiBaseUrl}$modelName:generateContent?key=$apiKey';
  }

  List<RecipeModel> _generateMockRecipes(
      String ingredients, String cuisine, int? calories) {
    // Generate random mock data
    final random = DateTime.now().millisecondsSinceEpoch;

    final List<String> availableCuisines = [
      'Italian',
      'Mexican',
      'Chinese',
      'Indian',
      'American',
      'French',
      'Japanese',
      'Turkish',
      'Arabic'
    ];

    String getCuisine(int index) {
      if (cuisine == 'Any' || cuisine == 'All') {
        return availableCuisines[(random + index) % availableCuisines.length];
      }
      return cuisine;
    }

    int getCalories(int base) {
      if (calories != null && base > calories) {
        // Linter says receiver can't be null, but calories serves as receiver? No, base > calories.
        // Wait, calories is int?. If checks != null, it is promoted.
        // The lint message said "receiver can't be null".
        // line 97: base > calories!
        // line 98: return calories! - 10
        // If flow analysis knows it's not null, I can remove !.
        return calories - 10;
      }
      return base;
    }

    final c1 = getCuisine(1);
    final c2 = getCuisine(3);
    final c3 = getCuisine(7);

    return [
      RecipeModel(
        name: 'Traditional $c1 Platter',
        cuisine: c1,
        ingredients: ['Fresh Vegetables', ...ingredients.split(',')],
        instructions: [
          'Begin by washing and finely chopping the fresh vegetables. Heat a tablespoon of oil in a skillet.',
          'Add your main ingredients and the vegetables to the pan. Sauté for 10-12 minutes until tender.',
          'Season with traditional $c1 spices and salt to taste.',
          'Serve warm, garnished with fresh parsley or cilantro.'
        ],
        prepTime: 20,
        calories: getCalories(350),
        difficulty: 'Easy',
      ),
      RecipeModel(
        name: 'Spicy $c2 Delight',
        cuisine: c2,
        ingredients: ['Chili Peppers', 'Garlic', ...ingredients.split(',')],
        instructions: [
          'In a mixing bowl, combine the main ingredients with minced garlic and chopped chili peppers.',
          'Let the mixture rest for 15 minutes to allow the flavors to meld.',
          'Cook on a hot grill or pan for 6-8 minutes per side until fully cooked and slightly charred.',
          'Serve with a cooling side salad or yogurt dip to balance the heat.'
        ],
        prepTime: 30,
        calories: getCalories(450),
        difficulty: 'Medium',
      ),
      RecipeModel(
        name: 'Creamy $c3 Bowl',
        cuisine: c3,
        ingredients: [
          'Cream or Coconut Milk',
          'Herbs',
          ...ingredients.split(',')
        ],
        instructions: [
          'Prepare the base by sautéing onions and garlic until translucent.',
          'Add the main ingredients and pour in the cream or coconut milk. Bring to a gentle simmer.',
          'Cover and cook on low heat for 20 minutes allowing the sauce to thicken.',
          'Stir in fresh herbs just before serving over a bed of steamed rice.'
        ],
        prepTime: 40,
        calories: getCalories(550),
        difficulty: 'Hard',
      ),
    ];
  }
}
