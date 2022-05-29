import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;

import '../../Modelo/ListaModelo.dart';
import '../Textos.dart';
import 'salvarPDF/SavePDFMobile.dart'
if (dart.library.html) 'salvarPDF/SavePDFWeb.dart';

class GerarPDF {
  late List<String> listaLegenda = [];

  //metodo para pegar todos os dados e jogar no pdf
  pegarDados(String nomePDF,
      String tipoListagem,
      String observacao,
      List<ListaModelo> _lista) {
    listaLegenda.addAll([
      Textos.labelData,
      Textos.labelHoraTroca,
    ]);
    if (tipoListagem == Textos.labelCooperador) {
      listaLegenda.addAll([
        Textos.labelPrimeiraHoraPortao,
        Textos.labelSegundaHoraPortao,
        Textos.labelPrimeiraHoraPulpito,
        Textos.labelSegundaHoraPulpito,
      ]);
    }else{
      listaLegenda.addAll([
        Textos.labelPrimeiraHoraEntrada,
        Textos.labelSegundaHoraEntrada,
        Textos.labelMesaApoio
      ]);
    }
    listaLegenda.addAll(
        [Textos.labelUniforme, Textos.labelServirCeia,Textos.labelRecolherOferta,Textos.labelIrmaoReserva]);
    gerarPDF(nomePDF, _lista,tipoListagem, observacao);
  }

  gerarPDF(String nomePDF, List<ListaModelo> _lista,String tipoListagem,
      String observacao) async {
    final pdfLib.Document pdf = pdfLib.Document();
    //definindo que a variavel vai receber o caminho da imagem
    final image =
    (await rootBundle.load('assets/imagens/adtl.png')).buffer.asUint8List();
    final imageLogo =
    (await rootBundle.load('assets/imagens/logo.png')).buffer.asUint8List();

    if (observacao == "definir" || observacao == "Definir" || observacao.isEmpty) {
      observacao = "Sem Observações.";
    }
    //adicionando a pagina ao pdf
    pdf.addPage(pdfLib.MultiPage(
      //definindo formato
        margin:
        const pdfLib.EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 10),
        //CABECALHO DO PDF
        header: (context) =>
            pdfLib.Column(
              children: [
                pdfLib.Container(
                  alignment: pdfLib.Alignment.centerRight,
                  child: pdfLib.Column(children: [
                    pdfLib.Image(pdfLib.MemoryImage(image),
                        width: 50, height: 50),
                    pdfLib.Text(Textos.nomeIgreja),
                  ]),
                ),
                pdfLib.SizedBox(height: 5),
                pdfLib.Text(Textos.txtCabecalhoPDF,
                    textAlign: pdfLib.TextAlign.center),
              ],
            ),
        //RODAPE DO PDF
        footer: (context) =>
            pdfLib.Column(children: [
              pdfLib.Container(
                  child: pdfLib.Column(children: [
                    pdfLib.Text("Observações:"),
                    pdfLib.Container(
                      child: pdfLib.Text(observacao,
                          textAlign: pdfLib.TextAlign.center,
                          style:
                          pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold)),
                    ),
                  ])),
              pdfLib.SizedBox(height: 20.0),
              pdfLib.Container(
                child: pdfLib.Text(Textos.txtRodapePDF,
                    textAlign: pdfLib.TextAlign.center),
              ),
              pdfLib.Container(
                  padding: const pdfLib.EdgeInsets.only(
                      left: 0.0, top: 10.0, bottom: 0.0, right: 0.0),
                  alignment: pdfLib.Alignment.centerRight,
                  child: pdfLib.Container(
                    alignment: pdfLib.Alignment.centerRight,
                    child: pdfLib.Row(
                        mainAxisAlignment: pdfLib.MainAxisAlignment.end,
                        children: [
                          pdfLib.Text(Textos.txtGeradoApk,
                              textAlign: pdfLib.TextAlign.center),
                          pdfLib.SizedBox(width: 10),
                          pdfLib.Image(pdfLib.MemoryImage(imageLogo),
                              width: 20, height: 20),
                        ]),
                  )),
            ]),
        pageFormat: PdfPageFormat.a4,
        orientation: pdfLib.PageOrientation.portrait,
        //CORPO DO PDF
        build: (context) =>
        [
          pdfLib.SizedBox(height: 20),
          pdfLib.Table.fromTextArray(
              defaultColumnWidth: const pdfLib.FixedColumnWidth(1.0),
              cellPadding: const pdfLib.EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 5.0),
              headerPadding: const pdfLib.EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 10.0),
              cellAlignment: pdfLib.Alignment.center,
              data:listagemDados(tipoListagem, _lista)),
        ]));

    List<int> bytes = await pdf.save();
    salvarPDF(bytes, '$nomePDF.pdf');
  }

  listagemDados(String tipoListagem, List<ListaModelo> _lista) {
    if (tipoListagem == Textos.labelCooperador) {
      return <List<String>>[
        listaLegenda,..._lista.map((e) => [
          e.dataSemana,
          e.horario,
          e.primeiroHorario,
          e.segundoHorario,
          e.primeiroHorarioPulpito,
          e.segundoHorarioPulpito,
          e.uniforme,
          e.servirCeia,
          e.recolherOferta,
          e.reserva
        ])
      ];
    }else{
      return <List<String>>[
        listaLegenda,..._lista.map((e) => [
          e.dataSemana,
          e.horario,
          e.primeiroHorario,
          e.segundoHorario,
          e.mesaApoio,
          e.uniforme,
          e.servirCeia,
          e.recolherOferta,
          e.reserva
        ])
      ];
    }
  }

}
