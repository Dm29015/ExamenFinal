import 'package:flutter/material.dart';
import 'package:peaje_flutter/Controller/peajeController.dart';
import 'package:intl/intl.dart';

class RegistrarPeaje extends StatefulWidget {
  const RegistrarPeaje({super.key});

  @override
  State<RegistrarPeaje> createState() => _RegistrarPeajeState();
}

class _RegistrarPeajeState extends State<RegistrarPeaje> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _fechaRegistroController =
      TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final List<String> _categoriasTarifa = ['I', 'II', 'III', 'IV', 'V'];

  List<String> _nombresPeajes = [];
  String? _selectedNombrePeaje;
  String? _selectedCategoriaTarifa;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchNombresPeajes();
  }

  void _fetchNombresPeajes() async {
    try {
      // Llamar a la función para obtener los nombres de peajes
      List<String> nombresPeajes =
          await fetchNombresPeajes(); // Esta función debe devolver List<String>

      // Actualizar el estado con los nombres de peajes obtenidos
      setState(() {
        _nombresPeajes = nombresPeajes;
      });
    } catch (e) {
      // Mostrar un mensaje de error en caso de falla al cargar los nombres de peajes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar nombres de peajes: $e')),
      );
    }
  }

  void _fetchValorPeaje() async {
    if (_selectedNombrePeaje != null && _selectedCategoriaTarifa != null) {
      try {
        String valor = await fetchValorPeaje(
            _selectedNombrePeaje!, _selectedCategoriaTarifa!);
        setState(() {
          _valorController.text = valor;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el valor del peaje: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _placaController.dispose();
    _fechaRegistroController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Peaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la placa';
                  }
                  if (!RegExp(r'^[A-Z]{3}[0-9]{3}$').hasMatch(value)) {
                    return 'Formato de placa inválido. Debe ingresar 3 letras seguidas de 3 números';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Nombre del Peaje'),
                value: _selectedNombrePeaje,
                onChanged: (value) {
                  setState(() {
                    _selectedNombrePeaje = value;
                    _fetchValorPeaje(); // Llamada a la función para obtener más datos relacionados con el peaje seleccionado
                  });
                },
                items: _nombresPeajes.toSet().toList().map((nombre) {
                  // Convertir a Set y luego a List para asegurar valores únicos
                  return DropdownMenuItem(
                    value: nombre,
                    child: Text(nombre),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un nombre de peaje';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'ID Categoría Tarifa'),
                value: _selectedCategoriaTarifa,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoriaTarifa = value;
                    _fetchValorPeaje();
                  });
                },
                items: _categoriasTarifa.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaRegistroController,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Registro'),
                onTap: () async {
                  // Mostrar el datepicker al hacer tap en el campo de texto
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _fechaRegistroController.text =
                          DateFormat('yyyy-MM-dd').format(_selectedDate!);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la fecha de registro';
                  }
                  // Validar formato de fecha si es necesario
                  return null;
                },
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // Dentro de tu onPressed para registrar el peaje
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var nuevoPeaje = {
                      "placa": _placaController.text,
                      "nombrePeaje": _selectedNombrePeaje!,
                      "idCategoriaTarifa": _selectedCategoriaTarifa!,
                      "fechaRegistro": _selectedDate!.toIso8601String(),
                      "valor": _valorController.text,
                    };

                    try {
                      // Llamar a la función para registrar el peaje
                      await registrarPeaje(nuevoPeaje);

                      // Navegar de vuelta al índice u otra pantalla
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error registrando peaje: $e')),
                      );
                    }
                  }
                },

                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 213, 79, 1)),
                child: const Text(
                  'Registrar',
                  style: TextStyle(color: Color.fromARGB(255, 42, 54, 68)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
