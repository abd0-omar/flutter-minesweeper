// import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/core/theme/app_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool firstTap = true;
  int rows = 9;
  int columns = 9;
  int totalMines = 10;
  List<List<Cell>> grid = [];

  int flagCount = 10;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _intializeGrid();
  }

  void _intializeGrid() {
    // Initialize grid with empty cells
    grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => Cell(
          row: row,
          col: col,
        ),
      ),
    );

    // Add mines to random cells
    final random = Random();
    int count = 0;
    while (count < totalMines) {
      int randomRow = random.nextInt(rows);
      int randomCol = random.nextInt(columns);
      if (!grid[randomRow][randomCol].hasMine) {
        grid[randomRow][randomCol].hasMine = true;
        count++;
      }
    }

    // Calculate adjacent mines for each cell
    // a number 0-8 base on surounding / neighbour mines
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        /// has mines no nothing
        if (grid[row][col].hasMine) continue;

        int adjacentMines = 0;
        for (final dir in directions) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];

          if (_isValidCell(newRow, newCol) && grid[newRow][newCol].hasMine) {
            adjacentMines++;
          }
        }

        /// adjacentMines indicate the number of mines
        /// in its sourounding / neighbour
        grid[row][col].adjacentMines = adjacentMines;
      }
    }
  }

  /// [-1,-1] [-1,0] [-1,1]
  ///
  /// [0,-1] [cell] [0,1]
  ///
  /// [1,-1] [1,0] [1,1]
  final directions = [
    const [-1, -1],
    const [-1, 0],
    const [-1, 1],
    const [0, -1],
    const [0, 1],
    const [1, -1],
    const [1, 0],
    const [1, 1],
  ];

  final smallDirections = [
    const [-1, 0],
    const [0, -1],
    const [0, 1],
    const [1, 0],
  ];

  // check for valid cell
  bool _isValidCell(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < columns;
  }

  // while (board[2][3] != Tile.zero) {
  //   var largestZeroIsland = 0;
  //   var largestCordsI = 0;
  //   var largestCordsJ = 0;
  //   var visited = List.generate(row, (_) => List.filled(col, false));

  //   for (int i = 0; i < row; i++) {
  //     for (int j = 0; j < col; j++) {
  //       if (board[i][j] == Tile.zero && !visited[i][j]) {
  //         var count = findLargestIsland(visited, i, j);
  //         if (largestZeroIsland < count) {
  //           largestZeroIsland = count;
  //           largestCordsI = i;
  //           largestCordsJ = j;
  //         }
  //       }
  //     }
  //   }
  //   // have to move again
  //   print("would have to move again");
  //   barrelShift(visited, largestCordsI, largestCordsJ, 2, 3);
  //   printBoard();
  //   print("");
  //   // make the corresponding num for every tile
  //   for (var i = 0; i < row; i++) {
  //     for (var j = 0; j < col; j++) {
  //       if (board[i][j] == Tile.bomb) {
  //         continue;
  //       }
  //       putTilesWithMinesCounter(i, j);
  //     }
  //   }
  //   print("");
  //   printBoard();
  //   print("");
  //   print("move again?");
  // }

  Cell _handleCellFirstTap(Cell targetCell) {
    int findLargestIsland(
      // List<List<Tile>> board,
      List<List<bool>> visited,
      Cell cell,
    ) {
      final i = cell.row;
      final j = cell.col;
      if (i < 0 ||
          i >= rows ||
          j < 0 ||
          j >= columns ||
          grid[i][j].adjacentMines != 0 ||
          grid[i][j].hasMine ||
          visited[i][j]) {
        return 0;
      }

      visited[i][j] = true;

      int zerosCount = 1;

      for (var dir in smallDirections) {
        int ni = i + dir[0];
        int nj = j + dir[1];
        zerosCount += findLargestIsland(visited, Cell(row: ni, col: nj));
      }
      return zerosCount;
    }

    void printBoardCoords() {
      StringBuffer buffer = StringBuffer();

      for (var row in grid) {
        for (var cell in row) {
          buffer.write(
              '(${cell.row},${cell.col}) '); // Append coordinates to the buffer without starting a new line
        }
        buffer.writeln(''); // Add 'new line' after each row
      }

      print(buffer.toString()); // Print the whole buffer
    }

    void printBoard() {
      StringBuffer buffer = StringBuffer();

      for (var row in grid) {
        for (var col in row) {
          if (col.hasMine) {
            buffer.write(
                "x "); // Append 'x' to the buffer without starting a new line
          } else {
            buffer.write(
                "${col.adjacentMines} "); // Append adjacentMines followed by a space to the buffer without starting a new line
          }
        }
        buffer.writeln(''); // Add 'new line' after each row
      }

      print(buffer.toString()); // Print the whole buffer
    }

    // void printBoard() {
    //   for (var row in grid) {
    //     for (var col in row) {
    //       stdout.write('$col ');
    //     }
    //     stdout.write('\n');
    //   }
    // }

    void moveRight() {
      var gridColumns = grid[0].length;

      var rightCol = List<Cell>.generate(
        grid.length,
        (i) => grid[i][gridColumns - 1],
      );

      for (var j = gridColumns - 1; j > 0; j--) {
        for (var i = 0; i < grid.length; i++) {
          // grid[i][j].col = j;
          grid[i][j] = grid[i][j - 1];
        }
      }

      for (var i = 0; i < grid.length; i++) {
        // rightCol[i].col = 0;
        grid[i][0] = rightCol[i];
      }
    }

    void moveLeft() {
      var gridColumns = grid[0].length;

      var leftCol = List<Cell>.generate(
        grid.length,
        (i) => grid[i][0],
      );

      for (var j = 0; j < gridColumns - 1; j++) {
        for (var i = 0; i < grid.length; i++) {
          // grid[i][j].col = j;
          grid[i][j] = grid[i][j + 1];
        }
      }

      for (var i = 0; i < grid.length; i++) {
        // leftCol[i].col = gridColumns - 1;
        grid[i][gridColumns - 1] = leftCol[i];
      }
    }

    void moveUp() {
      var gridRows = grid.length;

      var topRow = List<Cell>.generate(
        grid[0].length,
        (j) => grid[0][j],
      );

      for (var i = 0; i < gridRows - 1; i++) {
        for (var j = 0; j < grid[0].length; j++) {
          // grid[i][j].row = i;
          grid[i][j] = grid[i + 1][j];
        }
      }

      for (var j = 0; j < grid[0].length; j++) {
        // topRow[j].row = gridRows - 1;
        grid[gridRows - 1][j] = topRow[j];
      }
    }

    void moveDown() {
      var gridRows = grid.length;

      var bottomRow = List<Cell>.generate(
        grid[0].length,
        (j) => grid[gridRows - 1][j],
      );

      for (var i = gridRows - 1; i > 0; i--) {
        for (var j = 0; j < grid[0].length; j++) {
          // grid[i][j].row = i;
          grid[i][j] = grid[i - 1][j];
        }
      }

      for (var j = 0; j < grid[0].length; j++) {
        // bottomRow[j].row = 0;
        grid[0][j] = bottomRow[j];
      }
    }

    void barrelShift(
        List<List<bool>> visited, Cell largestIslandCell, Cell targetCell) {
      var largestCoordsI = largestIslandCell.row;
      var largestCoordsJ = largestIslandCell.col;
      var targetPositionI = targetCell.row;
      var targetPositionJ = targetCell.col;
      if (grid[targetPositionI][targetPositionJ].adjacentMines == 0 &&
          !grid[targetPositionI][targetPositionJ].hasMine) {
        return;
      }
      final rowOffset = targetPositionI - largestCoordsI;
      final colOffset = targetPositionJ - largestCoordsJ;

      if (rowOffset > 0) {
        for (var i = 0; i < rowOffset; i++) {
          moveDown();
          print('moved down');
          printBoard();
          if (grid[targetPositionI][targetPositionJ].adjacentMines == 0 &&
              !grid[targetPositionI][targetPositionJ].hasMine) {
            return;
          }
        }
      } else if (rowOffset < 0) {
        for (var i = 0; i < rowOffset.abs(); i++) {
          moveUp();
          print('moved up');
          printBoard();
          if (grid[targetPositionI][targetPositionJ].adjacentMines == 0 &&
              !grid[targetPositionI][targetPositionJ].hasMine) {
            return;
          }
        }
      }

      if (colOffset > 0) {
        for (var i = 0; i < colOffset; i++) {
          moveRight();
          print('moved right');
          printBoard();
          if (grid[targetPositionI][targetPositionJ].adjacentMines == 0 &&
              !grid[targetPositionI][targetPositionJ].hasMine) {
            return;
          }
        }
      } else if (colOffset < 0) {
        for (var i = 0; i < colOffset.abs(); i++) {
          moveLeft();
          print('moved left');
          printBoard();
          if (grid[targetPositionI][targetPositionJ].adjacentMines == 0 &&
              !grid[targetPositionI][targetPositionJ].hasMine) {
            return;
          }
        }
      }
    }

    printBoard();
    var largestZeroIsland = 0;
    // var largestCordsI = 0;
    // var largestCordsJ = 0;
    var largestIslandCell = Cell(row: 0, col: 0);
    var visited = List.generate(rows, (_) => List.filled(columns, false));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (grid[i][j].adjacentMines == 0 &&
            !grid[i][j].hasMine &&
            !visited[i][j]) {
          var count = findLargestIsland(visited, Cell(row: i, col: j));
          print("the count is:$count");
          if (largestZeroIsland < count) {
            largestZeroIsland = count;
            // largestCordsI = i;
            // largestCordsJ = j;
            largestIslandCell = Cell(row: i, col: j);
          }
        }
      }
    }

    print("largest zero island is {$largestZeroIsland}");
    print(
        "largest zero island cords ${largestIslandCell.row} ${largestIslandCell.col}");
    print("target cords${targetCell.row} ${targetCell.col}");
    printBoard();
