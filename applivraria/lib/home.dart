import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List books = [];
  bool loading = false;

  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchBooks("romance"); // carregamento inicial
  }

  Future<void> fetchBooks(String query) async {
    setState(() {
      loading = true;
    });

    try {
      final url = Uri.parse(
        "https://www.googleapis.com/books/v1/volumes?q=$query",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          books = (data["items"] ?? [])
              .where((item) => item["volumeInfo"] != null)
              .toList();
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        print("Erro da API: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Erro ao buscar livros: $e");
    }
  }

  String getBookPrice(dynamic saleInfo) {
    if (saleInfo == null) return "Indisponível";
    if (saleInfo["saleability"] == "FOR_SALE") {
      final amount = saleInfo["retailPrice"]?["amount"] ?? 0.0;
      return "R\$ ${amount.toStringAsFixed(2)}";
    }
    return "Indisponível";
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, '/perfil'); // seu perfil page route
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amor & Livros"),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFDF2),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFFf47cb9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Campo de busca
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Buscar livros...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) fetchBooks(value);
              },
            ),
            const SizedBox(height: 12),

            // Lista de livros responsiva
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : books.isEmpty
                      ? const Center(child: Text("Nenhum livro encontrado"))
                      : ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index]["volumeInfo"];
                            final saleInfo = books[index]["saleInfo"];
                            return BookCard(book: book, saleInfo: saleInfo);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final dynamic book;
  final dynamic saleInfo;

  const BookCard({super.key, required this.book, required this.saleInfo});

  String getBookPrice() {
    if (saleInfo == null) return "Indisponível";
    if (saleInfo["saleability"] == "FOR_SALE") {
      final amount = saleInfo["retailPrice"]?["amount"] ?? 0.0;
      return "R\$ ${amount.toStringAsFixed(2)}";
    }
    return "Indisponível";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Capa do livro
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book["imageLinks"]?["thumbnail"] != null
                  ? Image.network(
                      book["imageLinks"]["thumbnail"],
                      width: 90,
                      height: 130,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 90,
                      height: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 40),
                    ),
            ),
            const SizedBox(width: 12),

            // Info do livro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book["title"] ?? "Sem título",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book["authors"]?.join(", ") ?? "Autor desconhecido",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getBookPrice(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFf47cb9)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 130,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf47cb9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final link = saleInfo["buyLink"];
                        if (link != null) launchUrl(Uri.parse(link));
                      },
                      child: const Text(
                        "Visualizar",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
