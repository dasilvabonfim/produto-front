import 'package:flutter/material.dart';
import 'package:produtos/Widgets/productslist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produtos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de produtos gamer muito baratos'),
        ),
        body: const ProductsList(),
      ),
    );
  }
}