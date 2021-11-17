import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pokedex/consts/consts_app.dart';
import 'package:pokedex/models/pokeapi.dart';
import 'package:pokedex/pages/about_pages/about_page.dart';
import 'package:pokedex/stores/pokeapi_store.dart';
import 'package:pokedex/stores/pokeapiv2_storie.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class PokeDetailPage extends StatefulWidget {
  final int index;

  PokeDetailPage({Key key, this.index}) : super(key: key);

  @override
  _PokeDetailPageState createState() => _PokeDetailPageState();
}

class _PokeDetailPageState extends State<PokeDetailPage> {
  PageController _pageController;
  PokeApiStore _pokemonStore;
  PokeApiV2Store _pokeApiV2Store;
  MultiTrackTween _animation;
  double _progress;
  double _multiple;
  double _opacity;
  double _opacityTitleAppBar;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 0.52);
    _pokemonStore = GetIt.instance<PokeApiStore>();
    _pokeApiV2Store = GetIt.instance<PokeApiV2Store>();
    _pokeApiV2Store.getInfoPokemon(_pokemonStore.pokemonAtual.name);
    _pokeApiV2Store.getInfoSpecie(_pokemonStore.pokemonAtual.id.toString());
    _animation = MultiTrackTween([
      Track("rotation").add(Duration(seconds: 5), Tween(begin: 0.0, end: 6.0),
          curve: Curves.linear)
    ]);
    _progress = 0;
    _multiple = 1;
    _opacity = 1;
    _opacityTitleAppBar = 0;
  }

  double interval(double lower, double upper, double progress) {
    assert(lower < upper);

    if (progress > upper) return 1.0;
    if (progress < lower) return 0.0;

    return ((progress - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _pokemonStore.corPokemon,
        child: Stack(
          children: <Widget>[
            Observer(
              builder: (context) {
                return AnimatedContainer(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        _pokemonStore.corPokemon.withOpacity(0.7),
                        _pokemonStore.corPokemon,
                      ])),
                  child: Stack(
                    children: [
                      AppBar(
                        centerTitle: true,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        actions: <Widget>[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ControlledAnimation(
                                        playback: Playback.LOOP,
                                        duration: _animation.duration,
                                        tween: _animation,
                                        builder: (context, animation) {
                                          return Transform.rotate(
                                            child: Opacity(
                                              child: Image.asset(
                                                ConstsApp.whitePokeball,
                                                height: 47,
                                                width: 47,
                                              ),
                                              opacity:
                                                  _opacityTitleAppBar >= 0.2
                                                      ? 0.2
                                                      : 0.0,
                                            ),
                                            angle: animation['rotation'],
                                          );
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.favorite_border),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.14 -
                            _progress *
                                (MediaQuery.of(context).size.height * 0.060),
                        left: 20 +
                            _progress *
                                (MediaQuery.of(context).size.height * 0.060),
                        child: Text(
                          _pokemonStore.pokemonAtual.name,
                          style: TextStyle(
                              fontFamily: 'Google',
                              fontSize: 34 -
                                  _progress *
                                      (MediaQuery.of(context).size.height *
                                          0.011),
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: (MediaQuery.of(context).size.height * 0.16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                setTipos(_pokemonStore.pokemonAtual.type),
                                Text(
                                  '#' +
                                      _pokemonStore.pokemonAtual.num.toString(),
                                  style: TextStyle(
                                      fontFamily: 'Google',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                );
              },
            ),
            SlidingSheet(
              listener: (state) {
                setState(() {
                  _progress = state.progress;
                  _multiple = 1 - interval(0.0, 0.87, _progress);
                  _opacity = _multiple;
                  _opacityTitleAppBar = interval(0.0, 0.87, _progress);
                });
              },
              elevation: 0,
              cornerRadius: 30,
              snapSpec: const SnapSpec(
                snap: true,
                snappings: [0.60, 0.87],
                positioning: SnapPositioning.relativeToAvailableSpace,
              ),
              builder: (context, state) {
                return Container(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height * 0.12,
                  child: AbautPage(),
                );
              },
            ),
            Opacity(
              opacity: _opacity,
              child: Padding(
                child: SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _pokemonStore.setPokemonAtual(index: index);
                      _pokeApiV2Store
                          .getInfoPokemon(_pokemonStore.pokemonAtual.name);
                      _pokeApiV2Store.getInfoSpecie(
                          _pokemonStore.pokemonAtual.id.toString());
                    },
                    itemCount: _pokemonStore.pokeAPI.pokemon.length,
                    itemBuilder: (BuildContext context, int index) {
                      Pokemon _pokeItem =
                          _pokemonStore.getPokemon(index: index);
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ControlledAnimation(
                              playback: Playback.LOOP,
                              duration: _animation.duration,
                              tween: _animation,
                              builder: (context, animation) {
                                return Transform.rotate(
                                  child: Hero(
                                      child: Opacity(
                                        child: Image.asset(
                                          ConstsApp.whitePokeball,
                                          height: 280,
                                          width: 280,
                                        ),
                                        opacity: 0.2,
                                      ),
                                      tag: '' //_pokeItem.name + 'roatation',
                                      ),
                                  angle: animation['rotation'],
                                );
                              }),
                          Observer(builder: (context) {
                            return AnimatedPadding(
                              child: Hero(
                                tag: index == _pokemonStore.posicaoAtual
                                    ? _pokeItem.name
                                    : 'none' + index.toString(),
                                child: CachedNetworkImage(
                                  height: 180,
                                  width: 180,
                                  placeholder: (context, url) => new Container(
                                    color: Colors.transparent,
                                  ),
                                  color: index == _pokemonStore.posicaoAtual
                                      ? null
                                      : Colors.black.withOpacity(0.5),
                                  imageUrl:
                                      'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_pokeItem.num}.png',
                                ),
                              ),
                              duration: Duration(milliseconds: 400),
                              curve: Curves.bounceInOut,
                              padding: EdgeInsets.all(
                                  index == _pokemonStore.posicaoAtual ? 0 : 60),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
                padding: EdgeInsets.only(
                    top: _opacityTitleAppBar == 1
                        ? 1000
                        : (MediaQuery.of(context).size.height * 0.25) -
                            _progress * 65),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget setTipos(List<String> types) {
    List<Widget> lista = [];
    types.forEach((nome) {
      lista.add(
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(80, 255, 255, 255)),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  nome.trim(),
                  style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            )
          ],
        ),
      );
    });
    return Row(
      children: lista,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
