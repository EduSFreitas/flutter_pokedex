import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/configs/colors.dart';
import 'package:pokedex/configs/images.dart';
import 'package:pokedex/core/extensions/context.dart';
import 'package:pokedex/domain/entities/pokemon.dart';

class PokemonBall extends StatelessWidget {
  const PokemonBall(this.pokemon);

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;
    final pokeballSize = screenHeight * 0.1;
    final pokemonSize = pokeballSize * 0.85;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image(
              image: AppImages.pokeball,
              width: pokeballSize,
              height: pokeballSize,
              color: AppColors.lightGrey,
            ),
            CachedNetworkImage(
              imageUrl: pokemon.image,
              imageBuilder: (_, image) => Image(
                image: image,
                width: pokemonSize,
                height: pokemonSize,
              ),
            )
          ],
        ),
        SizedBox(height: 3),
        Text(pokemon.name),
      ],
    );
  }
}

class PokemonEvolution extends StatefulWidget {
  final Animation animation;
  final Pokemon pokemon;

  const PokemonEvolution(this.pokemon, this.animation);

  @override
  _PokemonEvolutionState createState() => _PokemonEvolutionState();
}

class _PokemonEvolutionState extends State<PokemonEvolution> {
  Widget _buildRow({Pokemon current, Pokemon next, String reason}) {
    return Row(
      children: <Widget>[
        Expanded(child: PokemonBall(current)),
        Expanded(
          child: Column(
            children: <Widget>[
              Icon(Icons.arrow_forward, color: AppColors.lightGrey),
              SizedBox(height: 7),
              Text(
                reason,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(child: PokemonBall(next)),
      ],
    );
  }

  Widget _buildDivider() {
    return Column(
      children: <Widget>[
        SizedBox(height: 21),
        Divider(),
        SizedBox(height: 21),
      ],
    );
  }

  List<Widget> buildEvolutionList(List<Pokemon> pokemons) {
    if (pokemons.length < 2) {
      return [
        Center(child: Text('No evolution')),
      ];
    }

    return Iterable<int>.generate(pokemons.length - 1) // skip the last one
        .map(
          (index) => _buildRow(
            current: pokemons[index],
            next: pokemons[index + 1],
            reason: pokemons[index + 1].evolutionReason,
          ),
        )
        .expand((widget) => [widget, _buildDivider()])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Evolution Chain',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, height: 0.8),
          ),
          SizedBox(height: 28),
          ...buildEvolutionList(widget.pokemon.evolutions),
        ],
      ),
      builder: (context, child) {
        final scrollable = widget.animation.value.floor() == 1;

        return SingleChildScrollView(
          physics: scrollable
              ? BouncingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 31, horizontal: 28),
          child: child,
        );
      },
    );
  }
}
