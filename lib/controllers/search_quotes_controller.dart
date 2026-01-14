import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/quotable_model.dart';
import '../repositories/quotes_repository.dart';

final searchQuotesProvider =
    StateNotifierProvider<SearchQuotesController, AsyncValue<List<Quotable>?>>((
      ref,
    ) {
      final repo = ref.watch(quotesRepositoryProvider);
      return SearchQuotesController(repo);
    });

class SearchQuotesController
    extends StateNotifier<AsyncValue<List<Quotable>?>> {
  SearchQuotesController(this.repo) : super(const AsyncValue.data(null));

  final QuotesRepository repo;

  Future<void> searchQuotes(String query) async {
    state = const AsyncValue.loading();
    try {
      final data = await repo.searchQuotes(query: query);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
