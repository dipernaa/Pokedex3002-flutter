import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const double inchesInDecimeter = 3.93701;
const double poundsInHectograms = 0.220462;

String decimetersToFeetInches(int? decimeters) {
  if (decimeters == null) {
    return '';
  }

  final int inches = (decimeters * inchesInDecimeter).floor();
  final int feet = (inches / 12).floor();
  final int leftoverInches = inches - (feet * 12);

  final String feetMeasure = '${feet}ft';
  final String inchesMeasure = '${leftoverInches}in';

  return '$feetMeasure $inchesMeasure';
}

String hectogramsToPounds (int? hectograms) {
  if (hectograms == null) {
    return '';
  }

  return '${(hectograms * poundsInHectograms).floor()} lbs';
}

const String pokemonDetailsQuery = """
  query samplePokeAPIquery(\$pokemon_id: Int!) {
    pokemon_v2_pokemon(where: {id: {_eq: \$pokemon_id}}) {
      base_experience
      height
      id
      name
      weight
      pokemon_v2_pokemonabilities {
        pokemon_v2_ability {
          name
          id
        }
      }
      pokemon_v2_pokemonspecy {
        base_happiness
        capture_rate
        is_legendary
        is_mythical
        is_baby
        pokemon_v2_pokemonspeciesflavortexts(limit: 1, where: {flavor_text: {_is_null: false}}) {
          flavor_text
        }
      }
      pokemon_v2_pokemonstats {
        base_stat
        pokemon_v2_stat {
          name
        }
      }
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
""";

const colorByType = <String, Map<String, Color>>{
  'bug': {
    'main': Colors.lightGreen,
    'text': Colors.white,
  },
  'grass': {
    'main': Colors.green,
    'text': Colors.white,
  },
  'normal': {
    'main': Colors.orange,
    'text': Colors.black,
  },
  'electric': {
    'main': Colors.yellow,
    'text': Colors.black,
  },
  'flying': {
    'main': Colors.pink,
    'text': Colors.white,
  },
  'poison': {
    'main': Colors.purple,
    'text': Colors.white,
  },
  'fire': {
    'main': Colors.deepOrange,
    'text': Colors.white,
  },
  'fighting': {
    'main': Colors.teal,
    'text': Colors.white,
  },
  'rock': {
    'main': Colors.white12,
    'text': Colors.black,
  },
  'psychic': {
    'main': Colors.deepPurple,
    'text': Colors.white,
  },
  'dragon': {
    'main': Colors.redAccent,
    'text': Colors.white,
  },
  'steel': {
    'main': Colors.white24,
    'text': Colors.white,
  },
  'ground': {
    'main': Colors.brown,
    'text': Colors.white,
  },
  'water': {
    'main': Colors.blue,
    'text': Colors.white,
  },
};

class PokedexDetailScreenArguments {
  final int id;
  final String title;
  final List<String> types;

  PokedexDetailScreenArguments(this.id, this.title, this.types);
}

class PokedexDetailScreen extends StatelessWidget {
  const PokedexDetailScreen({Key? key}) : super(key: key);

  static const routeName = '/details';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PokedexDetailScreenArguments;

    final httpLink = HttpLink("https://beta.pokeapi.co/graphql/v1beta/");

    final client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );

    return GraphQLProvider(
      child: PokemonDetails(pokemonId: args.id, pokemonName: args.title, pokemonTypes: args.types),
      client: client,
    );
  }
}

class PokemonDetails extends StatelessWidget {
  final int pokemonId;
  final String pokemonName;
  final List<String> pokemonTypes;

  const PokemonDetails({Key? key, required this.pokemonId, required this.pokemonName, required this.pokemonTypes}) : super(key: key);

  @override
  Widget build(context) {
    Map<String, Color> mainColor = colorByType[pokemonTypes[0]] ?? colorByType['normal']!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor['main'],
        foregroundColor: mainColor['text'],
        title: Text(pokemonName)
      ),
      body: Query(
        options: QueryOptions(
          document: gql(pokemonDetailsQuery),
          variables: {
            'pokemon_id': pokemonId,
          },
        ),
        builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Text('Loading');
          }

          List? details = result.data?['pokemon_v2_pokemon'];

          if (details == null) {
            return const Text('No pokemon :(');
          }

          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Image(
                        image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                      ),
                      flex: 4,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            child: Row(
                              children: [
                                Text(pokemonId.toString()),
                                const SizedBox(width: 8),
                                Text(pokemonName),
                              ],
                            ),
                            padding: const EdgeInsets.all(4.0)
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: pokemonTypes.map((currentType) {
                              Map<String, Color>? typeColors = colorByType[currentType] ?? colorByType['normal']!;

                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: Padding(
                                    child: Text(
                                      currentType.toUpperCase(),
                                      style: TextStyle(
                                          color: typeColors['text']!,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(
                                              blurRadius: 2.0,
                                              color: Color.fromRGBO(153, 153, 153, 1.0),
                                              offset: Offset(2.0, 2.0),
                                            ),
                                          ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 2.0,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: const Border(
                                      bottom: BorderSide(width: 2.0, color: Colors.black),
                                      left: BorderSide(width: 2.0, color: Colors.black),
                                      right: BorderSide(width: 2.0, color: Colors.black),
                                      top: BorderSide(width: 2.0, color: Colors.black),
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                    color: typeColors['main'],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            child: Padding(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'HT',
                                        style: TextStyle(
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2.0,
                                              color: Color.fromRGBO(153, 153, 153, 1.0),
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        decimetersToFeetInches(details[0]['height']),
                                        style: const TextStyle(
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2.0,
                                              color: Color.fromRGBO(153, 153, 153, 1.0),
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'WT',
                                        style: TextStyle(
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2.0,
                                              color: Color.fromRGBO(153, 153, 153, 1.0),
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        hectogramsToPounds(details[0]['weight']),
                                        style: const TextStyle(
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2.0,
                                              color: Color.fromRGBO(153, 153, 153, 1.0),
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.only(
                                bottom: 2.0,
                                left: 8.0,
                                right: 2.0,
                                top: 2.0,
                              ),
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 2.0, color: Colors.black),
                                left: BorderSide(width: 2.0, color: Colors.black),
                                right: BorderSide(width: 2.0, color: Colors.black),
                                top: BorderSide(width: 2.0, color: Colors.black),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ],
                      ),
                      flex: 6,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child:
                      Container(
                        child: Container(
                          child: Padding(
                            child: Text(
                              details[0]['pokemon_v2_pokemonspecy']['pokemon_v2_pokemonspeciesflavortexts'][0]['flavor_text'].toString().replaceAll(RegExp(r'[\n\f]'), ' '),
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Color.fromRGBO(153, 153, 153, 1.0),
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 2.0, color: mainColor['main']!),
                              left: BorderSide(width: 8.0, color: mainColor['main']!),
                              right: BorderSide(width: 8.0, color: mainColor['main']!),
                              top: BorderSide(width: 2.0, color: mainColor['main']!),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 2.0, color: Colors.black),
                            left: BorderSide(width: 2.0, color: Colors.black),
                            right: BorderSide(width: 2.0, color: Colors.black),
                            top: BorderSide(width: 2.0, color: Colors.black),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
          );
        }
      ),
    );
  }
}