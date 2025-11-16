import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:music_recommendation_system/Pages/WelcomeScreen.dart';
import 'package:music_recommendation_system/Pages/HomeScreen.dart';
import 'package:music_recommendation_system/Pages/ManualEEGInputScreen.dart';
import 'package:music_recommendation_system/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Based Music Recommendation System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/manual-eeg': (context) => const ManualEEGInputScreen(),
      },
    );
  }
}
