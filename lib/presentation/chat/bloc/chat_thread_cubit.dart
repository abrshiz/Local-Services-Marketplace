import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/repositories/chat_repository.dart';
import 'package:localservicemarket/presentation/chat/bloc/chat_state.dart';

class ChatThreadCubit extends Cubit<ChatThreadState> {
  ChatThreadCubit(this._chat, this.conversationId) : super(const ChatThreadState());

  final ChatRepository _chat;
  final String conversationId;
  Timer? _pollTimer;

  Future<void> start() async {
    await refresh();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: ThreadStatus.loading));
    }
    try {
      final messages = await _chat.getMessages(conversationId);
      emit(ChatThreadState(status: ThreadStatus.loaded, messages: messages));
    } on Failure catch (e) {
      if (!silent) {
        emit(ChatThreadState(status: ThreadStatus.failure, errorMessage: e.message));
      }
    }
  }

  Future<void> send(String body) async {
    if (body.trim().isEmpty) return;
    emit(state.copyWith(status: ThreadStatus.sending));
    try {
      await _chat.sendMessage(conversationId, body.trim());
      await refresh(silent: true);
    } on Failure catch (e) {
      emit(state.copyWith(status: ThreadStatus.failure, errorMessage: e.message));
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
