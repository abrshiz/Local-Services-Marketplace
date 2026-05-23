import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/chat/bloc/chat_list_cubit.dart';
import 'package:localservicemarket/presentation/chat/bloc/chat_state.dart';
import 'package:localservicemarket/presentation/chat/chat_thread_page.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatListCubit(sl())..load(),
      child: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state.status == ChatListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ChatListStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Could not load messages'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<ChatListCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No conversations yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Message a provider from their profile to start chatting.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ChatListCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: state.conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = state.conversations[i];
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ChatThreadPage(
                          conversationId: c.conversationId,
                          peerName: c.peerName,
                        ),
                      ),
                    );
                    if (context.mounted) {
                      context.read<ChatListCubit>().load();
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          c.peerName.isNotEmpty ? c.peerName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.peerName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.lastMessage.isEmpty ? 'Start chatting' : c.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat.Md().format(c.lastMessageAt.toLocal()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
