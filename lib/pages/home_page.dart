import 'dart:ffi';

import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_1/model/radio.dart';
import 'package:radio_1/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _selectedColor = AIColors.primaryColor1;
  bool _isPlaying = false;
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;

  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    fetchRadios();
    setupAlan();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
    });
  }

  Future<void> fetchRadios() async {
    final radioJson = await rootBundle.loadString('assets/radio.json');
    radios = await MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
  }

  _playMusic(String url) {
    _audioPlayer.play(UrlSource(url));
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    _isPlaying = true;
    print(radios);
    setState(() {});
  }

  void setupAlan() {
    AlanVoice.addButton(
        "55f0c45787863b3ed77d2cc156fa73652e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;
      case "play_channel":
        print(response);
        final id = response["id"];
        _audioPlayer.pause();
        print(id);
        print(
            "innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnknknnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
        MyRadio newRadio;
        newRadio = radios.firstWhere((element) => element.id == id);
        print(newRadio);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        _playMusic(newRadio.url);
        break;
      case "stop":
        _audioPlayer.stop();
        break;

      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;

        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;

        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);

        break;
      default:
        print("Command was ${response["comand"]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {});
    });
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(
                colors: [
                  AIColors.primaryColor2,
                  AIColors.primaryColor1,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
              .make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),
          // VxSwiper.builder(itemCount: radios.lenght, itemBuilder: itemBuilder)
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1.0,
                  onPageChanged: (index) {
                    var colhex = radios[index].color;
                    _selectedColor = Color(int.parse(colhex));
                  },
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final rad = radios[index];
                    return VxBox(
                            child: ZStack(
                      [
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: VxBox(
                                  child: rad.category.text.uppercase.white
                                      .make()
                                      .px16())
                              .height(40)
                              .black
                              .alignCenter
                              .withRounded(value: 10.0)
                              .make(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              rad.name.text.xl3.white.bold.make(),
                              5.heightBox,
                              rad.tagline.text.sm.white.semiBold.center.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: [
                            Icon(
                              CupertinoIcons.play_circle,
                              color: Colors.white,
                            ),
                            10.heightBox,
                            "Double tap to play".text.gray300.make(),
                          ].vStack(),
                        ),
                      ],
                      clip: Clip.antiAlias,
                    ))
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken),
                          ),
                        )
                        .withRounded(value: 60)
                        .border(color: Colors.black, width: 5.0)
                        .make()
                        .onDoubleTap(() {
                      _playMusic(rad.url);
                    }).p16();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),

          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing Now - ${_selectedRadio.name} FM"
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  _isPlaying = false;
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              }),
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