//
    // setState(() {
    barrelShift(visited, largestIslandCell, targetCell);
    // });
    print("");
    printBoard();
    printBoardCoords();
    print("");

    // setState(() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (grid[row][col].hasMine) continue;

        int adjacentMines = 0;
        for (final dir in directions) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];

          if (_isValidCell(newRow, newCol) && grid[newRow][newCol].hasMine) {
            adjacentMines++;
          }
        }
        grid[row][col].adjacentMines = adjacentMines;
        // grid[row][col].row = row;
        // grid[row][col].col = col;
      }
    }
    // });
    printBoard();
    print("");

    printBoard();
    print("");

    printBoardCoords();
    print("move again?");

    // setState(() {
    //   print("doing the state");
    //   grid = newGrid;
    // });

    while (grid[targetCell.row][targetCell.col].adjacentMines != 0 ||
        grid[targetCell.row][targetCell.col].hasMine) {
      print("will move again");
      print("${grid[targetCell.row][targetCell.col].adjacentMines}");
      print("${grid[targetCell.row][targetCell.col].adjacentMines}");

      for (var dir in directions) {
        int ni = targetCell.row + dir[0];
        int nj = targetCell.col + dir[1];
        if (grid[ni][nj].adjacentMines == 0 && !grid[ni][nj].hasMine) {
          /*
        T: (1, 1)
        x 1 0
        1 1 0
        0 0 0
        0 0 0
        SHIFTING UPPPPP!!!!
        1 1 0
        0 0 0
        0 0 0
        x 1 0
        */

          // make sure it is valid
          if (dir[0] == 1 && dir[1] == 0) {
            moveUp();
            print("moved up");
            printBoard();
            break;
          }
          if (dir[0] == -1 && dir[1] == 0) {
            moveDown();
            print("moved down");
            printBoard();
            break;
          }
          if (dir[0] == 0 && dir[1] == 1) {
            moveLeft();
            print("moved left");
            printBoard();
            break;
          }
          if (dir[0] == 0 && dir[1] == -1) {
            moveRight();
            print("moved right");
            printBoard();
            break;
          }
          if (dir[0] == 1 && dir[1] == 1) {
            moveLeft();
            moveUp();
            print("moved left");
            print("moved up");
            printBoard();
            break;
          }
          if (dir[0] == -1 && dir[1] == -1) {
            moveRight();
            moveDown();
            print("moved right");
            print("moved down");
            printBoard();
            break;
          }
          if (dir[0] == 1 && dir[1] == -1) {
            moveRight();
            moveUp();
            print("moved right");
            print("moved up");
            printBoard();
            break;
          }
          if (dir[0] == -1 && dir[1] == 1) {
            moveLeft();
            moveDown();
            print("moved left");
            print("moved down");
            printBoard();
            break;
          }
          // diagonal
        }
      }
      // });
      printBoard();
      print("assigning bombs");
      printBoard();
      // Assign numbers to tiles based on adjacent bombs
      // for (int i = 0; i < rows; i++) {
      //   for (int j = 0; j < columns; j++) {
      //     if (grid[i][j].adjacentMines == 0) {
      //       continue;
      //     }
      //     putTilesWithMinesCounter(i, j);
      //   }
      // }
      print("");
      printBoard();
      // setState(() {
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          /// has mines no nothing
          if (grid[row][col].hasMine) continue;

          int adjacentMines = 0;
          for (final dir in directions) {
            int newRow = row + dir[0];
            int newCol = col + dir[1];

            if (_isValidCell(newRow, newCol) && grid[newRow][newCol].hasMine) {
              adjacentMines++;
            }
          }

          /// adjacentMines indicate the number of mines
          /// in its sourounding / neighbour
          // setState(() {
          grid[row][col].adjacentMines = adjacentMines;
          // });
        }
      }
    }
    //   // });
    //   print("");
    //   printBoard();
    // }
    // printBoardCoords();
    // // setState(() {
    // //   for (int i = 0; i < grid.length; i++) {
    // //     for (int j = 0; j < grid[i].length; j++) {
    // //       grid[i][j].row = i;
    // //       grid[i][j].col = j;
    // //     }
    // //   }
    // // });

    printBoardCoords();
    // targetCell.row = 0;
    // targetCell.col = 0;
    var fx = grid[targetCell.row][targetCell.col].row;
    var fy = grid[targetCell.row][targetCell.col].col;
    print("$fx");
    print("$fy");
    print("${targetCell.row}");
    print("${targetCell.col}");
    var x = targetCell.row;
    var y = targetCell.col;
    printBoardCoords();
    // print("$fx");
    // print("$fy");
    // print("${targetCell.row}");
    // print("${targetCell.col}");
    // print("$targetCell");
    // return targetCell;
    // setState(() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        grid[i][j].row = i;
        grid[i][j].col = j;
      }
    }
    // });
    print("$x");
    print("$y");
    printBoardCoords();
    return Cell(row: x, col: y);
  }

  void _handleCellTap(Cell cell) {
    if (firstTap == true) {
      cell = _handleCellFirstTap(cell);
      // print("F $f");
      // cell = f;
      // print("F $f");
      // cell.row
      firstTap = false;
    }
    print("second time");
    print("${cell.row}");
    print("${cell.col}");
    if (gameOver || cell.isOpen || cell.isFlagged) return;

    setState(() {
      cell.isOpen = true;

      if (cell.hasMine) {
        // Game over - show all mines
        gameOver = true;
        for (final row in grid) {
          for (final cell in row) {
            if (cell.hasMine) {
              cell.isOpen = true;
            }
          }
        }
        showSnackBar(context, message: "Game Over !!!!");
      } else if (_checkForWin()) {
        // Game won - show all cells
        gameOver = true;

        for (final row in grid) {
          for (final cell in row) {
            cell.isOpen = true;
          }
        }
        showSnackBar(context, message: "Congratulation :D");
      } else if (cell.adjacentMines == 0) {
        // Open adjacent cells if there are no mines nearby
        _openAdjacentCells(cell.row, cell.col);
      }
    });
  }

  bool _checkForWin() {
    for (final row in grid) {
      for (final cell in row) {
        // chek if we still has un open cell
        // that are not mines
        // if we has on immidiate return
        // indicate that the game still not over
        if (!cell.hasMine && !cell.isOpen) {
          return false;
        }
      }
    }

    return true;
  }

  /// open neibour cell untill found a mines
  void _openAdjacentCells(int row, int col) {
    /// open neigbour cells
    for (final dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];

      /// if not open and not mines
      if (_isValidCell(newRow, newCol) &&
          !grid[newRow][newCol].hasMine &&
          !grid[newRow][newCol].isOpen) {
        setState(() {
          // open the cell
          grid[newRow][newCol].isOpen = true;
          // and check if its has no mines in suroinding
          /// open adjacentCells in that position

          /// this process will get loop untul it find a mines
          if (grid[newRow][newCol].adjacentMines == 0) {
            _openAdjacentCells(newRow, newCol);
          }
        });
      }
    }

    if (gameOver) return;

    if (_checkForWin()) {
      gameOver = true;
      for (final row in grid) {
        for (final cell in row) {
          if (cell.hasMine) {
            cell.isOpen = true;
          }
        }
      }
      showSnackBar(context, message: "Congratulation :D");
    }
  }

  void _handleCellLongPress(Cell cell) {
    if (cell.isOpen) return;
    if (flagCount <= 0 && !cell.isFlagged) return;

    setState(() {
      cell.isFlagged = !cell.isFlagged;

      if (cell.isFlagged) {
        flagCount--;
      } else {
        flagCount++;
      }
    });
  }

  void _reset() {
    setState(() {
      grid = [];
      gameOver = false;
      flagCount = 10;
      firstTap = true;
    });

    _intializeGrid();
  }

  void showSnackBar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Minesweeper',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "Flag",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      flagCount.toString(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(
                    Icons.restart_alt,
                  ),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
              ],
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.all(24),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: rows * columns,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final int row = index ~/ columns;
              final int col = index % columns;
              final cell = grid[row][col];

              return GestureDetector(
                onTap: () => _handleCellTap(cell),
                //   if (firstTap) {
                //     _handleCellFirstTap(cell);
                //   }
                //   _handleCellTap(cell);
                // },
                onLongPress: () => _handleCellLongPress(cell),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: cell.isOpen
                        ? Colors.white
                        : cell.isFlagged
                            ? AppColor.primarySwatch[100]
                            : AppColor.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(-4, -4),
                        color: AppColor.white,
                      ),
                      BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(4, 4),
                        color: AppColor.lightGray,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cell.isOpen
                          ? cell.hasMine
                              ? '💣'
                              : '${cell.adjacentMines}'
                          : cell.isFlagged
                              ? '🚩'
                              : '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: cell.isFlagged ? 24 : 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class Cell {
  int row;
  int col;

  bool hasMine;
  bool isOpen;
  bool isFlagged;

  /// the sum of surounded mines
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isFlagged = false,
    this.hasMine = false,
    this.isOpen = false,
    this.adjacentMines = 0,
  });
}
