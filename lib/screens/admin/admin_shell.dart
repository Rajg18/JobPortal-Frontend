import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'jobs_management_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _screens = [
    AdminDashboardScreen(),
    JobsManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth  = context.read<AuthProvider>();
    final token = auth.token ?? '';
    final email = auth.email ?? '';

    return MultiProvider(
      providers: [
        // ownerEmail ensures this recruiter only sees jobs they posted
        ChangeNotifierProvider(create: (_) => JobProvider(token, ownerEmail: email)),
        ChangeNotifierProvider(create: (_) => ApplicationProvider(token)),
      ],
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                icon:       Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label:      'Dashboard',
              ),
              BottomNavigationBarItem(
                icon:       Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work_rounded),
                label:      'Jobs',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
