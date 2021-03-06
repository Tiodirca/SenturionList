import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Modelo/ListaModelo.dart';
import '../Uteis/AjustarVisualizacao.dart';
import '../Uteis/Constantes.dart';
import 'package:intl/intl.dart';
import '../Uteis/PaletaCores.dart';
import '../Uteis/Servicos/banco_de_dados.dart';
import '../Uteis/Textos.dart';
import '../Widgets/WidgetFundoTelas.dart';
import '../Widgets/WidgetTelaCarregamento.dart';

class TelaAtualizar extends StatefulWidget {
  final String nomeTabela;
  final String idItem;

  const TelaAtualizar(
      {Key? key, required this.nomeTabela, required this.idItem})
      : super(key: key);

  @override
  State<TelaAtualizar> createState() => _TelaAtualizarState(nomeTabela, idItem);
}

class _TelaAtualizarState extends State<TelaAtualizar> {
  String tabela = "";
  String id = "";

  _TelaAtualizarState(this.tabela, this.id);

  final TextEditingController _controllerPriHorario =
      TextEditingController(text: "");
  final TextEditingController _controllerSegHorario =
      TextEditingController(text: "");
  final TextEditingController _controllerPriHorarioPulpito =
      TextEditingController(text: "");
  final TextEditingController _controllerSegHorarioPulpito =
      TextEditingController(text: "");
  final TextEditingController _controllerMesaApoio =
      TextEditingController(text: "");
  final TextEditingController _controllerUniforme =
      TextEditingController(text: "");
  final TextEditingController _controllerServirCeia =
      TextEditingController(text: "");
  final TextEditingController _controllerRecolherOferta =
      TextEditingController(text: "");
  final TextEditingController _controllerReserva =
      TextEditingController(text: "");

  //variavel usada para validar o formulario
  final _chaveFormulario = GlobalKey<FormState>();

  DateTime? retornoDataPicker;
  String retornoHorarioEscala = "";
  String data = "";
  String primeiroHorarioSemana = "";
  String segundoHorarioSemana = "";
  String primeiroHFSemana = "";
  String segundoHFSemana = "";
  String retornoMetodo = "";
  bool _boleanoServirCeia = false;
  bool _boleanoMesaApoio = false;
  bool _boleanoIrmaoReserva = false;
  bool _boolSegundoHorario = true;
  bool statusTelaCarregamento = false;
  bool boolCultosExtras = false;

  var listagemRetorno = {};
  late List<ListaModelo> _lista;

  //variavel utilizada para exibir a mensagem no snackbar
  final snackBarPreencherData = SnackBar(content: Text(Textos.erroData));
  final snackBarSucesso = SnackBar(content: Text(Textos.snackAtualizar));

