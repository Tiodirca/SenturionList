import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Modelo/ListaModelo.dart';
import '../Constantes.dart';

class ServicosItens {
  static var root = Uri.parse("https://senturionlist.000webhostapp.com");

  static const acaoAdicionarDados = 'adicionarDados';
  static const acaoRecupearDados = 'recuperarDados';
  static const acaoRecupearDadosPorID = 'recuperarDadosPorID';
  static const acaoAtualizarDados = 'atualizarDados';
  static const acaoDeletarDados = 'deletarDados';

  //metodo para adicionar dados no banco de dados
  static Future<String> adicionarItens(
      String primeiroHorario,
      String segundoHorario,
      String primeiroHorarioPulpito,
      String segundoHorarioPulpito,
      String recolherOferta,
      String uniforme,
      String mesaApoio,
      String servirCeia,
      String dataSemana,
      String horario,
      String nomeTabela,
      String reserva) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoAdicionarDados;
      map[Constantes.jsonPrimeiroHorario] = primeiroHorario;
      map[Constantes.jsonSegundoHorario] = segundoHorario;
      map[Constantes.jsonPrimeiroHorarioPulpito] = primeiroHorarioPulpito;
      map[Constantes.jsonSegundoHorarioPulpito] = segundoHorarioPulpito;
      map[Constantes.jsonRecolherOferta] = recolherOferta;
      map[Constantes.jsonUniforme] = uniforme;
      map[Constantes.jsonMesaApoio] = mesaApoio;
      map[Constantes.jsonServirCeia] = servirCeia;
      map[Constantes.jsonDataSemana] = dataSemana;
      map[Constantes.jsonHorario] = horario;
      map[Constantes.jsonReserva] = reserva;
      map[Constantes.jsonTabela] = nomeTabela;
      //definindo que a variavel vai receber os seguintes parametros
      final response =
          await http.post(root, body: map).timeout(const Duration(seconds: 20));
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return response.body;
      }
    } catch (e) {
      return "erro";
    }
  }

  //metodo para recuperar os dados do banco de dados
  static Future<List<ListaModelo>> recuperarItens(String tabela) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoRecupearDados;
      map['tabela'] = tabela;
      //definindo que a variavel vai receber os seguintes parametros
      final response =
          await http.post(root, body: map).timeout(const Duration(seconds: 20));

      if (200 == response.statusCode) {
        List<ListaModelo> list = parseResponse(response.body);
        return list;
      }
    } catch (e) {
      debugPrint(e.toString()); // return an empty list on exception/error
    }
    return <ListaModelo>[];
  }

  //metodo para recuparar os dados do banco de dados
  static Future<List<ListaModelo>> recuperarDadosPorID(
      String tabela, String id) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};

      //passando os parametros para o map
      map['action'] = acaoRecupearDadosPorID;
      map['tabela'] = tabela;
      map['id'] = id;
      //definindo que a variavel vai receber os seguintes parametros
      final response =
          await http.post(root, body: map).timeout(const Duration(seconds: 20));
      if (200 == response.statusCode) {
        List<ListaModelo> list = parseResponse(response.body);
        return list;
      }
    } catch (e) {
      debugPrint(e.toString()); // return an empty list on exception/error
    }
    return <ListaModelo>[];
  }

  //metodo para transformar os dados obtidos pelo json em objetos
  static List<ListaModelo> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<ListaModelo>((json) => ListaModelo.fromJson(json))
        .toList();
  }
  // metodo para atualizar as informacoes no banco de dados
  static Future<String> atualizar(
      String idDado,
      String primeiroHorario,
      String segundoHorario,
      String primeiroHorarioPulpito,
      String segundoHorarioPulpito,
      String recolherOferta,
      String uniforme,
      String mesaApoio,
      String servirCeia,
      String dataSemana,
      String horario,
      String nomeTabela,
      String reserva) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoAtualizarDados;
      map['id'] = idDado;
      map[Constantes.jsonPrimeiroHorario] = primeiroHorario;
      map[Constantes.jsonSegundoHorario] = segundoHorario;
      map[Constantes.jsonPrimeiroHorarioPulpito] = primeiroHorarioPulpito;
      map[Constantes.jsonSegundoHorarioPulpito] = segundoHorarioPulpito;
      map[Constantes.jsonRecolherOferta] = recolherOferta;
      map[Constantes.jsonUniforme] = uniforme;
      map[Constantes.jsonMesaApoio] = mesaApoio;
      map[Constantes.jsonServirCeia] = servirCeia;
      map[Constantes.jsonDataSemana] = dataSemana;
      map[Constantes.jsonHorario] = horario;
      map[Constantes.jsonReserva] = reserva;
      map[Constantes.jsonTabela] = nomeTabela;
      //definindo que a variavel vai receber os seguintes parametros
      final response = await http.post(root, body: map);
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }

  //metodo para deletar os dados
  static Future<String> deletar(String id, String nomeTabela) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoDeletarDados;
      map['id'] = id;
      map['tabela'] = nomeTabela;
      //definindo que a variavel vai receber os seguintes parametros
      final response =
          await http.post(root, body: map).timeout(const Duration(seconds: 20));
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }


}
