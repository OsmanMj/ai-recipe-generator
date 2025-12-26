import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/recipe_provider.dart';
import '../../core/constants/app_constants.dart';
import 'onboarding_screen.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: favoritesAsync.when(
        data: (recipes) {
          // Calculate Stats
          final totalFavorites = recipes.length;
          final cuisineCounts = <String, int>{};
          for (var recipe in recipes) {
            cuisineCounts[recipe.cuisine] =
                (cuisineCounts[recipe.cuisine] ?? 0) + 1;
          }

          // Chef Level Logic
          String chefTitle = "Novice Cook";
          String chefImage = "assets/images/novice_cook.png";
          double progressToNextLevel = 0.0;
          int nextLevelTarget = 5;

          if (totalFavorites >= 30) {
            chefTitle = "Master Chef";
            chefImage = "assets/images/master_chef.png";
            progressToNextLevel = 1.0;
            nextLevelTarget = 30;
          } else if (totalFavorites >= 15) {
            chefTitle = "Sous Chef";
            chefImage = "assets/images/sous_chef.png";
            nextLevelTarget = 30;
            progressToNextLevel = (totalFavorites - 15) / (30 - 15);
          } else if (totalFavorites >= 5) {
            chefTitle = "Home Cook";
            chefImage = "assets/images/home_cook.png";
            nextLevelTarget = 15;
            progressToNextLevel = (totalFavorites - 5) / (15 - 5);
          } else {
            progressToNextLevel = totalFavorites / 5;
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Kitchen Stats",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Chef Level Card (Advanced Design)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEF6C00), // Darker Orange
                            theme.primaryColor,
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Current Level",
                                      style: GoogleFonts.cairo(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      chefTitle,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  chefImage,
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$totalFavorites Favorites",
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    totalFavorites >= 30
                                        ? "Max Level"
                                        : "Next: $nextLevelTarget",
                                    style: GoogleFonts.cairo(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progressToNextLevel,
                                  minHeight: 8,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 14),
                    Text(
                      "Cuisine Breakdown",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Cuisine Circular Indicators
                    cuisineCounts.isEmpty
                        ? Text(
                            "Save recipes to see your tastes!",
                            style: GoogleFonts.cairo(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7)),
                          )
                        : SizedBox(
                            height: 140,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: cuisineCounts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final entry =
                                    cuisineCounts.entries.elementAt(index);
                                final percentage = entry.value / totalFavorites;
                                final color = Colors
                                    .primaries[index % Colors.primaries.length];

                                final isDark = Theme.of(context).brightness ==
                                    Brightness.dark;

                                return Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.grey.withOpacity(0.1),
                                    ),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              value: percentage,
                                              strokeWidth: 6,
                                              backgroundColor: isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      color),
                                              strokeCap: StrokeCap.round,
                                            ),
                                            Center(
                                              child: Text(
                                                "${(percentage * 100).toInt()}%",
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        entry.key,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.grey[300]
                                              : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "${entry.value} Saved",
                                        style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: (100 * index).ms)
                                    .slideX();
                              },
                            ),
                          ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              // Settings Options
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text("Dark Mode",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                value: Theme.of(context).brightness == Brightness.dark,
                activeColor: theme.primaryColor,
                onChanged: (val) {
                  ref.read(themeModeNotifierProvider.notifier).toggle();
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: Text("Clear Favorites",
                    style: GoogleFonts.cairo(
                        color: Colors.red[300], fontWeight: FontWeight.w600)),
                onTap: () {
                  _showClearConfirmation(context, ref);
                },
              ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Version ${AppConstants.appVersion}",
                  style: GoogleFonts.cairo(color: Colors.grey[600]),
                ),
              ),
            ],
          );
        },
        error: (e, st) => Center(child: Text('Error loading stats: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text("Clear Favorites?",
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, color: Colors.white)),
        content: Text(
            "Are you sure you want to delete all your saved recipes? This cannot be undone.",
            style: GoogleFonts.cairo(color: Colors.grey[300])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(favoritesProvider.notifier).clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Favorites cleared!",
                        style: GoogleFonts.cairo(color: Colors.white)),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text("Clear All",
                style: GoogleFonts.cairo(
                    color: Colors.red[400], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
