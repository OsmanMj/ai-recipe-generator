import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/pdf_service.dart';
import '../../data/models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch favorites to rebuild UI when toggled
    ref.watch(favoritesProvider);
    final isFavorite = ref.read(favoritesProvider.notifier).isFavorite(recipe);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        // Removed Favorite action from AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            _buildStatsRow(context),
            const SizedBox(height: 24),

            // Action Row (Cook, Share, Save)
            _buildActionRow(context, ref, isFavorite),
            const SizedBox(height: 24),

            // Chef's Tip
            _buildChefsTip(context),
            const SizedBox(height: 24),

            // Ingredients
            Text(
              "Ingredients",
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: recipe.ingredients
                      .map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 8, color: primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ing,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Instructions
            Text(
              "How to Cook",
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipe.instructions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildInstructionStep(context, index);
              },
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.bar_chart,
            label: "Difficulty",
            value: recipe.difficulty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            label: "Calories",
            value: "${recipe.calories} kcal",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer,
            label: "Cook Time",
            value: "${recipe.prepTime} min",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    // Determine text colors based on brightness if needed, but usually primary works well
    // Using CardTheme color
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors
                  .grey, // Simple grey is usually readable on both, or use caption style
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref, bool isFavorite) {
    // Ensuring icons visible against card color (which is likely background of this row?
    // Actually this row is directly on scaffold body.
    // Icons were black87 or primary. In dark mode black87 might be invisible on dark scaffold?
    // Let's check AppTheme. Scaffold background is dark (121212). Black87 is obscure.
    // We should use Theme.of(context).textTheme.bodyMedium.color or similar.

    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.print_rounded,
          label: "Print PDF",
          onTap: () async {
            final pdfService = PdfService();
            await pdfService.generateAndPrint(recipe);
          },
          defaultColor: textColor,
        ),
        _buildActionButton(
          context,
          icon: Icons.share,
          label: "Share",
          onTap: () {
            _showShareOptions(context);
          },
          defaultColor: textColor,
        ),
        _buildActionButton(
          context,
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          label: "Favorite",
          isActive: isFavorite,
          onTap: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(recipe);
          },
          defaultColor: textColor,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool isActive = false,
      required Color defaultColor}) {
    final color = isActive ? Theme.of(context).primaryColor : defaultColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefsTip(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // We want a subtle background of primary color
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chef's Tip",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "For a more authentic flavor, ensure you use fresh ingredients where possible. Adjust spices to your personal taste preference!",
                  style: TextStyle(
                    // You might want a slightly darker/readable shade for text
                    // if primary is very bright, but usually primary is fine for text if contrast ok.
                    // Let's use bodyLarge color combined with primary or just inherit.
                    // But user specifically wanted to replace green with app matching color.
                    color: primaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(BuildContext context, int index) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final borderColor = Theme.of(context).dividerColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // We don't have step titles in the model, so we simulate a header
                Text(
                  "Step ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.instructions[index],
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor, // Use theme text color
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    // Format text "like real life" with emojis and clear structure
    final shareText = """
🍲 *${recipe.name}*
💪 Difficulty: ${recipe.difficulty} | 🔥 ${recipe.calories} kcal | ⏱️ ${recipe.prepTime} min

🛒 *Ingredients:*
${recipe.ingredients.map((e) => "• $e").join('\n')}

👩‍🍳 *Instructions:*
${recipe.instructions.asMap().entries.map((e) => "Step ${e.key + 1}: ${e.value}").join('\n\n')}

_Generated by AI Recipe Generator_ 🤖
""";

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true, // Modern handle
      isScrollControlled: true, // Allows content to take needed space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share Recipe",
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    icon: FontAwesomeIcons.whatsapp,
                    label: "WhatsApp",
                    color: const Color(0xFF25D366),
                    onTap: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(
                          "whatsapp://send?text=${Uri.encodeComponent(shareText)}");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        // Fallback to web if mobile app not installed (e.g. simulator)
                        final webUrl = Uri.parse(
                            "https://wa.me/?text=${Uri.encodeComponent(shareText)}");
                        if (await canLaunchUrl(webUrl)) {
                          await launchUrl(webUrl);
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Could not open WhatsApp')),
                          );
                        }
                      }
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.copy_rounded,
                    label: "Copy",
                    color: Colors.blueAccent,
                    onTap: () async {
                      Navigator.pop(context);
                      await Clipboard.setData(ClipboardData(text: shareText));
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Recipe copied to clipboard')),
                      );
                    },
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.share_rounded,
                    label: "More",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(shareText);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    // Determine background color relative to theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: FaIcon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
