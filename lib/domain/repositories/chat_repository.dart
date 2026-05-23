import 'package:localservicemarket/domain/entities/chat_message.dart';
import 'package:localservicemarket/domain/entities/conversation.dart';

abstract class ChatRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation> openConversation(String peerId);
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage> sendMessage(String conversationId, String body);
}
