import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/login_page.dart';
import 'presentation/main_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, User;
// Import necessario per provider
import 'package:provider/provider.dart';
// Import del provider preferiti custom
import 'providers/favorites_provider.dart';
// Import del nuovo provider watchlist
import 'providers/watchlist_provider.dart';
// Import del provider per la gestione della lingua
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica il file .env
  await dotenv.load(fileName: ".env");

  // Inizializza Firebase con le impostazioni generate dalla CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Wrappa MyApp in un MultiProvider che fornisce sia FavoritesProvider che WatchlistProvider che LocaleProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => WatchlistProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocaleProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const MainLayout();
          } else {
            return const LoginPage();
          }
        }
        // Mostra un indicatore di caricamento mentre si verifica lo stato di autenticazione
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Sfondo globale nero assoluto
        primaryColor: const Color(0xFF6366F1),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6366F1),
          surface: Colors.black, // Colore surface impostato su nero profondo
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
