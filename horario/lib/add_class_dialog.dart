import 'package:flutter/material.dart';
import 'main.dart'; 

class AddClassDialog extends StatefulWidget {
  final Function(SchoolClass) onAdd;

  const AddClassDialog({super.key, required this.onAdd});

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();
  final _classroomController = TextEditingController(); 
  
  int _selectedDay = 0;
  int _selectedStartHour = 7;
  int _selectedDuration = 1;
  Color _selectedColor = Colors.blueAccent;

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.teal,
    Colors.pinkAccent,
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _classroomController.dispose(); 
    super.dispose();
  }

  void _submit() {
    if (_subjectController.text.isEmpty) return;

    final newClass = SchoolClass(
      id: DateTime.now().toString(),
      subject: _subjectController.text,
      teacher: _teacherController.text,
      classroom: _classroomController.text.isEmpty ? 'N/A' : _classroomController.text,
      dayOfWeek: _selectedDay,
      startHour: _selectedStartHour,
      duration: _selectedDuration,
      color: _selectedColor,
    );

    widget.onAdd(newClass);
    Navigator.of(context).pop();
  }

  String _formatDropdownHour(int hour24) {
    int hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    String amPm = hour24 >= 12 ? 'PM' : 'AM';
    return '$hour12:00 $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Agregar Nueva Clase'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Materia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teacherController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Maestro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _classroomController,
              decoration: const InputDecoration(
                labelText: 'Salón de Clases (Ej. A-12)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(labelText: 'Día de la semana'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Lunes')),
                DropdownMenuItem(value: 1, child: Text('Martes')),
                DropdownMenuItem(value: 2, child: Text('Miércoles')),
                DropdownMenuItem(value: 3, child: Text('Jueves')),
                DropdownMenuItem(value: 4, child: Text('Viernes')),
              ],
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedStartHour,
                    decoration: const InputDecoration(labelText: 'Hora inicio'),
                    items: List.generate(14, (index) {
                      int hour24 = 7 + index;
                      return DropdownMenuItem(
                        value: hour24,
                        child: Text(_formatDropdownHour(hour24)), 
                      );
                    }),
                    onChanged: (val) => setState(() => _selectedStartHour = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(labelText: 'Horas (Duración)'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 hr')),
                      DropdownMenuItem(value: 2, child: Text('2 hrs')),
                      DropdownMenuItem(value: 3, child: Text('3 hrs')),
                    ],
                    onChanged: (val) => setState(() => _selectedDuration = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Color de la clase:', textAlign: TextAlign.left),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}