import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:jigsaw_flutter/models/puzzle_block.dart';
import 'package:jigsaw_flutter/puzzle_config.dart';

part 'puzzle_core_event.dart';
part 'puzzle_core_state.dart';

class PuzzleCoreBloc extends Bloc<PuzzleCoreEvent, PuzzleCoreState> {
  final String imageUrl;

  final int puzzleSize = 6;

  late img.Image image;
  final List<img.Image> imageBlocks = [];
  final puzzleBoardKey = GlobalKey();

  final Completer initCompleter = Completer();

  final double threshold = 25.0;

  final ValueNotifier<List<PuzzleBlock>> originalPuzzleBlocks =
      ValueNotifier([]);
  final List<PuzzleChip> puzzleChips = [];
  final ValueNotifier<List<PuzzleChip>> unDoneBlocks = ValueNotifier([]);

  final Map<String, GlobalObjectKey> originalKeys = {};

  Offset getGlobalPosition(GlobalKey key) {
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  PuzzleCoreBloc({required this.imageUrl}) : super(PuzzleCoreInitial()) {
    on<PuzzlePlacedEvent>((event, emit) {
      Offset originalPos =
          getGlobalPosition(originalKeys[event.block.keyString]!);
      Offset draggedPos = getGlobalPosition(event.blockKey);

      if ((originalPos - draggedPos).distance < threshold) {
        PuzzleChip chip = puzzleChips
            .where(
                (puzzles) => puzzles.blockIndeces.contains(event.block.index))
            .first;
        chip.setCompleted();
      }
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      originalPuzzleBlocks.notifyListeners();
    });

    initBloc();
  }

  Future initBloc() async {
    originalPuzzleBlocks.addListener(_onPuzzleBlockUpdate);
    splitImageIntoBlocks();
  }

  @override
  Future close() async {
    originalPuzzleBlocks.removeListener(_onPuzzleBlockUpdate);
    originalPuzzleBlocks.dispose();
    unDoneBlocks.dispose();
    super.close();
  }

  void _onPuzzleBlockUpdate() {
    List<PuzzleChip> unDone =
        puzzleChips.where((chip) => !chip.isDone).toList();
    unDoneBlocks.value = unDone;
  }

  Future<Uint8List> getUint8ListFromNetworkImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image from network');
    }
  }

  void splitImageIntoBlocks() async {
    Uint8List fullImage = await getUint8ListFromNetworkImage(imageUrl);

    image = img.decodeImage(fullImage) ?? img.Image(width: 0, height: 0);

    List<PuzzleBlock> blocks = [];
    imageBlocks.clear();

    int imageWidth = image.width;
    int imageHeight = image.height;

    int blockWidth = imageWidth ~/ puzzleSize;
    int blockHeight = imageHeight ~/ puzzleSize;

    for (int row = 0; row < puzzleSize; row++) {
      for (int col = 0; col < puzzleSize; col++) {
        int x = col * blockWidth;
        int y = row * blockHeight;
        final croppedImage = img.copyCrop(
          image,
          x: x,
          y: y,
          width: blockWidth,
          height: blockHeight,
        );

        PuzzleBlock block = PuzzleBlock(
          index: row * puzzleSize + col,
          x: x,
          y: y,
          image: croppedImage,
        );
        originalKeys[block.keyString] = GlobalObjectKey(block.keyString);

        blocks.add(block);
        imageBlocks.add(croppedImage);
      }
    }

    puzzleChips.clear();
    puzzleChips
        .addAll(PuzzleConfig.generatePuzzleBlocks(blocks.asMap(), puzzleSize));

    originalPuzzleBlocks.value = blocks;

    if (!initCompleter.isCompleted) {
      initCompleter.complete();
    }
  }
}
