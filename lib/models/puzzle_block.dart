import 'package:image/image.dart' as img;

class PuzzleBlock {
  final int x, y;
  final int index;
  final img.Image image;
  bool isDone;

  PuzzleBlock({
    required this.x,
    required this.y,
    required this.index,
    required this.image,
    this.isDone = false,
  });

  void setCompleted() => isDone = true;

  String get keyString => "$index";
}

class PuzzleChip {
  final List<PuzzleBlock> blocks;
  final Set<int> blockIndeces;
  final int puzzleSize;
  bool isDone;
  PuzzleChip({
    required this.blocks,
    required this.puzzleSize,
    required this.blockIndeces,
    this.isDone = false,
  }) : assert(blocks.isNotEmpty && blocks.length == blockIndeces.length);

  void setCompleted() {
    isDone = true;
    for (PuzzleBlock block in blocks) {
      block.setCompleted();
    }
  }

  Pair calculateColsRange() {
    Set<int> indeces = {};
    for (PuzzleBlock block in blocks) {
      indeces.add(block.index % puzzleSize);
    }
    List<int> index = indeces.toList()..sort();
    return Pair(min: index.first, max: index.last);
  }

  Pair calculateRowsRange() {
    Set<int> indeces = {};
    for (PuzzleBlock block in blocks) {
      indeces.add(block.index ~/ puzzleSize);
    }
    List<int> index = indeces.toList()..sort();
    return Pair(min: index.first, max: index.last);
  }

  List<PuzzleBlock?> generateVisualChip() {
    Pair colRange = calculateColsRange();
    Pair rowRange = calculateRowsRange();
    List<PuzzleBlock?> res = [];
    for (int i = rowRange.min; i <= rowRange.max; i++) {
      for (int j = colRange.min; j <= colRange.max; j++) {
        int index = i * puzzleSize + j;
        if (blockIndeces.contains(index)) {
          res.add(blocks.where((element) => element.index == index).first);
        } else {
          res.add(null);
        }
      }
    }
    return res;
  }

  PuzzleBlock get firstBlock => blocks.first;
}

class Pair {
  final int min, max;
  Pair({required this.min, required this.max});
}
