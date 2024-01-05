part of '../models.dart';

/// This object describes the origin of a message. It can be one of
/// - [MessageOriginUser]
/// - [MessageOriginHiddenUser]
/// - [MessageOriginChat]
/// - [MessageOriginChannel]

abstract class MessageOrigin {
  /// Type of the message origin
  final MessageOriginType type;

  /// Date the message was sent originally in Unix time
  final int date;

  /// Creates a new [MessageOrigin] instance.
  MessageOrigin({
    required this.type,
    required this.date,
  });

  /// Creates a new [MessageOrigin] instance from a JSON object.
  factory MessageOrigin.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MessageOrigin.fromJson not implemented');
  }

  /// Converts [MessageOrigin] instance to a JSON object.
  Map<String, dynamic> toJson();
}