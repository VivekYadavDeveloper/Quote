import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

import '../models/quotable_model.dart';
import '../models/quote_model.dart';
import '../utils/api_path.dart';

final quotesRepositoryProvider = Provider<QuotesRepository>(
  (ref) => QuotesRepository(),
);

class QuotesRepository {
  final supabase = sp.Supabase.instance.client;

  // Future<List<Quotable>> getRandomQuotes() async {
  //   // Use debug-only IOClient that accepts the cert for api.quotable.io
  //   http.Client? client;
  //   IOClient? ioClient;
  //
  //   try {
  //     if (kDebugMode) {
  //       final httpClient = HttpClient()
  //         ..badCertificateCallback =
  //             (X509Certificate cert, String host, int port) {
  //               // ONLY allow this host while debugging
  //               return host == 'api.quotable.io';
  //             };
  //       ioClient = IOClient(httpClient);
  //       client = ioClient;
  //     } else {
  //       // Release mode: use the default client (no cert bypass)
  //       client = http.Client();
  //     }
  //
  //     final uri = Uri.parse('$baseUrl$quotesPath$randomPath?limit=20');
  //     print('🌐 Fetching quotes from: $uri');
  //
  //     final response = await client.get(uri);
  //
  //     print('📡 Status Code: ${response.statusCode}');
  //     print('📡 Response body: ${response.body}');
  //
  //     if (response.statusCode != 200) {
  //       throw Exception(
  //         'Failed to load quotes: ${response.statusCode} - ${response.body}',
  //       );
  //     }
  //
  //     final data = jsonDecode(response.body);
  //
  //     // Accept both a JSON array or object with "results"
  //     if (data is List) {
  //       return data
  //           .map((e) => Quotable.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     }
  //
  //     if (data is Map && data['results'] is List) {
  //       return (data['results'] as List)
  //           .map((e) => Quotable.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     }
  //
  //     throw Exception('Unexpected JSON structure: ${data.runtimeType}');
  //   } catch (e, st) {
  //     print('❌ Error in getRandomQuotes: $e\n$st');
  //     rethrow;
  //   } finally {
  //     // Close only the IOClient if we created it
  //     ioClient?.close();
  //     // If you used a plain http.Client in release we could close it as well,
  //     // but don't close global clients used elsewhere. If you created a client
  //     // instance here you can close it (above ioClient.close() suffices).
  //   }
  // }
  Future<List<Quotable>> getRandomQuotes({
    required int page,
    int limit = 20,
  }) async {
    http.Client client;
    IOClient? ioClient;

    try {
      if (kDebugMode) {
        final httpClient = HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) {
                return host == 'api.quotable.io';
              };
        ioClient = IOClient(httpClient);
        client = ioClient;
      } else {
        client = http.Client();
      }

      final uri = Uri.parse('$baseUrl$quotesPath?page=$page&limit=$limit');

      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final List results = json['results'];

      return results.map((e) => Quotable.fromJson(e)).toList();
    } finally {
      ioClient?.close();
    }
  }
  /*Below Code Is Working When SSL TSL Activated Licence*/
  // Future<List<Quotable>> getRandomQuotes() async {
  //   try {
  //     print(
  //       '🌐 Fetching quotes from API: $baseUrl$quotesPath$randomPath?limit=20',
  //     );
  //
  //     final response = await http.get(
  //       Uri.parse('https://api.quotable.io/quotes/random?limit=20'),
  //     );
  //
  //     print('📡 Status Code: ${response.statusCode}');
  //     print('📡 Response body: ${response.body}');
  //
  //     if (response.statusCode != 200) {
  //       throw Exception(
  //         'Failed to load quotes: ${response.statusCode} - ${response.body}',
  //       );
  //     }
  //
  //     final data = jsonDecode(response.body);
  //     print('📡 Parsed data type: ${data.runtimeType}');
  //
  //     if (data is List) {
  //       return data
  //           .map((e) => Quotable.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     }
  //
  //     // Some APIs return an object with a "results" array
  //     if (data is Map && data['results'] is List) {
  //       final list = (data['results'] as List)
  //           .map((e) => Quotable.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //       return list;
  //     }
  //
  //     throw Exception('Unexpected JSON structure: ${data.runtimeType}');
  //   } catch (e, st) {
  //     print('❌ Error in getRandomQuotes: $e\n$st');
  //     rethrow;
  //   }
  // }

  Future<List<Quotable>> searchQuotes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$searchPath$quotesPath?query=$query'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search quotes: ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final data = json['results'] as List;

      final quotes = data.map((e) => Quotable.fromJson(e)).toList();
      return quotes;
    } catch (e) {
      log('Error in searchQuotes: $e');
      rethrow;
    }
  }

  // Create a quote
  Future<void> createQuote(Quote quote) async {
    try {
      final data = quote.toJson();
      await supabase.from('quotes').insert(data);
      print('✅ Quote created successfully');
    } on sp.PostgrestException catch (e) {
      print('❌ Supabase Error: ${e.message}');
      print('💡 Make sure the "quotes" table exists in your Supabase database');
      rethrow;
    } catch (e) {
      print('❌ Error creating quote: $e');
      rethrow;
    }
  }

  // Get quotes by me
  Future<List<Quote>> getQuotesByMe(String userId) async {
    try {
      final response = await supabase
          .from('quotes')
          .select()
          .eq('user_id', userId);

      debugPrint('✅ Quotes by me: $response');

      List<Quote> quotes = [];

      for (var quote in response) {
        quotes.add(Quote.fromJson(quote));
      }

      return quotes;
    } on sp.PostgrestException catch (e) {
      print('❌ Supabase Error: ${e.message}');
      print('💡 Make sure the "quotes" table exists in your Supabase database');
      // Return empty list instead of throwing error
      return [];
    } catch (e) {
      log('❌ Error getting quotes by me: $e');
      // Return empty list instead of throwing error
      return [];
    }
  }

  // delete a quote
  Future<void> deleteQuote(Quote quote) async {
    try {
      await supabase.from('quotes').delete().eq('id', quote.id.toString());
      print('✅ Quote deleted successfully');
    } on sp.PostgrestException catch (e) {
      print('❌ Supabase Error: ${e.message}');
      print('💡 Make sure the "quotes" table exists in your Supabase database');
      rethrow;
    } catch (e) {
      log('❌ Error deleting quote: $e');
      rethrow;
    }
  }
}
