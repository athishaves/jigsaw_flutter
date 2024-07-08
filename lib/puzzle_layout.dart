import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:jigsaw_flutter/bloc/puzzle_core_bloc.dart';
import 'package:jigsaw_flutter/draggable_block.dart';
import 'package:jigsaw_flutter/models/puzzle_block.dart';

double sizePerBlock = 65;

class PuzzleLayout extends StatelessWidget {
  const PuzzleLayout({super.key});

  @override
  Widget build(BuildContext context) {
    PuzzleCoreBloc bloc = BlocProvider.of<PuzzleCoreBloc>(context);
    return Column(
      children: [
        ValueListenableBuilder<List<PuzzleBlock>>(
            key: bloc.puzzleBoardKey,
            valueListenable: bloc.originalPuzzleBlocks,
            builder: (context, blocks, child) {
              return CustomPaint(
                foregroundPainter: GridPainter(puzzleSize: bloc.puzzleSize),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: bloc.puzzleSize,
                  ),
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    img.Image imageBlock = bloc.imageBlocks[index];
                    Widget imageWidget = getImageBlock(
                      imageBlock,
                      width: sizePerBlock,
                      height: sizePerBlock,
                    );
                    return Container(
                      width: sizePerBlock,
                      height: sizePerBlock,
                      key: bloc.originalKeys[blocks[index].keyString],
                      color: Colors.red,
                      child: blocks[index].isDone ? imageWidget : null,
                    );
                  },
                ),
              );
            }),
        const SizedBox(height: 25),
        Container(
          color: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: ValueListenableBuilder<List<PuzzleChip>>(
              valueListenable: bloc.unDoneBlocks,
              builder: (context, blocks, child) {
                return SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: blocks.take(3).map((puzzleChip) {
                      PuzzleBlock firstBlock = puzzleChip.firstBlock;
                      GlobalObjectKey key =
                          GlobalObjectKey("${firstBlock.x}-${firstBlock.y}");
                      return DraggableBlock(
                        originalPosition: Offset(
                          firstBlock.x.toDouble(),
                          firstBlock.y.toDouble(),
                        ),
                        onDragEnd: () => bloc.add(
                          PuzzlePlacedEvent(
                            block: firstBlock,
                            blockKey: key,
                          ),
                        ),
                        child: getChipBlock(
                          puzzleChip,
                          key,
                          width: 20.0,
                          height: 20.0,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
        )
      ],
    );
  }

  Widget getChipBlock(
    PuzzleChip chip,
    GlobalObjectKey firstBlockKey, {
    double? width,
    double? height,
  }) {
    List<PuzzleBlock?> visualClip = chip.generateVisualChip();

    Pair colRange = chip.calculateColsRange();
    int colSize = colRange.max - colRange.min + 1;

    Pair rowRange = chip.calculateRowsRange();
    int rowSize = rowRange.max - rowRange.min + 1;

    return SizedBox(
      width: sizePerBlock * colSize,
      height: sizePerBlock * rowSize,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: colSize,
        ),
        itemCount: visualClip.length,
        itemBuilder: (context, index) {
          if (visualClip[index] == null) {
            return Container();
          }
          return SizedBox(
            key: chip.firstBlock == visualClip[index] ? firstBlockKey : null,
            child: getImageBlock(
              visualClip[index]!.image,
              width: width,
              height: height,
            ),
          );
        },
      ),
    );
  }

  Widget getImageBlock(img.Image imageBlock, {double? width, double? height}) =>
      Image.memory(
        Uint8List.fromList(img.encodePng(imageBlock)),
        width: width,
        height: height,
        fit: BoxFit.fill,
      );
}

class GridPainter extends CustomPainter {
  final int puzzleSize;

  const GridPainter({required this.puzzleSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    for (int i = 1; i < puzzleSize; i++) {
      canvas.drawLine(
        Offset(size.width * i / puzzleSize, 0),
        Offset(size.width * i / puzzleSize, size.height),
        paint,
      );
    }
    for (int i = 1; i < puzzleSize; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / puzzleSize),
        Offset(size.height, size.height * i / puzzleSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
