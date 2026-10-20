import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'favorites_page.dart';
import 'watchlist_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        // Logo stile piattaforma streaming: CineTrack rosso, grande, grassetto
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'CineTrack',
            style: const TextStyle(
              color: Color(0xFFFF2323), // rosso acceso
              fontWeight: FontWeight.w900,
              fontSize: 32,
              letterSpacing: 1.4,
              fontFamily: 'Sans', // opzionale, aggiungere un tocco logo
            ),
          ),
        ),
        actions: [
          // Pulsante ricerca a destra
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Da implementare
            },
          ),
          // Pulsante preferiti a destra
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          // Pulsante watchlist a destra
          IconButton(
            icon: const Icon(Icons.bookmark),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WatchlistPage(),
                ),
              );
            },
          ),
        ],
        // Migliora fusione con sfondo aggiungendo un gradiente dark trasparente che cala verso il basso
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Il gradiente parte da nero quasi opaco sopra a trasparente sotto
              colors: [
                Color.fromRGBO(0, 0, 0, 0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: const HomeTab(),
    );
  }
}
