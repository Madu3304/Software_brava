import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/ficha_provider.dart';

class PerfilFichaHeaderCard extends StatelessWidget {
  final VoidCallback? onAlterar;

  const PerfilFichaHeaderCard({
    super.key,
    this.onAlterar,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FichaEmAndamentoProvider>();
    final perfil = provider.perfilAtendimento;
    final selecionadas = provider.condicoesIdentificadas;

    final String titulo;
    final String subtitulo;
    final IconData icone;
    final List<String> condicoes;

    if (perfil == 'gestante') {
      titulo = 'Ficha da gestante';
      subtitulo = 'Avaliação obstétrica e materno-fetal';
      icone = Icons.child_care_outlined;
      condicoes = const [
        'Dor abdominal',
        'Sangramento vaginal',
        'Perda de líquido',
        'Contrações',
        'Movimentos fetais presentes',
      ];
    } else if (perfil == 'idoso') {
      titulo = 'Ficha do idoso';
      subtitulo = 'Avaliação geriátrica e funcional';
      icone = Icons.health_and_safety_outlined;
      condicoes = const [
        'Risco de queda',
        'Alteração de consciência',
        'Uso de anticoagulante',
        'Polifarmácia',
        'Déficit de mobilidade',
      ];
    } else {
      titulo = 'Ficha do paciente comum';
      subtitulo = 'Atendimento clínico ou traumático';
      icone = Icons.person_outline;
      condicoes = const [
        'Queixa clínica',
        'Trauma',
        'Dor intensa',
        'Alergia conhecida',
        'Sem comorbidades relatadas',
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF6D5D5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFFFF1F1),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.fieryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icone, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B0804),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E4A43),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onAlterar ??
                      () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.selecaoAtendimento,
                          ),
                  child: const Text(
                    'Alterar',
                    style: TextStyle(
                      color: AppColors.darkRed,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.darkRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Marque as condições identificadas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: condicoes.map((label) {
                    final selected = selecionadas.contains(label);
                    return InkWell(
                      onTap: () => provider.alternarCondicao(label),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFFFEBEE) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryRed
                                : const Color(0xFFE2E8F0),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.darkRed : AppColors.textDark,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
