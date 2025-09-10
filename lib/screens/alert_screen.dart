import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String location;
  final String weatherCondition;
  final double temperature;

  Alert({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.location,
    required this.weatherCondition,
    required this.temperature,
  });

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      weatherCondition: map['weatherCondition'] ?? '',
      temperature: (map['temperature'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'location': location,
      'weatherCondition': weatherCondition,
      'temperature': temperature,
    };
  }
}