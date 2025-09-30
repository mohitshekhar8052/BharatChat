import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Chatterbox',
            theme: themeProvider.themeData,
            home: const SplashScreen(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/auth': (context) => const AuthScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/chat-list': (context) => const ChatListScreen(),
              '/stories': (context) => const StoriesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/contacts': (context) => const ContactsScreen(),
              '/main': (context) => const MainTabScreen(),
              '/auth-wrapper': (context) => const AuthWrapper(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
