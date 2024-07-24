import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'dart:convert';

class UserService extends ChangeNotifier {
  static const String API_URL = 'https://jsonplaceholder.typicode.com/posts';

  UserRequest? _userRequest;
  String? _error;
  bool _isLoading = false;

  UserRequest? get userRequest => _userRequest;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchUserRequest(int userId, int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$API_URL?userId=$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          _userRequest = UserRequest.fromMap(data[0]);
        } else {
          _error = 'No data found for user ID $userId';
        }
      } else {
        _error = 'Error fetching data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
