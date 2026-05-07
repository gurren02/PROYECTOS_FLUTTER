import 'package:flutter/material.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart'; // Importante para que reconozca el plugin

void main() {
  runApp(const MiChatbotApp());
}

// 2. La estructura principal de la aplicación
class MiChatbotApp extends StatelessWidget {
  const MiChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

// 3. La pantalla visual con el botón
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  // 4. función para abrir el chat
  void abrirChat() {
    dynamic conversationObject = {
      'appId': '25347c34eb3bccfb76d3b6422e9439c5b', //
    };

    KommunicateFlutterPlugin.buildConversation(conversationObject)
        .then((clientConversationId) {
      print("Chat abierto con éxito. ID: " + clientConversationId.toString());
    }).catchError((error) {
      print("Error al abrir el chat: " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Inteligente'),
      ),
      body: const Center(
        child: Text(
          'Toca el botón flotante para hablar con Pepe 👇',
          style: TextStyle(fontSize: 18),
        ),
      ),
      // Un botón flotante en la esquina inferior derecha
      floatingActionButton: FloatingActionButton(
        onPressed: abrirChat, // Al presionar, ejecuta tu función
        child: const Icon(Icons.chat),
      ),
    );
  }
}