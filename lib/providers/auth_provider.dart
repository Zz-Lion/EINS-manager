import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';

class AuthProgressState extends Equatable {
  AuthProgressState({required this.loading});

  final bool loading;

  AuthProgressState copyWith({bool? loading}) {
    return AuthProgressState(loading: loading ?? this.loading);
  }

  @override
  List<Object> get props => [loading];
}

class AuthProvider with ChangeNotifier {
  final firebaseAuth.FirebaseAuth _auth = firebaseAuth.FirebaseAuth.instance;

  AuthProgressState state = AuthProgressState(loading: false);

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      state = state.copyWith(loading: false);
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();

      rethrow;
    }
  }

  void signOut() {
    _auth.signOut();
  }
}
