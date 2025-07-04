import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonGridScreen extends StatefulWidget {
  const PokemonGridScreen({super.key});

  @override
  State<PokemonGridScreen> createState() => _PokemonGridScreenState();
}

class _PokemonGridScreenState extends State<PokemonGridScreen> {
  List<String> types = [];
  String? selectedType;
  bool isLoadingTypes = true;
  String? errorTypes;

  List<Map<String, dynamic>> allPokemon = [];
  List<Map<String, dynamic>> filteredPokemon = [];
  bool isLoadingPokemon = true;
  String? errorPokemon;

  @override
  void initState() {
    super.initState();
    fetchTypes();
    fetchAllPokemon();
  }

  Future<void> fetchTypes() async {
    setState(() {
      isLoadingTypes = true;
      errorTypes = null;
    });
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        setState(() {
          types = results.map<String>((t) => t['name'] as String).toList();
          isLoadingTypes = false;
        });
      } else {
        setState(() {
          errorTypes = 'Failed to load types';
          isLoadingTypes = false;
        });
      }
    } catch (e) {
      setState(() {
        errorTypes = 'Error: $e';
        isLoadingTypes = false;
      });
    }
  }

  Future<void> fetchAllPokemon() async {
    setState(() {
      isLoadingPokemon = true;
      errorPokemon = null;
    });
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=200'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        final List<Map<String, dynamic>> pokemonList = [];
        for (var p in results) {
          final name = p['name'];
          final url = p['url'];
          final id = url.split('/')[url.split('/').length - 2];
          final spriteUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
          pokemonList.add({'name': name, 'id': id, 'sprite': spriteUrl});
        }
        setState(() {
          allPokemon = pokemonList;
          filteredPokemon = pokemonList;
          isLoadingPokemon = false;
        });
      } else {
        setState(() {
          errorPokemon = 'Failed to load Pokémon';
          isLoadingPokemon = false;
        });
      }
    } catch (e) {
      setState(() {
        errorPokemon = 'Error: $e';
        isLoadingPokemon = false;
      });
    }
  }

  Future<void> filterByType(String? type) async {
    if (type == null) {
      setState(() {
        filteredPokemon = allPokemon;
        selectedType = null;
      });
      return;
    }
    setState(() {
      isLoadingPokemon = true;
      selectedType = type;
    });
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type/$type'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List pokemonList = data['pokemon'];
        final Set<String> names = pokemonList.map<String>((p) => p['pokemon']['name'] as String).toSet();
        final filtered = allPokemon.where((p) => names.contains(p['name'])).toList();
        setState(() {
          filteredPokemon = filtered;
          isLoadingPokemon = false;
        });
      } else {
        setState(() {
          errorPokemon = 'Failed to filter Pokémon';
          isLoadingPokemon = false;
        });
      }
    } catch (e) {
      setState(() {
        errorPokemon = 'Error: $e';
        isLoadingPokemon = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Grid (Filter by Type)')),
      body: Column(
        children: [
          if (isLoadingTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else if (errorTypes != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(errorTypes!),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: selectedType == null,
                    onSelected: (_) => filterByType(null),
                  ),
                  ...types.map((type) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(type.toUpperCase()),
                          selected: selectedType == type,
                          onSelected: (_) => filterByType(type),
                        ),
                      )),
                ],
              ),
            ),
          Expanded(
            child: isLoadingPokemon
                ? const Center(child: CircularProgressIndicator())
                : errorPokemon != null
                    ? Center(child: Text(errorPokemon!))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredPokemon.length,
                        itemBuilder: (context, index) {
                          final p = filteredPokemon[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  p['sprite'],
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.catching_pokemon, size: 48),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p['name'].toString().toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 