import 'package:chidvest/models/child.dart';
import 'package:chidvest/models/search.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import 'dart:ui';

import 'package:webview_flutter/webview_flutter.dart';

// Main Page to navigate between activities
class KidsActivitiesPage extends StatelessWidget {
  
  const KidsActivitiesPage({Key? key,}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fun Activities',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActivityCard(
                context,
                'Painting Fun',
                'Create colorful artworks!',
                Icons.brush,
                Colors.purple,
                const PaintingApp(),
              ),
              const SizedBox(height: 16),
              _buildActivityCard(
                context,
                'Tic Tac Toe',
                'Play against the computer!',
                Icons.grid_on,
                Colors.green,
                const TicTacToeGame(),
              ),
              const SizedBox(height: 16),
              _buildActivityCard(
                context,
                'Story Time',
                'Read a fun story!',
                Icons.book,
                Colors.orange,
                const StoryPage(),
              ),
              const SizedBox(height: 16),
              _buildActivityCard(
                context,
                'Net Browsing',
                'hello Google',
                Icons.language,
                Colors.blue,
                ChildBrowser(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String title,
      String description, IconData icon, Color color, Widget destination) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. PAINTING APP
class PaintingApp extends StatefulWidget {
  const PaintingApp({Key? key}) : super(key: key);

  @override
  _PaintingAppState createState() => _PaintingAppState();
}

class _PaintingAppState extends State<PaintingApp> {
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  List<DrawingPoint?> points = [];
  List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.brown,
    Colors.white
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painting Fun'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                points.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Canvas area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            width: double.infinity,
            height: double.infinity,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  points.add(
                    DrawingPoint(
                      offset: details.localPosition,
                      paint: Paint()
                        ..color = selectedColor
                        ..isAntiAlias = true
                        ..strokeWidth = strokeWidth
                        ..strokeCap = StrokeCap.round,
                    ),
                  );
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  points.add(
                    DrawingPoint(
                      offset: details.localPosition,
                      paint: Paint()
                        ..color = selectedColor
                        ..isAntiAlias = true
                        ..strokeWidth = strokeWidth
                        ..strokeCap = StrokeCap.round,
                    ),
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  points.add(null);
                });
              },
              child: CustomPaint(
                painter: DrawingPainter(points: points),
                size: Size.infinite,
              ),
            ),
          ),

          // Color palette and brush size controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Brush size slider
                  Row(
                    children: [
                      const Icon(Icons.brush, size: 20),
                      Expanded(
                        child: Slider(
                          value: strokeWidth,
                          min: 1,
                          max: 20,
                          divisions: 19,
                          onChanged: (value) {
                            setState(() {
                              strokeWidth = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  // Color palette
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Drawing point class
class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

// Custom painter for drawing
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
          PointMode.points,
          [points[i]!.offset],
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

// 2. TIC TAC TOE GAME
class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({Key? key}) : super(key: key);

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late List<List<String>> board;
  late bool isPlayerTurn;
  late String gameStatus;
  late int playerWins;
  late int computerWins;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.generate(3, (_) => List.filled(3, ''));
    isPlayerTurn = true;
    gameStatus = "Your turn! Tap to place X";
    playerWins = 0;
    computerWins = 0;
  }

  void _resetBoard() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      isPlayerTurn = true;
      gameStatus = "Your turn! Tap to place X";
    });
  }

  void _makeMove(int row, int col) {
    if (board[row][col].isNotEmpty || !isPlayerTurn) return;

    setState(() {
      // Player's move
      board[row][col] = 'X';
      isPlayerTurn = false;

      // Check if player won
      if (_checkWinner('X')) {
        gameStatus = "You win! 🎉";
        playerWins++;
        return;
      }

      // Check for a draw
      if (_isBoardFull()) {
        gameStatus = "It's a draw! 🤝";
        return;
      }

      gameStatus = "Computer is thinking...";

      // Delay computer's move for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        _computerMove();
      });
    });
  }

  void _computerMove() {
    if (_isBoardFull()) return;

    // Simple AI for computer move
    int row, col;

    // Try to win
    var winningMove = _findWinningMove('O');
    if (winningMove != null) {
      row = winningMove[0];
      col = winningMove[1];
    }
    // Block player from winning
    else {
      var blockingMove = _findWinningMove('X');
      if (blockingMove != null) {
        row = blockingMove[0];
        col = blockingMove[1];
      }
      // Take center if available
      else if (board[1][1].isEmpty) {
        row = 1;
        col = 1;
      }
      // Random move
      else {
        var emptySpots = <List<int>>[];
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            if (board[i][j].isEmpty) {
              emptySpots.add([i, j]);
            }
          }
        }
        if (emptySpots.isNotEmpty) {
          var randomIndex = Random().nextInt(emptySpots.length);
          row = emptySpots[randomIndex][0];
          col = emptySpots[randomIndex][1];
        } else {
          return; // No empty spots
        }
      }
    }

    setState(() {
      board[row][col] = 'O';

      // Check if computer won
      if (_checkWinner('O')) {
        gameStatus = "Computer wins! 😔";
        computerWins++;
        return;
      }

      // Check for a draw
      if (_isBoardFull()) {
        gameStatus = "It's a draw! 🤝";
        return;
      }

      isPlayerTurn = true;
      gameStatus = "Your turn! Tap to place X";
    });
  }

  List<int>? _findWinningMove(String player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      var count = 0;
      var emptyCol = -1;
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == player) count++;
        if (board[i][j].isEmpty) emptyCol = j;
      }
      if (count == 2 && emptyCol != -1) {
        return [i, emptyCol];
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      var count = 0;
      var emptyRow = -1;
      for (int i = 0; i < 3; i++) {
        if (board[i][j] == player) count++;
        if (board[i][j].isEmpty) emptyRow = i;
      }
      if (count == 2 && emptyRow != -1) {
        return [emptyRow, j];
      }
    }

    // Check diagonals
    var count = 0;
    var emptyIdx = [-1, -1];
    for (int i = 0; i < 3; i++) {
      if (board[i][i] == player) count++;
      if (board[i][i].isEmpty) emptyIdx = [i, i];
    }
    if (count == 2 && emptyIdx[0] != -1) {
      return emptyIdx;
    }

    count = 0;
    emptyIdx = [-1, -1];
    for (int i = 0; i < 3; i++) {
      if (board[i][2 - i] == player) count++;
      if (board[i][2 - i].isEmpty) emptyIdx = [i, 2 - i];
    }
    if (count == 2 && emptyIdx[0] != -1) {
      return emptyIdx;
    }

    return null;
  }

  bool _checkWinner(String player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player &&
          board[i][1] == player &&
          board[i][2] == player) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == player &&
          board[1][i] == player &&
          board[2][i] == player) {
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player) {
      return true;
    }

    return false;
  }

  bool _isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Score and status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('You (X)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$playerWins',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Computer (O)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$computerWins',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Game status
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                gameStatus,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Game board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      return GestureDetector(
                        onTap: () {
                          if (_checkWinner('X') ||
                              _checkWinner('O') ||
                              _isBoardFull()) {
                            // Game is over, reset the board
                            _resetBoard();
                          } else {
                            _makeMove(row, col);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: col < 2
                                  ? BorderSide(color: Colors.grey.shade400)
                                  : BorderSide.none,
                              bottom: row < 2
                                  ? BorderSide(color: Colors.grey.shade400)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              board[row][col],
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: board[row][col] == 'X'
                                    ? Colors.blue
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Reset button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _resetBoard,
              icon: const Icon(Icons.refresh),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. SIMPLE STORY PAGE
class StoryPage extends StatelessWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Time'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story title
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/teddy_bear.png', // Replace with your asset
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.auto_stories,
                              size: 64,
                              color: Colors.brown,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Teddys Big Adventure',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Story content with paragraphs
              _buildStoryParagraph(
                  'Once upon a time, there was a teddy bear named Teddy. Teddy was a small brown bear with a red bow tie. He lived in a toy box with all the other toys.'),

              _buildStoryParagraph(
                  'One day, when everyone was asleep, Teddy decided to go on an adventure. He climbed out of the toy box and jumped to the floor with a soft thud.'),

              _buildStoryParagraph(
                  '"I wonder whats in the kitchen," thought Teddy. He walked down the hallway, his little paws making no sound on the carpet.'),

              _buildStoryParagraph(
                  'In the kitchen, Teddy found a cookie jar on the counter. "Mmm, cookies!" he said. But the counter was too high for him to reach.'),

              _buildStoryParagraph(
                  'Just then, Teddy heard a sound. It was Buddy, the family dog! "Hello Buddy," whispered Teddy. "Can you help me get a cookie?"'),

              _buildStoryParagraph(
                  'Buddy wagged his tail and barked softly. He walked to the counter and stood on his hind legs. Teddy climbed onto Buddys back and reached for the cookie jar.'),

              _buildStoryParagraph(
                  'But oh no! The cookie jar wobbled and fell with a CRASH! Cookies scattered all over the floor.'),

              _buildStoryParagraph(
                  '"Oh dear," said Teddy. "We better clean this up!" Teddy and Buddy quickly ate all the cookies. Then they heard footsteps coming down the stairs.'),

              _buildStoryParagraph(
                  'Teddy rushed back to the toy box and jumped inside. He closed his eyes and pretended to be just a regular teddy bear again.'),

              _buildStoryParagraph(
                  'In the morning, Teddys owner Emma couldnt understand why there were cookie crumbs on Buddys fur and a smile on her teddy bears face.'),

              _buildStoryParagraph(
                  'And that was Teddys big adventure! But it wouldnt be his last...'),

              // The end
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'The End',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          height: 1.5,
        ),
      ),
    );
  }
}

class ChildBrowser extends StatefulWidget {
  @override
  _ChildBrowserState createState() => _ChildBrowserState();
}

class _ChildBrowserState extends State<ChildBrowser> {
  late final WebViewController _controller;
  Box<SearchHistory> searchBox = Hive.box<SearchHistory>('search_history');
  Box<BlockedWebsite> blockedBox = Hive.box<BlockedWebsite>('blocked_websites');

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (isBlocked(url)) {
              _controller.loadRequest(Uri.parse("about:blank"));
              showBlockedDialog(url);
            } else {
              saveHistory(url);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse("https://www.google.com"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Safe Browser")),
      body: WebViewWidget(controller: _controller),
    );
  }

  bool isBlocked(String url) {
    return blockedBox.values.any((blocked) => url.contains(blocked.url));
  }

  void saveHistory(String url) {
    searchBox.add(SearchHistory(url: url, timestamp: DateTime.now()));
  }

  void showBlockedDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Access Restricted"),
        content: Text("This site ($url) is blocked by the parent."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
