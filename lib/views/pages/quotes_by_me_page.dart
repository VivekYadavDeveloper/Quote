import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../controllers/favorite_controller.dart';
import '../../controllers/quotes_controller.dart';
import '../../models/quote_model.dart';
import '../themes/colors.dart';
import '../themes/typography.dart';
import '../widgets/empty_state.dart';
import '../widgets/icon_solid_light.dart';
import 'create_quote_page.dart';
import 'quote_detail_page.dart';

class QuotesByMePage extends ConsumerWidget {
  const QuotesByMePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesState = ref.watch(myQuotesProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 66,
        titleSpacing: 20,
        title: Text("Created by you", style: MyTypography.h3),
        actions: [
          IconSolidLight(
            icon: PhosphorIcons.plus(PhosphorIconsStyle.regular),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateQuotePage()),
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),

      // ✅ BODY FIXED
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myQuotesProvider);
        },
        child: quotesState.when(
          skipLoadingOnRefresh: true,

          // =================== DATA ===================
          data: (quotes) {
            if (quotes == null || quotes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  EmptyState(description: "No quotes created yet"),
                ],
              );
            }

            return StaggeredGridView.countBuilder(
              physics: const AlwaysScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              itemCount: quotes.length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
              itemBuilder: (context, index) {
                final quote = quotes[index];
                final cardColor = Color(quote.backgroundColor);
                final textColor = Color(quote.textColor);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onLongPress: () => onLongPressCard(context, quote, ref),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuoteDetailPage(quote: quote),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.quotes(PhosphorIconsStyle.fill),
                          color: textColor,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        AutoSizeText(
                          quote.content,
                          maxFontSize: 20,
                          minFontSize: 14,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          textAlign: quote.textAlign,
                          style: GoogleFonts.getFont(
                            quote.fontFamily,
                            color: textColor,
                            fontSize: quote.fontSize,
                            fontWeight: quote.fontWeight,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          quote.author,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: MyTypography.body2.copyWith(
                            color: textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },

          // =================== LOADING ===================
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 250),
              Center(
                child: CircularProgressIndicator(color: MyColors.primaryDark),
              ),
            ],
          ),

          // =================== ERROR ===================
          error: (_, __) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 250),
              Center(child: Text("Something went wrong!")),
            ],
          ),
        ),
      ),
    );
  }

  // =================== BOTTOM SHEET ===================
  void onLongPressCard(BuildContext context, Quote quote, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionTile(
                icon: PhosphorIcons.pencil(PhosphorIconsStyle.regular),
                text: "Edit",
                trailing: Chip(
                  backgroundColor: MyColors.secondary,
                  label: Text(
                    "Coming soon",
                    style: MyTypography.caption1.copyWith(
                      color: MyColors.primaryDark,
                    ),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              _actionTile(
                icon: PhosphorIcons.trashSimple(PhosphorIconsStyle.regular),
                text: "Delete",
                onTap: () {
                  Navigator.pop(context);
                  ref.read(myQuotesProvider.notifier).deleteQuote(quote).then((
                    _,
                  ) {
                    ref.invalidate(myQuotesProvider);
                    ref.invalidate(favoriteProvider);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: MyColors.primaryDark),
            const SizedBox(width: 10),
            Text(
              text,
              style: MyTypography.body1.copyWith(color: MyColors.primaryDark),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
