import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senturionlistv2/Widgets/WidgetCriarEscala.dart';
import 'package:senturionlistv2/Widgets/WidgetTelaCarregamento.dart';

import '../Modelo/MostrarTabelas.dart';
import '../Modelo/Observacoes.dart';
import '../Uteis/Constantes.dart';
import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';
import '../Widgets/WidgetFundoTelas.dart';
import '../uteis/Servicos/ServicosTabela.dart' as servicotabela;
import '../uteis/Servicos/ServicoObservacoes.dart' as servicoobservacao;

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
  late List<Observacoes> listaObservacao;

  //metodo para chamar o metodo do servico para recuperar as tabelas contidas no banco de dados
  chamarRecuperarTabelas() async {
    //chamando metodo e mudando o estado da variavel
    await servicotabela.ServicosTabela.recuperarTabelas().then((lista) {
      setState(() {
        //definindo que a variavel global vai receber o valor da variavel local
        tabela = lista;
        //removendo o item da lista que contem a palavra especificada
        lista.removeWhere((item) => item.tabelas == 'Observacoes');
        //verificando se a lista retornada nao e vazia
        if (lista.isNotEmpty) {
          //defindo nome para o item do dropDown
          nomeItemDrop = lista.first.tabelas;
        } else {
          nomeItemDrop = "";
        }
        statusTelaCarregamento = false;
        if (lista.isEmpty) {
          setState(() {
            exibirTelas = exibirTelas = Constantes.argErroRecuperarDados;
          });
        } else {
          exibirTelas = exibirTelas = Constantes.argVerListaInicial;
        }
      });
    });
  }

  //metodo para recuperar dados do banco de dados
  chamarRecuperarIDObservacao() async {
    await servicoobservacao.ServicoObservacoes.recuperarObservacoesPorTabela(
            tabelaSelecionada)
        .then((lista) {
      setState(() {
        //verificando se a lista retornada nao e vazia
        if (lista.isNotEmpty) {
          // removendo todos os item que nao contenham no campo especificado o nome da tabela
          lista.removeWhere((item) => item.nomeTabela != tabelaSelecionada);
          setState(() {
            idObservacao = lista
                .map((e) => e.id)
                .toString()
                .replaceAll(RegExp(r'[),(]'), '');
            statusTelaCarregamento = false;
          });
        }else{
          statusTelaCarregamento = false;
        }
      });
    });
  }

  //metodo pra chamar metodo do servico para deletar tabela do banco de dados
  chamarDeletarTabelas() async {
    setState(() {
      statusTelaCarregamento = true;
    });
    if(idObservacao.isNotEmpty){
      String retornoDeletarObservacao =
      await servicoobservacao.ServicoObservacoes.deletarObservacao(idObservacao, tabelaSelecionada);
      if (retornoDeletarObservacao == Constantes.retornoJsonSucesso) {
        final snackBarSucesso =
        SnackBar(content: Text(Textos.snackDeletarObservacao));
        ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
      }
    }
    String retornoMetodoDeletar =
       await servicotabela.ServicosTabela.deletarTabela(tabelaSelecionada);
    //verificando se o retorno foi igual ao esperado
    if (retornoMetodoDeletar == Constantes.retornoJsonSucesso) {
      //criando snack bar para exibir ao usuario
      final snackBarSucesso =
          SnackBar(content: Text(Textos.selecaoEscalasSnacKDeletar));
      ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
      //definindo um set state para mudar o estado
      setState(() {
        exibirConfirmacaoEscala = false;
        chamarRecuperarTabelas();
      });
    } else {
      //criando snack bar para exibir ao usuario
      final snackBarError = SnackBar(
          content: Text(
              'Não foi possivel deletar está escala: $retornoMetodoDeletar'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
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
                Row(
                  children: [
                    Text(
                      Textos.txtAlertExclusaoTab,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      tabelaSelecionada,
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
                chamarDeletarTabelas();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //sobre escrevendo o metodo init state
  @override
  void initState() {
    super.initState();
    //iniciando variavel
    tabela = [];
    // chamando metodo
    chamarRecuperarTabelas();
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
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            child: Text(
                              Textos.selecaoEscalasDes,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            child: Column(
                              children: [
                                Text(
                                  Textos.btnCriarEscala,
                                  textAlign: TextAlign.center,
                                ),
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
                              Text(Textos.selecaoEscalasDesDropDown),
                              DropdownButton(
                                value: nomeItemDrop,
                                icon: const Icon(Icons.list_alt_outlined),
                                items: tabela
                                    .map((item) => DropdownMenuItem<String>(
                                          child: Text(item.tabelas.replaceAll(RegExp(r'_'), ' ')),
                                          value: item.tabelas,
                                        ))
                                    .toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    nomeItemDrop = value!;
                                    tabelaSelecionada = value;
                                    exibirConfirmacaoEscala = true;
                                    statusTelaCarregamento = true;
                                    chamarRecuperarIDObservacao();
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
                                          const Text("Escala selecionada:"),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            tabelaSelecionada.replaceAll(RegExp(r'_'), ' '),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
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
                                heroTag: "fecharObservacao",
                                child: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    if (nomeItemDrop.isEmpty) {
                                      exibirTelas =
                                          Constantes.argErroRecuperarDados;
                                    } else {
                                      exibirTelas =
                                          Constantes.argVerListaInicial;
                                    }
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 350,
                            child: Text(
                              Textos.erroBuscaBanco,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
                                  heroTag: "adicionar",
                                  backgroundColor: Colors.green,
                                  child: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      exibirTelas =
                                          Constantes.argSelecaoEscalaCriar;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
                                  heroTag: "recarregar",
                                  backgroundColor: PaletaCores.corAdtlLetras,
                                  child: const Icon(Icons.refresh),
                                  onPressed: () {
                                    setState(() {
                                      statusTelaCarregamento = true;
                                    });
                                    chamarRecuperarTabelas();
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      );
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
