import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senturionlistv2/Modelo/TabelaModelo.dart';
import 'package:senturionlistv2/Widgets/WidgetCriarEscala.dart';
import 'package:senturionlistv2/Widgets/WidgetTelaCarregamento.dart';

import '../Modelo/MostrarTabelas.dart';
import '../Modelo/Observacoes.dart';
import '../Uteis/Constantes.dart';
import '../Uteis/PaletaCores.dart';
import '../Uteis/Servicos/banco_de_dados.dart';
import '../Uteis/Textos.dart';
import '../Widgets/WidgetFundoTelas.dart';

class TelaSelecaoEscalas extends StatefulWidget {
  const TelaSelecaoEscalas({Key? key}) : super(key: key);

  @override
  State<TelaSelecaoEscalas> createState() => _TelaSelecaoEscalasState();
}

class _TelaSelecaoEscalasState extends State<TelaSelecaoEscalas> {
  bool statusTelaCarregamento = true;
  bool exibirConfirmacaoEscala = false;
  String exibirTelas = Constantes.argVerListaInicial;
  String nomeItemDrop = "";
  String tabelaSelecionada = "";
  String observacao = "";
  String idObservacao = "";
  late List<MostrarTabelas> tabela;
  late List<TabelaModelo> tabelaLocal;
  var nomeTabelas;
  late List<Observacoes> listaObservacao;

  // referencia nossa classe para gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;

  //metodo para chamar o metodo do servico para
  // recuperar as tabelas contidas no banco de dados
  chamarRecuperarTabelasLocais() async {
    final tabelas = await bancoDados.consultaTabela(); //fazendo consulta
    setState(() {
      exibirTelas = Constantes.argVerListaInicial;
      statusTelaCarregamento = false;
    });
    //pegando os elementos e adicionando em outra tabela para manipulacao
    for (var linha in tabelas) {
      nomeTabelas = linha['name'];
      nomeItemDrop = nomeTabelas;
      tabelaLocal.add(TabelaModelo(nomeTabela: nomeTabelas));
    }
    //removendo primeiro index contem valor desnecessario
    tabelaLocal.removeAt(0);
  }

  //sobre escrevendo o metodo init state
  @override
  void initState() {
    super.initState();
    //iniciando variavel
    tabela = [];
    tabelaLocal = [];
    // chamando metodo
    chamarRecuperarTabelasLocais();
  }

  Future<void> alertExclusao() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Textos.txtAlertExclusao),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Textos.txtAlertExclusaoDes),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [
                    Text(
                      Textos.txtAlertExclusaoTab,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      tabelaSelecionada.replaceAll(RegExp(r'_'), ' '),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Não',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Sim',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                bancoDados.excluirTabela(tabelaSelecionada);
                Navigator.of(context).pop();
                setState(() {
                  statusTelaCarregamento = true;
                  chamarRecuperarTabelasLocais();
                  final snackBarSucesso =
                      SnackBar(content: Text(Textos.snackSucesso));
                  ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
                  nomeItemDrop = "";
                  tabelaLocal = [];
                  exibirConfirmacaoEscala = false;
                });
              },
            ),
          ],
        );
      },
    );
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
            Constantes.telaSelecaoEscala,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              //setando tamanho do icone
              iconSize: 30,
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/");
              },
              icon: const Icon(Icons.arrow_back_ios))),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (!statusTelaCarregamento) {
          return Stack(
            children: [
              const WidgetFundoTelas(alterarLargura: ""),
              SingleChildScrollView(
                child: SizedBox(
                  width: larguraTela,
                  height: alturaTela - alturaBarraStatus - alturaAppBar,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    if (exibirTelas == Constantes.argVerListaInicial) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Text(Textos.selecaoEscalasDes,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                )),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            child: Column(
                              children: [
                                Text(Textos.btnCriarEscala,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    )),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  height: 50,
                                  width: 50,
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.green,
                                    child: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        exibirTelas =
                                            Constantes.argSelecaoEscalaCriar;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Text(Textos.selecaoEscalasDesDropDown,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  )),
                              DropdownButton(
                                value:
                                    nomeItemDrop,
                                icon: const Icon(Icons.list_alt_outlined),
                                items: tabelaLocal
                                    .map((item) => DropdownMenuItem<String>(
                                          child: Text(item.nomeTabela.replaceAll(RegExp(r'_'), ' ')),
                                          value: item.nomeTabela,
                                        ))
                                    .toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    nomeItemDrop = value!;
                                    tabelaSelecionada = value;
                                    exibirConfirmacaoEscala = true;
                                    //statusTelaCarregamento = true;
                                    //chamarRecuperarIDObservacao();
                                  });
                                },
                              ),
                              Visibility(
                                  visible: exibirConfirmacaoEscala,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Escala selecionada:",
                                              style: TextStyle(
                                                fontSize: 16,
                                              )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            tabelaSelecionada.replaceAll(
                                                RegExp(r'_'), ' '),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              height: 60,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pushReplacementNamed(
                                                        context,
                                                        Constantes.rotaVerLista,
                                                        arguments:
                                                            tabelaSelecionada);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary:
                                                              Colors.green),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: const [
                                                      Icon(
                                                          Icons
                                                              .list_alt_outlined,
                                                          size: 30),
                                                      Text(
                                                        "Usar está Escala",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            const SizedBox(
                                              width: 50,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              height: 50,
                                              width: 50,
                                              child: FloatingActionButton(
                                                heroTag: "deletar",
                                                backgroundColor: Colors.red,
                                                child: const Icon(Icons
                                                    .delete_forever_outlined),
                                                onPressed: () {
                                                  alertExclusao();
                                                },
                                              ),
                                            )
                                          ]),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      );
                    } else if (exibirTelas ==
                        Constantes.argSelecaoEscalaCriar) {
                      return Container(
                        margin: const EdgeInsets.only(
                            left: 0.0, top: 10.0, right: 0.0, bottom: 0.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: FloatingActionButton(
                                backgroundColor: Colors.red,
                                heroTag: "fecharCriacaoTabela",
                                child: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    exibirTelas = Constantes.argVerListaInicial;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: larguraTela,
                              padding: const EdgeInsets.all(10),
                              child: const WidgetCriarEscala(),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                ),
              )
            ],
          );
        } else {
          return SizedBox(
            height: alturaTela - alturaBarraStatus - alturaAppBar,
            child: const WidgetTelaCarregamento(),
          );
        }
      }),
    );
  }
}
