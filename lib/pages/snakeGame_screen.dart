// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

enum Direction { up, down, left, right }

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  // Coordenadas iniciales de la comida
  Offset foodCoordinates = const Offset(0, 0);
  List<Offset> snakeSegments = [
    const Offset(3, 5), // Coordenadas iniciales del primer segmento
    const Offset(3, 4), // Coordenadas iniciales del segundo segmento
  ];

  int socreGame = 0;

  bool isPlaying = false;

  Timer? gameTimer;
  int numRows = 13; // Número de filas en la cuadrícula
  int numColumns = 10; // Número de columnas en la cuadrícula
  Direction currentDirection = Direction.right;

  void changeDirection(Direction newDirection) {
    if (newDirection == Direction.up && currentDirection != Direction.down) {
      currentDirection = Direction.up;
    } else if (newDirection == Direction.down &&
        currentDirection != Direction.up) {
      currentDirection = Direction.down;
    } else if (newDirection == Direction.left &&
        currentDirection != Direction.right) {
      currentDirection = Direction.left;
    } else if (newDirection == Direction.right &&
        currentDirection != Direction.left) {
      currentDirection = Direction.right;
    }
  }

  // Función para iniciar el temporizador del juego
  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      moveSnake();
    });
  }

  // Función para detener el temporizador del juego
  void stopGameTimer() {
    gameTimer?.cancel();
  }

  void playGame() {
    generateRandomFood();
    startGameTimer();
    setState(() {
      isPlaying = true;
    });
  }

  void resetGame() {
    setState(() {
      snakeSegments = [
        const Offset(3, 5), // Coordenadas iniciales del primer segmento
        const Offset(3, 4), // Coordenadas iniciales del segundo segmento
      ];
      socreGame = 0;
      playGame();
    });
  }

  @override
  void initState() {
    //iniciar el juego a los 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      AwesomeDialog(
        dismissOnTouchOutside: false,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Start',
        btnOkOnPress: () async {
          playGame();
        },
      ).show();
    });
    super.initState();
    // Inicializa las coordenadas de la comida al comienzo del juego
  }

  void moveSnake() {
    setState(() {
      // Obtiene la cabeza de la serpiente
      Offset head = snakeSegments.first;

      // Calcula la posición de la siguiente celda en la dirección actual
      Offset newHead;
      switch (currentDirection) {
        case Direction.up:
          newHead = Offset(head.dx, head.dy - 1);
          break;
        case Direction.down:
          newHead = Offset(head.dx, head.dy + 1);
          break;
        case Direction.left:
          newHead = Offset(head.dx - 1, head.dy);
          break;
        case Direction.right:
          newHead = Offset(head.dx + 1, head.dy);
          break;
      }

      // Agrega la nueva cabeza a la serpiente
      snakeSegments.insert(0, newHead);

      // Remueve la cola de la serpiente (si es demasiado larga)
      if (snakeSegments.length > 2) {
        snakeSegments.removeLast();
      }

      if (checkSelfCollision()) {
        // La serpiente se ha autocolisionado, maneja la finalización del juego aquí.
        stopGameTimer();
        AwesomeDialog(
          dismissOnTouchOutside: false,
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.BOTTOMSLIDE,
          // title: 'Game Over',
          body: Column(
            children: [
              Text('Game Over',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.black,
                    fontSize: 25,
                  )),
              const SizedBox(
                height: 10,
              ),
              Text('Score: $socreGame',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.black,
                    fontSize: 15,
                  )),
            ],
          ),
          btnOkOnPress: () async {
            resetGame();
          },
        ).show();
      }

      // Verifica colisiones con la comida u otras condiciones de finalización del juego
      checkCollisions();
    });
  }

  bool checkSelfCollision() {
    final head = snakeSegments.first;

    // Itera a través de los segmentos de la serpiente (excluyendo la cabeza)
    for (int i = 1; i < snakeSegments.length; i++) {
      if (snakeSegments[i] == head) {
        // La cabeza de la serpiente colisionó con uno de sus segmentos, lo que indica una autocolisión.
        return true;
      }
    }

    // No se encontraron colisiones con la serpiente misma.
    return false;
  }

  void checkCollisions() {
    // Verifica si la cabeza de la serpiente colisiona con la comida
    if (snakeSegments.first == foodCoordinates) {
      // La serpiente ha comido la comida, así que genera una nueva comida
      generateRandomFood();

      // Aquí puedes agregar lógica adicional, como hacer crecer la serpiente
      //aumentamos el tamaño de la serpiente
      snakeSegments.add(snakeSegments.last);
      // o aumentar la puntuación del juego.
      socreGame++;
    }

    // Verifica si la cabeza de la serpiente colisiona con los límites del juego
    if (snakeSegments.first.dx < 0 ||
        snakeSegments.first.dx >= numColumns ||
        snakeSegments.first.dy < 0 ||
        snakeSegments.first.dy >= numRows) {
      stopGameTimer();
      AwesomeDialog(
        dismissOnTouchOutside: false,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.BOTTOMSLIDE,
        // title: 'Game Over',
        body: Column(
          children: [
            Text('Game Over',
                style: GoogleFonts.pressStart2p(
                  color: Colors.black,
                  fontSize: 25,
                )),
            const SizedBox(
              height: 10,
            ),
            Text('Score: $socreGame',
                style: GoogleFonts.pressStart2p(
                  color: Colors.black,
                  fontSize: 15,
                )),
          ],
        ),
        btnOkOnPress: () async {
          resetGame();
        },
      ).show();

      // La serpiente ha chocado con los límites del juego, aquí puedes manejar la finalización del juego.
      // Puedes mostrar un mensaje de "Game Over" y reiniciar el juego, por ejemplo.
      // También puedes detener el temporizador (timer) para detener el movimiento de la serpiente.
    }

    // Aquí puedes agregar más comprobaciones de colisiones según las reglas de tu juego.
  }

  void generateRandomFood() {
    final random = Random();
    const maxX = 10; // Número de columnas en la cuadrícula
    const maxY = 13; // Número de filas en la cuadrícula
    Offset newFoodCoordinates;

    do {
      // Genera coordenadas aleatorias para la comida dentro de la cuadrícula
      final foodX = random.nextInt(maxX).toDouble();
      final foodY = random.nextInt(maxY).toDouble();
      newFoodCoordinates = Offset(foodX, foodY);
    } while (snakeSegments.contains(
        newFoodCoordinates)); // Verifica que la comida no esté en la serpiente

    setState(() {
      foodCoordinates = newFoodCoordinates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 90, 158, 120),
        title: BounceInDown(
            duration: const Duration(seconds: 2),
            child: Text('Score: $socreGame',
                style: GoogleFonts.pressStart2p(
                  color: Colors.black,
                  fontSize: 20,
                ))),
      ),
      body: Column(
        children: [
          // Lienzo del juego (70% de la pantalla)
          SizedBox(
            width: 425,
            height: 533,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                color:
                    Colors.grey[200], // Puedes personalizar el color de fondo
                // Aquí debes dibujar tu juego, la serpiente y la comida.
                child: CustomPaint(
                  painter: SnakeGamePainter(
                    // Pasa las coordenadas de la serpiente y la comida
                    snakeSegments: snakeSegments,
                    foodCoordinates: foodCoordinates,
                    segmentSize: 50.0, // Tamaño de segmento de serpiente
                    numRows: 13, // Número de filas en la cuadrícula
                    numColumns: 10, // Número de columnas en la cuadrícula
                    cellSize: 38.1, // Tamaño de celda de la cuadrícula
                    isPlaying: isPlaying, // Estado del juego
                  ),
                ),
              ),
            ),
          ),

          // Botones de movimiento (30% de la pantalla)

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BounceInUp(
                duration: const Duration(seconds: 2),
                child: GestureDetector(
                    onTap: () => changeDirection(Direction.up),
                    child: Image.asset('assets/img/up.png',
                        width: 80, height: 80, fit: BoxFit.fill)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BounceInLeft(
                    duration: const Duration(seconds: 2),
                    child: GestureDetector(
                        onTap: () => changeDirection(Direction.left),
                        child: Image.asset('assets/img/izq.png',
                            width: 80, height: 80, fit: BoxFit.fill)),
                  ),
                  BounceInRight(
                    duration: const Duration(seconds: 2),
                    child: GestureDetector(
                        onTap: () => changeDirection(Direction.right),
                        child: Image.asset('assets/img/der.png',
                            width: 80, height: 80, fit: BoxFit.fill)),
                  ),
                ],
              ),
              BounceInDown(
                duration: const Duration(seconds: 2),
                child: GestureDetector(
                    onTap: () => changeDirection(Direction.down),
                    child: Image.asset('assets/img/dow.png',
                        width: 80, height: 80, fit: BoxFit.fill)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SnakeGamePainter extends CustomPainter {
  final List<Offset> snakeSegments;
  final Offset foodCoordinates;
  final double segmentSize;
  final int numRows;
  final int numColumns;
  final double cellSize;
  final bool isPlaying;

  SnakeGamePainter({
    required this.isPlaying,
    required this.snakeSegments,
    required this.foodCoordinates,
    required this.segmentSize,
    required this.numRows,
    required this.numColumns,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibuja la cuadrícula
    final Paint gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numColumns; col++) {
        final left = col * cellSize;
        final top = row * cellSize;
        final rect = Rect.fromLTWH(left, top, cellSize, cellSize);
        canvas.drawRect(rect, gridPaint);
      }
    }

    // Dibuja el cuadro de límite
    final Paint borderPaint = Paint()
      ..color = const Color.fromARGB(255, 90, 158, 120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
        borderPaint);

    if (isPlaying) {
      final Paint snakePaint = Paint()
        ..color = const Color.fromARGB(255, 90, 158, 120);

      for (var segment in snakeSegments) {
        final left = segment.dx * cellSize;
        final top = segment.dy * cellSize;
        final rect = Rect.fromLTWH(left, top, cellSize, cellSize);
        canvas.drawRect(rect, snakePaint);
      }

      // Dibuja la comida
      final Paint foodPaint = Paint()..color = Colors.red;
      final foodLeft = foodCoordinates.dx * cellSize;
      final foodTop = foodCoordinates.dy * cellSize;
      final foodRect = Rect.fromLTWH(foodLeft, foodTop, cellSize, cellSize);
      canvas.drawRect(foodRect, foodPaint);
      // Dibuja la serpiente
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
