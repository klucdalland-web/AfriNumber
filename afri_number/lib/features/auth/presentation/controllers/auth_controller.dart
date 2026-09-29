import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Contrôleur auth (stub) — à brancher sur les repositories / API.
class AuthController extends GetxController {
  AuthController(this._repository, this._storage);

  final AuthRepository _repository;
  final StorageService _storage;

  final isLoading = false.obs;

  // Exemple de signature pour plus tard :
  // Future<void> login(String email, String password) async { ... }
  // Future<void> register(...) async { ... }
  // Future<void> logout() async { ... }
}
