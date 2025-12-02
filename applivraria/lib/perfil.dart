import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String name = '';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        name = doc['name'] ?? '';
        email = doc['email'] ?? user!.email ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        email = user!.email ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();

      // Após deletar, você pode redirecionar o usuário para a tela de login ou outra
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir conta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 320;

    return Scaffold(
      backgroundColor: Color(0xFF4A47A3), // roxo escuro
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Container(
                width: 320,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFF4A47A3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Icon menu no topo esquerdo
                          Positioned(
                            left: 16,
                            top: 16,
                            child: Icon(Icons.menu, color: Colors.white),
                          ),
                          // Icon configuração no topo direito
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Icon(Icons.settings, color: Colors.white),
                          ),
                          // Avatar fictício no centro (sem foto)
                          Center(
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 60, color: Color(0xFF4A47A3)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A47A3),
                      ),
                    ),

                    SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ElevatedButton(
                        onPressed: _deleteAccount,
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
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
