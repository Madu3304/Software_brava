String calcularHorarioSaidaPrevista(DateTime horarioAbertura) {
  final horarioSaida = horarioAbertura.add(
    const Duration(minutes: 2),
  );

  final hora = horarioSaida.hour.toString().padLeft(2, '0');
  final minuto = horarioSaida.minute.toString().padLeft(2, '0');

  return '$hora:$minuto';
}