import 'package:flutter/material.dart';
import 'package:senturionlistv2/Modelo/Observacoes.dart';
import 'package:senturionlistv2/Widgets/WidgetGerarPDF.dart';

import '../Modelo/ListaModelo.dart';
import '../Uteis/Constantes.dart';
import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';
import '../Widgets/WidgetFundoTelas.dart';

import 'package:intl/intl.dart';
import '../Widgets/WidgetTelaCarregamento.dart';
import '../uteis/Servicos/ServicosItens.dart' as servicoitem;
import '../uteis/Servicos/ServicoObservacoes.dart' as servicoobservacoes;

class TelaListagem extends StatefulWidget {
  final String nomeTabela;

  const TelaListagem({Key? key, required this.nomeTabela}) : super(key: key);

  @override
  State<TelaListagem> createState() => _TelaListagemState(nomeTabela);
}

class _TelaListagemState extends State<TelaListagem> {
  String tabela = "";

  _TelaListagemState(this.tabela);

  bool statusObservacao = false;
  bool textFieldObservacao = false;
  String exibirTelas = Constantes.argTelaCarregamento;
  late List<ListaModelo> _listaModelo;
  late List<Observacoes> listaObservacao;
  String observacao = "";
  String nomeBotao = "";
  String idObservacao = "";
  final TextEditingController _controllerObservacaoTabela =
      TextEditingController(text: "");

  //variavel usada para validar o formulario
  final chaveObservacao = GlobalKey<FormState>();

  //sobre escrevendo o metodo init state
  @override
  void initState() {
    super.initState();
    //iniciando variaveis
    _listaModelo = [];
    listaObservacao = [];
    // chamando metodo
    chamarRecuperarDados();
  }

  chamarRecuperarDados() async {
    await servicoitem.ServicosItens.recuperarItens(tabela).then((lista) {
      setState(() {
        if (lista.isEmpty) {
          exibirTelas = Constantes.argTelaListaVazia;
        } else {
          chamarRecuperarObservacao();
          lista.sort((a, b) => DateFormat("dd/MM/yyyy EEEE", "pt_BR")
              .parse(a.dataSemana)
              .compareTo(
                  DateFormat("dd/MM/yyyy EEEE", "pt_BR").parse(b.dataSemana)));
          _listaModelo = lista;
        }
      });
    });
  }

