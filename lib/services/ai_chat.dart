import 'dart:convert'; // ✅ 引入 dart:convert 來解析 JSON
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RecommendedRestaurant {
  final String id;
  final String name;
  final String? imageUrl;

  RecommendedRestaurant({required this.id, required this.name, this.imageUrl});

  factory RecommendedRestaurant.fromMap(Map<String, dynamic> map) {
    return RecommendedRestaurant(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final List<RecommendedRestaurant> recommendations;

  Message({required this.text, this.isUser = true, List<RecommendedRestaurant>? recommendations})
    : recommendations = recommendations ?? [];
}

class AiChatService with ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> addMessage(Message msg, String id) async {
    if (msg.text.isEmpty || _isLoading) return;

    _messages.add(msg);
    _isLoading = true;
    notifyListeners();

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'recommendRestaurant',
      );
      final response = await callable.call({
        "messages": _messages.map((m) => {"text": m.text, "isUser": m.isUser}).toList(),
        "userId": id,
      });

      // ✅ 解析後端回傳的 JSON
      final data = response.data as Map<String, dynamic>;
      final type = data['type'];
      final text = data['text'] as String;

      if (type == 'recommendation' && data['restaurants'] != null) {
        final List<dynamic> restaurantData = data['restaurants'] as List;
      debugPrint("Response data: ${restaurantData.toString()}");
        final recommendations =
            restaurantData
                .map((item) => RecommendedRestaurant.fromMap(Map<String, dynamic>.from(item)))
                .toList();

        _messages.add(Message(text: text, isUser: false, recommendations: recommendations));
        debugPrint("Received recommendations: ${recommendations.map((r) => r.name).join(', ')}");
      } else {
        _messages.add(Message(text: text, isUser: false));
        debugPrint("Received message: $text");
      }
    } catch (e) {
      debugPrint("Error calling recommendRestaurant: $e");
      _messages.add(Message(text: "Sorry, I'm having trouble connecting.", isUser: false));
    } finally {
      _isLoading = false;
    }

    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
