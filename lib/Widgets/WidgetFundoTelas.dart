import 'package:flutter/material.dart';
import '../Uteis/AjustarVisualizacao.dart';
import '../Uteis/PaletaCores.dart';

class WidgetFundoTelas extends StatefulWidget {
  final alterarLargura;
  const WidgetFundoTelas({Key? key,required this.alterarLargura}) : super(key: key);

  @override
  State<WidgetFundoTelas> createState() => _WidgetFundoTelasState(alterarLargura);
}

class _WidgetFundoTelasState extends State<WidgetFundoTelas> {
  String larguraAlterada = "";
  _WidgetFundoTelasState(this.larguraAlterada);

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
            //Positioned permite colocar o item em qualquer lugar
            Positioned(
              //definindo container para dividir tela ao meio
              child: Container(
                color: PaletaCores.corAzul,
                width: larguraTela,
                height: alturaTela * 0.4,
              ),
            ),
            Center(
              //definindo um widget de tela de rolagem
              child: SingleChildScrollView(
                  child: Card(
                    //definindo elevacao do card
                    elevation: 4,
                    //definindo bordas para o card
                    shape: const RoundedRectangleBorder(
                        //definindo arredondamento para todas as bordas
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    //container regiao dos textFields
                    child: SizedBox(
                        height:
                            alturaTela,
                        width: AjustarVisualizacao.ajustarLarguraComponentes(
                            larguraTela, larguraAlterada),
                        child: Container()),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
