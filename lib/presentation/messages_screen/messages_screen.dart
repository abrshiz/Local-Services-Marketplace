import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import './widgets/chat_list_item_widget.dart';
import './widgets/message_filter_chip_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 'chat_1',
      'name': 'Elena Petrova',
      'role': 'House Cleaning Specialist',
      'lastMessage': 'Yes, I\'m available this Thursday at 10 AM.',
      'time': '10:02 AM',
      'unreadCount': 2,
      'imageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
      'isOnline': true,
    },
    {
      'id': 'chat_2',
      'name': 'James Okonkwo',
      'role': 'Master Plumber',
      'lastMessage': 'I\'ve sent the invoice for the pipe repair.',
      'time': 'Yesterday',
      'unreadCount': 0,
      'imageUrl': 'https://images.unsplash.com/photo-1659353591742-9fa64d94738e',
      'isOnline': false,
    },
    {
      'id': 'chat_3',
      'name': 'Priya Nair',
      'role': 'Electrician',
      'lastMessage': 'Great, see you then!',
      'time': 'May 10',
      'unreadCount': 0,
      'imageUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_125538482-1766485545000.png',
      'isOnline': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface),
          ),
        ],
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          _buildFilterChips(theme),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ChatListItemWidget(chat: chat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          MessageFilterChipWidget(label: 'All', isSelected: true, onTap: () {}),
          const SizedBox(width: 8),
          MessageFilterChipWidget(label: 'Unread', isSelected: false, onTap: () {}),
          const SizedBox(width: 8),
          MessageFilterChipWidget(label: 'Providers', isSelected: false, onTap: () {}),
          const SizedBox(width: 8),
          MessageFilterChipWidget(label: 'Archived', isSelected: false, onTap: () {}),
        ],
      ),
    );
  }
}
