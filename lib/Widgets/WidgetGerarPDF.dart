import 'package:flutter/material.dart';
import 'package:senturionlistv2/Uteis/Constantes.dart';

import '../Modelo/ListaModelo.dart';
import '../Uteis/PDF/GerarPDF.dart';
import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';

class WidgetGerarPDF extends StatefulWidget {
  final String nomeTabela;
  final String observacao;
 final List<ListaModelo> listaModelo;

  const WidgetGerarPDF({Key? key, required this.nomeTabela,required this.listaModelo,required this.observacao}) : super(key: key);

  @override
  State<WidgetGerarPDF> createState() => _WidgetGerarPDFState(nomeTabela,listaModelo,observacao);
}

class _WidgetGerarPDFState extends State<WidgetGerarPDF> {
  String tabela = "";
  String observacao = "";
  List<ListaModelo> lista;

  _WidgetGerarPDFState(this.tabela,this.lista,this.observacao);

  //variavel usada para validar o formulario
  final chaveFormulario = GlobalKey<FormState>();
  final TextEditingController _controllerNomePDF =
      TextEditingController(text: "");

  pegarNomePDF(BuildContext context, String tipoListagem) {
    String nomePDF = _controllerNomePDF.text;
    if (chaveFormulario.currentState!.validate()) {
      GerarPDF gerarPDF = GerarPDF();
      gerarPDF.pegarDados(nomePDF,tipoListagem,observacao,lista);
      Navigator.pushReplacementNamed(
          context, Constantes.rotaVerLista,
          arguments:
          tabela);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      child: Container(
          padding: const EdgeInsets.all(5),
          height: 500,
          child: Column(
            children: [
              Text(
                Textos.txtGerarPDFDescricao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(Textos.txtEscalaSelecionada),
                  Text(
                    tabela.replaceAll(RegExp(r'_'), ' '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                Textos.txtGerarPDFInfoCampo,textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: chaveFormulario,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 5.0, top: 0.0, right: 5.0, bottom: 5.0),
                  //definindo espaçamento interno do container
                  width: 300,
                  //definindo o textField
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _controllerNomePDF,
                    validator: (value) {
                      if (value!.isEmpty) return Textos.erroTextCadVazio;
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: Textos.labelNomePDF,
                        labelStyle: const TextStyle(
                          color:PaletaCores.corAdtl,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.red),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 1, color: PaletaCores.corAdtl),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 1, color: PaletaCores.corAdtl),
                          borderRadius: BorderRadius.circular(5),
                        )),
                  ),
                ),
              ),
              Text(
                Textos.txtGerarPDFInfoOpcoes,textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5.0),
                    width: 170,
                    height: 60,
                    child: ElevatedButton(
                        onPressed: () {
                          pegarNomePDF(context, Textos.labelCooperadora);
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        child: Text(Textos.labelCooperadora)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5.0),
                    width: 170,
                    height: 60,
                    child: ElevatedButton(
                        onPressed: () {
                          pegarNomePDF(context, Textos.labelCooperador);
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        child: Text(Textos.labelCooperador)),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
