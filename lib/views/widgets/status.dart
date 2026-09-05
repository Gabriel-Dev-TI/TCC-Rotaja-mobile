import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';

class converteStatus extends StatelessWidget {
  converteStatus({super.key,required Status this.status});
  Status status;

  @override
  Widget build(BuildContext context) {
    final bg;
    final color;
    final icon;
    final label;
    switch (status) {
      case Status.pendente:
        bg = const Color(0xFFFFF7ED);
        color = Colors.orange;
        icon = Icons.schedule_rounded;
        label = 'Pendente';
        break;
        case Status.aceita:
        bg = const Color(0xFFEFF6FF);
        color = Colors.blue;
        icon = Icons.local_shipping_outlined;
        label = 'Aceito';
        break;
      case Status.em_transito:
        bg = const Color(0xFFEFF6FF);
        color = Colors.blue;
        icon = Icons.local_shipping_outlined;
        label = 'Em Trânsito';
        break;
      case Status.concluido:
        bg = const Color(0xFFE8F5E9);
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'Entregue';
        break;
      case Status.cancelado:
        bg = const Color(0xFFFFEBEE);
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Cancelado';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}