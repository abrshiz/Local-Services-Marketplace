import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/domain/entities/chat_message.dart';
import 'package:localservicemarket/domain/entities/conversation.dart';
import 'package:localservicemarket/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._api);

  final ApiDataSource _api;

  Conversation _mapConversation(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] as String,
      customerId: json['customerId'] as String,
      providerId: json['providerId'] as String,
      peerId: json['peerId'] as String,
      peerName: json['peerName'] as String? ?? 'User',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      unread: json['unread'] as bool? ?? false,
    );
  }

  ChatMessage _mapMessage(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getConversations();
      return list.map(_mapConversation).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Conversation> openConversation(String peerId) async {
    try {
      await _api.ensureInitialized();
      final json = await _api.openConversation(peerId);
      return _mapConversation(json);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final list = await _api.getMessages(conversationId);
      return list.map(_mapMessage).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String body) async {
    try {
      final json = await _api.sendMessage(conversationId, body);
      return _mapMessage(json);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
