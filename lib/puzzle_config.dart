import 'package:jigsaw_flutter/models/puzzle_block.dart';

class PuzzleConfig {
  static List<List<int>> easyBlock = [
    [0, 1, 7],
    [2, 3, 8, 14],
    [4, 5, 9, 10],
    [6, 12, 13, 18],
    [15, 21, 22],
    [11, 16, 17, 23],
    [19, 20, 25],
    [24, 30, 31, 32],
    [26, 27, 33, 34],
    [28, 29, 35],
  ];

  static List<PuzzleChip> generatePuzzleBlocks(
    Map<int, PuzzleBlock> blocks,
    int puzzleSize,
  ) {
    List<PuzzleChip> res = [];
    for (var block in easyBlock) {
      res.add(
        PuzzleChip(
          blockIndeces: block.toSet(),
          puzzleSize: puzzleSize,
          blocks: block.map((index) => blocks[index]!).toList(),
        ),
      );
    }
    return res;
  }
}
