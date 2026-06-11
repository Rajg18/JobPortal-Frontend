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

  // Lock to portrait only for a clean mobile experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Light status bar — dark icons on white background.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.dark,
    systemNavigationBarColor:  Color(0xFFFFFFFF),
    systemNavigationBarIconBrightness: Brightness.dark,
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
      title:          'JobPortal',
      debugShowCheckedModeBanner: false,
      theme:          AppTheme.light,
      home:           const _AuthGate(),
    );
  }
}

/// Decides which screen to show based on auth state.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // While restoring session from shared prefs, show a branded splash.
    if (!auth.isLoggedIn && auth.token == null) {
      return FutureBuilder(
        // Small delay so restoreSession() can complete before flicker.
        future: Future.delayed(const Duration(milliseconds: 300)),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return _SplashScreen();
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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedLogo(),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: Color(0xFFF5A623), strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Text('H',
            style: TextStyle(
              fontSize: 38, fontWeight: FontWeight.w800,
              color: Colors.white)),
        ),
      ),
    );
  }
}
