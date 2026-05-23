import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/entities/chat_message.dart';
import 'package:localservicemarket/domain/entities/conversation.dart';

enum ChatListStatus { initial, loading, loaded, failure }

class ChatListState extends Equatable {
  const ChatListState({
    this.status = ChatListStatus.initial,
    this.conversations = const [],
    this.errorMessage,
  });

  final ChatListStatus status;
  final List<Conversation> conversations;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, conversations, errorMessage];
}

enum ThreadStatus { initial, loading, loaded, sending, failure }

class ChatThreadState extends Equatable {
  const ChatThreadState({
    this.status = ThreadStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  final ThreadStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;

  ChatThreadState copyWith({
    ThreadStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
  }) {
    return ChatThreadState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage];
}
