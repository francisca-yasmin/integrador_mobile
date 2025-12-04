import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilPage extends StatelessWidget {
  final String name;
  final String email;
  final String docId; // << ID do documento do usuário

  PerfilPage({
    required this.name,
    required this.email,
    required this.docId,
  });

  /// Função para excluir o usuário do Firestore
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("usuario")
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Conta excluída com sucesso!")),
      );

      Navigator.pop(context); // volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir conta: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A47A3),
      body: Center(
        child: Container(
          width: 320,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A47A3),
                ),
              ),

              SizedBox(height: 8),

              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 32),

              ElevatedButton(
                onPressed: () => _deleteAccount(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A47A3),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Text(
                  'Excluir Conta',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
