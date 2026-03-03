import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'schedule_screen.dart';

void main() {
  runApp(const HorarioApp());
}

class HorarioApp extends StatelessWidget {
  const HorarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horario Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const ScheduleScreen(),
    );
  }
}

// --- MODELO DE DATOS ---
class SchoolClass {
  final String id;
  final String subject;
  final String teacher;
  final String classroom; 
  int dayOfWeek; 
  int startHour; 
  int duration; 
  Color color;

  SchoolClass({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.classroom, 
    required this.dayOfWeek,
    required this.startHour,
    required this.duration,
    required this.color,
  });
}