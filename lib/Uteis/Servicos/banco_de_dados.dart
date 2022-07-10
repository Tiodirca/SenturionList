import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../Constantes.dart';

class BancoDeDados {
  static const bancoDadosNome = Constantes.nomeBanco;
  static const bancoDadosVersao = 1;
  static const table = Constantes.nomeTabela;
  static const bancoID = Constantes.bancoId;
  static const String bancoPrimeiroHorario = Constantes.jsonPrimeiroHorario;
  static const String bancoSegundoHorario = Constantes.jsonSegundoHorario;
  static const String bancoPrimeiroHPulpito =
      Constantes.jsonPrimeiroHorarioPulpito;
  static const String bancoSegundoHPulpito =
      Constantes.jsonSegundoHorarioPulpito;
  static const String bancoRecolherOferta = Constantes.jsonRecolherOferta;
  static const String bancoUniforme = Constantes.jsonUniforme;
  static const String bancoMesaApoio = Constantes.jsonMesaApoio;
  static const String bancoServirCeia = Constantes.jsonServirCeia;
  static const String bancoData = Constantes.jsonDataSemana;
  static const String bancoHorario = Constantes.jsonHorario;
  static const String bancoReserva = Constantes.jsonReserva;

  // torna a clase singleton
  BancoDeDados._privateConstructor();

  static final BancoDeDados instance = BancoDeDados._privateConstructor();

  // tem somente uma referência ao banco de dados
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // abre o banco de dados e o cria se ele não existir
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, bancoDadosNome);
    return await openDatabase(path, version: bancoDadosVersao);
  }

  // Código SQL para criar o banco de dados e a tabela
  Future criarTabela(String tabela) async {
    Database? db = await instance.database;
    await db!.execute('''
          CREATE TABLE $tabela (
            $bancoID INTEGER PRIMARY KEY,
            $bancoPrimeiroHorario TEXT NOT NULL,
            $bancoSegundoHorario TEXT NOT NULL,
            $bancoPrimeiroHPulpito TEXT NOT NULL,
            $bancoSegundoHPulpito TEXT NOT NULL,
            $bancoRecolherOferta TEXT NOT NULL,
            $bancoUniforme TEXT NOT NULL,
            $bancoMesaApoio TEXT NOT NULL,
            $bancoServirCeia TEXT NOT NULL,
            $bancoData TEXT NOT NULL,
            $bancoHorario TEXT NOT NULL,
            $bancoReserva TEXT NOT NULL
          )
          ''');
  }

  // Código SQL para criar o banco de dados e a tabela
  Future excluirTabela(String tabela) async {
    Database? db = await instance.database;
    await db!.execute("DROP TABLE $tabela");
  }

  Future<List<Map<String, dynamic>>> consultarPorID(
      String tabela, String idDado) async {
    Database? db = await instance.database;
    return await db!.query("$tabela WHERE id = $idDado");
  }

  // métodos auxiliares
  // metodo para inserir dados no banco
  // uma linha e inserida onde cada chave
  // no Map é um nome de coluna e o valor é o valor da coluna.
  Future<int> inserir(Map<String, dynamic> row, String tabela) async {
    Database? db = await instance.database;
    return await db!.insert(tabela, row);
  }

  // metodo para realizr a consuta no banco de dados de todas as linhas
  // elas são retornadas como uma lista de mapas
  Future<List<Map<String, dynamic>>> consultarLinhas(String tabela) async {
    Database? db = await instance.database;
    return await db!.query(tabela);
  }

  Future<List<Map<String, Object?>>> consultaTabela() async {
    Database? db = await instance.database;
    return await db!.rawQuery("SELECT * FROM sqlite_master WHERE type='table'");
  }

  // metodo para atualizar os dados
  // a coluna id no mapa está definida. Os outros
  // valores das colunas serão usados para atualizar a linha.
  Future<int> atualizar(Map<String, dynamic> row, String tabela,int id) async {
    Database? db = await instance.database;
    return await db!
        .update(tabela, row, where: '$bancoID = ?', whereArgs: [id]);
  }

  // metodo para excluir a linha especificada pelo id.
  Future<int> excluir(int id, String tabela) async {
    Database? db = await instance.database;
    return await db!.delete(tabela, where: '$bancoID = ?', whereArgs: [id]);
  }
}
