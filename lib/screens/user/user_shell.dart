import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'my_applications_screen.dart';
import 'profile_screen.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});
  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    MyApplicationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthProvider>().token ?? '';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider(token)),
        ChangeNotifierProvider(create: (_) => ApplicationProvider(token)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(token)),
      ],
      child: Builder(
        builder: (ctx) => Scaffold(
          // Each screen handles its own Scaffold/AppBar — no outer shell chrome
          body: IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: _BottomNav(
            index: _index,
            onTap: (i) => setState(() => _index = i),
          ),
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
    final w = MediaQuery.of(context).size.width;
    // On wide screens, the nav is in each screen's AppBar; hide bottom nav
    if (w > 900) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13151A),
        border: Border(top: BorderSide(color: Color(0xFF252830), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(0, Icons.work_outline_rounded,  Icons.work_rounded,          'Jobs'),
              _item(1, Icons.inbox_outlined,         Icons.inbox_rounded,         'Applied'),
              _item(2, Icons.person_outline_rounded, Icons.person_rounded,        'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData off, IconData on, String label) {
    final sel = index == i;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? on : off,
                size: 22,
                color: sel ? const Color(0xFF10B981) : const Color(0xFF4B5263)),
            const SizedBox(height: 3),
            Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? const Color(0xFF10B981) : const Color(0xFF4B5263))),
          ],
        ),
      ),
    );
  }
}
