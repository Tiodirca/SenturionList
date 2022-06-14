import 'package:flutter/material.dart';
import 'package:senturionlistv2/Uteis/Constantes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Uteis/PaletaCores.dart';
import '../uteis/Textos.dart';

class WidgetConfigHoraEscala extends StatefulWidget {
  const WidgetConfigHoraEscala({Key? key}) : super(key: key);

  @override
  State<WidgetConfigHoraEscala> createState() => _WidgetConfigHoraEscalaState();
}

class _WidgetConfigHoraEscalaState extends State<WidgetConfigHoraEscala> {
  TimeOfDay? horario = const TimeOfDay(hour: 19, minute: 00);

  String primeiroHorarioSemana = "";
  String segundoHorarioSemana = "";
  String primeiroHFSemana = "";
  String segundoHFSemana = "";
  bool mudarTelaConfig = true;
  bool boolCultosExtras = false;
  bool boolTrocaHoraPregacao = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //chamando metodo
    recuperarHoraMudadoECultoExtra();
  }

  gravarDadosPadrao() async {
    //metodo para gravar informacoes padroes no share preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        Constantes.primeiroHSemana, Constantes.horarioInicialSemana);
    prefs.setString(Constantes.segundoHSemana, Constantes.horarioFinalSemana);
    prefs.setString(
        Constantes.primeiroHFSemana, Constantes.horarioInicialFSemana);
    prefs.setString(Constantes.segundoHFSemana, Constantes.horarioFinalFsemana);
    prefs.setBool(Constantes.trocaHoraPregacao, false);
    prefs.setBool(Constantes.cultosExtras, false);
    recuperarHoraMudadoECultoExtra();
  }

  //metodo para recuperar o horario gravado no share prefereces
  recuperarHoraMudadoECultoExtra() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //definindo que as variaveis vao receber o valor gravado no share
      primeiroHorarioSemana = prefs.getString(Constantes.primeiroHSemana) ?? '';
      boolTrocaHoraPregacao =
          prefs.getBool(Constantes.trocaHoraPregacao) ?? false;

      segundoHorarioSemana = prefs.getString(Constantes.segundoHSemana) ?? '';
      primeiroHFSemana = prefs.getString(Constantes.primeiroHFSemana) ?? '';
      segundoHFSemana = prefs.getString(Constantes.segundoHFSemana) ?? '';
      boolCultosExtras = prefs.getBool(Constantes.cultosExtras) ?? false;
    });
  }

  // metodo para mudar o horario
  //share preferences para salvar os horario em uma chave valor
  mudarHorario(String qualHoraMudar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //variavel que vai receber o novo horario
    TimeOfDay? novoHorario = await showTimePicker(
      context: context,
      initialTime: horario!,
      helpText: Textos.txtLegendaTimePicker,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.white,
              onPrimary: PaletaCores.corAdtlLetras,
              surface: PaletaCores.corAdtl,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (novoHorario != null) {
      setState(() {
        horario = novoHorario;
        prefs.setString('horaMudada', "sim");
        if (qualHoraMudar == Constantes.primeiroHSemana) {
          primeiroHorarioSemana = "${horario!.hour}:${horario!.minute}";
          prefs.setString(Constantes.primeiroHSemana, primeiroHorarioSemana);
        } else if (qualHoraMudar == Constantes.segundoHSemana) {
          segundoHorarioSemana = "${horario!.hour}:${horario!.minute}";
          prefs.setString(Constantes.segundoHSemana, segundoHorarioSemana);
        } else if (qualHoraMudar == Constantes.primeiroHFSemana) {
          primeiroHFSemana = "${horario!.hour}:${horario!.minute}";
          prefs.setString(Constantes.primeiroHFSemana, primeiroHFSemana);
        } else if (qualHoraMudar == Constantes.segundoHFSemana) {
          segundoHFSemana = "${horario!.hour}:${horario!.minute}";
          prefs.setString(Constantes.segundoHFSemana, segundoHFSemana);
        }
      });
    }
  }

  //metodo para recuperar se vai ter culto extras
  cultosExtras() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constantes.cultosExtras, boolCultosExtras);
  }

  //metodo para mudar status caso o radio button para troca na hora da pregacao
  //mudando valores quando ativado e quando desativado
  trocaHoraPregacao() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constantes.trocaHoraPregacao, boolTrocaHoraPregacao);
    if (boolTrocaHoraPregacao) {
      setState(() {
        segundoHFSemana = Textos.txtLegTrocaHoraPregacao;
        segundoHorarioSemana = Textos.txtLegTrocaHoraPregacao;
        prefs.setString(Constantes.segundoHSemana, segundoHorarioSemana);
        prefs.setString(Constantes.segundoHFSemana, segundoHFSemana);
      });
    } else {
      setState(() {
        segundoHFSemana = Constantes.horarioFinalFsemana;
        segundoHorarioSemana = Constantes.horarioFinalSemana;
        prefs.setString(Constantes.segundoHSemana, segundoHorarioSemana);
        prefs.setString(Constantes.segundoHFSemana, segundoHFSemana);
      });
    }
  }

  // widget responsavel por mostrar os horarios de troca configurados
  Widget selecaoHorario(double larguraTela, String legendaIndicadora,
          String horario, String estadoMudarHorario) =>
      SizedBox(
        width: larguraTela,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(legendaIndicadora),
            Text(horario),
            SizedBox(
              height: 40,
              width: 40,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  mudarHorario(estadoMudarHorario);
                },
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    return Card(
      elevation: 20,
      child: Container(
          padding: const EdgeInsets.all(5),
          width: larguraTela,
          height: alturaTela * 0.6,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Text(Textos.txtTrocarHoraDes,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17)),
                const SizedBox(
                  height: 10,
                ),

                Text(Textos.txtTrocarHoraSemana,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                // selecao HORARIO SEMANA
                selecaoHorario(larguraTela, Textos.txtTrocaPrimeiroHorario,
                    primeiroHorarioSemana, Constantes.primeiroHSemana),
                selecaoHorario(larguraTela, Textos.txtTrocaSegundoHorario,
                    segundoHorarioSemana, Constantes.segundoHSemana),
                Text(Textos.txtTrocarHoraFinalSemana,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                // selecao HORARIO FINAL DE SEMANA
                selecaoHorario(larguraTela, Textos.txtTrocaPrimeiroHorario,
                    primeiroHFSemana, Constantes.primeiroHFSemana),
                selecaoHorario(larguraTela, Textos.txtTrocaSegundoHorario,
                    segundoHFSemana, Constantes.segundoHFSemana),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(Textos.txtTrocaHoraPregacao,
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(
                      height: 20,
                      child: Switch(
                          value: boolTrocaHoraPregacao,
                          activeColor: PaletaCores.corAdtl,
                          onChanged: (bool valor) {
                            setState(() {
                              boolTrocaHoraPregacao = valor;
                              trocaHoraPregacao();
                            });
                          }),
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(Textos.txtTrocaCultoExtras,
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(
                      height: 20,
                      child: Switch(
                          value: boolCultosExtras,
                          activeColor: PaletaCores.corAdtl,
                          onChanged: (bool valor) {
                            setState(() {
                              boolCultosExtras = valor;
                              cultosExtras();
                            });
                          }),
                    ),
                    SizedBox(
                      width: larguraTela,
                      child: Column(
                        children: [
                          Text(Textos.txtLegTrocaResetarHorario,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.all(5),
                            height: 45,
                            width: 45,
                            child: FloatingActionButton(
                              heroTag: "resetarValores",
                              backgroundColor: PaletaCores.corAdtlLetras,
                              child: const Icon(Icons.update),
                              onPressed: () {
                                setState(() {
                                  gravarDadosPadrao();
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Text(Textos.txtDesenvolvedor,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(Textos.txtNomeDev,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16)),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
