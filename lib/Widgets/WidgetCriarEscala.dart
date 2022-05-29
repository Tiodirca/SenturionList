import 'package:flutter/material.dart';
import 'package:senturionlistv2/Uteis/Constantes.dart';
import 'package:senturionlistv2/Widgets/WidgetTelaCarregamento.dart';

import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';
import '../uteis/Servicos/ServicosTabela.dart' as servicotabela;
import '../uteis/Servicos/ServicoObservacoes.dart' as servicoobservacoes;

class WidgetCriarEscala extends StatefulWidget {
  const WidgetCriarEscala({Key? key}) : super(key: key);

  @override
  State<WidgetCriarEscala> createState() => _WidgetCriarEscalaState();
}

class _WidgetCriarEscalaState extends State<WidgetCriarEscala> {
  bool exibirCampoObs = false;
  bool exibirTelaCarregamento = false;

  //variavel usada para validar o formulario
  final _formKeyTabela = GlobalKey<FormState>();
  final _formKeyObservacao = GlobalKey<FormState>();
  int valorRadioButton = 0;
  final TextEditingController _controllerCadastrarTabela =
      TextEditingController(text: "");
  final TextEditingController _controllerObservacaoTabela =
      TextEditingController(text: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //metodo para chamar metodo de servico para criacao da tabela no banco de dados
  chamarCriarTabelas() async {
    setState(() {
      exibirTelaCarregamento = true;
    });
    //instanciando variavel que vai receber o que for digitado no textField
    String nomeTabela = _controllerCadastrarTabela.text.replaceAll(RegExp(r' '), '_');
    //definindo que a variavel vai receber o retorno do metodo
    String retornoMetodoCriar = await servicotabela.ServicosTabela.criarTabela(
        nomeTabela, Constantes.acaoCriarTabela);
    //verificando se o retorno foi igual ao esperado
    if (retornoMetodoCriar == Constantes.retornoJsonSucesso) {
      //criando snack bar para exibir ao usuario
      final snackBarSucesso = SnackBar(content: Text(Textos.snackSucesso));
      ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
        chamarCriarTabelaObservacao();
    } else {
      setState(() {
        exibirTelaCarregamento = false;
        nomeTabela = "";
      });
      //instanciando variavel que vai receber o retorno do metodo
      final snackBarError = SnackBar(
          content:
              Text('Não foi possivel criar a escala: $retornoMetodoCriar'));
      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
    }
  }

  //metodo para chamar metodo de servico para criacao da tabela no banco de dados
  chamarCriarTabelaObservacao() async {
    String nomeTabela = _controllerCadastrarTabela.text;
   String retorno =  await servicotabela.ServicosTabela.criarTabela(
        nomeTabela, Constantes.acaoCriarTabelaObservacao);
    setState(() {
      if(retorno == Constantes.retornoJsonSucesso){
        Navigator.pushReplacementNamed(context, Constantes.rotaCadastrar,
            arguments: nomeTabela);
      }else{
        Navigator.pushReplacementNamed(context, Constantes.rotaCadastrar,
            arguments: nomeTabela);
      }
    });
  }

  // metodo para adicionar observacao a escala
  chamarAdicionarObservacao() async {
    String nomeTabela = _controllerCadastrarTabela.text;
    String observacao = Constantes.definirMinusculo;
    if (valorRadioButton == 1) {
      observacao = _controllerObservacaoTabela.text;
    }
    await servicoobservacoes.ServicoObservacoes.adicionarObservacao(
        observacao, nomeTabela);
  }

  //metodo para mudar o estado do radio button
  void mudarRadioButton(int value) {
    setState(() {
      valorRadioButton = value;
      switch (valorRadioButton) {
        case 0:
          setState(() {
            exibirCampoObs = false;
          });
          break;
        case 1:
          setState(() {
            exibirCampoObs = true;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    //definindo que a variavel vai receber o retorno do metodo
    return Card(
      elevation: 20,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: larguraTela,
        height: alturaTela * 0.6,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          if (exibirTelaCarregamento) {
            return const WidgetTelaCarregamento();
          } else {
            return Column(
              children: [
                Text(Textos.btnCriarEscala,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17)),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Text(
                      Textos.criarEscalaDescricao,
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    Form(
                      key: _formKeyTabela,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                        //definindo espaçamento interno do container
                        width: 300,
                        //definindo o textField
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _controllerCadastrarTabela,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return Textos.erroTextNomeEscala;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: Textos.labelNomeEscala,
                              labelStyle:
                                  const TextStyle(color: PaletaCores.corAdtl),
                              //definindo estilo do textfied
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 1, color: PaletaCores.corAdtl),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              //definindo estilo do textfied ao ser clicado
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 1, color: PaletaCores.corAdtl),
                                borderRadius: BorderRadius.circular(5),
                              )),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(Textos.criarEscalaDesRadioObservacao),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                                value: 0,
                                activeColor: PaletaCores.corAdtl,
                                groupValue: valorRadioButton,
                                onChanged: (_) {
                                  mudarRadioButton(0);
                                }),
                            const Text(
                              'Não',
                            ),
                            Radio(
                                value: 1,
                                activeColor: PaletaCores.corAdtl,
                                groupValue: valorRadioButton,
                                onChanged: (_) {
                                  mudarRadioButton(1);
                                }),
                            const Text(
                              'Sim',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: exibirCampoObs,
                          child: Form(
                            key: _formKeyObservacao,
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                              //definindo espaçamento interno do container
                              width: 300,
                              //definindo o textField
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: _controllerObservacaoTabela,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return Textos.erroTextObservacao;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelStyle: const TextStyle(
                                        color: PaletaCores.corAdtl),
                                    labelText: Textos.labelObservacao,
                                    //definindo estilo do textfied
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Colors.red),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: PaletaCores.corAdtl),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    //definindo estilo do textfied ao ser clicado
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: PaletaCores.corAdtl),
                                      borderRadius: BorderRadius.circular(5),
                                    )),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 160,
                      height: 60,
                      child: ElevatedButton(
                          onPressed: () {
                            if (valorRadioButton == 1) {
                              if (_formKeyObservacao.currentState!.validate() &&
                                  _formKeyTabela.currentState!.validate()) {
                                chamarCriarTabelas();
                                chamarAdicionarObservacao();
                              }
                            } else {
                              if (_formKeyTabela.currentState!.validate()) {
                                chamarCriarTabelas();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: PaletaCores.corAdtlLetras),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.add, size: 30),
                              Text(
                                Textos.btnCriarEscala,
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
              ],
            );
          }
        }),
      ),
    );
  }
}
