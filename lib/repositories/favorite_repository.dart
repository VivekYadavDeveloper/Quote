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
      // ✅ FIXED: Remove the join, just select from favorites directly
      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('✅ Favorite quotes: $response');

      List<Quote> quotes = [];

      for (var favorite in response) {
        // Create Quote from favorite data
        quotes.add(
          Quote(
            id: favorite['quote_id'],
            author: favorite['author'] ?? '',
            content: favorite['content'] ?? '',
            backgroundColor: favorite['background_color'],
            textColor: favorite['text_color'],
            fontFamily: favorite['font_family'] ?? 'Inter',
            fontWeight: favorite['font_weight'] ?? 'w500',
            textAlign: favorite['text_align'] ?? 'left',
            userId: userId,
          ),
        );
      }

      return quotes;
    } catch (e) {
      debugPrint('❌ Error getting favorites: $e');
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
      'font_weight': quote.fontWeight,
      'text_align': quote.textAlign,
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
    try {
      await supabase.from('favorites').delete().eq('user_id', userId);
      debugPrint('✅ Deleted all favorites');
    } catch (e) {
      debugPrint('❌ Error deleting all favorites: $e');
      rethrow;
    }
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
