import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../core/services/imgbb_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final imgBBServiceProvider = Provider<ImgBBService>((ref) {
  return ImgBBService();
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserDataProvider = FutureProvider((ref) async {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser != null) {
    return ref.watch(firestoreServiceProvider).getUser(authUser.uid);
  }
  return null;
});
