import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/user_shell.dart';
import 'screens/admin/admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.light,
    systemNavigationBarColor: Color(0xFF09090B),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..restoreSession(),
      child: const JobPortalApp(),
    ),
  );
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HireLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn && auth.token == null) {
      return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 400)),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _SplashScreen();
          }
          return auth.isLoggedIn
              ? (auth.role == 'ADMIN' ? const AdminShell() : const UserShell())
              : const LoginScreen();
        },
      );
    }

    if (!auth.isLoggedIn) return const LoginScreen();
    return auth.role == 'ADMIN' ? const AdminShell() : const UserShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF09090B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Logo(),
            SizedBox(height: 32),
            SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1), strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatefulWidget {
  const _Logo();
  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('H',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                    color: Colors.white)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('HireLoop',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                color: Color(0xFFF4F4F5), letterSpacing: -0.3)),
        ],
      ),
    );
  }
}