  chamarDeletar(ListaModelo listaModelo) {
    servicoitem.ServicosItens.deletar(listaModelo.id, tabela).then((result) {
      if ('sucesso' == result) {
        const snackBarSucesso =
            SnackBar(content: Text('Item apagado com sucesso.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
        //chamando metodo
        chamarRecuperarDados();
      }
    });
  }

//metodo para recuperar dados do banco de dados
  chamarRecuperarObservacao() async {
    await servicoobservacoes.ServicoObservacoes.recuperarObservacoesPorTabela(tabela)
        .then((lista) {
      setState(() {
        //verificando se a lista retornada nao e vazia
        if (lista.isNotEmpty) {
          listaObservacao = lista;
          // removendo todos os item que nao contenham no campo especificado o nome da tabela
          lista.removeWhere((item) => item.nomeTabela != tabela);
          setState(() {
            exibirTelas = Constantes.argVerListaInicial;
            observacao = lista
                .map((e) => e.observacaoTabela)
                .toString()
                .replaceAll(RegExp(r'[),(]'), '');
            idObservacao = lista
                .map((e) => e.id)
                .toString()
                .replaceAll(RegExp(r'[),(]'), '');
          });
        } else {
          setState(() {
            if (_listaModelo.isNotEmpty) {
              statusObservacao = false;
            }
            exibirTelas = Constantes.argVerListaInicial;
          });
        }
      });
    });
    if (observacao.isEmpty) {
      setState(() {
        statusObservacao = false;
        nomeBotao = Textos.btnAdicionarObservacao;
      });
    } else {
      setState(() {
        nomeBotao = Textos.btnAtualizarObservacao;
        statusObservacao = true;
      });
    }
  }

  chamarAtualizarObservacao() async {
    String observacaoAtualizar = _controllerObservacaoTabela.text;
    print("D:" + idObservacao + "T:" + tabela);
    String retornoMetodo = await servicoobservacoes.ServicoObservacoes.atualizarObservacao(
        idObservacao, observacaoAtualizar, tabela);
    print(retornoMetodo);
    if (retornoMetodo == Constantes.retornoJsonSucesso) {
      Navigator.pushReplacementNamed(context, Constantes.rotaVerLista, arguments: tabela);
    } else {
      final snackBarError = SnackBar(
          content: Text('Não foi possivel atualizar os dados: $retornoMetodo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
  }

  chamarAdicionarObservacao() async {
    String observacao = _controllerObservacaoTabela.text;
    //definindo que a variavel vai receber o retorno do metodo
    String retornoMetodo =
        await servicoobservacoes.ServicoObservacoes.adicionarObservacao(observacao, tabela);
    //verificando se o retorno foi igual ao esperado
    if (retornoMetodo == Constantes.retornoJsonSucesso) {
      //criando snack bar para exibir ao usuario
      final snackBarSucesso = SnackBar(content: Text(Textos.snackSucesso));
      ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
      Navigator.pushReplacementNamed(context, Constantes.rotaVerLista, arguments: tabela);
    } else {
      setState(() {
        exibirTelas = Constantes.argVerListaInicial;
      });
      //instanciando variavel que vai receber o retorno do metodo
      final snackBarError = SnackBar(
          content: Text('Não foi possivel criar a escala: $retornoMetodo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
  }

  Future<void> alertaExclusao(ListaModelo listaModelo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Textos.txtAlertExclusao,
            style: const TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Textos.txtAlertExclusaoDesItem,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [
                    Text(
                      Textos.txtAlertExclusaoItem,
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      listaModelo.dataSemana,
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
                setState(() {
                  exibirTelas = Constantes.argTelaCarregamento;
                });
                chamarDeletar(listaModelo);
                Navigator.of(context).pop();
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

    mudarAltura(double altura) {
      if (altura <= 700) {
        alturaTela + alturaAppBar;
      } else {
        if (statusObservacao == false) {
          altura = altura - alturaAppBar - alturaBarraStatus;
          return altura;
        } else if (textFieldObservacao == true) {
          altura = altura + alturaAppBar;
          return altura;
        } else {
          return altura;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: PaletaCores.corAdtl,
          title: const Text(
            Constantes.telaListagemItens,
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
        if (exibirTelas == Constantes.argVerListaInicial) {
          return Stack(
            children: [
              const WidgetFundoTelas(
                  alterarLargura: Constantes.telaListagemItens),
              SingleChildScrollView(
                child: SizedBox(
                  width: larguraTela,
                  height: mudarAltura(alturaTela),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 20.0),
                        width: larguraTela,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(Textos.txtEscalaSelecionada),
                            Text(
                              tabela.replaceAll(RegExp(r'_'), ' '),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(left: 0.0,top: 0.0,right: 10.0,bottom: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              height: 50,
                              width: 50,
                              child: FloatingActionButton(
                                heroTag: "recarregarListaNormal",
                                backgroundColor: Colors.green,
                                child: const Icon(Icons.refresh),
                                onPressed: () {
                                  chamarRecuperarDados();
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              height: 50,
                              width: 50,
                              child: FloatingActionButton(
                                heroTag: "adicionarItem",
                                backgroundColor: Colors.green,
                                child: const Icon(Icons.add),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, Constantes.rotaCadastrar,
                                      arguments: tabela);
                                },
                              ),
                            ),

                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                        height: alturaTela * 0.5,
                        child: ListView(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 10,
                                columns: [
                                  DataColumn(
                                      label: Text(Textos.labelData,
                                          textAlign: TextAlign.center)),
                                  DataColumn(
                                    label: Text(Textos.labelHoraTroca,
                                        textAlign: TextAlign.center),
                                  ),
                                  DataColumn(
                                      label: Text(Textos.labelPrimeiraHora,
                                          textAlign: TextAlign.center)),
                                  DataColumn(
                                    label: Text(Textos.labelSegundaHora,
                                        textAlign: TextAlign.center),
                                  ),
                                  DataColumn(
                                      label: Text(
                                          Textos.labelPrimeiraHoraPulpito,
                                          textAlign: TextAlign.center)),
                                  DataColumn(
                                    label: Text(Textos.labelSegundaHoraPulpito,
                                        textAlign: TextAlign.center),
                                  ),
                                  DataColumn(
                                      label: Text(Textos.labelMesaApoio,
                                          textAlign: TextAlign.center)),
                                  DataColumn(
                                    label: Text(Textos.labelUniforme,
                                        textAlign: TextAlign.center),
                                  ),
                                  DataColumn(
                                    label: Text(Textos.labelRecolherOferta,
                                        textAlign: TextAlign.center),
                                  ),
                                  DataColumn(
                                    label: Text(Textos.labelServirCeia,
                                        textAlign: TextAlign.center),
                                  ),
                                  DataColumn(
                                    label: Text(Textos.labelIrmaoReserva,
                                        textAlign: TextAlign.center),
                                  ),
                                  const DataColumn(
                                    label: Text('Editar',
                                        textAlign: TextAlign.center),
                                  ),
                                  const DataColumn(
                                    label: Text('Deletar',
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                                rows: _listaModelo
                                    .map(
                                      (item) => DataRow(cells: [
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.dataSemana,
                                                textAlign: TextAlign.center))),
                                        DataCell(Container(
                                            alignment: Alignment.center,
                                            width: 90,
                                            //SET width
                                            child: Text(item.horario,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.primeiroHorario,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.segundoHorario,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(
                                                item.primeiroHorarioPulpito,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(
                                                item.segundoHorarioPulpito,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.mesaApoio,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.uniforme,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.recolherOferta,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 90,
                                            //SET width
                                            child: Text(item.servirCeia,
                                                textAlign: TextAlign.center))),
                                        DataCell(SizedBox(
                                            width: 180,
                                            //SET width
                                            child: Text(item.reserva,
                                                textAlign: TextAlign.center))),
                                        DataCell(
                                          IconButton(
                                            alignment: Alignment.centerRight,
                                            icon: const Icon(Icons.edit),
                                            color: PaletaCores.corAdtlLetras,
                                            onPressed: () {
                                              var dadosTela = {};
                                              dadosTela['tabela'] = tabela;
                                              dadosTela['id'] = item.id;
                                              Navigator.pushReplacementNamed(
                                                context,
                                                Constantes.rotaAtualizar,
                                                arguments: dadosTela,
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            alignment: Alignment.centerRight,
                                            icon: const Icon(
                                                Icons.delete_forever_outlined),
                                            color: Colors.red,
                                            onPressed: () {
                                              alertaExclusao(item);
                                            },
                                          ),
                                        ),
                                      ]),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: textFieldObservacao,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Form(
                                key: chaveObservacao,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 5.0,
                                      top: 5.0,
                                      right: 5.0,
                                      bottom: 5.0),
                                  //definindo espaçamento interno do container
                                  width: 300,
                                  //definindo o textField
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _controllerObservacaoTabela,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return Textos.erroTextCadVazio;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: Textos.labelObservacao,
                                        labelStyle: const TextStyle(
                                          color:PaletaCores.corAdtl,
                                        ),
                                        //definindo estilo do textfied
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 2, color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: PaletaCores.corAdtl),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        //definindo estilo do textfied ao ser clicado
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: PaletaCores.corAdtl),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        )),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: Colors.red,
                                iconSize: 30,
                                onPressed: () {
                                  setState(() {
                                    if (observacao.isNotEmpty) {
                                      statusObservacao = true;
                                    }
                                    textFieldObservacao = false;
                                  });
                                },
                              ),
                            ],
                          )),
                      Visibility(
                          visible: statusObservacao,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                Textos.txtObservaocao,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text(observacao),
                            ],
                          )),
                      Container(
                        width: larguraTela,
                        margin: const EdgeInsets.only(left: 0.0,bottom: 0.0,right: 0.0,top: 10.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5.0),
                              width: 170,
                              height: 60,
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (!textFieldObservacao) {
                                      setState(() {
                                        exibirTelas = Constantes.argGerarPDF;
                                      });
                                    } else {
                                      if (chaveObservacao.currentState!
                                          .validate()) {
                                        setState(() {
                                          exibirTelas =
                                              Constantes.argTelaCarregamento;
                                          if (observacao.isNotEmpty) {
                                            chamarAtualizarObservacao();
                                          } else {
                                            chamarAdicionarObservacao();
                                          }
                                        });

                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green),
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      if (!textFieldObservacao) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Icon(Icons.archive_outlined,
                                                size: 30),
                                            Text(
                                              Textos.btnGerarPDF,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            )
                                          ],
                                        );
                                      } else {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Icon(Icons.save, size: 30),
                                            Text(
                                              Textos.btnSalvar,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  )),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5.0),
                              width: 210,
                              height: 60,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, Constantes.rotaSelecaoEscala,
                                        arguments: "");
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: PaletaCores.corAdtlLetras),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(Icons.repeat_outlined,
                                          size: 30),
                                      Text(
                                        Textos.btnTrocarEscala,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 5.0),
                              width: 240,
                              height: 60,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _controllerObservacaoTabela.text =
                                          observacao;
                                      statusObservacao = false;
                                      textFieldObservacao = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: PaletaCores.corAzul),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      LayoutBuilder(
                                        builder: (BuildContext context,
                                            BoxConstraints constraints) {
                                          if (nomeBotao ==
                                              Textos.btnAdicionarObservacao) {
                                            return const Icon(Icons.add,
                                                size: 30);
                                          } else {
                                            return const Icon(
                                                Icons.update_outlined,
                                                size: 30);
                                          }
                                        },
                                      ),
                                      Text(
                                        nomeBotao,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        } else if (exibirTelas == Constantes.argGerarPDF) {
          return Stack(
            children: [
              const WidgetFundoTelas(
                  alterarLargura: Constantes.telaListagemItens),
              SingleChildScrollView(
                child: SizedBox(
                    width: larguraTela,
                    height: alturaTela - alturaAppBar - alturaBarraStatus,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          height: 50,
                          width: 50,
                          child: FloatingActionButton(
                            heroTag: "fecharTelas",
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                exibirTelas = Constantes.argVerListaInicial;
                              });
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: larguraTela,
                          child: WidgetGerarPDF(
                              nomeTabela: tabela,
                              listaModelo: _listaModelo,
                              observacao: observacao),
                        )
                      ],
                    )),
              )
            ],
          );
        } else if (exibirTelas == Constantes.argTelaListaVazia) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                      heroTag: "AdicionarItemErro",
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, Constantes.rotaCadastrar,
                            arguments: tabela);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      heroTag: "RecarregarListaErro",
                      backgroundColor: PaletaCores.corAdtlLetras,
                      child: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          exibirTelas = Constantes.argTelaCarregamento;
                        });
                        chamarRecuperarDados();
                      },
                    ),
                  )
                ],
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
