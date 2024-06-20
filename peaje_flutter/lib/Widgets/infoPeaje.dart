import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String campo;
  final String valor;

  const InfoRow({super.key, required this.campo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$campo:',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(valor, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
