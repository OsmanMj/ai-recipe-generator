import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../providers/recipe_provider.dart';
import 'recipe_list_screen.dart';
import 'favorites_screen.dart';
import 'loading_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _ingredientsController = TextEditingController();

  void _generateRecipes() async {
    final ingredients = _ingredientsController.text.trim();
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Please enter specific ingredients!',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
          elevation: 4,
        ),
      );
      return;
    }

    final cuisine = ref.read(selectedCuisineProvider);
    final calories = ref.read(selectedCaloriesProvider);

    // Show Loading Screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingScreen()),
    );

    // Trigger generation (min delay to show animation)
    final minDelay = Future.delayed(const Duration(seconds: 4));
    final generationParams = ref
        .read(generatedRecipesProvider.notifier)
        .generate(ingredients, cuisine, calories);

    await Future.wait([minDelay, generationParams]);

    // Navigate to results
    if (mounted) {
      // Replace Loading Screen with Result List
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecipeListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCuisine = ref.watch(selectedCuisineProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(theme.brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeNotifierProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.8),
                    theme.primaryColor.withOpacity(0.4)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's in your\nkitchen?",
                    style: GoogleFonts.cairo(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ).animate().fadeIn().moveX(begin: -20, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    "We'll help you cook something amazing.",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Ingredients",
                    style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ingredientsController,
                    decoration: InputDecoration(
                      hintText: "e.g. Chicken, Tomato, Rice",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      prefixIcon: const Icon(Icons.shopping_basket_outlined),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  Text(
                    "Preferred Cuisine",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: AppConstants.cuisines.map((cuisine) {
                      final isSelected = selectedCuisine == cuisine;
                      return ChoiceChip(
                        label: Text(cuisine),
                        selected: isSelected,
                        selectedColor: theme.primaryColor,
                        backgroundColor: theme.cardColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                .read(selectedCuisineProvider.notifier)
                                .set(cuisine);
                          }
                        },
                      ).animate().scale(
                          delay:
                              50.ms * AppConstants.cuisines.indexOf(cuisine));
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Calorie Filter Section (Modern Card Design)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    color: Colors.orange, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  "Max Calories",
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${ref.watch(selectedCaloriesProvider) ?? 2000} Kcal",
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            activeTrackColor: theme.primaryColor,
                            inactiveTrackColor:
                                theme.primaryColor.withOpacity(0.1),
                            thumbColor: Colors.white,
                            overlayColor: theme.primaryColor.withOpacity(0.1),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10, elevation: 4),
                          ),
                          child: Slider(
                            value: (ref.watch(selectedCaloriesProvider) ?? 2000)
                                .toDouble(),
                            min: 100,
                            max: 2000,
                            divisions: 19,
                            label:
                                "${ref.watch(selectedCaloriesProvider) ?? 2000} Kcal",
                            onChanged: (value) {
                              ref
                                  .read(selectedCaloriesProvider.notifier)
                                  .set(value.toInt());
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Presets
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCaloriePreset(ref, theme, 400, "Light"),
                            _buildCaloriePreset(ref, theme, 800, "Balanced"),
                            _buildCaloriePreset(ref, theme, 1500, "Feast"),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _generateRecipes,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      icon: const Icon(Icons.auto_awesome, size: 24),
                      label: Text(
                        "Generate Recipes",
                        style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 100), // Spacing for floating NavBar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriePreset(
      WidgetRef ref, ThemeData theme, int calories, String label) {
    final isSelected = ref.watch(selectedCaloriesProvider) == calories;
    return InkWell(
      onTap: () {
        ref.read(selectedCaloriesProvider.notifier).set(calories);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
