class Observacoes {
  String id;
  String observacaoTabela;
  String nomeTabela;

  Observacoes({
    required this.id,
    required this.observacaoTabela,
    required this.nomeTabela,
  });

  factory Observacoes.fromJson(Map<String, dynamic> json) {
    return Observacoes(
      id: json['id'] as String,
      observacaoTabela: json['observacaoTabela'] as String,
      nomeTabela: json['nomeTabela'] as String,
    );
  }
}
