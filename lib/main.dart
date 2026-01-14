import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:quote_vault/views/auth_check.dart';
import 'package:quote_vault/views/themes/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  String supabaseUrl = dotenv.get('SUPABASE_URL');
  String supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY');

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return FlutterWebFrame(
      maximumSize: const Size(480, double.infinity),
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quotes Vault',
          themeMode: ThemeMode.light,
          darkTheme: MyTheme.darkTheme,
          theme: MyTheme.lightTheme,
          home: const AuthCheck(),
        );
      },
    );
  }
}
