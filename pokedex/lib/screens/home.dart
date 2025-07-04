import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon_details_screen.dart';
import 'dart:math';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: const Text("PokeDex"),
          actions: [
            IconButton(
              icon: const Icon(Icons.catching_pokemon, size: 42),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.red,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // All Pokémon Tab with Pokéball watermark background
            Stack(
              children: [
                // Pokéball watermark as background
                Positioned(
                  bottom: 32,
                  right: 32,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.08,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 220,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const _AllPokemonTab(),
              ],
            ),
            const _TypesTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        elevation: 8,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon, size: 30, color: Colors.white),
            label: 'Pokémon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, size: 28, color: Colors.white),
            label: 'Dex',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _AllPokemonTab extends StatefulWidget {
  const _AllPokemonTab();
  @override
  State<_AllPokemonTab> createState() => _AllPokemonTabState();
}

class _AllPokemonTabState extends State<_AllPokemonTab> {
  List<Map<String, dynamic>> allPokemon = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAllPokemon();
  }

  Future<void> fetchAllPokemon() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=200'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        final List<Map<String, dynamic>> pokemonList = [];
        for (var p in results) {
          final name = p['name'];
          final url = p['url'];
          final id = url.split('/')[url.split('/').length - 2];
          final spriteUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
          pokemonList.add({'name': name, 'id': id, 'sprite': spriteUrl});
        }
        setState(() {
          allPokemon = pokemonList;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load Pokémon';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allPokemon.length,
      itemBuilder: (context, index) {
        final p = allPokemon[index];
        return ColoredPokemonCard(
          pokemon: p,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetailsScreen(
                  name: p['name'],
                  spriteUrl: p['sprite'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TypesTab extends StatefulWidget {
  const _TypesTab();
  @override
  State<_TypesTab> createState() => _TypesTabState();
}

class _TypesTabState extends State<_TypesTab> {
  List<String> types = [];
  String? selectedType;
  List<Map<String, dynamic>> filteredPokemon = [];
  bool isLoadingTypes = true;
  bool isLoadingPokemon = false;
  String? errorTypes;
  String? errorPokemon;
  final TextEditingController _typeController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTypes();
  }

  Future<void> fetchTypes() async {
    setState(() {
      isLoadingTypes = true;
      errorTypes = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/type'),
      );
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

  Future<void> fetchPokemonByType(String type) async {
    setState(() {
      isLoadingPokemon = true;
      errorPokemon = null;
      filteredPokemon = [];
    });
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/type/$type'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List pokemonList = data['pokemon'];
        final List<Map<String, dynamic>> pokemons = [];
        for (var p in pokemonList) {
          final name = p['pokemon']['name'];
          final url = p['pokemon']['url'];
          final id = url.split('/')[url.split('/').length - 2];
          final spriteUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
          pokemons.add({'name': name, 'id': id, 'sprite': spriteUrl});
        }
        setState(() {
          filteredPokemon = pokemons;
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

  Future<void> fetchPokemonByName(String name) async {
    setState(() {
      isLoadingPokemon = true;
      errorPokemon = null;
      filteredPokemon = [];
    });
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/${name.toLowerCase()}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final id = data['id'].toString();
        final spriteUrl = data['sprites']['front_default'] ?? '';
        final typesList = (data['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();
        setState(() {
          filteredPokemon = [
            {
              'name': data['name'],
              'id': id,
              'sprite': spriteUrl,
              'types': typesList,
            },
          ];
          isLoadingPokemon = false;
        });
      } else {
        setState(() {
          errorPokemon = 'No Pokémon found with that name.';
          isLoadingPokemon = false;
        });
      }
    } catch (e) {
      setState(() {
        errorPokemon = 'No Pokémon found with that name.';
        isLoadingPokemon = false;
      });
    }
  }

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredPokemon = [];
        errorPokemon = null;
      });
      return;
    }
    if (types.contains(query.toLowerCase())) {
      await fetchPokemonByType(query.toLowerCase());
    } else {
      await fetchPokemonByName(query.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _typeController,
                onChanged: (value) {
                  searchQuery = value;
                },
                onSubmitted: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Enter Pokemon name or type',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _onSearch(_typeController.text);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: types
                    .take(8)
                    .map(
                      (type) => ActionChip(
                        label: Text(type.toUpperCase()),
                        shape: StadiumBorder(
                          side: BorderSide(color: Colors.red, width: 2),
                        ),
                        onPressed: () {
                          _typeController.text = type;
                          _onSearch(type);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        if (isLoadingPokemon)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        if (errorPokemon != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(errorPokemon!),
          ),
        if (!isLoadingPokemon &&
            errorPokemon == null &&
            filteredPokemon.isNotEmpty)
          Expanded(
            child: GridView.builder(
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
                return ColoredPokemonCard(
                  pokemon: p,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailsScreen(
                          name: p['name'],
                          spriteUrl: p['sprite'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

// Type color mapping (same as details screen)
const Map<String, List<Color>> typeColorMap = {
  'normal': [Color(0xFFA8A878), Color(0xFFC6C6A7)],
  'fire': [Color(0xFFF08030), Color(0xFFF5AC78)],
  'water': [Color(0xFF6890F0), Color(0xFF9DB7F5)],
  'electric': [Color(0xFFF8D030), Color(0xFFFAE078)],
  'grass': [Color(0xFF78C850), Color(0xFFA7DB8D)],
  'ice': [Color(0xFF98D8D8), Color(0xFFBCE6E6)],
  'fighting': [Color(0xFFC03028), Color(0xFFD67873)],
  'poison': [Color(0xFFA040A0), Color(0xFFC183C1)],
  'ground': [Color(0xFFE0C068), Color(0xFFEBD69D)],
  'flying': [Color(0xFFA890F0), Color(0xFFC6B7F5)],
  'psychic': [Color(0xFFF85888), Color(0xFFFA92B2)],
  'bug': [Color(0xFFA8B820), Color(0xFFC6D16E)],
  'rock': [Color(0xFFB8A038), Color(0xFFD1C17D)],
  'ghost': [Color(0xFF705898), Color(0xFFA292BC)],
  'dragon': [Color(0xFF7038F8), Color(0xFFA27DFA)],
  'dark': [Color(0xFF705848), Color(0xFFA29288)],
  'steel': [Color(0xFFB8B8D0), Color(0xFFD1D1E0)],
  'fairy': [Color(0xFFEE99AC), Color(0xFFF4BDC9)],
};

// In-memory cache for Pokémon types
final Map<String, String> _pokemonTypeCache = {};

class ColoredPokemonCard extends StatefulWidget {
  final Map<String, dynamic> pokemon;
  final void Function()? onTap;
  const ColoredPokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  State<ColoredPokemonCard> createState() => _ColoredPokemonCardState();
}

class _ColoredPokemonCardState extends State<ColoredPokemonCard>
    with SingleTickerProviderStateMixin {
  String? type;
  bool loading = true;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + Random().nextInt(200)),
    );
    _scaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    fetchType();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchType() async {
    final name = widget.pokemon['name'];
    if (_pokemonTypeCache.containsKey(name)) {
      setState(() {
        type = _pokemonTypeCache[name];
        loading = false;
      });
      _controller.forward();
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fetchedType = data['types'][0]['type']['name'];
        _pokemonTypeCache[name] = fetchedType;
        setState(() {
          type = fetchedType;
          loading = false;
        });
        _controller.forward();
      } else {
        setState(() {
          type = null;
          loading = false;
        });
        _controller.forward();
      }
    } catch (e) {
      setState(() {
        type = null;
        loading = false;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        typeColorMap[type] ?? [Colors.grey.shade200, Colors.grey.shade300];
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            height: 160,
            width: 140,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.red.shade100, width: 2),
              ),
              margin: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Image.network(
                        widget.pokemon['sprite'],
                        height: 54,
                        width: 54,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.catching_pokemon, size: 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.pokemon['name'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (type != null)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
