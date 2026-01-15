import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

import '../models/quote_model.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

class FavoriteRepository {
  final supabase = sp.Supabase.instance.client;

  Future<List<Quote>> getFavoriteQuotes(String userId) async {
    try {
      final res = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      ;

      print('✅ Favorite quotes: $res');

      return res.map<Quote>((json) {
        return Quote.fromJson(json); // ✅ IMPORTANT
      }).toList();
    } catch (e) {
      print('❌ Error getting favorites: $e');
      rethrow;
    }
  }

  Future<void> addFavoriteQuote(Quote quote) async {
    // Store all quote data in favorites table
    final data = {
      'user_id': quote.userId,
      'quote_id': quote.id,
      'author': quote.author,
      'content': quote.content,
      'background_color': quote.backgroundColor,
      'text_color': quote.textColor,
      'font_family': quote.fontFamily,
      'font_weight': quote.fontWeight.value,
      'text_align': quote.textAlign.index,
    };

    try {
      await supabase.from('favorites').insert(data);
      debugPrint('✅ Added to favorites');
    } catch (e) {
      debugPrint('❌ Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> deleteFavoriteQuote(Quote quote) async {
    try {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', quote.userId)
          .eq('quote_id', quote.id as Object);
      debugPrint('✅ Removed from favorites');
    } catch (e) {
      debugPrint('❌ Error deleting favorite: $e');
      rethrow;
    }
  }

  // delete all favorite quotes
  Future<void> deleteAllFavoriteQuotes(String userId) async {
    await supabase.from('favorites').delete().eq('user_id', userId);
  }

  // Check if a quote is favorited
  Future<bool> isFavorite(String userId, String quoteId) async {
    try {
      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('❌ Error checking favorite: $e');
      return false;
    }
  }
}
