import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../controllers/favorite_controller.dart';
import '../pages/quote_detail_page.dart';
import '../themes/colors.dart';
import '../themes/typography.dart';
import '../widgets/empty_state.dart';
import '../widgets/icon_solid_light.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteQuotesState = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 66,
        titleSpacing: 20,
        title: Text("Favorites", style: MyTypography.h3),
        actions: [
          favoriteQuotesState.isLoading
              ? Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: MyColors.primaryDark,
                    ),
                  ),
                )
              : IconSolidLight(
                  icon: PhosphorIcons.trashSimple(PhosphorIconsStyle.regular),
                  onTap: () {
                    ref
                        .read(favoriteProvider.notifier)
                        .deleteAllFavoriteQuotes();
                  },
                ),
          const SizedBox(width: 20),
        ],
      ),

      // ✅ BODY FIXED
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(favoriteProvider);
        },
        child: favoriteQuotesState.when(
          // =================== DATA ===================
          data: (quotes) {
            if (quotes == null || quotes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  EmptyState(description: "No favorites yet"),
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

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
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
                      color: Color(quote.backgroundColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.quotes(PhosphorIconsStyle.fill),
                          color: Color(quote.textColor),
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
                            color: Color(quote.textColor),
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
                            color: Color(quote.textColor),
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
}
