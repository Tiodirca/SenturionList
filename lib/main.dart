import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:senturionlistv2/Uteis/Constantes.dart';

import 'Uteis/Rotas.dart';
import 'Uteis/ScrollBehaviorPersonalizado.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // gerar arquivos para web flutter build web
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // definindo scroll behavior personalizado para permitir rolagem horizontal no navegador
      scrollBehavior: ScrollBehaviorPersonalizado(),
      //definicoes usadas no date picker
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      //setando o suporte da lingua usada no data picker
      supportedLocales: const [Locale('pt', 'BR')],
      debugShowCheckedModeBanner: false,
      //definindo rota inicial
      initialRoute: Constantes.rotaSplashScreen,
      onGenerateRoute: Rotas.generateRoute,
    );
  }
}
