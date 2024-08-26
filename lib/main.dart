import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:confetti/confetti.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExerciseScreen(),
    );
  }
}

class ExerciseScreen extends StatefulWidget {
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  String _error = '';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _fetchExercises();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    final url = Uri.parse('https://exercisedb.p.rapidapi.com/exercises');
    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-host': 'exercisedb.p.rapidapi.com',
          'x-rapidapi-key': 'edad0a1eccmsh8149e02a09690adp17e4cfjsn20d6039409e5',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _exercises = data;
          _isLoading = false;
        });
        _confettiController.play(); // Trigger confetti animation on successful data load
      } else {
        setState(() {
          _error = 'Failed to load exercises: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Container(
                child: Text(
                  'Exercise-Db',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                        ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
                        : ListView.builder(
                            itemCount: _exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = _exercises[index];
                              return Card(
                                color: Color.fromARGB(255, 255, 255, 255),
                                margin: EdgeInsets.all(8.0),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    exercise['gifUrl'] != null
                                        ? Container(
                                            width: double.infinity,
                                            height: 200, // Increased height for larger GIFs
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                              child: Image.network(
                                                exercise['gifUrl'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: double.infinity,
                                            height: 200,
                                            color: Color.fromARGB(255, 5, 4, 4),
                                            child: Icon(
                                              Icons.fitness_center,
                                              size: 100,
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        exercise['name'] ?? 'No Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      child: Text(
                                        exercise['instructions'] != null && exercise['instructions'].isNotEmpty
                                            ? exercise['instructions'].join(', ')
                                            : 'No Instructions',
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // or BlastDirectionality.directional
            shouldLoop: false,
            colors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
            createParticlePath: drawStar,
          ),
        ],
      ),
    );
  }

  Path drawStar(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    path.moveTo(center.dx, center.dy - radius);
    for (int i = 1; i <= 5; i++) {
      final x = center.dx + radius * cos(i * 2 * pi / 5);
      final y = center.dy - radius * sin(i * 2 * pi / 5);
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }
}
