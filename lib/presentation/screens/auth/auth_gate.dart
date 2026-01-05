import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main_screen.dart';
import 'animated_login_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Warning: This builds continuously on state changes.
        // For a more complex app, you might want to handle side effects (like fetching data) 
        // in a separate logic layer or Riverpod provider listener.
        
        if (snapshot.connectionState == ConnectionState.waiting) {
           // Check if there is an initial session to show content immediately
           final session = Supabase.instance.client.auth.currentSession;
           if (session != null) {
             return const MainScreen();
           }
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        // If session exists, user is logged in
        if (session != null) {
          return const MainScreen();
        } else {
          return const AnimatedLoginScreen();
        }
      },
    );
  }
}
