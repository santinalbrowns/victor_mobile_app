import 'package:flutter/material.dart';
import 'package:flutter_tag/features/auth/signup_screen.dart';
import 'package:flutter_tag/features/home/home_screen.dart';
import 'package:flutter_tag/services/auth_service.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/signin_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService _authService = AuthService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const SigninScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            redirect: (context, state) async {
              final isAuthenticated = await _authService.isAuthenticated();
              return isAuthenticated ? null : '/login';
            },
          ),
        ],
        redirect: (context, state) async {
          // Global redirect logic for authentication
          final isAuthenticated = await _authService.isAuthenticated();

          // If trying to access `/login` or `/signup` but already authenticated, redirect to `/home`
          if (isAuthenticated &&
              (state.fullPath == '/login' || state.fullPath == '/signup')) {
            return '/home';
          }

          // Allow navigation otherwise
          return null;
        },
      ),
    );
  }
}
