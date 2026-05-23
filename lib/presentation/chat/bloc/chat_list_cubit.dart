import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/repositories/chat_repository.dart';
import 'package:localservicemarket/presentation/chat/bloc/chat_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit(this._chat) : super(const ChatListState());

  final ChatRepository _chat;

  Future<void> load() async {
    emit(const ChatListState(status: ChatListStatus.loading));
    try {
      final list = await _chat.getConversations();
      emit(ChatListState(status: ChatListStatus.loaded, conversations: list));
    } on Failure catch (e) {
      emit(ChatListState(status: ChatListStatus.failure, errorMessage: e.message));
    }
  }
}
