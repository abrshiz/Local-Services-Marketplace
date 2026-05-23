import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.conversationId,
    required this.customerId,
    required this.providerId,
    required this.peerId,
    required this.peerName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unread = false,
  });

  final String conversationId;
  final String customerId;
  final String providerId;
  final String peerId;
  final String peerName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final bool unread;

  @override
  List<Object?> get props => [
        conversationId,
        customerId,
        providerId,
        peerId,
        peerName,
        lastMessage,
        lastMessageAt,
        unread,
      ];
}
