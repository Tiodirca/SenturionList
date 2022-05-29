import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../Modelo/Observacoes.dart';
import '../Constantes.dart';
import 'package:http/http.dart' as http;
class ServicoObservacoes{
  static var root = Uri.parse("https://senturionlist.000webhostapp.com");
  static const acaoAdicionarObservacao = 'adicionarObservacao';

  static const acaoRecuperarObservacaoPorTabela =
      "recuperarObservacao";
  static const acaoAtualizarObservacao = 'atualizarObservacao';
  static const acaodeletarObservacao= 'deletarObservacao';
  //metodo para adicionar dados na tabela de observacao
  static Future<String> adicionarObservacao(
      String observacaoTabela, String nomeTabela) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoAdicionarObservacao;
      map[Constantes.jsonObservacaoTabela] = observacaoTabela;
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

  //metodo para recuparar dados do banco de dados
  static Future<List<Observacoes>> recuperarObservacoesPorTabela(
      String tabela) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoRecuperarObservacaoPorTabela;
      map['tabela'] = "Observacoes";
      //definindo que a variavel vai receber os seguintes parametros
      final response = await http.post(root, body: map).timeout(const Duration(seconds: 20));
      if (200 == response.statusCode) {
        List<Observacoes> list = parseResponseObservacao(response.body);
        return list;
      }
    } catch (e) {
      debugPrint(e.toString()); // return an empty list on exception/error
    }
    return <Observacoes>[];
  }
  //metodo para transformar os dados obtidos pelo json em objetos
  static List<Observacoes> parseResponseObservacao(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<Observacoes>((json) => Observacoes.fromJson(json))
        .toList();
  }

  //metodo para atualizar no banco de dados
  static Future<String> atualizarObservacao(
      String idDado,
      String observacaoTabela,
      String nomeTabela,) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoAtualizarObservacao;
      map['id'] = idDado;
      map[Constantes.jsonObservacaoTabela] = observacaoTabela;
      map[Constantes.jsonTabela] = nomeTabela;
      map[Constantes.jsonNomeTabela] = nomeTabela;
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
  static Future<String> deletarObservacao(String id, String nomeTabela) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaodeletarObservacao;
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