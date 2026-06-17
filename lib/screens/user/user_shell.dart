import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'my_applications_screen.dart';
import 'ai_match_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});
  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;
  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthProvider>().token ?? '';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider(token)),
        ChangeNotifierProvider(create: (_) => ApplicationProvider(token)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(token)),
        ChangeNotifierProvider(create: (_) => MessageProvider(token)),
      ],
      child: Builder(
        builder: (ctx) => Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              HomeScreen(
                onGoToApplications: () => _goTo(2),
                onGoToAiMatch:      () => _goTo(4),
                onGoToMessages:     () => _goTo(3),
                onGoToProfile:      () => _goTo(1),
              ),
              ProfileScreen(onBack: () => _goTo(0)),
              MyApplicationsScreen(onGoHome: () => _goTo(0)),
              MessagesScreen(onGoHome: () => _goTo(0)),
              AiMatchScreen(onGoHome: () => _goTo(0)),
            ],
          ),
          bottomNavigationBar: _BottomNav(index: _index, onTap: _goTo),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 900) return const SizedBox.shrink();

    final unread = context.watch<MessageProvider>().unreadCount;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13151A),
        border: Border(top: BorderSide(color: Color(0xFF252830), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(children: [
            _item(context, 0, Icons.work_outline_rounded,
                Icons.work_rounded, 'Jobs'),
            _item(context, 1, Icons.person_outline_rounded,
                Icons.person_rounded, 'Profile'),
            _item(context, 2, Icons.inbox_outlined,
                Icons.inbox_rounded, 'Applied'),
            _itemWithBadge(context, 3, Icons.forum_outlined,
                Icons.forum_rounded, 'Messages', unread),
            _item(context, 4, Icons.auto_awesome_outlined,
                Icons.auto_awesome_rounded, 'AI Match',
                iconColor: const Color(0xFF8B5CF6)),
          ]),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext ctx, int i,
    IconData off, IconData on, String label, {
    Color? iconColor,
  }) {
    final sel = index == i;
    final color = sel
        ? (iconColor ?? const Color(0xFF10B981))
        : const Color(0xFF4B5263);
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(sel ? on : off, size: 22, color: color),
          const SizedBox(height: 3),
          Text(label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: color)),
        ]),
      ),
    );
  }

  Widget _itemWithBadge(
    BuildContext ctx, int i,
    IconData off, IconData on, String label, int badgeCount,
  ) {
    final sel   = index == i;
    final color = sel ? const Color(0xFF10B981) : const Color(0xFF4B5263);
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(sel ? on : off, size: 22, color: color),
            if (badgeCount > 0)
              Positioned(
                right: -6, top: -4,
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$badgeCount',
                      style: const TextStyle(
                        fontSize: 8, color: Colors.white,
                        fontWeight: FontWeight.w700))),
                ),
              ),
          ]),
          const SizedBox(height: 3),
          Text(label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: color)),
        ]),
      ),
    );
  }
}