  // referencia nossa classe para gerenciar o banco de dados
  final bancoDados = BancoDeDados.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    statusTelaCarregamento = true;
    recuperarHorarioEscalaCultoExtra();
    //chamarRecuperarDados();
    consultarDados();
    _lista = [];
    statusTelaCarregamento = false;
  }

  //metodo para realizar a consulta no banco de dados
  // e preencher a lista com os dados
  void consultarDados() async {
    final registros = await bancoDados.consultarPorID(tabela, id);
    setState(() {
      for (var linha in registros) {
        _lista.add(ListaModelo(
            id: linha[Constantes.bancoId].toString(),
            primeiroHorario: linha[Constantes.jsonPrimeiroHorario],
            segundoHorario: linha[Constantes.jsonSegundoHorario],
            primeiroHorarioPulpito:
                linha[Constantes.jsonPrimeiroHorarioPulpito],
            segundoHorarioPulpito: linha[Constantes.jsonSegundoHorarioPulpito],
            mesaApoio: linha[Constantes.jsonMesaApoio],
            dataSemana: linha[Constantes.jsonDataSemana],
            horario: linha[Constantes.jsonHorario],
            recolherOferta: linha[Constantes.jsonRecolherOferta],
            reserva: linha[Constantes.jsonReserva],
            servirCeia: linha[Constantes.jsonServirCeia],
            uniforme: linha[Constantes.jsonUniforme]));
      }
    });
    //chamando metodo para preecher todos os campos
    preencherCampos();
  }

  // metodo para atualizar os dados no banco de dados
  atualizarDados() async {
    var primeiroHorario = listagemRetorno[Constantes.jsonPrimeiroHorario];
    var segundoHorario = listagemRetorno[Constantes.jsonSegundoHorario];
    var primeiroHorarioPulpito =
        listagemRetorno[Constantes.jsonPrimeiroHorarioPulpito];
    var segundoHorarioPulpito =
        listagemRetorno[Constantes.jsonSegundoHorarioPulpito];
    var recolherOferta = listagemRetorno[Constantes.jsonRecolherOferta];
    var uniforme = listagemRetorno[Constantes.jsonUniforme];
    var mesaApoio = listagemRetorno[Constantes.jsonMesaApoio];
    var servirCeia = listagemRetorno[Constantes.jsonServirCeia];
    var dataSemana = listagemRetorno[Constantes.jsonDataSemana];
    var horario = listagemRetorno[Constantes.jsonHorario];
    var reserva = listagemRetorno[Constantes.jsonReserva];

    // linha para incluir os dados
    Map<String, dynamic> linha = {
      BancoDeDados.bancoPrimeiroHorario: primeiroHorario,
      BancoDeDados.bancoSegundoHorario: segundoHorario,
      BancoDeDados.bancoPrimeiroHPulpito: primeiroHorarioPulpito,
      BancoDeDados.bancoSegundoHPulpito: segundoHorarioPulpito,
      BancoDeDados.bancoRecolherOferta: recolherOferta,
      BancoDeDados.bancoUniforme: uniforme,
      BancoDeDados.bancoMesaApoio: mesaApoio,
      BancoDeDados.bancoServirCeia: servirCeia,
      BancoDeDados.bancoData: dataSemana,
      BancoDeDados.bancoHorario: horario,
      BancoDeDados.bancoReserva: reserva,
    };
    await bancoDados.atualizar(linha, tabela,
        int.parse(id)); // chamando metodo responsavel por atualziar
    ScaffoldMessenger.of(context).showSnackBar(snackBarSucesso);
    Navigator.pushReplacementNamed(context, Constantes.rotaVerLista,
        arguments: tabela);
  }

  // metodo para receperar os dados gravados no share preferences
  recuperarHorarioEscalaCultoExtra() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    primeiroHorarioSemana = prefs.getString(Constantes.primeiroHSemana) ?? '';
    segundoHorarioSemana = prefs.getString(Constantes.segundoHSemana) ?? '';
    primeiroHFSemana = prefs.getString(Constantes.primeiroHFSemana) ?? '';
    segundoHFSemana = prefs.getString(Constantes.segundoHFSemana) ?? '';
    boolCultosExtras = prefs.getBool(Constantes.cultosExtras) ?? false;
  }

  //metodo para setar strings vazias no textfield
  limparValoresTextField() {
    _controllerPriHorario.text = '';
    _controllerSegHorario.text = '';
    _controllerMesaApoio.text = '';
    _controllerUniforme.text = '';
    _controllerServirCeia.text = '';
    _controllerRecolherOferta.text = '';
    _controllerReserva.text = '';
    _controllerSegHorarioPulpito.text = '';
    _controllerPriHorarioPulpito.text = '';
    setState(() {
      retornoDataPicker = null;
    });
  }

  //metodo para validar a data e para exibir o horario da escala
  validarDataHorarioEscala(String data, String tipoExibicao) {
    String horario = "";
    if (tipoExibicao == Constantes.horarioEscala) {
      if (data.contains(Constantes.quartaFeira) ||
          data.contains(Constantes.sextaFeira) ||
          (boolCultosExtras && data.contains(Constantes.quintaFeira))) {
        horario = primeiroHorarioSemana + " troca ??s " + segundoHorarioSemana;
        return horario;
      } else if (data.contains(Constantes.domingo) ||
          (boolCultosExtras && data.contains(Constantes.sabado))) {
        horario = primeiroHFSemana + " troca ??s " + segundoHFSemana;
        return horario;
      } else {
        return Textos.cadTxtSemCulto;
      }
    } else {
      if (data.contains(Constantes.quartaFeira) ||
          data.contains(Constantes.sextaFeira)) {
        return true;
      } else if (data.contains(Constantes.domingo)) {
        return true;
      } else if (boolCultosExtras &&
          (data.contains(Constantes.sabado) ||
              data.contains(Constantes.quintaFeira))) {
        return true;
      } else {
        return false;
      }
    }
  }

  //metodo para listar os dados digitados nos text form filed e no date picker
  listandoDadosDigitados() {
    var listagemDados = {};
    //criando variaveis que vao receber o valor do textfield
    String primeiroH = _controllerPriHorario.text;
    String segundoH = _controllerSegHorario.text;
    String recolherOferta = _controllerRecolherOferta.text;
    String uniforme = _controllerUniforme.text;
    String mesaApoio = _controllerMesaApoio.text;
    String servirCeia = _controllerServirCeia.text;
    String reserva = _controllerReserva.text;
    String primeiroHPulpito = _controllerPriHorarioPulpito.text;
    String segundoHPulpito = _controllerSegHorarioPulpito.text;
    //verificando se o campo vai receber valor vazio
    if (primeiroH.contains(Constantes.definirMaiusculo) ||
        primeiroH.contains(Constantes.definirMinusculo)) {
      listagemDados[Constantes.jsonPrimeiroHorario] = "";
    } else {
      listagemDados[Constantes.jsonPrimeiroHorario] = primeiroH;
    }

    //verificando se o campo vai receber valor vazio
    if (segundoH.contains(Constantes.definirMaiusculo) ||
        segundoH.contains(Constantes.definirMinusculo)) {
      listagemDados[Constantes.jsonSegundoHorario] = "";
    } else {
      listagemDados[Constantes.jsonSegundoHorario] = segundoH;
    }

    //verificando se o campo vai receber valor vazio
    if (recolherOferta.contains(Constantes.definirMaiusculo) ||
        recolherOferta.contains(Constantes.definirMinusculo)) {
      listagemDados[Constantes.jsonRecolherOferta] = "";
    } else {
      listagemDados[Constantes.jsonRecolherOferta] = recolherOferta;
    }
    //verificando se o campo vai receber valor vazio
    if (uniforme.contains(Constantes.definirMaiusculo) ||
        uniforme.contains(Constantes.definirMinusculo)) {
      listagemDados[Constantes.jsonUniforme] = "";
    } else {
      listagemDados[Constantes.jsonUniforme] = uniforme;
    }
    //definindo que a variavel boleana vai receber o valor do metodo
    bool validarData = validarDataHorarioEscala(data, "validarData");
    //verificando se a data selecionada e valida
    if (data.isNotEmpty && validarData == true) {
      //adicionando string no map
      listagemDados[Constantes.jsonDataSemana] = data;
      listagemDados[Constantes.jsonHorario] =
          validarDataHorarioEscala(data, Constantes.horarioEscala);
    } else {
      return false;
    }

    //verificando se as variaveis boleanas sao verdadeiras
    if (_boolSegundoHorario == true) {
      if (primeiroHPulpito.contains(Constantes.definirMaiusculo) ||
          primeiroHPulpito.contains(Constantes.definirMinusculo)) {
        listagemDados[Constantes.jsonPrimeiroHorarioPulpito] = "";
      } else {
        listagemDados[Constantes.jsonPrimeiroHorarioPulpito] = primeiroHPulpito;
      }
      //verificando se o campo vai receber valor vazio
      if (segundoHPulpito.contains(Constantes.definirMaiusculo) ||
          segundoHPulpito.contains(Constantes.definirMinusculo)) {
        listagemDados[Constantes.jsonSegundoHorarioPulpito] = "";
      } else {
        listagemDados[Constantes.jsonSegundoHorarioPulpito] = segundoHPulpito;
      }
    } else {
      listagemDados[Constantes.jsonPrimeiroHorarioPulpito] = "";
      listagemDados[Constantes.jsonSegundoHorarioPulpito] = "";
    }
    if (_boleanoMesaApoio == true) {
      listagemDados[Constantes.jsonMesaApoio] = mesaApoio;
    } else {
      listagemDados[Constantes.jsonMesaApoio] = "";
    }
    if (_boleanoServirCeia == true) {
      listagemDados[Constantes.jsonDataSemana] = data + " Santa Ceia";
      //adicionando string no map
      listagemDados[Constantes.jsonServirCeia] = servirCeia;
    } else {
      listagemDados[Constantes.jsonServirCeia] = "";
    }
    if (reserva.contains(Constantes.definirMinusculo) ||
        reserva.contains(Constantes.definirMaiusculo)) {
      listagemDados[Constantes.jsonReserva] = "";
    } else {
      listagemDados[Constantes.jsonReserva] = reserva;
    }
    //retornando lista com todos os dados
    return listagemDados;
  }

  preencherCampos() {
    _controllerPriHorario.text = _lista
        .map((e) => e.primeiroHorario)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerSegHorario.text = _lista
        .map((e) => e.segundoHorario)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerPriHorarioPulpito.text = _lista
        .map((e) => e.primeiroHorarioPulpito)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerSegHorarioPulpito.text = _lista
        .map((e) => e.segundoHorarioPulpito)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerRecolherOferta.text = _lista
        .map((e) => e.recolherOferta)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerUniforme.text = _lista
        .map((e) => e.uniforme)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerServirCeia.text = _lista
        .map((e) => e.servirCeia)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerMesaApoio.text = _lista
        .map((e) => e.mesaApoio)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    _controllerReserva.text = _lista
        .map((e) => e.reserva)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    if (_controllerMesaApoio.text != "") {
      setState(() {
        _boleanoMesaApoio = true;
        _boolSegundoHorario = false;
      });
    }
    if (_controllerPriHorarioPulpito.text != "" ||
        _controllerSegHorarioPulpito.text != "") {
      setState(() {
        _boolSegundoHorario = true;
      });
    }
    if (_controllerServirCeia.text != "") {
      setState(() {
        _boleanoServirCeia = true;
      });
    }
    if (_controllerReserva.text != "") {
      setState(() {
        _boleanoIrmaoReserva = true;
      });
    }
    String dataRecuperada = _lista
        .map((e) => e.dataSemana)
        .toString()
        .replaceAll(RegExp(r'[),(]'), '');
    setState(() {
      retornoDataPicker =
          DateFormat("dd/MM/yyyy EEEE", "pt_BR").parse(dataRecuperada);
    });
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
        if (_boolSegundoHorario == false &&
            ((_boleanoIrmaoReserva == true && _boleanoServirCeia == false) ||
                _boleanoIrmaoReserva == false && _boleanoServirCeia == true)) {
          altura = altura - alturaAppBar;
          return altura;
        } else if (_boolSegundoHorario == true &&
            _boleanoServirCeia == false &&
            _boleanoIrmaoReserva == false) {
          altura = altura - alturaAppBar;
          return altura;
        } else {
          return altura;
        }
      }
    }

    double tamanhoTextField = AjustarVisualizacao.ajustarTextField(larguraTela);

    //string que vai receber o date picker ja formado para o padrao informado
    data = retornoDataPicker == null
        ? ""
        : DateFormat("dd/MM/yyyy EEEE", "pt_BR").format(retornoDataPicker!);

    retornoHorarioEscala =
        validarDataHorarioEscala(data, Constantes.horarioEscala);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: PaletaCores.corAdtl,
          title: const Text(
            Constantes.telaAtualizarItens,
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
              Container(
                alignment: Alignment.center,
                width: larguraTela,
                child: SingleChildScrollView(
                  child: SizedBox(
                      width: AjustarVisualizacao.ajustarLarguraComponentes(
                          larguraTela, "telaListagem"),
                      height: mudarAltura(alturaTela),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 5.0),
                            width: larguraTela,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(Textos.txtEscalaSelecionada, style: const TextStyle(
                                  fontSize: 16,
                                )),
                                Text(
                                  tabela.replaceAll(RegExp(r'_'), ' '),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Form(
                            key: _chaveFormulario,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(Textos.atualizarDescricao,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(
                                  width: AjustarVisualizacao
                                      .ajustarLarguraComponentes(
                                          larguraTela, ""),
                                  child: Column(
                                    children: [
                                      Text(Textos.txtCampoData,
                                          style: const TextStyle(fontSize: 18)),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: FloatingActionButton(
                                          backgroundColor: PaletaCores.corAdtl,
                                          child: const Icon(
                                              Icons.date_range_outlined,
                                              size: 40),
                                          //setando tamanho do icone
                                          onPressed: () {
                                            showDatePicker(
                                              helpText:
                                                  Textos.txtLegendaDataPicker,
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2001),
                                              lastDate: DateTime(2222),
                                              builder: (context, child) {
                                                return Theme(
                                                  data:
                                                      ThemeData.dark().copyWith(
                                                    colorScheme:
                                                        const ColorScheme.light(
                                                      primary:
                                                          PaletaCores.corAdtl,
                                                      onPrimary: Colors.white,
                                                      surface:
                                                          PaletaCores.corAdtl,
                                                      onSurface: Colors.black,
                                                    ),
                                                    dialogBackgroundColor:
                                                        Colors.white,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            ).then((date) {
                                              setState(() {
                                                //definindo que a  variavel vai receber o valor selecionado no data picker
                                                retornoDataPicker = date;
                                              });
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(data,
                                          style: const TextStyle(fontSize: 16)),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      bottom: 10.0,
                                      right: 10.0,
                                      top: 0.0),
                                  child: Text(Textos.txtDesCampoVazio,
                                      textAlign: TextAlign.center, style: const TextStyle(
                                        fontSize: 16,
                                      )),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 5.0,
                                      top: 0.0,
                                      right: 5.0,
                                      bottom: 5.0),
                                  width: tamanhoTextField,
                                  //definindo o textField
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _controllerPriHorario,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return Textos.erroTextCadVazio;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: Textos.labelPrimeiraHora,
                                        labelStyle: const TextStyle(
                                          color: PaletaCores.corAdtl,
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
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 5.0,
                                      top: 0.0,
                                      right: 5.0,
                                      bottom: 5.0),
                                  width: tamanhoTextField,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _controllerSegHorario,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return Textos.erroTextCadVazio;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: Textos.labelSegundaHora,
                                        labelStyle: const TextStyle(
                                          color: PaletaCores.corAdtl,
                                        ),
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
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: PaletaCores.corAdtl),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        )),
                                  ),
                                ),
                                Visibility(
                                    visible: _boolSegundoHorario,
                                    child: Wrap(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 5.0,
                                              top: 2.0,
                                              right: 5.0,
                                              bottom: 5.0),
                                          width: tamanhoTextField,
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            controller:
                                                _controllerPriHorarioPulpito,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return Textos.erroTextCadVazio;
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                                labelText: Textos
                                                    .labelPrimeiraHoraPulpito,
                                                labelStyle: const TextStyle(
                                                  color: PaletaCores.corAdtl,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 2,
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          PaletaCores.corAdtl),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          PaletaCores.corAdtl),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                )),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 5.0,
                                              top: 2.0,
                                              right: 5.0,
                                              bottom: 5.0),
                                          width: tamanhoTextField,
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            controller:
                                                _controllerSegHorarioPulpito,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return Textos.erroTextCadVazio;
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                                labelText: Textos
                                                    .labelSegundaHoraPulpito,
                                                labelStyle: const TextStyle(
                                                  color: PaletaCores.corAdtl,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 2,
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          PaletaCores.corAdtl),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          PaletaCores.corAdtl),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                )),
                                          ),
                                        ),
                                      ],
                                    )),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 5.0,
                                      top: 2.0,
                                      right: 5.0,
                                      bottom: 5.0),
                                  //definindo espa??amento interno do container
                                  width: tamanhoTextField,
                                  //definindo o textField
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _controllerRecolherOferta,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return Textos.erroTextCadVazio;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: Textos.labelRecolherOferta,
                                        labelStyle: const TextStyle(
                                          color: PaletaCores.corAdtl,
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
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: PaletaCores.corAdtl),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        )),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 5.0,
                                      top: 2.0,
                                      right: 5.0,
                                      bottom: 5.0),
                                  width: tamanhoTextField,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _controllerUniforme,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return Textos.erroUniforme;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: Textos.labelUniforme,
                                        labelStyle: const TextStyle(
                                          color: PaletaCores.corAdtl,
                                        ),
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
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: PaletaCores.corAdtl),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        )),
                                  ),
                                ),
                                Visibility(
                                  visible: _boleanoMesaApoio,
                                  //container mesa de apoio
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 5.0,
                                        top: 2.0,
                                        right: 5.0,
                                        bottom: 5.0),
                                    width: tamanhoTextField,
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: _controllerMesaApoio,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return Textos.erroTextCadVazio;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          labelText: Textos.labelMesaApoio,
                                          labelStyle: const TextStyle(
                                            color: PaletaCores.corAdtl,
                                          ),
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
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: PaletaCores.corAdtl),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
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
                                Visibility(
                                  visible: _boleanoServirCeia,
                                  //container  servir ceia
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 5.0,
                                        top: 2.0,
                                        right: 5.0,
                                        bottom: 5.0),
                                    width: tamanhoTextField,
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: _controllerServirCeia,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return Textos.erroTextCadVazio;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          labelText: Textos.labelServirCeia,
                                          labelStyle: const TextStyle(
                                            color: PaletaCores.corAdtl,
                                          ),
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
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: PaletaCores.corAdtl),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
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
                                Visibility(
                                  visible: _boleanoIrmaoReserva,
                                  //container  servir ceia
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 5.0,
                                        top: 2.0,
                                        right: 5.0,
                                        bottom: 5.0),
                                    width: tamanhoTextField,
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: _controllerReserva,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return Textos.erroTextCadVazio;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          labelText: Textos.labelIrmaoReserva,
                                          labelStyle: const TextStyle(
                                            color: PaletaCores.corAdtl,
                                          ),
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
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: PaletaCores.corAdtl),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
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
                              ],
                            ),
                          ),
                          Container(
                            width: larguraTela,
                            padding: const EdgeInsets.all(10.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      Textos.txtLegendaSelecaoDia,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(retornoHorarioEscala,
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Card(
                              margin: const EdgeInsets.only(
                                  right: 0.0,
                                  bottom: 20.0,
                                  top: 0.0,
                                  left: 0.0),
                              elevation: 10,
                              shape: const RoundedRectangleBorder(
                                  //definindo arredondamento para todas as bordas
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Wrap(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(Textos.labelServirCeia),
                                      Switch(
                                          value: _boleanoServirCeia,
                                          activeColor: PaletaCores.corAdtl,
                                          onChanged: (bool valorServirCeia) {
                                            setState(() {
                                              _boleanoServirCeia =
                                                  valorServirCeia;
                                            });
                                          }),
                                      Text(Textos.labelCooperadora),
                                      Switch(
                                          value: _boleanoMesaApoio,
                                          activeColor: PaletaCores.corAdtl,
                                          onChanged:
                                              (bool valorExibirMesaApoio) {
                                            setState(() {
                                              _boolSegundoHorario =
                                                  !valorExibirMesaApoio;
                                              _boleanoMesaApoio =
                                                  valorExibirMesaApoio;
                                            });
                                          })
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(Textos.labelIrmaoReserva),
                                      Switch(
                                          value: _boleanoIrmaoReserva,
                                          activeColor: PaletaCores.corAdtl,
                                          onChanged:
                                              (bool valorExibirMesaApoio) {
                                            setState(() {
                                              _boleanoIrmaoReserva =
                                                  valorExibirMesaApoio;
                                            });
                                          })
                                    ],
                                  ),
                                ],
                              )),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 5.0),
                                width: 170,
                                height: 60,
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_chaveFormulario.currentState!
                                          .validate()) {
                                        if (listandoDadosDigitados() == false) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  snackBarPreencherData);
                                        } else {
                                          listagemRetorno
                                              .addAll(listandoDadosDigitados());
                                          setState(() {
                                            statusTelaCarregamento = true;
                                          });
                                          atualizarDados();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(Icons.update, size: 30),
                                        Text(
                                          Textos.btnAtualizar,
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
                                    horizontal: 5.0, vertical: 5.0),
                                width: 170,
                                height: 60,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, Constantes.rotaVerLista,
                                          arguments: tabela);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: PaletaCores.corAdtl),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(Icons.list_alt_outlined,
                                            size: 30),
                                        Text(
                                          Textos.btnVerEscalas,
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
                                    horizontal: 5.0, vertical: 5.0),
                                width: 250,
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
                            ],
                          ),
                        ],
                      )),
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
