import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonDetailsScreen extends StatefulWidget {
  final String name;
  final String spriteUrl;
  const PokemonDetailsScreen({super.key, required this.name, required this.spriteUrl});

  @override
  State<PokemonDetailsScreen> createState() => _PokemonDetailsScreenState();
}

class _PokemonDetailsScreenState extends State<PokemonDetailsScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? details;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> evolutions = [];
  bool isLoadingEvolutions = false;
  bool showEvolutions = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _evolutionKey = GlobalKey();

  // Type colors mapping
  final Map<String, List<Color>> typeColors = {
    'normal': [const Color(0xFFA8A878), const Color(0xFFC6C6A7)],
    'fire': [const Color(0xFFF08030), const Color(0xFFF5AC78)],
    'water': [const Color(0xFF6890F0), const Color(0xFF9DB7F5)],
    'electric': [const Color(0xFFF8D030), const Color(0xFFFAE078)],
    'grass': [const Color(0xFF78C850), const Color(0xFFA7DB8D)],
    'ice': [const Color(0xFF98D8D8), const Color(0xFFBCE6E6)],
    'fighting': [const Color(0xFFC03028), const Color(0xFFD67873)],
    'poison': [const Color(0xFFA040A0), const Color(0xFFC183C1)],
    'ground': [const Color(0xFFE0C068), const Color(0xFFEBD69D)],
    'flying': [const Color(0xFFA890F0), const Color(0xFFC6B7F5)],
    'psychic': [const Color(0xFFF85888), const Color(0xFFFA92B2)],
    'bug': [const Color(0xFFA8B820), const Color(0xFFC6D16E)],
    'rock': [const Color(0xFFB8A038), const Color(0xFFD1C17D)],
    'ghost': [const Color(0xFF705898), const Color(0xFFA292BC)],
    'dragon': [const Color(0xFF7038F8), const Color(0xFFA27DFA)],
    'dark': [const Color(0xFF705848), const Color(0xFFA29288)],
    'steel': [const Color(0xFFB8B8D0), const Color(0xFFD1D1E0)],
    'fairy': [const Color(0xFFEE99AC), const Color(0xFFF4BDC9)],
  };

  final Map<String, IconData> statIcons = {
    'hp': Icons.favorite,
    'attack': Icons.flash_on,
    'defense': Icons.shield,
    'special-attack': Icons.auto_awesome,
    'special-defense': Icons.security,
    'speed': Icons.directions_run,
  };

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.name}'));
      if (response.statusCode == 200) {
        setState(() {
          details = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load details';
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

  Future<void> toggleEvolutionChain() async {
    if (showEvolutions) {
      setState(() {
        showEvolutions = false;
        evolutions = [];
      });
      return;
    }

    if (details == null) return;
    setState(() {
      isLoadingEvolutions = true;
    });
    try {
      final speciesUrl = details!['species']['url'];
      final speciesResponse = await http.get(Uri.parse(speciesUrl));
      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);
        final evolutionChainUrl = speciesData['evolution_chain']['url'];
        final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
        if (evolutionResponse.statusCode == 200) {
          final evolutionData = json.decode(evolutionResponse.body);
          final chain = evolutionData['chain'];
          final evolutionList = _extractEvolutions(chain);
          setState(() {
            evolutions = evolutionList;
            showEvolutions = true;
            isLoadingEvolutions = false;
          });
          // Scroll to evolution section after frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_evolutionKey.currentContext != null) {
              Scrollable.ensureVisible(
                _evolutionKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoadingEvolutions = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading evolutions: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _extractEvolutions(Map<String, dynamic> chain) {
    final List<Map<String, dynamic>> evolutions = [];
    final currentName = chain['species']['name'];
    
    if (currentName != widget.name) {
      evolutions.add({
        'name': currentName,
        'sprite': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_getPokemonId(chain['species']['url'])}.png',
      });
    }
    
    if (chain['evolves_to'] != null && chain['evolves_to'].isNotEmpty) {
      for (var evolution in chain['evolves_to']) {
        final evolutionName = evolution['species']['name'];
        if (evolutionName != widget.name) {
          evolutions.add({
            'name': evolutionName,
            'sprite': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_getPokemonId(evolution['species']['url'])}.png',
          });
        }
        if (evolution['evolves_to'] != null && evolution['evolves_to'].isNotEmpty) {
          for (var nextEvolution in evolution['evolves_to']) {
            final nextEvolutionName = nextEvolution['species']['name'];
            if (nextEvolutionName != widget.name) {
              evolutions.add({
                'name': nextEvolutionName,
                'sprite': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_getPokemonId(nextEvolution['species']['url'])}.png',
              });
            }
          }
        }
      }
    }
    
    return evolutions;
  }

  String _getPokemonId(String url) {
    return url.split('/')[url.split('/').length - 2];
  }

  List<Color> _getTypeColors() {
    if (details == null || details!["types"] == null || details!["types"].isEmpty) {
      return [Colors.grey.shade300, Colors.grey.shade400];
    }
    final primaryType = details!["types"][0]["type"]["name"];
    return typeColors[primaryType] ?? [Colors.grey.shade300, Colors.grey.shade400];
  }

  Widget buildStatBar(String statName, int value, Color color) {
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final Animation<double> animation = Tween<double>(begin: 0, end: value / 200.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    controller.forward();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(statIcons[statName.toLowerCase()] ?? Icons.bar_chart, color: color, size: 22),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              statName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Container(
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: animation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.name.toUpperCase())),
        body: Center(child: Text(error!)),
      );
    }
    if (details == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.name.toUpperCase())),
        body: const Center(child: Text('No details found')),
      );
    }

    final typeColors = _getTypeColors();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: typeColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pokémon Card
                Container(
                  margin: const EdgeInsets.only(top: 12), // Slightly reduced
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with ID
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: typeColors[0].withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${details!["id"]}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: typeColors[0],
                              ),
                            ),
                            if (details!["types"] != null)
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (var t in details!["types"])
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: typeColors[0],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        t["type"]["name"].toString().toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      
                      // Pokémon Image (larger)
                      Container(
                        padding: const EdgeInsets.only(top: 20, bottom: 4),
                        child: Image.network(
                          widget.spriteUrl,
                          height: 220,
                          width: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.catching_pokemon,
                            size: 120,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats Section
                      if (details!["stats"] != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Base Stats',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...details!["stats"].map<Widget>((s) => buildStatBar(
                                    s["stat"]["name"],
                                    s["base_stat"],
                                    typeColors[0],
                                  )),
                            ],
                          ),
                        ),
                      
                      // Abilities Section
                      if (details!["abilities"] != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Abilities',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (var a in details!["abilities"])
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        a["ability"]["name"].toString().toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      // Evolution Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: toggleEvolutionChain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: typeColors[0],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          icon: Icon(showEvolutions ? Icons.keyboard_arrow_up : Icons.trending_up),
                          label: Text(showEvolutions ? 'Hide Evolutions' : 'Show Evolutions'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Evolution Section (margin always outside the card)
                if (isLoadingEvolutions)
                  Container(
                    key: _evolutionKey,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                
                if (showEvolutions && !isLoadingEvolutions)
                  Container(
                    key: _evolutionKey,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: typeColors[0].withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Evolution Chain',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (evolutions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No evolutions found'),
                          )
                        else
                          ...evolutions.map((evolution) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  leading: Image.network(
                                    evolution['sprite'],
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.catching_pokemon),
                                  ),
                                  title: Text(
                                    evolution['name'].toString().toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, color: typeColors[0]),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PokemonDetailsScreen(
                                          name: evolution['name'],
                                          spriteUrl: evolution['sprite'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 