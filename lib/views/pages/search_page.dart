import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quote_vault/views/pages/quote_detail_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../controllers/search_quotes_controller.dart';
import '../../models/quote_model.dart';
import '../../utils/random_colors.dart';
import '../themes/colors.dart';
import '../themes/typography.dart';
import '../widgets/icon_solid_light.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchQuotesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 76,
        leading: IconSolidLight(
          icon: PhosphorIcons.caretLeft(PhosphorIconsStyle.regular),
          onTap: () => Navigator.pop(context),
        ),
        title: Text("Search Quote", style: MyTypography.h3),

        // 🔽 SEARCH FORM
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Form(
              key: _formKey,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextFormField(
                  controller: _controller,
                  cursorColor: MyColors.black,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Find a quote here",
                    hintStyle: MyTypography.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                      color: MyColors.black,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller.clear();
                              ref.read(searchQuotesProvider.notifier).clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),

                  // 🔹 Optional validation
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Type something";
                    }
                    if (value.trim().length < 3) {
                      return "Minimum 3 characters";
                    }
                    return null;
                  },

                  onChanged: (value) {
                    setState(() {});
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 600), () {
                      if (value.trim().length >= 3) {
                        ref
                            .read(searchQuotesProvider.notifier)
                            .searchQuotes(value.trim());
                      } else {
                        ref.read(searchQuotesProvider.notifier).clear();
                      }
                    });
                  },

                  onFieldSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      ref
                          .read(searchQuotesProvider.notifier)
                          .searchQuotes(_controller.text.trim());
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),

      // 🔽 BODY
      body: searchState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (quotes) {
          if (quotes == null) {
            return Center(
              child: _EmptyState(
                title: "Start typing to search quotes",
                subtitle: "",
                icon: PhosphorIcons.magnifyingGlassPlus(
                  PhosphorIconsStyle.regular,
                ),
              ),
            );
          }

          if (quotes.isEmpty) {
            return Center(
              child: _EmptyState(
                title: "No quotes found",
                subtitle: "Write something different",
                icon: PhosphorIcons.empty(PhosphorIconsStyle.regular),
              ),
            );
          }

          // ✅ GRID
          return StaggeredGridView.countBuilder(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            itemCount: quotes.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
            itemBuilder: (context, index) {
              final cardColor = getRandomColor();
              final q = quotes[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final quote = Quote(
                    id: q.id,
                    author: q.author ?? '',
                    content: q.content ?? '',
                    backgroundColor: cardColor.value,
                    textColor: Colors.white.value,
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.center,
                    userId: 'c8a706e3-893b-4d1c-9f08-cf2b22d5874f',
                    profession: '',
                  );

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
                    children: [
                      Icon(
                        PhosphorIcons.quotes(PhosphorIconsStyle.fill),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      AutoSizeText(
                        q.content ?? '',
                        maxFontSize: 20,
                        minFontSize: 14,
                        maxLines: 15,
                        overflow: TextOverflow.ellipsis,
                        style: MyTypography.body2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        q.author ?? '',
                        style: MyTypography.body2.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: MyColors.secondary,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.all(40),
            child: Icon(icon, size: 48),
          ),
          const SizedBox(height: 40),
          Text(title, style: MyTypography.h2),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: MyTypography.body1.copyWith(color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
