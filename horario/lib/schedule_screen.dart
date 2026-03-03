import 'package:flutter/material.dart';
import 'add_class_dialog.dart';
import 'main.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool isEditing = false;
  bool isDeleting = false; // <- NUEVO ESTADO PARA EL MODO BORRAR
  List<SchoolClass> classes = [];
  
  final List<String> days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
  final int startOfDay = 7; // 7 AM
  final int endOfDay = 21; // 9 PM
  final double hourHeight = 80.0; 

  void _addNewClass(SchoolClass newClass) {
    setState(() {
      classes.add(newClass);
    });
  }

  void _updateClassPosition(SchoolClass schoolClass, int newDay, int newHour) {
    setState(() {
      schoolClass.dayOfWeek = newDay;
      schoolClass.startHour = newHour;
    });
  }

  String _formatHour12(int hour24) {
    int hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    String amPm = hour24 >= 12 ? 'PM' : 'AM';
    return '$hour12:00\n$amPm'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Horario'),
        actions: [
          // BOTÓN DE MODO BORRAR
          IconButton(
            icon: Icon(
              Icons.delete,
              color: isDeleting ? Colors.redAccent : Colors.white,
            ),
            tooltip: isDeleting ? 'Salir de Borrar' : 'Modo Borrar',
            onPressed: () {
              setState(() {
                isDeleting = !isDeleting;
                if (isDeleting) isEditing = false; // Desactiva edición si activas borrado
              });
            },
          ),
          // BOTÓN DE MODO EDITAR
          IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isEditing ? Colors.greenAccent : Colors.white,
            ),
            tooltip: isEditing ? 'Guardar Cambios' : 'Modo Editar',
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (isEditing) isDeleting = false; // Desactiva borrado si activas edición
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar Clase',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddClassDialog(onAdd: _addNewClass),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 60), 
              ...List.generate(days.length, (index) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[800]!),
                        bottom: BorderSide(color: Colors.grey[800]!),
                      ),
                    ),
                    child: Text(
                      days[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna de horas
                  SizedBox(
                    width: 60, 
                    child: Column(
                      children: List.generate(endOfDay - startOfDay + 1, (index) {
                        return Container(
                          height: hourHeight,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatHour12(startOfDay + index),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        );
                      }),
                    ),
                  ),
                  // DragTargets
                  ...List.generate(days.length, (dayIndex) {
                    return Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: List.generate(endOfDay - startOfDay, (hourIndex) {
                              int currentHour = startOfDay + hourIndex;
                              return DragTarget<SchoolClass>(
                                onAcceptWithDetails: (details) {
                                  _updateClassPosition(details.data, dayIndex, currentHour);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return Container(
                                    height: hourHeight,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: Colors.grey[800]!),
                                        top: BorderSide(color: Colors.grey[800]!),
                                      ),
                                      color: candidateData.isNotEmpty
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                          ...classes.where((c) => c.dayOfWeek == dayIndex).map((c) {
                            return Positioned(
                              top: (c.startHour - startOfDay) * hourHeight,
                              left: 0,
                              right: 0,
                              height: c.duration * hourHeight,
                              child: _buildClassCard(c),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(SchoolClass c) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth >= 1200;

    double subjectSize = isLargeScreen ? 18.0 : 14.0;    
    double teacherSize = isLargeScreen ? 14.0 : 11.0;    
    double classroomSize = isLargeScreen ? 12.0 : 9.0;   

    // Contenedor base de la tarjeta
    Widget card = Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.subject,
            style: TextStyle(
                fontSize: subjectSize,
                fontWeight: FontWeight.bold, 
                color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            c.teacher,
            style: TextStyle(
                fontSize: teacherSize,
                fontWeight: FontWeight.normal, 
                color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Salón: ${c.classroom}',
            style: TextStyle(
                fontSize: classroomSize,
                fontWeight: FontWeight.normal, 
                color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    // Si el modo borrar está activo, mostramos un filtro rojo y eliminamos al tocar
    if (isDeleting) {
      return GestureDetector(
        onTap: () {
          setState(() {
            classes.removeWhere((element) => element.id == c.id);
          });
        },
        child: Stack(
          children: [
            card, // Tarjeta base
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.6), // Filtro rojo
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Si el modo editar está activo, habilitamos arrastrar y soltar
    if (isEditing) {
      return Draggable<SchoolClass>(
        data: c,
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.8,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              height: c.duration * hourHeight,
              child: card,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: card,
        ),
        child: card,
      );
    }

    // Modo normal (solo vista)
    return card;
  }
}