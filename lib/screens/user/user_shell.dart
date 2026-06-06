import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
          body: IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap:        (i) => setState(() => _index = i),
              items: const [
                BottomNavigationBarItem(
                  icon:      Icon(Icons.work_outline),
                  activeIcon: Icon(Icons.work_rounded),
                  label:     'Jobs',
                ),
                BottomNavigationBarItem(
                  icon:      Icon(Icons.inbox_outlined),
                  activeIcon: Icon(Icons.inbox_rounded),
                  label:     'Applied',
                ),
                BottomNavigationBarItem(
                  icon:      Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label:     'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
