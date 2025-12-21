import 'dart:async';
import 'package:ai_recipe_generator/core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ai_recipe_generator/presentation/screens/recipe_detail_screen.dart';
import 'package:ai_recipe_generator/data/models/recipe_model.dart';
// NOTE: We might need a way to fetch the recipe by ID if we only get the ID.
// For now, let's assume we navigate to the detail screen.
// However, RecipeDetailScreen usually expects a full RecipeModel.
// We will need to adjust this. Since I cannot change the whole architecture to fetch by ID right now without more context,
// I will create a placeholder logic or check how RecipeDetailScreen works.

class DeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey;

  DeepLinkService(this.navigatorKey);

  Future<void> init() async {
    _appLinks = AppLinks();

    // Check initial link
    try {
      final Uri? uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleLink(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial link: $e');
      }
    }

    // Attach listener
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleLink(uri);
      },
      onError: (err) {
        if (kDebugMode) {
          print('Deep Link Error: $err');
        }
      },
    );
  }

  void _handleLink(Uri uri) {
    if (kDebugMode) {
      print('Received Deep Link: $uri');
    }

    // Scheme: airecipe://recipe/<id>
    if (uri.scheme == 'airecipe' && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments[0] == 'recipe' && uri.pathSegments.length > 1) {
        final recipeId = uri.pathSegments[1];
        _navigateToRecipe(recipeId);
      }
    }
  }

  void _navigateToRecipe(String recipeId) {
    try {
      // 1. Parse ID
      final id = int.tryParse(recipeId);
      if (id == null) {
        debugPrint("Invalid Recipe ID: $recipeId");
        return;
      }

      // 2. Fetch from Hive Box
      // We assume the box is already opened in main.dart
      if (!Hive.isBoxOpen(AppConstants.favoritesBox)) {
        debugPrint("Favorites box not open");
        return;
      }

      final box = Hive.box<RecipeModel>(AppConstants.favoritesBox);
      final recipe = box.get(id);

      if (recipe != null) {
        // 3. Navigate
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      } else {
        debugPrint("Recipe not found for ID: $id");
        // Optional: Show a "Recipe not found" dialog or snackbar if we had context
      }
    } catch (e) {
      debugPrint("Error navigating to recipe: $e");
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
