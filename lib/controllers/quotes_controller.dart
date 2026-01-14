import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/quotable_model.dart';
import '../models/quote_model.dart';
import '../repositories/quotes_repository.dart';
import 'user_controller.dart';

/// ---------------- PROVIDERS ----------------

final quotesControllerProvider =
    StateNotifierProvider<QuotesController, AsyncValue<List<Quotable>>>((ref) {
      final repo = ref.watch(quotesRepositoryProvider);
      return QuotesController(repo);
    });

final myQuotesProvider =
    StateNotifierProvider<MyQuotesController, AsyncValue<List<Quote>>>((ref) {
      final repo = ref.watch(quotesRepositoryProvider);
      final userId = ref.read(userProvider)!.id;
      return MyQuotesController(repo, userId);
    });

/// ---------------- CONTROLLER ----------------

class QuotesController extends StateNotifier<AsyncValue<List<Quotable>>> {
  QuotesController(this._repo) : super(const AsyncValue.loading()) {
    fetchFirstPage();
  }

  final QuotesRepository _repo;

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  /// 🔹 First load / refresh
  Future<void> fetchFirstPage() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();

    try {
      final quotes = await _repo.getRandomQuotes(page: _page);
      state = AsyncValue.data(quotes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 🔹 Pagination
  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _page++;

    try {
      final newQuotes = await _repo.getRandomQuotes(page: _page);

      if (newQuotes.isEmpty) {
        _hasMore = false;
      } else {
        state = state.whenData((old) => [...old, ...newQuotes]);
      }
    } catch (_) {
      _page--; // rollback page on error
    } finally {
      _isLoading = false;
    }
  }
}

/// ---------------- MY QUOTES CONTROLLER ----------------

class MyQuotesController extends StateNotifier<AsyncValue<List<Quote>>> {
  MyQuotesController(this._repo, this._userId)
    : super(const AsyncValue.loading()) {
    fetchMyQuotes();
  }

  final QuotesRepository _repo;
  final String _userId;

  Future<void> fetchMyQuotes() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repo.getQuotesByMe(_userId);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createQuote(Quote quote) async {
    await _repo.createQuote(quote);
    fetchMyQuotes();
  }

  Future<void> deleteQuote(Quote quote) async {
    await _repo.deleteQuote(quote);
    fetchMyQuotes();
  }
}
