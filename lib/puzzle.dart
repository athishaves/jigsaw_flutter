import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsaw_flutter/bloc/puzzle_core_bloc.dart';
import 'package:jigsaw_flutter/puzzle_layout.dart';

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    PuzzleCoreBloc bloc = BlocProvider.of<PuzzleCoreBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: bloc.initCompleter.future,
            builder: (context, snapshot) {
              return snapshot.connectionState != ConnectionState.done
                  ? const SizedBox.shrink()
                  : const PuzzleLayout();
            },
          ),
        ],
      ),
    );
  }
}
