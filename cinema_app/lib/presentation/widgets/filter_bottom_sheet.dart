import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialGenre;
  final String? initialYear;
  final String? initialDirector;
  final double? initialRating;
  final Map<String, int> genres;

  final List<String>? years;

  const FilterBottomSheet({
    super.key,
    this.initialGenre,
    this.initialYear,
    this.initialDirector,
    this.initialRating,
    required this.genres,
    this.years,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedGenre;
  String? _selectedYear;
  double? _selectedRating;
  final TextEditingController _directorController = TextEditingController();

  late final List<String> _years;

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.initialGenre;
    _selectedYear = widget.initialYear;
    _selectedRating = widget.initialRating ?? 0.0;
    _directorController.text = widget.initialDirector ?? '';
    // Se non forniti, genera la lista degli anni - ultimi 30 anni
    _years = widget.years ??
        List<String>.generate(30, (i) => (DateTime.now().year - i).toString());
  }

  @override
  void dispose() {
    _directorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inizio UI bottom sheet filtro
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtra film',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Selettore Genere - usa le chiavi della mappa come etichetta
              DropdownButtonFormField<String>(
                initialValue: _selectedGenre,
                hint: const Text(
                  'Genere',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: InputDecoration(
                  labelText: 'Genere',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFF353548),
                ),
                dropdownColor: const Color(0xFF353548),
                items: widget.genres.keys
                    .toList()
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value;
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedYear,
                hint: const Text(
                  'Anno',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: InputDecoration(
                  labelText: 'Anno',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFF353548),
                ),
                dropdownColor: const Color(0xFF353548),
                items: _years.map((year) {
                  final value = year.toString();
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedYear = val;
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating minimo',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Slider(
                    value: _selectedRating ?? 0.0,
                    onChanged: (val) {
                      setState(() {
                        _selectedRating = val;
                      });
                    },
                    min: 0,
                    max: 10,
                    divisions: 20,
                    label: (_selectedRating ?? 0.0).toStringAsFixed(1),
                    activeColor: Colors.red,
                    inactiveColor: Colors.white24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _directorController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Regista',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFF353548),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white70,
                          width: 1.3,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Annulla',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final result = {
                          'genre': _selectedGenre,
                          'year': _selectedYear,
                          'rating': _selectedRating,
                          'director': _directorController.text.trim(),
                        };
                        Navigator.pop(context, result);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Applica',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    // Fine UI bottom sheet filtro
  }
}