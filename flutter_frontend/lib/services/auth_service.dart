/*
 * Copyright (c) 2026 Duta Alif Gunawan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

class AuthService {
  static const String _userKey = 'user_data';

  Future<void> saveUser(User user) async {
    print("AuthService: Saving user to SharedPreferences - ID: ${user.id}, Name: ${user.name}, Email: ${user.email}"); // Debug log
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'token': user.token,
    };
    await prefs.setString(_userKey, jsonEncode(userData));
    print("AuthService: User data saved successfully"); // Debug log
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userKey);
    
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      return User(
        id: int.tryParse(userData['id'].toString()) ?? 0,
        name: userData['name'],
        email: userData['email'],
        token: userData['token'],
      );
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }


}