import 'package:flutter/material.dart';
import 'package:senturionlistv2/Telas/TelaAtualizar.dart';
import 'package:senturionlistv2/Telas/TelaCadastro.dart';
import 'package:senturionlistv2/Telas/TelaInicial.dart';
import 'package:senturionlistv2/Telas/TelaListagem.dart';
import 'package:senturionlistv2/Telas/TelaSelecaoEscalas.dart';
import 'package:senturionlistv2/Uteis/Constantes.dart';

import '../Telas/SplashScreen.dart';
import 'PaletaCores.dart';

class Rotas {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Recebe os parâmetros na chamada do Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const TelaInicial());
      case Constantes.rotaSplashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Constantes.rotaAtualizar:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaAtualizar(
              nomeTabela: args["tabela"],idItem: args["id"],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaCadastrar:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TelaCadastro(
              nomeTabela: args,
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaSelecaoEscala:
        return MaterialPageRoute(builder: (_) => const TelaSelecaoEscalas());
      case Constantes.rotaVerLista:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TelaListagem(
              nomeTabela: args,
            ),
          );
        } else {
          return erroRota(settings);
        }
    }

    // Se o argumento não é do tipo correto, retorna erro
    return erroRota(settings);
  }

  //metodo para exibir mensagem de erro
  static Route<dynamic> erroRota(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: PaletaCores.corAdtl,
          title: const Text("Tela não encontrada!"),
        ),
        body: Container(
          color: PaletaCores.corAdtl,
          child: const Center(
            child: Text("Tela não encontrada."),
          ),
        ),
      );
    });
  }
}
