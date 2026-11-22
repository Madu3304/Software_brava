import 'package:flutter/services.dart';

/// Validador e formatador de CPF de acordo com as regras da Receita Federal (Módulo 11).
class CpfValidator {
  /// Valida CPF de acordo com o cálculo do Módulo 11 e bloqueio de sequências repetidas.
  static bool validar(String? cpf) {
    if (cpf == null || cpf.trim().isEmpty) return false;

    // 1. Limpeza: remove todos os caracteres que não forem dígitos
    final digitos = cpf.replaceAll(RegExp(r'\D'), '');

    // 2. Quantidade: deve ter exatamente 11 dígitos
    if (digitos.length != 11) return false;

    // 3. Bloqueio de sequências repetidas (00000000000 ... 99999999999)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digitos)) return false;

    // 4. Cálculo do 1º Dígito Verificador (pesos decrescentes de 10 a 2)
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(digitos[i]) * (10 - i);
    }
    int resto = (soma * 10) % 11;
    if (resto == 10 || resto == 11) resto = 0;
    if (resto != int.parse(digitos[9])) return false;

    // 5. Cálculo do 2º Dígito Verificador (pesos decrescentes de 11 a 2)
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(digitos[i]) * (11 - i);
    }
    resto = (soma * 10) % 11;
    if (resto == 10 || resto == 11) resto = 0;
    if (resto != int.parse(digitos[10])) return false;

    return true;
  }

  /// Retorna a mensagem de erro apropriada ou null se válido.
  /// Se [obrigatorio] for false, campos vazios são considerados aceitos (não preenchidos).
  static String? validarComMensagem(String? cpf, {bool obrigatorio = false}) {
    if (cpf == null || cpf.trim().isEmpty) {
      return obrigatorio ? 'CPF é obrigatório' : null;
    }

    final digitos = cpf.replaceAll(RegExp(r'\D'), '');

    if (digitos.length != 11) {
      return 'CPF deve conter exatamente 11 números';
    }

    if (RegExp(r'^(\d)\1{10}$').hasMatch(digitos)) {
      return 'CPF inválido (sequência de números repetidos)';
    }

    if (!validar(cpf)) {
      return 'CPF inválido pelos critérios da Receita Federal';
    }

    return null;
  }

  /// Formata uma string de dígitos no padrão 000.000.000-00
  static String formatar(String? cpf) {
    if (cpf == null) return '';
    final digitos = cpf.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 11) return cpf;
    return '${digitos.substring(0, 3)}.${digitos.substring(3, 6)}.${digitos.substring(6, 9)}-${digitos.substring(9, 11)}';
  }
}

/// Formatter automático para aplicar máscara de CPF (000.000.000-00) enquanto o usuário digita.
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita a 11 dígitos
    final truncated = digitos.length > 11 ? digitos.substring(0, 11) : digitos;

    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(truncated[i]);
    }

    final formatado = buffer.toString();
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }
}

