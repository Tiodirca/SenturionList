import 'package:flutter/material.dart';

import '../Uteis/PaletaCores.dart';
import '../Uteis/Textos.dart';

class WidgetTelaCarregamento extends StatelessWidget {
  const WidgetTelaCarregamento({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(10),
      width: larguraTela,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Textos.txtCarregamento,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(PaletaCores.corAdtl),
              strokeWidth: 3.0,
            )
          ],
        ),
      ),
    );
  }
}

