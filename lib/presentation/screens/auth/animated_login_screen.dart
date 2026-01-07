import 'package:flutter/material.dart';
import 'package:animated_login/animated_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'verify_otp_screen.dart';

class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({super.key});

  @override
  State<AnimatedLoginScreen> createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen> {
  // Login Logic
  Future<String?> _onLogin(LoginData data) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: data.email,
        password: data.password,
      );
      if (response.session != null) {
        return null; // Success
      } else {
        return 'Please check your email to confirm your account.';
      }
    } on AuthException catch (e) {
      // Check for generic "Invalid login credentials" or specific 400 bad request logic if needed
      if (e.message.toLowerCase().contains('invalid login credentials') || e.statusCode == '400') {
         return 'Wrong credentials provided.';
      }
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.'; 
    }
  }

  // Signup Logic
  Future<String?> _onSignup(SignUpData data) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: data.email,
        password: data.password,
        emailRedirectTo: kIsWeb ? null : 'io.supabase.flutterlab://login-callback',
        data: {'full_name': data.name}, // Store name
      );

      final user = response.user;
      if (user != null) {
        // Create profile
        await _createProfileIfNeeded(user.id, data.name);
        
        if (response.session == null) {
           return 'Please check your email to confirm your account.';
        }
        return null; // Success
      } else {
         return 'Sign up failed.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Forgot Password Logic
  Future<String?> _onForgotPassword(String email) async {
    print("DEBUG: _onForgotPassword called with $email");
    try {
      print("DEBUG: Sending OTP for password recovery (via signInWithOtp)...");
      // Use signInWithOtp to send a code. This acts as a "login" which allows password reset.
      // We set shouldCreateUser: false because this is a recovery flow for EXISTING users.
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, 
        emailRedirectTo: kIsWeb ? null : 'io.supabase.flutterlab://login-callback',
      );
      print("DEBUG: OTP sent.");
      
      // Navigate to OTP verification screen
      if (mounted) {
         print("DEBUG: Navigating to VerifyOtpScreen");
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (_) => VerifyOtpScreen(email: email),
           ),
         );
      }
      
      return null; // Success
    } on AuthException catch (e) {
      print("DEBUG: AuthException in _onForgotPassword: ${e.message} (Code: ${e.statusCode})");
      return e.message; // Return friendly message
    } catch (e) {
      print("DEBUG: Error in _onForgotPassword: $e");
      return "An error occurred: $e";
    }
  }

  Future<void> _createProfileIfNeeded(String userId, String? name) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': userId,
          'full_name': name,
        });
      }
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final mainTheme = Theme.of(context);
    
    return AnimatedLogin(
        onLogin: _onLogin,
        onSignup: _onSignup,
        onForgotPassword: _onForgotPassword,
        
        // Customize Logo
        logo: Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Icon(Icons.shopping_bag_outlined, size: 80, color: mainTheme.colorScheme.primary),
        ),
        
        // Customize Theme
        loginDesktopTheme: LoginViewTheme(
          // Use app colors
          backgroundColor: mainTheme.colorScheme.background,
          formFieldBackgroundColor: Colors.white,
          actionButtonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(mainTheme.colorScheme.primary),
            foregroundColor: MaterialStateProperty.all(mainTheme.colorScheme.onPrimary),
          ),
          logoPadding: const EdgeInsets.only(bottom: 20),
          formFieldElevation: 0, 
          // Custom text styles that ARE supported
          changeActionTextStyle: TextStyle(color: mainTheme.colorScheme.primary, fontWeight: FontWeight.bold),
          forgotPasswordStyle: TextStyle(color: mainTheme.colorScheme.secondary),
          welcomeTitleStyle: TextStyle(color: mainTheme.textTheme.displaySmall?.color ?? mainTheme.colorScheme.onBackground),
          welcomeDescriptionStyle: TextStyle(color: mainTheme.textTheme.bodyLarge?.color ?? mainTheme.colorScheme.onBackground.withOpacity(0.7)),
        ),
        loginMobileTheme: LoginViewTheme(
          backgroundColor: mainTheme.colorScheme.background,
          formFieldBackgroundColor: Colors.white,
          actionButtonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(mainTheme.colorScheme.primary),
            foregroundColor: MaterialStateProperty.all(mainTheme.colorScheme.onPrimary),
          ),
          logoPadding: const EdgeInsets.only(bottom: 20),
          formFieldElevation: 0,
          changeActionTextStyle: TextStyle(color: mainTheme.colorScheme.primary, fontWeight: FontWeight.bold),
          forgotPasswordStyle: TextStyle(color: mainTheme.colorScheme.secondary),
          welcomeTitleStyle: TextStyle(color: mainTheme.textTheme.displaySmall?.color ?? mainTheme.colorScheme.onBackground),
          welcomeDescriptionStyle: TextStyle(color: mainTheme.textTheme.bodyLarge?.color ?? mainTheme.colorScheme.onBackground.withOpacity(0.7)),
        ),
        
        // Customize Texts
        loginTexts: LoginTexts(
          welcomeBack: 'Welcome Back!',
          welcome: 'Welcome!',
          welcomeBackDescription: 'Enter your details to sign in',
          welcomeDescription: 'Sign up to get started',
          signUp: 'Sign Up',
          login: 'Log In',
          notHaveAnAccount: 'Don\'t have an account?',
          alreadyHaveAnAccount: 'Already have an account?',
        ),
        
        // Options
        signUpMode: SignUpModes.name, // Ask for Name + Email + Password
        socialLogins: const [], // Add social logins here if needed later
        passwordValidator: ValidatorModel(
          customValidator: _passwordValidator,
          length: 0,
          checkUpperCase: false,
          checkLowerCase: false,
          checkNumber: false,
          checkSpace: false,
        ),
      );
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    // Return null to mark as valid, letting the server handle auth errors
    return null; 
  }
}
