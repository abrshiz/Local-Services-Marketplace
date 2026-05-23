import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.isMine,
  });

  final String messageId;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final bool isMine;

  @override
  List<Object?> get props =>
      [messageId, conversationId, senderId, body, createdAt, isMine];
}
