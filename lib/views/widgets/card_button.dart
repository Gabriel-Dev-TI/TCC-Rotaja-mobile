import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
    required this.funcao,
    this.corFundo,
    this.icone,
    this.subtitulo,
    required this.titulo,
  });

  final VoidCallback funcao;
  final Color? corFundo;
  final String titulo;
  final String? subtitulo;
  final Widget? icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corPrimaria = corFundo ?? tema.colorScheme.primary;

    return Card(
      color: corPrimaria, 
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: funcao,
        splashColor: Colors.white, 
        highlightColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: Colors.white, 
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (subtitulo != null)
                      Text(
                        subtitulo!,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: Colors.white70, 
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              if (icone != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: Colors.white, size: 24),
                    child: icone!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}  