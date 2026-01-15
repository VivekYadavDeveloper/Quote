import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/quote_model.dart';
import '../repositories/favorite_repository.dart';
import 'user_controller.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteController, AsyncValue<List<Quote>>>((ref) {
      final repo = FavoriteRepository();
      final user = ref.watch(userProvider)!; // logged-in user
      return FavoriteController(repo, user.id)..loadFavorites();
    });

class FavoriteController extends StateNotifier<AsyncValue<List<Quote>>> {
  final FavoriteRepository repo;
  final String userId;

  FavoriteController(this.repo, this.userId)
    : super(const AsyncValue.loading());

  // ================= LOAD =================
  Future<void> loadFavorites() async {
    try {
      final data = await repo.getFavoriteQuotes(userId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ================= CHECK =================
  bool isFavorite(String content) {
    final list = state.value;
    if (list == null) return false;
    return list.any((q) => q.content == content);
  }

  // ================= TOGGLE =================
  Future<void> toggleFavorite(Quote quote) async {
    final fav = isFavorite(quote.content);

    if (fav) {
      await repo.deleteFavoriteQuote(quote);
    } else {
      await repo.addFavoriteQuote(quote);
    }

    await loadFavorites();
  }

  // ================= DELETE ALL ✅ =================
  Future<void> deleteAll() async {
    try {
      await repo.deleteAllFavoriteQuotes(userId);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
