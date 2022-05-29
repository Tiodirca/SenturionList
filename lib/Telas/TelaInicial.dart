import 'package:flutter/material.dart';

import '../Widgets/WidgetConfigHoraEscala.dart';
import '../Uteis/Constantes.dart';
import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';
import '../Widgets/WidgetFundoTelas.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({Key? key}) : super(key: key);

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  bool exibirTelaInicial = true;
  bool mudarStatusBtnConfig = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaBarraStatus = MediaQuery.of(context).padding.top;
    double alturaAppBar = AppBar().preferredSize.height;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: PaletaCores.corAdtl,
          title: const Text(
            Constantes.telaIncial,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: Image.asset(
            'assets/imagens/logo.png',
          )),
      body: Stack(
        children: [
          const WidgetFundoTelas(alterarLargura: ""),
          SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(10),
                width: larguraTela,
                height: alturaTela - alturaAppBar - alturaBarraStatus,
                child: Column(
                  children: [
                    // Apartir daqui mudar
                    Container(
                        margin: const EdgeInsets.all(10),
                        //definindo largura
                        width: larguraTela,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton(
                              backgroundColor: PaletaCores.corAzul,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  if (mudarStatusBtnConfig) {
                                    return const Icon(Icons.settings);
                                  } else {
                                    return const Icon(Icons.close);
                                  }
                                },
                              ),
                              onPressed: () {
                                setState(() {
                                  if (mudarStatusBtnConfig) {
                                    exibirTelaInicial = false;
                                    mudarStatusBtnConfig = false;
                                  } else {
                                    exibirTelaInicial = true;
                                    mudarStatusBtnConfig = true;
                                  }
                                });
                              },
                            ),
                          ],
                        )),
                    LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      if (exibirTelaInicial) {
                        return Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              //definindo espaçamento interno do container
                              padding: const EdgeInsets.all(10),
                              //definindo largura
                              width: 300,
                              height: 100,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, Constantes.rotaSelecaoEscala);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: PaletaCores.corAdtl),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(Icons.list_alt_outlined,
                                          size: 30),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            Textos.btnListaEscalas,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            Textos.btnCadastrarItem,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        );
                      } else {
                        return const WidgetConfigHoraEscala();
                      }
                    })
                  ],
                )),
          )
        ],
      ),
    );
  }
}
