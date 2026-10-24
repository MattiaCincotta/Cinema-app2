import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart'; // Import del provider lingua
import 'home_tab.dart';
import 'favorites_page.dart';
import 'watchlist_page.dart';
import 'search_page.dart';

// Import AuthService e LoginPage per gestire il logout
import 'package:cinema_app/data/auth_service.dart';
import 'login_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  void _showLanguageDialog(BuildContext context) {
    final currentLocale = context.read<LocaleProvider>().languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          context.read<LocaleProvider>().translate('change_language'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.white),
              title: const Text('it-IT', style: TextStyle(color: Colors.white)),
              trailing: currentLocale == 'it-IT'
                  ? const Icon(Icons.check, size: 18, color: Colors.redAccent)
                  : null,
              onTap: () {
                context.read<LocaleProvider>().changeLanguage('it-IT');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.white),
              title: const Text('en-US', style: TextStyle(color: Colors.white)),
              trailing: currentLocale == 'en-US'
                  ? const Icon(Icons.check, size: 18, color: Colors.redAccent)
                  : null,
              onTap: () {
                context.read<LocaleProvider>().changeLanguage('en-US');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.white),
              title: const Text('es-ES', style: TextStyle(color: Colors.white)),
              trailing: currentLocale == 'es-ES'
                  ? const Icon(Icons.check, size: 18, color: Colors.redAccent)
                  : null,
              onTap: () {
                context.read<LocaleProvider>().changeLanguage('es-ES');
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleProvider>().languageCode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        elevation: 0,
        titleSpacing: 0,
        // Titolo CineTrack stile minimale
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'CineTrack',
            style: TextStyle(
              fontSize: 20, // Riduci la dimensione del font
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.fade,
          ),
        ),
        actions: [
          AnimatedSearchBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                Ionicons.heartOutline,
                color: Colors.white.withValues(alpha: 0.9),
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
                color: Colors.white.withValues(alpha: 0.9),
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
              icon: const Icon(Icons.more_vert, color: Colors.white),
              offset: const Offset(0, 50),
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'language') {
                  _showLanguageDialog(context); // Mostra dialog di cambio lingua
                } else if (value == 'logout') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        context.read<LocaleProvider>().translate('logout'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        context.read<LocaleProvider>().translate('confirm_logout'),
                        style: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 15,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            context.read<LocaleProvider>().translate('cancel'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            // Richiama il metodo di disconnessione
                            await AuthService().logout();
                            // Ferma l esecuzione in caso di contesto chiuso
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (Route<dynamic> _) => false,
                            );
                          },
                          child: Text(
                            context.read<LocaleProvider>().translate('confirm'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'language',
                  child: Row(
                    children: [
                      const Icon(Icons.translate, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        context.read<LocaleProvider>().translate('language'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Text(
                        context.read<LocaleProvider>().translate('logout'),
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
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
              color: Colors.black.withValues(alpha: 0.4),
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
          color: _isHovered ? Colors.black.withValues(alpha: 0.9) : Colors.transparent,
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
                    color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.9),
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