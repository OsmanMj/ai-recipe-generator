import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/recipe_model.dart';

class PdfService {
  /// Generates a PDF for the given recipe and triggers the print dialog.
  Future<void> generateAndPrint(RecipeModel recipe) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final homeCookImage =
        await imageFromAssetBundle('assets/images/home_cook.png');

    // Check if recipe name contains Arabic to determine default direction
    final isArabic = _containsArabic(recipe.name);
    final textDirection =
        isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final textAlign = isArabic ? pw.TextAlign.right : pw.TextAlign.left;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.Column(
              children: [
                pw.Center(
                  child: pw.Text(
                    recipe.name,
                    textDirection: textDirection,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                // Info Row
                pw.Directionality(
                  textDirection: textDirection,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                          "Cuisine", recipe.cuisine, font, fontBold, isArabic),
                      _buildInfoItem("Difficulty", recipe.difficulty, font,
                          fontBold, isArabic),
                      _buildInfoItem("Prep Time", "${recipe.prepTime} min",
                          font, fontBold, isArabic),
                      _buildInfoItem("Calories", "${recipe.calories} kcal",
                          font, fontBold, isArabic),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
              ],
            );
          }
          return pw.Container();
        },
        build: (pw.Context context) {
          return [
            // Ingredients
            pw.Directionality(
              textDirection: textDirection,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    isArabic ? "المكونات" : "Ingredients",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  ...recipe.ingredients.map(
                    (ing) => pw.Row(
                      mainAxisAlignment: isArabic
                          ? pw.MainAxisAlignment.start
                          : pw.MainAxisAlignment.start,
                      children: [
                        pw.Text("• ", style: const pw.TextStyle(fontSize: 18)),
                        pw.Expanded(
                          child: pw.Text(
                            ing,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Instructions
            pw.Directionality(
              textDirection: textDirection,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    isArabic ? "خطوات الطهي" : "Cooking Steps",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  ...List.generate(recipe.instructions.length, (index) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "${index + 1}. ",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              recipe.instructions[index],
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Generated by AI Recipe Generator",
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Image(
                    homeCookImage,
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${recipe.name}.pdf',
    );
  }

  pw.Widget _buildInfoItem(String label, String value, pw.Font font,
      pw.Font fontBold, bool isArabic) {
    return pw.Column(
      children: [
        pw.Text(label,
            textDirection:
                isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.Text(value,
            textDirection:
                isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
