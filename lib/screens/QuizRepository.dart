import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database _database;

class QuizRepository {
  String? _currentStudentEmail;

  QuizRepository() {
    _initializeDatabase(); // Calling _initializeDatabase() in the constructor
  }

  Future<void> _initializeDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'quiz.db');

  // Close the database connection if it's already open
  await _database?.close();

  // Open the database with openDatabase and onCreate callback
  _database = await openDatabase(
    path,
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE students(id INTEGER PRIMARY KEY, email TEXT, password TEXT)',
      );
      await db.execute(
        'CREATE TABLE quizzes(id INTEGER PRIMARY KEY, user_id INTEGER, title TEXT, description TEXT, FOREIGN KEY(user_id) REFERENCES students(id))',
      );
      await db.execute(
        'CREATE TABLE questions(id INTEGER PRIMARY KEY, quiz_id INTEGER, question TEXT, FOREIGN KEY(quiz_id) REFERENCES quizzes(id))',
      );
      await db.execute(
        'CREATE TABLE options(id INTEGER PRIMARY KEY, question_id INTEGER, option TEXT, is_correct INTEGER, FOREIGN KEY(question_id) REFERENCES questions(id))',
      );
      await db.execute(
        'CREATE TABLE student_scores(id INTEGER PRIMARY KEY, student_id INTEGER, quiz_id INTEGER, score INTEGER, FOREIGN KEY(student_id) REFERENCES students(id), FOREIGN KEY(quiz_id) REFERENCES quizzes(id))',
      );
    },
    version: 2, // Increase the version number
  );
}
  Future<int> registerStudent(String email, String password) async {
  int studentId = -1;

  try {
    // Check if the user exists in the SQLite database
    final result = await _database.query(
      'students',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isEmpty) {
      // If user doesn't exist, insert the user
      studentId = await _database.insert(
        'students',
        {'email': email, 'password': password},
      );
    } else {
      // If user exists, retrieve the student ID
      studentId = result[0]['id'] as int;
    }
  } catch (e) {
    if (e is DatabaseException && e.toString().contains('no such table')) {
      // If 'no such table' error occurs, create the required tables and retry registration
      await _initializeDatabase();
      studentId = await registerStudent(email, password); // Retry registering after table creation
    } else {
      // Print and return -1 for other exceptions
      print('Error occurred during registration: $e');
      studentId = -1;
    }
  }

  return studentId;
}
  Future<Database> getDatabase() async {
  if (_database == null) {
    await _initializeDatabase();
  }
  return _database!;
}

  Future<int> login(String email, String password) async {
    int studentId = -1;

    try {
      // Ensure database is initialized before executing the query
      await _initializeDatabase();

      // Check if the user exists in the SQLite database
      final result = await _database.query(
        'students',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        // If user exists, retrieve the student ID and set the current email
        studentId = result[0]['id'] as int;
        _currentStudentEmail = email;
      } else {
        // If user doesn't exist, throw an exception
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      // Handle exceptions
      print('Error occurred during login: $e');
      rethrow;
    }

    return studentId;
  }

  Future<void> saveStudentScore(int studentId, int quizId, int score) async {
    await _initializeDatabase();

    await _database.insert(
      'student_scores',
      {'student_id': studentId, 'quiz_id': quizId, 'score': score},
    );
  }

  // Future<void> initializeDatabase() async {
  //   if (_database == null) {
  //     _initializeDatabase();
  //   }
  // }

Future<int> register(String email, String password) async {
  try {
    final studentId = await _database.insert(
      'students',
      {'email': email, 'password': password},
    );
    return studentId;
  } catch (e) {
    print('Error occurred during registration: $e');
    return -1;
  }
}

  Future<void> signUp(String email, String password) async {
    if (_database == null) {
      await _initializeDatabase();
    }

    await _database.insert(
      'students',
      {'email': email, 'password': password},
    );
    _currentStudentEmail = email;
  }

  Future<void> signIn(String email, String password) async {
    if (_database == null) {
      await _initializeDatabase();
    }
    final result = await _database.query(
      'students',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) {
      throw Exception('Invalid email or password');
    }
  }

  bool isSignedIn() {
    return _currentStudentEmail != null;
  }

  Future<void> signOut() async {
    _currentStudentEmail = null;
  }

  Future<int> createStudent(String name, String email) async {
    await _initializeDatabase();
    final studentId = await _database.insert(
      'students',
      {'name': name, 'email': email},
    );
    return studentId;
  }

  Future<int> getStudentId() async {
    if (_currentStudentEmail == null) {
      throw Exception('Not signed in');
    }

    final result = await _database.query(
      'students',
      where: 'email = ?',
      whereArgs: [_currentStudentEmail],
    );

    if (result.isEmpty) {
      throw Exception('Failed to fetch student ID');
    }

    return result[0]['id'] as int;
  }

  Future<List<dynamic>> getQuizzes() async {
    await _initializeDatabase();

    try {
      final allQuizzes = await _database.query('quizzes');

      final quizzes = <dynamic>[];
      for (final quiz in allQuizzes) {
        final int quizId = quiz['id'] as int;
        final List<dynamic> questions = await getQuizQuestions(quizId);
        quizzes.add({
          'id': quizId,
          'title': quiz['title'],
          'questions': questions,
        });
      }

      return quizzes;
    } catch (error) {
      print('Error fetching quizzes: $error');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> getQuizQuestions(int quizId) async {
    await _initializeDatabase();
    try {
      final allQuestions = await _database.query(
        'questions',
        where: 'quiz_id = ?',
        whereArgs: [quizId],
      );

      return await Future.wait(allQuestions.map((question) async {
        final int questionId = question['id'] as int;
        final List<dynamic> options = await getQuestionOptions(questionId);

        return {
          'id': questionId,
          'question': question['question'],
          'options': options,
        };
      }));
    } catch (error) {
      print('Error fetching quiz questions: $error');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> getQuestionOptions(int questionId) async {
    await _initializeDatabase();
    try {
      final allOptions = await _database.query(
        'options',
        where: 'question_id = ?',
        whereArgs: [questionId],
      );

      return allOptions.map((option) {
        return {
          'id': option['id'] as int,
          'option': option['option'] as String,
          'isCorrect': option['is_correct'] == 1,
        };
      }).toList();
    } catch (error) {
      print('Error fetching question options: $error');
      return <dynamic>[];
    }
  }

  Future<int> createQuiz(String title, String description) async {
    await _initializeDatabase();
    final quizId = await _database.insert(
      'quizzes',
      {'title': title, 'description': description},
    );
    return quizId;
  }

  Future<int> createQuestion(int quizId, String question) async {
    await _initializeDatabase();
    final questionId = await _database.insert(
      'questions',
      {'quiz_id': quizId, 'question': question},
    );
    return questionId;
  }

  Future<int> createOption(int questionId, String option, bool isCorrect) async {
    await _initializeDatabase();
    final optionId = await _database.insert(
      'options',
      {'question_id': questionId, 'option': option, 'is_correct': isCorrect ? 1 : 0},
    );
    return optionId;
  }

  Future<void> updateQuiz(int quizId, String newTitle) async {
    await _initializeDatabase();
    await _database.update(
      'quizzes',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [quizId],
    );
  }

  Future<void> updateQuestion(int questionId, String newQuestion) async {
    await _initializeDatabase();
    await _database.update(
      'questions',
      {'question': newQuestion},
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<void> updateOption(int optionId, String newOption, bool isCorrect) async {
    await _initializeDatabase();
    await _database.update(
      'options',
      {'option': newOption, 'is_correct': isCorrect ? 1 : 0},
      where: 'id = ?',
      whereArgs: [optionId],
    );
  }

  Future<void> deleteQuestion(int questionId) async {
    await _database.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<void> deleteQuiz(int quizId) async {
    await _database.delete(
      'quizzes',
      where: 'id = ?',
      whereArgs: [quizId],
    );
  }

  Future<void> deleteOption(int optionId) async {
    await _database.delete(
      'options',
      where: 'id = ?',
      whereArgs: [optionId],
    );
  }
}