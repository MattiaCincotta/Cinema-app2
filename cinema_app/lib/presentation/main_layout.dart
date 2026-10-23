import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart'; // Import del provider lingua
import 'home_tab.dart';
import 'favorites_page.dart';
import 'watchlist_page.dart';
import 'search_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleProvider>().languageCode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        titleSpacing: 0,
        // Titolo CineTrack stile minimale
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'CineTrack',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 22,
              letterSpacing: 8.0,
              fontFamily: 'Sans',
            ),
          ),
        ),
        actions: [
          AnimatedSearchBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                Ionicons.heartOutline,
                color: Colors.white.withOpacity(0.9),
                size: 22,
              ),
              iconSize: 22,
              tooltip: context.watch<LocaleProvider>().translate('favorites'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesPage()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                Ionicons.bookmarkOutline,
                color: Colors.white.withOpacity(0.9),
                size: 22,
              ),
              iconSize: 22,
              tooltip: context.watch<LocaleProvider>().translate('watchlist'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WatchlistPage(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton<String>(
              tooltip: context.watch<LocaleProvider>().translate('change_language'),
              icon: Icon(
                Ionicons.languageOutline,
                color: Colors.white.withOpacity(0.9),
                size: 22,
              ),
              onSelected: (value) {
                context.read<LocaleProvider>().changeLanguage(value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'it-IT',
                  child: Row(
                    children: [
                      Text('it-IT'),
                      if (currentLocale == 'it-IT')
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.check, size: 18, color: Colors.redAccent),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'en-US',
                  child: Row(
                    children: [
                      Text('en-US'),
                      if (currentLocale == 'en-US')
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.check, size: 18, color: Colors.redAccent),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'es-ES',
                  child: Row(
                    children: [
                      Text('es-ES'),
                      if (currentLocale == 'es-ES')
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.check, size: 18, color: Colors.redAccent),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
      ),
      body: HomeTab(languageCode: currentLocale),
    );
  }
}

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isHovered = false;
  final TextEditingController _controller = TextEditingController();
  String _lastQuery = '';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isHovered ? 250 : 48,
        height: 48,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.black.withOpacity(0.9) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: _isHovered
            ? Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    Ionicons.searchOutline,
                    color: Colors.white.withOpacity(0.9),
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: context.watch<LocaleProvider>().translate('search'),
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (value) {
                        final query = value.trim();
                        if (query.isNotEmpty && query != _lastQuery) {
                          _lastQuery = query;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchPage(initialQuery: query),
                            ),
                          );
                          _controller.clear();
                          setState(() {
                            _isHovered = false;
                          });
                        }
                      },
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Ionicons.searchOutline,
                      color: Colors.white.withOpacity(0.9),
                      size: 22,
                    ),
                    iconSize: 22,
                    splashRadius: 18,
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _isHovered = false;
                      });
                    },
                  ),
                ],
              )
            : Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Icon(
                      Ionicons.searchOutline,
                      color: Colors.white.withOpacity(0.9),
                      size: 22,
                    ),
                    iconSize: 22,
                    splashRadius: 22,
                    tooltip: context.watch<LocaleProvider>().translate('search'),
                    onPressed: () {
                      setState(() {
                        _isHovered = true;
                      });
                    },
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}