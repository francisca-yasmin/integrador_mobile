import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilPage extends StatelessWidget {
  final String docId; // ID do usuário no Firestore

  PerfilPage({required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("usuario")
            .doc(docId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text("Usuário não encontrado",
                  style: TextStyle(fontSize: 18)),
            );
          }

          var user = snapshot.data!.data() as Map<String, dynamic>;
          String name = user["name"] ?? "Usuário";
          String email = user["email"] ?? "email@dominio.com";

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF47CB9),Color(0xFFB86FD8), ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FOTO DO PERFIL (GENÉRICA)
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // NOME
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                // EMAIL
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 40),

                // CARTÃO BRANCO
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informações da Conta",
                        style: TextStyle(
                          color: Color(0xFFf47cb9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text("Nome: $name",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 6),
                      Text("Email: $email",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
