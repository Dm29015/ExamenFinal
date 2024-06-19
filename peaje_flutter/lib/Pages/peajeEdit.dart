import 'package:flutter/material.dart';
import 'package:peaje_flutter/Controller/peajeController.dart';
import 'package:peaje_flutter/Models/peajeModel.dart';
import 'package:intl/intl.dart';

class EditarPeaje extends StatefulWidget {
  final Peaje peaje;

  const EditarPeaje({super.key, required this.peaje});

  @override
  State<EditarPeaje> createState() => _EditarPeajeState();
}

class _EditarPeajeState extends State<EditarPeaje> {
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
    _initFields();
    _fetchNombresPeajes();
  }

  void _initFields() {
    _placaController.text = widget.peaje.placa;
    _selectedNombrePeaje = widget.peaje.nombrePeaje;
    _selectedCategoriaTarifa = widget.peaje.idCategoriaTarifa;
    _fechaRegistroController.text = widget.peaje.fechaRegistro;
    _valorController.text = widget.peaje.valor.toString();
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
    // if (_selectedNombrePeaje != null && _selectedCategoriaTarifa != null) {
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
      // }
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
        title: const Text('Editar Peaje'),
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
                    const InputDecoration(labelText: 'Categoría de Tarifa'),
                value: _selectedCategoriaTarifa,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoriaTarifa = value;
                    _fetchValorPeaje();
                  });
                },
                items: _categoriasTarifa.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una categoría de tarifa';
                  }
                  if (!['I', 'II', 'III', 'IV', 'V'].contains(value)) {
                    return 'Categoría de tarifa inválida';
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
                readOnly:
                    true, // Si es solo para mostrar, de lo contrario quita esta línea
                decoration: const InputDecoration(labelText: 'Valor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El valor es obligatorio';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Ingrese un valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var peajeActualizado = {
                      "id": widget.peaje.id,
                      "placa": _placaController.text,
                      "nombrePeaje": _selectedNombrePeaje!,
                      "idCategoriaTarifa": _selectedCategoriaTarifa!,
                      "fechaRegistro": _fechaRegistroController.text,
                      "valor": double.parse(
                          _valorController.text)
                    };

                    try {
                      await actualizarPeaje(widget.peaje.id, peajeActualizado);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Registro del peaje editado con éxito!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context)
                          .pop(true); // Indicar éxito al volver
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Error al editar el registro del peaje.'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 128, 39, 187)),
                child: const Text(
                  'Editar',
                  style: TextStyle(color: Color.fromARGB(255, 219, 225, 231)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
