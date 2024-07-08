import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsaw_flutter/bloc/puzzle_core_bloc.dart';
import 'package:jigsaw_flutter/puzzle.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => PuzzleCoreBloc(
            imageUrl:
                "https://www.postergully.com/cdn/shop/products/5d68e2a90a40bc8f0370d1a3ac392e55.jpg?v=1578650091"),
        child: const PuzzleGame(),
      ),
    );
  }
}
