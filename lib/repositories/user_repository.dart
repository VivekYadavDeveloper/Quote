import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

import '../models/user_model.dart';

class UserRepository {
  final supabase = sp.Supabase.instance.client;

  Future<void> createUser(UserModel user) async {
    final data = user.toJson();
    try {
      await supabase.from('user_details').insert(data);
    } catch (e) {
      debugPrint('❌ Create user error: $e');
      debugPrint(e.toString());
      rethrow;
    }
  }

  // fetch user
  Future<UserModel> fetchUser(String userId) async {
    try {
      final response = await supabase
          .from('user_details')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // 👈 SAFE

      // 🔹 If profile does not exist → create it
      if (response == null) {
        final authUser = supabase.auth.currentUser!;

        final newUser = UserModel(id: authUser.id, email: authUser.email!);

        await createUser(newUser);
        return newUser;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Fetch user error: $e');
      rethrow;
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
