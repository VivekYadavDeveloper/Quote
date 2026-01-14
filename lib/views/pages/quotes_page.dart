import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/quotes_controller.dart';
import '../../models/quote_model.dart';
import '../../utils/random_colors.dart';
import '../templates/quote_detail_page_template.dart';
import '../templates/search_page_template.dart';
import '../themes/typography.dart';
import '../widgets/icon_solid_light.dart';
import '../widgets/quotes_card.dart';

class QuotesPage extends ConsumerStatefulWidget {
  const QuotesPage({super.key});

  @override
  ConsumerState<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends ConsumerState<QuotesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(quotesControllerProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesState = ref.watch(quotesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Quotes", style: MyTypography.h2),
        actions: [
          IconSolidLight(
            icon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(quotesControllerProvider.notifier).fetchFirstPage();
        },
        child: quotesState.when(
          // ================= DATA =================
          data: (quotes) {
            if (quotes.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 250),
                  Center(child: Text("No quotes available")),
                ],
              );
            }

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              itemCount: quotes.length + 1,
              itemBuilder: (context, index) {
                // 🔄 Loader at bottom
                if (index == quotes.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final quoteData = quotes[index];
                final cardColor = getRandomColor();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final quote = Quote(
                        author: quoteData.author ?? '',
                        content: quoteData.content ?? '',
                        backgroundColor: cardColor.value,
                        textColor: Colors.white.value,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.left,
                        userId: 'c8a706e3-893b-4d1c-9f08-cf2b22d5874f',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuoteDetailPage(
                            quote: quote,
                            content: quote.content,
                            author: quote.author,
                            authorAvatar: '',
                            authorJob: '',
                          ),
                        ),
                      );
                    },
                    child: QuotesCard(
                      color: cardColor,
                      author: quoteData.author ?? '',
                      content: quoteData.content ?? '',
                    ),
                  ),
                );
              },
            );
          },

          // ================= LOADING =================
          loading: () => const Center(child: CircularProgressIndicator()),

          // ================= ERROR =================
          error: (error, _) => Center(
            child: Text(
              "Something went wrong\n$error",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
