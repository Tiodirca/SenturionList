import 'package:flutter/material.dart';
import 'package:senturionlistv2/Uteis/Constantes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';
import '../Widgets/WidgetTelaCarregamento.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    gravarDadosPadrao();
    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context, "/");
    });
  }

  gravarDadosPadrao() async {
    //metodo para gravar informacoes padroes no share preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final horaMudada = prefs.getString('horaMudada') ?? '';
    if (horaMudada != "sim") {
      prefs.setString(Constantes.primeiroHSemana, Constantes.horarioInicialSemana);
      prefs.setString(Constantes.segundoHSemana, Constantes.horarioFinalSemana);
      prefs.setString(Constantes.primeiroHFSemana, Constantes.horarioInicialFSemana);
      prefs.setString(Constantes.segundoHFSemana, Constantes.horarioFinalFsemana);
    }
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    return Scaffold(
      //container geral da tela
      body: Container(
        color: PaletaCores.corAdtl,
        width: larguraTela,
        height: alturaTela,
        //Stack permite colocar um item sobre o outro
        child: Stack(
          children: [
            Positioned(
              child: Container(
                color: PaletaCores.corAzul,
                width: larguraTela,
                height: alturaTela * 0.5,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: larguraTela,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            alignment: AlignmentDirectional.center,
                            width: larguraTela * 0.9,
                            height: alturaTela * 0.4,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: larguraTela * 0.9,
                                  height: alturaTela * 0.2,
                                  child: Image.asset(
                                    'assets/imagens/logo.png',
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  Textos.txtNomeAplicativo,
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: PaletaCores.corAzul),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: larguraTela * 0.9,
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 20.0),
                          child: const Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: WidgetTelaCarregamento(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
