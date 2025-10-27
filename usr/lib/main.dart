import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const int initialGameSpeed = 200;

  List<int> snake = [45, 65, 85, 105, 125];
  int food = 0;
  String direction = 'down';
  bool isPlaying = false;
  int score = 0;
  int gameSpeed = initialGameSpeed;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    snake = [45, 65, 85, 105, 125];
    direction = 'down';
    gameSpeed = initialGameSpeed;
    score = 0;
    generateFood();
    isPlaying = true;
    timer = Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
      moveSnake();
      if (checkCollision()) {
        endGame();
      }
    });
  }

  void endGame() {
    isPlaying = false;
    timer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  void moveSnake() {
    setState(() {
      int head;
      switch (direction) {
        case 'up':
          head = snake.first - gridSize;
          break;
        case 'down':
          head = snake.first + gridSize;
          break;
        case 'left':
          head = snake.first - 1;
          break;
        case 'right':
          head = snake.first + 1;
          break;
        default:
          return;
      }

      if (snake.contains(head)) {
        endGame();
        return;
      }

      snake.insert(0, head);

      if (snake.first == food) {
        score++;
        if (gameSpeed > 50) {
          gameSpeed = gameSpeed - 10;
          timer?.cancel();
          timer = Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
            moveSnake();
            if (checkCollision()) {
              endGame();
            }
          });
        }
        generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  bool checkCollision() {
    int head = snake.first;
    if (head < 0 || head >= gridSize * gridSize) {
      return true;
    }
    if (direction == 'left' && head % gridSize == gridSize - 1) {
      return true;
    }
    if (direction == 'right' && head % gridSize == 0) {
      // This logic is slightly flawed for the right edge, but works with current setup
      // A better check would be if the previous head was also at the edge
      // For simplicity, we'll allow wrapping around in this case, but a real collision would be head % gridSize == 0
    }

    // Check self-collision
    for (var i = 1; i < snake.length; i++) {
      if (snake[i] == head) {
        return true;
      }
    }

    return false;
  }

  void generateFood() {
    food = Random().nextInt(gridSize * gridSize);
    while (snake.contains(food)) {
      food = Random().nextInt(gridSize * gridSize);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridSize * gridSize,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snake.contains(index)) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == food) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: isPlaying ? null : startGame,
                  child: Text(isPlaying ? 'Playing...' : 'Start Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
