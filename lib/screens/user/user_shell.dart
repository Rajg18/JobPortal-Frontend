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
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.work_outline_rounded),
                  activeIcon: Icon(Icons.work_rounded),
                  label: 'Jobs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inbox_outlined),
                  activeIcon: Icon(Icons.inbox_rounded),
                  label: 'Applied',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
