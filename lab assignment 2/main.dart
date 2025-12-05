import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'package:intl/intl.dart';

// --- Global Constants and Model ---

// Database file name
const String databaseName = 'number_game.db';
// Table name for game history
const String tableName = 'game_history';

// Data Model for a single game result entry
class GameResult {
  final int? id;
  final int attempt;
  final String status;
  final DateTime timestamp;

  GameResult({
    this.id,
    required this.attempt,
    required this.status,
    required this.timestamp,
  });

  // Convert a GameResult object into a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'attempt': attempt,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Convert a Map (from the database) into a GameResult object
  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      id: map['id'],
      attempt: map['attempt'],
      status: map['status'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}

// --- Database Helper ---

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the default document directory path for the database
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);

    // Open the database or create it if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Create the game_history table
        return db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            attempt INTEGER,
            status TEXT,
            timestamp INTEGER
          )
          ''');
      },
    );
  }

  // Insert a new game result into the database
  Future<void> insertResult(GameResult result) async {
    final db = await database;
    await db.insert(
      tableName,
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all game results from the database
  Future<List<GameResult>> getHistory() async {
    final db = await database;
    // Query the table, ordering by timestamp descending (most recent first)
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );

    // Convert the List<Map<String, dynamic>> to List<GameResult>
    return List.generate(maps.length, (i) {
      return GameResult.fromMap(maps[i]);
    });
  }
}

// --- Main Application ---

final dbHelper = DatabaseHelper();

void main() {
  // Ensure that Flutter is initialized before using the database or other plugins
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuessingGameApp());
}

class GuessingGameApp extends StatelessWidget {
  const GuessingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          filled: true,
          fillColor: Colors.deepPurple.shade50,
        ),
      ),
      // Define all named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/result': (context) => const ResultScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

// --- Home/Guess Input Screen ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Generate a random number between 1 and 100 at the start of the game
  late int _targetNumber;
  final TextEditingController _guessController = TextEditingController();
  String _message = 'Guess a number between 1 and 100!';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  // Function to reset the game and generate a new target number
  void _startNewGame() {
    setState(() {
      _targetNumber = 1 + Random().nextInt(100); // 1 to 100 inclusive
      _message = 'Guess a number between 1 and 100!';
      _guessController.clear();
      debugPrint('New target number: $_targetNumber'); // For console testing
    });
  }

  // Function to process the user's guess
  void _checkGuess(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Input is validated, parse the guess
      final int? userGuess = int.tryParse(_guessController.text);

      if (userGuess == null) return; // Should not happen due to validator

      String resultStatus;

      if (userGuess == _targetNumber) {
        resultStatus = 'Correct!';
      } else if (userGuess > _targetNumber) {
        resultStatus = 'Too High';
      } else {
        resultStatus = 'Too Low';
      }

      // 1. Create the game result object
      final newResult = GameResult(
        attempt: userGuess,
        status: resultStatus,
        timestamp: DateTime.now(),
      );

      // 2. Store the result in SQLite
      // Capture navigator before the async gap so we don't use BuildContext after await
      final navigator = Navigator.of(context);
      await dbHelper.insertResult(newResult);

      // 3. Navigate to the ResultScreen (ensure widget still mounted)
      if (!mounted) return;
      navigator.pushNamed(
        '/result',
        arguments: {
          'guess': userGuess,
          'status': resultStatus,
          'target': _targetNumber,
          'onNewGame': _startNewGame, // Pass the callback to start a new game
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guessing Game'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Button to navigate to History screen
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).pushNamed('/history');
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Game Title and Instructions
              Text(
                'The Great Number Guess',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Guess Input Form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _guessController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Enter your guess',
                    hintText: 'e.g., 42',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number.';
                    }
                    final int? guess = int.tryParse(value);
                    if (guess == null || guess < 1 || guess > 100) {
                      return 'Must be a whole number between 1 and 100.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Guess Button
              ElevatedButton.icon(
                onPressed: () => _checkGuess(context),
                icon: const Icon(Icons.send),
                label: const Text('CHECK GUESS'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.deepPurple.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }
}

// --- Result Screen ---

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  // Helper function to determine the color based on the status
  Color _getStatusColor(String status) {
    if (status == 'Correct!') return Colors.green.shade600;
    if (status == 'Too High') return Colors.red.shade600;
    if (status == 'Too Low') return Colors.blue.shade600;
    return Colors.grey.shade600;
  }

  // Helper function to determine the icon based on the status
  IconData _getStatusIcon(String status) {
    if (status == 'Correct!') return Icons.check_circle_outline;
    if (status == 'Too High') return Icons.arrow_upward;
    if (status == 'Too Low') return Icons.arrow_downward;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed from the HomeScreen
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int guess = args['guess'] as int;
    final String status = args['status'] as String;
    final int target = args['target'] as int;
    final Function onNewGame = args['onNewGame'] as Function;

    final Color statusColor = _getStatusColor(status);
    final IconData statusIcon = _getStatusIcon(status);
    final bool isCorrect = status == 'Correct!';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess Result'),
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Result Status Icon
              Icon(statusIcon, size: 100, color: statusColor),
              const SizedBox(height: 20),

              // Status Text
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 10),

              // Details
              Text(
                'Your guess was: $guess',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
              if (isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'The number was $target! Great Job!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'The number to guess was $target.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ),

              const SizedBox(height: 60),

              // Back to Home Button
              ElevatedButton.icon(
                onPressed: () {
                  // If correct, start a new game by calling the callback
                  if (isCorrect) {
                    onNewGame();
                  }
                  // Navigate back to the home screen
                  Navigator.pop(context);
                },
                icon: Icon(isCorrect ? Icons.refresh : Icons.arrow_back),
                label: Text(isCorrect ? 'START NEW GAME' : 'TRY AGAIN'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: statusColor.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- History Screen ---

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<GameResult>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Load the history data when the screen initializes
    _historyFuture = dbHelper.getHistory();
  }

  // Refresh data from the database
  void _refreshHistory() {
    setState(() {
      _historyFuture = dbHelper.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory,
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: FutureBuilder<List<GameResult>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display error if fetching fails
            return Center(
              child: Text(
                'Error loading history: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Display message if history is empty
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text(
                    'No game history found.',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Start guessing on the home screen!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            // History loaded successfully, display the list
            final history = snapshot.data!;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isCorrect = item.status == 'Correct!';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isCorrect
                          ? Colors.green.shade400
                          : Colors.deepPurple.shade100,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCorrect
                          ? Colors.green
                          : Colors.deepPurple.shade200,
                      child: Text(
                        item.attempt.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      item.status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green.shade700
                            : Colors.deepPurple,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(item.timestamp.toLocal()),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      isCorrect ? Icons.star : Icons.chevron_right,
                      color: isCorrect ? Colors.amber : Colors.grey,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
