import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../user/messages_screen.dart';
import 'admin_dashboard_screen.dart';
import 'jobs_management_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  List<Widget> _buildScreens(VoidCallback goHome) => [
    const AdminDashboardScreen(),
    const JobsManagementScreen(),
    MessagesScreen(onGoHome: goHome),
  ];

  @override
  Widget build(BuildContext context) {
    final auth  = context.read<AuthProvider>();
    final token = auth.token ?? '';
    final email = auth.email ?? '';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider(token, ownerEmail: email)),
        ChangeNotifierProvider(create: (_) => ApplicationProvider(token)),
        ChangeNotifierProvider(create: (_) => MessageProvider(token)),
      ],
      child: Builder(
        builder: (ctx) {
          final unread  = ctx.watch<MessageProvider>().unreadCount;
          final screens = _buildScreens(() => setState(() => _index = 0));
          return Scaffold(
            body: IndexedStack(index: _index, children: screens),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: [
                  const BottomNavigationBarItem(
                    icon:       Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard_rounded),
                    label:      'Dashboard',
                  ),
                  const BottomNavigationBarItem(
                    icon:       Icon(Icons.work_outline),
                    activeIcon: Icon(Icons.work_rounded),
                    label:      'Jobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.forum_outlined),
                    ),
                    activeIcon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.forum_rounded),
                    ),
                    label: 'Inbox',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
