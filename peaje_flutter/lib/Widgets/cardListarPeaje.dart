// TARJETA CON BOTON DE EDITAR Y ELIMINAR
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String placa;
  final String peaje;
  final Color colorIcon;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const CardWidget({
    super.key,
    required this.colorIcon,
    required this.placa,
    required this.peaje,
    required this.onEditPressed,
    required this.onDeletePressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(111, 119, 133, 0.192),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: colorIcon,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Icon(Icons.airport_shuttle_rounded, color: Color.fromARGB(255, 42, 54, 68)),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(placa, style: const TextStyle(color: Colors.white, fontSize: 16)),
                Text(peaje, style: const TextStyle(color: Color.fromARGB(136, 255, 255, 255), fontSize: 12))
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                onPressed: onEditPressed,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDeletePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
