import 'dart:async';

import 'package:home_app/auth/auth_repository.dart';

/// An in-memory [AuthRepository]. Tests sign people in and out with [emit]
/// and make calls fail by setting the `*Error` fields.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({String? userId}) : _userId = userId;

  String? _userId;
  final _changes = StreamController<String?>.broadcast();

  Object? googleError;
  Object? sendCodeError;
  Object? verifyCodeError;
  int googleSignIns = 0;
  int signOuts = 0;
  final sentCodesTo = <String>[];
  final verifiedCodes = <({String email, String code})>[];

  void emit(String? userId) {
    _userId = userId;
    _changes.add(userId);
  }

  @override
  Stream<String?> watchUserId() async* {
    yield _userId;
    yield* _changes.stream;
  }

  @override
  Future<void> signInWithGoogle() async {
    googleSignIns++;
    if (googleError case final error?) throw error;
  }

  @override
  Future<void> sendEmailCode(String email) async {
    sentCodesTo.add(email);
    if (sendCodeError case final error?) throw error;
  }

  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    verifiedCodes.add((email: email, code: code));
    if (verifyCodeError case final error?) throw error;
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    emit(null);
  }
}
