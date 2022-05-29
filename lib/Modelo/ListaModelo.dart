class ListaModelo {
  String id;
  String primeiroHorario;
  String segundoHorario;
  String primeiroHorarioPulpito;
  String segundoHorarioPulpito;
  String recolherOferta;
  String uniforme;
  String mesaApoio;
  String servirCeia;
  String dataSemana;
  String horario;
  String reserva;

  ListaModelo({required this.id,
    required this.primeiroHorario,
    required this.segundoHorario,
    required this.primeiroHorarioPulpito,
    required this.segundoHorarioPulpito,
    required this.recolherOferta,
    required this.uniforme,
    required this.mesaApoio,
    required this.servirCeia,
    required this.dataSemana,
    required this.horario,
    required this.reserva});

  factory ListaModelo.fromJson(Map<String, dynamic> json) {
    return ListaModelo(
      id: json['id'] as String,
      primeiroHorario: json['primeiroHorario'] as String,
      segundoHorario: json['segundoHorario'] as String,
      primeiroHorarioPulpito: json['primeiroHorarioPulpito'] as String,
      segundoHorarioPulpito: json['segundoHorarioPulpito'] as String,
      recolherOferta: json['recolherOferta'] as String,
      uniforme: json['uniforme'] as String,
      mesaApoio: json['mesaApoio'] as String,
      servirCeia: json['servirCeia'] as String,
      dataSemana: json['dataSemana'] as String,
      horario: json['horario'] as String,
      reserva: json['reserva'] as String
    );
  }
}
