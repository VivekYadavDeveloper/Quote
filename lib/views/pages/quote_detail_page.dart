import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../controllers/favorite_controller.dart';
import '../../models/quote_model.dart';
import '../themes/typography.dart';
import '../widgets/icon_solid_light.dart';

class QuoteDetailPage extends ConsumerStatefulWidget {
  const QuoteDetailPage({super.key, required this.quote});

  final Quote quote;

  @override
  ConsumerState<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends ConsumerState<QuoteDetailPage> {
  Quote get quote => widget.quote;

  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey quoteCardKey = GlobalKey();

  final pageIndexNotifier = ValueNotifier(0);

  void onTapFavorite(WidgetRef ref) async {
    await ref.read(favoriteProvider.notifier).toggleFavorite(quote);
  }

  /// 🔹 Capture card & share (SYSTEM SHARE)
  Future<void> shareQuoteCard() async {
    try {
      // 🟢 Wait for UI to be fully rendered
      await Future.delayed(const Duration(milliseconds: 200));

      Uint8List? image = await screenshotController.capture(pixelRatio: 3.0);

      if (image == null || image.isEmpty) {
        throw Exception("Screenshot failed");
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/quote.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${quote.content}\n\n~ ${quote.author}',
      ); /*TODO: Future Done Text Chnage*/
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteState = ref.watch(favoriteProvider);
    final isFavorite = ref
        .read(favoriteProvider.notifier)
        .isFavorite(quote.content);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconSolidLight(
          icon: PhosphorIcons.caretLeft(PhosphorIconsStyle.regular),
          onTap: () => Navigator.pop(context),
        ),
        title: Text('Quote Detail', style: MyTypography.h3),
      ),
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            key: quoteCardKey,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(quote.backgroundColor),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.quotes(PhosphorIconsStyle.fill),
                    size: 70,
                    color: Color(quote.textColor),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: AutoSizeText(
                      quote.content,
                      maxFontSize: 28,
                      minFontSize: 18,
                      textAlign: quote.textAlign,
                      style: GoogleFonts.getFont(
                        quote.fontFamily,
                        color: Color(quote.textColor),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    quote.author,
                    style: MyTypography.body2.copyWith(
                      color: Color(quote.textColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      favoriteState.isLoading
                          ? const CircularProgressIndicator()
                          : IconSolidLight(
                              icon: isFavorite
                                  ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                                  : PhosphorIcons.heart(
                                      PhosphorIconsStyle.regular,
                                    ),
                              onTap: () => onTapFavorite(ref),
                            ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          WoltModalSheet.show(
                            context: context,
                            pageIndexNotifier: pageIndexNotifier,
                            pageListBuilder: (ctx) => [shareSheet(ctx)],
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 SIMPLE SHARE SHEET (no app-specific logic)
  WoltModalSheetPage shareSheet(BuildContext context) {
    return WoltModalSheetPage(
      child: ListTile(
        leading: const Icon(Icons.share),
        title: const Text('Share Quote'),
        onTap: () {
          Navigator.pop(context);
          shareQuoteCard();
        },
      ),
    );
  }
}
