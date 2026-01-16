import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

final userProvider = StateNotifierProvider<UserController, UserModel?>((ref) {
  return UserController();
});

class UserController extends StateNotifier<UserModel?> {
  UserController() : super(null);
  final _supabase = Supabase.instance.client;

  void setUser(UserModel? user) => state = user;

  // fetch user
  Future<void> fetchUser() async {
    state = null;
  }

  // update user
  Future<void> updateUser(UserModel user) async {
    state = user;
  }

  // delete user
  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    try {
      // 1️⃣ Delete user-related data (IMPORTANT ORDER)
      await _supabase.from('favorites').delete().eq('user_id', user.id);
      await _supabase.from('quotes').delete().eq('user_id', user.id);
      await _supabase.from('user_details').delete().eq('user_id', user.id);
      // 3️⃣ Sign out locally
      await _supabase.auth.signOut();

      // 4️⃣ Clear local state
      state = null;
    } catch (e) {
      rethrow;
    }
  }
}
