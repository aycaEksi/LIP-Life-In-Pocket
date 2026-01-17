import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Singleton pattern
  ApiService._();
  static final ApiService instance = ApiService._();

  // Token yönetimi
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // User bilgisi kaydetme
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // Header'ları hazırla
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  // Register
  Future<http.Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  // Verify code
  Future<http.Response> verifyCode({
    required String email,
    required String code,
  }) async {
    final body = {
      'email': email,
      'code': code,
    };
    
    // Debug için log
    print('Verify Code Request:');
    print('URL: $baseUrl/verify-code');
    print('Body: ${jsonEncode(body)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    return response;
  }

  // Login
  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  // Get profile
  Future<http.Response> getProfile() async {
    return await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(includeAuth: true),
    );
  }

  // Resend verification code
  Future<http.Response> resendVerificationCode(String email) async {
    return await http.post(
      Uri.parse('$baseUrl/resend-verification'),
      headers: await _getHeaders(),
      body: jsonEncode({'email': email}),
    );
  }

  // Motivation endpoint (token gerektirmiyor)
  Future<http.Response> getMotivation({
    required int energy,
    required int happiness,
    required int stress,
    String note = '',
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/motivation'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'energy': energy,
        'happiness': happiness,
        'stress': stress,
        'note': note,
      }),
    );
  }

  // Generic authenticated request helper
  Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders(includeAuth: true);

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Logout
  Future<void> logout() async {
    await removeToken();
    await removeUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  // Check if token is valid
  Future<bool> isAuthenticated() async {
    try {
      final response = await getProfile();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== DAY ENTRIES ====================
  
  // Resim upload
  Future<String?> uploadPhoto(String filePath) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No token');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-photo'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        // Backend'den dönen path'i al (örn: "/uploads/photo_1234567890.jpg")
        return data['path'] ?? data['url'];
      }
      
      return null;
    } catch (e) {
      print('Upload photo error: $e');
      return null;
    }
  }
  
  Future<http.Response> saveDayEntry({
    required String date,
    String? note,
    String? photo1Url,
    String? photo2Url,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'day-entries',
      body: {
        'date': date,
        'note': note,
        'photo1_path': photo1Url,  // Backend'de photo1_path bekleniyor
        'photo2_path': photo2Url,  // Backend'de photo2_path bekleniyor
      },
    );
  }

  Future<http.Response> getDayEntry(String date) async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'day-entries/$date',
    );
  }

  Future<http.Response> getAllDayEntries() async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'day-entries',
    );
  }

  // ==================== TASKS ====================
  
  Future<http.Response> createTask({
    required String period,
    required String title,
    String? dueDate,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'tasks',
      body: {
        'period': period,
        'title': title,
        'due_date': dueDate,
      },
    );
  }

  Future<http.Response> getTasks({String? period}) async {
    String endpoint = 'tasks';
    if (period != null) {
      endpoint += '?period=$period';
    }
    return await authenticatedRequest(
      method: 'GET',
      endpoint: endpoint,
    );
  }

  Future<http.Response> updateTask({
    required int id,
    String? title,
    bool? done,
    String? dueDate,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (done != null) body['done'] = done ? 1 : 0;
    if (dueDate != null) body['due_date'] = dueDate;
    
    return await authenticatedRequest(
      method: 'PUT',
      endpoint: 'tasks/$id',
      body: body,
    );
  }

  Future<http.Response> deleteTask(int id) async {
    return await authenticatedRequest(
      method: 'DELETE',
      endpoint: 'tasks/$id',
    );
  }

  // ==================== CAPSULES ====================
  
  Future<http.Response> createCapsule({
    required String title,
    required String note,
    required String unlockAt,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'capsules',
      body: {
        'title': title,
        'note': note,
        'unlock_at': unlockAt,
      },
    );
  }

  Future<http.Response> getCapsules() async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'capsules',
    );
  }

  Future<http.Response> deleteCapsule(int id) async {
    return await authenticatedRequest(
      method: 'DELETE',
      endpoint: 'capsules/$id',
    );
  }

  // ==================== MOODS ====================
  
  Future<http.Response> saveMood({
    required int energy,
    required int happiness,
    required int stress,
    String? note,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'moods',
      body: {
        'energy': energy,
        'happiness': happiness,
        'stress': stress,
        'note': note,
      },
    );
  }

  Future<http.Response> getMoods({int? limit}) async {
    String endpoint = 'moods';
    if (limit != null) {
      endpoint += '?limit=$limit';
    }
    return await authenticatedRequest(
      method: 'GET',
      endpoint: endpoint,
    );
  }

  Future<http.Response> getLatestMood() async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'moods/latest',
    );
  }

  Future<http.Response> getLatestDurum() async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'moods/latest-durum',
    );
  }

  /// AI'dan mood insight al (bildirimler için)
  Future<http.Response> getMoodInsight({
    required int energy,
    required int happiness,
    required int stress,
    String? note,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'moods/insight',
      body: {
        'energy': energy,
        'happiness': happiness,
        'stress': stress,
        'note': note,
      },
    );
  }

  // ==================== AVATAR ====================
  
  Future<http.Response> updateAvatar({
    String? gender,
    String? skinTone,
    String? eyeColor,
    String? hairStyle,
    String? hairColor,
    String? topClothing,
    String? topClothingColor,
    String? bottomClothing,
    String? bottomClothingColor,
  }) async {
    final body = <String, dynamic>{};
    if (gender != null) body['gender'] = gender;
    if (skinTone != null) body['skin_tone'] = skinTone;
    if (eyeColor != null) body['eye_color'] = eyeColor;
    if (hairStyle != null) body['hair_style'] = hairStyle;
    if (hairColor != null) body['hair_color'] = hairColor;
    if (topClothing != null) body['top_clothing'] = topClothing;
    if (topClothingColor != null) body['top_clothing_color'] = topClothingColor;
    if (bottomClothing != null) body['bottom_clothing'] = bottomClothing;
    if (bottomClothingColor != null) body['bottom_clothing_color'] = bottomClothingColor;
    
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'avatar',
      body: body,
    );
  }

  Future<http.Response> getAvatar() async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'avatar',
    );
  }

  // ==================== AVATAR PREFERENCES ====================
  
  Future<http.Response> updateAvatarPrefs({
    int? hair,
    int? eyes,
    int? outfit,
  }) async {
    final body = <String, dynamic>{};
    if (hair != null) body['hair'] = hair;
    if (eyes != null) body['eyes'] = eyes;
    if (outfit != null) body['outfit'] = outfit;
    
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'avatar-prefs',
      body: body,
    );
  }

  Future<http.Response> getAvatarPrefs() async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'avatar-prefs',
    );
  }

  // ==================== FOCUS DAILY ====================
  
  Future<http.Response> saveFocusDaily({
    required String date,
    required int hydrationCount,
    required int movementCount,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'focus-daily',
      body: {
        'date': date,
        'hydration_count': hydrationCount,
        'movement_count': movementCount,
      },
    );
  }

  Future<http.Response> getFocusDaily(String date) async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'focus-daily/$date',
    );
  }

  // ==================== PERSONAL REMINDERS ====================
  
  Future<http.Response> createPersonalReminder({
    required String date,
    required String text,
  }) async {
    return await authenticatedRequest(
      method: 'POST',
      endpoint: 'personal-reminders',
      body: {
        'date': date,
        'text': text,
      },
    );
  }

  Future<http.Response> getPersonalReminders(String date) async {
    return await authenticatedRequest(
      method: 'GET',
      endpoint: 'personal-reminders/$date',
    );
  }

  Future<http.Response> updatePersonalReminder({
    required int id,
    bool? done,
    String? text,
  }) async {
    final body = <String, dynamic>{};
    if (done != null) body['done'] = done ? 1 : 0;
    if (text != null) body['text'] = text;
    
    return await authenticatedRequest(
      method: 'PUT',
      endpoint: 'personal-reminders/$id',
      body: body,
    );
  }

  Future<http.Response> deletePersonalReminder(int id) async {
    return await authenticatedRequest(
      method: 'DELETE',
      endpoint: 'personal-reminders/$id',
    );
  }
}
