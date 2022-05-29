import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Modelo/MostrarTabelas.dart';

class ServicosTabela {
  static var root = Uri.parse("https://senturionlist.000webhostapp.com");


  static const acaoDeletarTabela = 'deletarTabela';
  static const acaoMostrarTabelas = 'mostrarTabelas';
  static const acaoDeletarItemObservacao = 'deletarItemObservacao';

  //metodo para criar tabela
  static Future<String> criarTabela(String nomeTabela,String acao) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando um map
      map['action'] = acao;
      map['tabela'] = nomeTabela;
      //definindo que a variavel vai receber os seguintes parametros
      final response = await http.post(root, body: map).timeout(const Duration(seconds: 20));
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }

  //metodo para recuparar as tabelas do banco de dados
  static Future<List<MostrarTabelas>> recuperarTabelas() async {
    try {
      //instanciando map
      var map = <String, dynamic>{};

      //passando os parametros para o map
      map['action'] = acaoMostrarTabelas;
      map['tabela'] = acaoMostrarTabelas;
      //definindo que a variavel vai receber os seguintes parametros
      final response = await http.post(root, body: map);
      if (200 == response.statusCode) {
        List<MostrarTabelas> list = parseResponseTabelas(response.body);
        return list;
      }
    } catch (e) {
      debugPrint(e.toString()); // return an empty list on exception/error
    }
    return <MostrarTabelas>[];
  }

  static List<MostrarTabelas> parseResponseTabelas(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<MostrarTabelas>((json) => MostrarTabelas.fromJson(json))
        .toList();
  }

  //metodo para deletar a tabela do banco de dados
  static Future<String> deletarTabela(String tabela) async {
    try {
      //instanciando map
      var map = <String, dynamic>{};
      //passando os parametros para o map
      map['action'] = acaoDeletarTabela;
      map['tabela'] = tabela;
      //definindo que a variavel vai receber os seguintes parametros
      final response = await http.post(root, body: map).timeout(const Duration(seconds: 20));
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
