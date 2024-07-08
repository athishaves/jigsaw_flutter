part of 'puzzle_core_bloc.dart';

class PuzzleCoreEvent {}

class PuzzlePlacedEvent extends PuzzleCoreEvent {
  final PuzzleBlock block;
  final GlobalKey blockKey;
  PuzzlePlacedEvent({
    required this.block,
    required this.blockKey,
  });
}
