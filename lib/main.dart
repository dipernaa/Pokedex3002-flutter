import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pokedex3002/pokedex_detail_screen.dart';
import 'package:pokedex3002/extensions/string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink("https://beta.pokeapi.co/graphql/v1beta/");

    final client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );

    return GraphQLProvider(
      child: MaterialApp(
        home: const PokedexHome(),
        routes: {
          PokedexDetailScreen.routeName: (context) => const PokedexDetailScreen(),
        },
        title: 'Pokedex 3002',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
      ),
      client: client,
    );
  }
}

const String gen1PokemonQuery = """
  query samplePokeAPIquery {
    pokemon_v2_pokemon(order_by: {id: asc}, where: {pokemon_v2_pokemonspecy: {generation_id: {_eq: 1}}, is_default: {_eq: true}}) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
""";

class PokedexHome extends StatelessWidget {
  const PokedexHome({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex 3002'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(gen1PokemonQuery),
        ),
        builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Text('Loading');
          }

          List? pokedex = result.data?['pokemon_v2_pokemon'];

          if (pokedex == null) {
            return const Text('No pokemon :(');
          }

          return ListView.builder(
            itemCount: pokedex.length,
            itemBuilder: (context, index) {
              final currentPokemon = pokedex[index];
              String capitalizedName = currentPokemon['name'].toString().capitalize();
              final pokemonTypes = currentPokemon['pokemon_v2_pokemontypes'].map<String>((currentType) => (
                currentType['pokemon_v2_type']['name'].toString()
              )).toList();

              return ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    PokedexDetailScreen.routeName,
                    arguments: PokedexDetailScreenArguments(currentPokemon['id'], capitalizedName, pokemonTypes)
                  );
                },
                // option 1
                title: Row(
                  children: [
                    Text(currentPokemon['id'].toString()),
                    Text(capitalizedName),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              );
            },
          );
        },
      )
    );
  }
}