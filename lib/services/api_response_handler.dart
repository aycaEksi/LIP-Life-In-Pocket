import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';
import '../theme/theme_manager.dart';


class ApiResponseHandler {
  static Future<T?> handleResponse<T>({
    required BuildContext context,
    required Future<dynamic> Function() apiCall,
    required T Function(Map<String, dynamic> data) onSuccess,
    ThemeManager? themeManager,
  }) async {
    try {
      final response = await apiCall();


      if (response.statusCode == 401 || response.statusCode == 403) {
        await ApiService.instance.logout();
        
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                themeManager: themeManager ?? ThemeManager(),
              ),
            ),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return null;
      }

  
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return onSuccess(data);
      }

      final errorData = jsonDecode(response.body);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}