import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snailpace/models/session_model.dart';

class UserSettingsProviderNotifier extends StateNotifier<List<SessionModel>> {
  UserSettingsProviderNotifier() : super([]);
}

final userSettingsProvider =
    StateNotifierProvider<UserSettingsProviderNotifier, List<SessionModel>>(
        (ref) {
  return UserSettingsProviderNotifier();
});
