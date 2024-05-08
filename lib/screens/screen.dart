import 'package:flutter/material.dart';
import 'auth_repository.dart';
import 'package:midquiz/utils/validators.dart';
import 'package:midquiz/services/session_manager.dart';
import 'QuizRepository.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  final SessionManager _sessionManager = SessionManager(); // Instance of SessionManagersesss

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text.trim();
                String password = _passwordController.text.trim();
                
                // Validate email and password
                if (Validators.isValidEmail(username) && Validators.isValidPassword(password)) {
                  // Attempt login
                  if (await _authRepository.login(username, password)) {
                    // Set session data
                    _sessionManager.setSessionData(username);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => QuizManagementScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login failed. Please check your credentials.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid email or password.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuizBrowserScreen()));
              },
              child: Text('Go to Quiz Browser'),
            ),
          ],
        ),
      ),
    );
  }
}


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authRepository = AuthRepository();
  final _quizRepository = QuizRepository(); // Used for student registration
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isStudent = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
              ),
              SizedBox(height: 12.0),
              CheckboxListTile(
                title: Text('Are you a student?'),
                value: _isStudent,
              onChanged: (bool? value) {
                  setState(() {
                    _isStudent = value ?? false;
                  });
                },
              ),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  await _register(email, password);
                },
                child: Text('Register'),
              ),
              SizedBox(height: 12.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

Future<void> _register(String email, String password) async {
  if (Validators.isValidEmail(email) && Validators.isValidPassword(password)) {
    try {
      final quizRepository = QuizRepository();
      final db = await quizRepository.getDatabase();

      if (_isStudent) {
  final studentId = await quizRepository.registerStudent(email, password);
  if (studentId != -1) {
    // Registration successful, navigate to QuizListScreen
  } else if (studentId == -2) {
    // Display a specific error message for other exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred during registration. Please try again.'),
      ),
    );
  } else {
    // Display a specific error message for 'no such table' error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No such table error. Please try again.'),
      ),
    );
  }
} else {
        final registered = await _authRepository.register(email, password);
        if (registered) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => QuizTakingScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid email and password.'),
      ),
    );
  }
}}




class QuizBrowserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Browser'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quiz Browser Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuizTakingScreen()));
              },
              child: Text('Start Quiz'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizTakingScreen extends StatelessWidget {
  final QuizRepository _quizRepository = QuizRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Taking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quiz Taking Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuizManagementScreen()));
              },
              child: Text('Go to Quiz Management'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/')); // Go back to login screen
              },
              child: Text('Logout'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizListScreen(),
                  ),
                );
              },
              child: Text('Do Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
class QuizManagementScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final QuizRepository quizRepository = QuizRepository(); // Assuming QuizRepository has a default constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validate fields
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  // Navigate to QuizManagementScreen2 with QuizRepository instance
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizManagementScreen2(
                        title: titleController.text,
                        description: descriptionController.text,
                        quizRepository: quizRepository, // Pass the instance of QuizRepository
                      ),
                    ),
                  );
                } else {
                  // Show error message if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                }
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


  class AddQuestionScreen extends StatefulWidget {
  final int quizId;
  final QuizRepository quizRepository;

  AddQuestionScreen({required this.quizId, required this.quizRepository});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  late QuizRepository _quizRepository; // Declare QuizRepository instance

  @override
  void initState() {
    super.initState();
    _initializeQuizRepository(); // Initialize QuizRepository
  }

  void _initializeQuizRepository() {
    _quizRepository = QuizRepository(); // Initialize QuizRepository
  }

  QuizRepository quizRepository() {
    return _quizRepository;
  }
  final _formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (index) => TextEditingController());
  final List<int> correctOptionIndices = [0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question'),
      ),
      body: Container(
        color: Color(0xFFF4F4F4),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            buildQuestionTextField(),
                            SizedBox(height: 10),
                            for (int i = 0; i < 4; i++)
                              buildOptionTextField(i),
                            SizedBox(height: 10),
                            DropdownButton<int>(
                              value: correctOptionIndices[index],
                              onChanged: (newValue) {
                                setState(() {
                                  correctOptionIndices[index] = newValue!;
                                });
                              },
                              items: List.generate(
                                4,
                                (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text('Option ${index + 1}'),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saving question...'),
                        ),
                      );

                      try {
                        // Create the question and get its ID
                        int questionId = await quizRepository().createQuestion(widget.quizId, questionController.text);

                        // Save each option
                        for (int i = 0; i < optionControllers.length; i++) {
                          String optionText = optionControllers[i].text;
                          bool isCorrect = i == correctOptionIndices[0];

                          // Save the option
                          await QuizRepository().createOption(questionId, optionText, isCorrect);
                        }

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Question saved successfully'),
                          ),
                        );

                        // Navigate back to the QuizManagementScreen2 or any other screen
                        Navigator.pop(context);
                      } catch (e) {
                        // Show error message if saving failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Save Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildQuestionTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Question',
      ),
      controller: questionController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a question';
        }
        return null;
      },
    );
  }

  TextFormField buildOptionTextField(int optionIndex) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Option ${optionIndex + 1}',
      ),
      controller: optionControllers[optionIndex],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an option';
        }
        return null;
      },
    );
  }
}





class QuizManagementScreen2 extends StatefulWidget {
  final String title;
  final String description;
  final QuizRepository quizRepository;

  QuizManagementScreen2({
    required this.title,
    required this.description,
    required this.quizRepository,
  });

  @override
  _QuizManagementScreen2State createState() => _QuizManagementScreen2State();
}

class _QuizManagementScreen2State extends State<QuizManagementScreen2> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> questionControllers = [];
  List<List<TextEditingController>> optionControllers = [
    List.generate(4, (index) => TextEditingController()),
  ];
  List<int> correctOptionIndices = [0];

  QuizRepository get quizRepository => widget.quizRepository; // Define a getter to access quizRepository from widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Management'),
      ),
      body: Container(
        color: Color(0xFFF4F4F4),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Quiz',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView.builder(
                      itemCount: questionControllers.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            buildQuestionTextField(index),
                            SizedBox(height: 10),
                            for (int i = 0; i < 4; i++)
                              buildOptionTextField(index, i),
                            SizedBox(height: 10),
                            DropdownButton<int>(
                              value: correctOptionIndices[index],
                              onChanged: (newValue) {
                                setState(() {
                                  correctOptionIndices[index] = newValue!;
                                });
                              },
                              items: List.generate(
                                4,
                                (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text('Option ${index + 1}'),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saving quiz...'),
                        ),
                      );

                      try {
                        // Create the quiz and get its ID
                        int quizId = await quizRepository.createQuiz(widget.title, widget.description);

                        // Save each question and its options
                        for (int i = 0; i < questionControllers.length; i++) {
                          // Create the question and get its ID
                          int questionId = await quizRepository.createQuestion(quizId, questionControllers[i].text);
                          
                          // Get the options for this question
                          List<String> options = optionControllers[i].map((controller) => controller.text).toList();
                          
                          // Save each option
                          for (int j = 0; j < options.length; j++) {
                            // Determine if this option is correct based on the selected index
                            bool isCorrect = j == correctOptionIndices[i];
                            
                            // Save the option
                            await quizRepository.createOption(questionId, options[j], isCorrect);
                          }
                        }

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Quiz saved successfully'),
                          ),
                        );

                        // Navigate to another screen or perform other actions
                      } catch (e) {
                        // Show error message if saving failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Save Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>QuizzesScreen(quizRepository)));
                  },
                  child: Text('View '),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      questionControllers.add(TextEditingController());
                      optionControllers.add(
                        List.generate(4, (index) => TextEditingController()),
                      );
                      correctOptionIndices.add(0);
                    });
                  },
                  child: Text('Add Question'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => QuizBrowserScreen()));
                  },
                  child: Text('View'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildQuestionTextField(int index) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Question',
      ),
      controller: questionControllers[index],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a question';
        }
        return null;
      },
    );
  }

  TextFormField buildOptionTextField(int questionIndex, int optionIndex) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Option ${optionIndex + 1}',
      ),
      controller: optionControllers[questionIndex][optionIndex],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an option';
        }
        return null;
      },
    );
  }
}






class EditScreen extends StatefulWidget {
  final int quizId;
  final int questionId;
  final int optionId;
  final String question;
  final String option;
  final bool isCorrect;
  final QuizRepository quizRepository;

  EditScreen({
    required this.quizId,
    required this.questionId,
    required this.optionId,
    required this.question,
    required this.option,
    required this.isCorrect,
    required this.quizRepository,
  });

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _questionController;
  late TextEditingController _optionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question);
    _optionController = TextEditingController(text: widget.option);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question:'),
            TextFormField(
              controller: _questionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Option:'),
            TextFormField(
              controller: _optionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updatedQuestion = _questionController.text;
                    final updatedOption = _optionController.text;
                    final updatedIsCorrect = widget.isCorrect;

                    await widget.quizRepository.updateQuestion(widget.questionId, updatedQuestion);
                    await widget.quizRepository.updateOption(widget.optionId, updatedOption, updatedIsCorrect);

                    Navigator.pop(context);
                  },
                  child: Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
Future<void> _showDeleteConfirmationDialog(BuildContext context, String itemType, Function onDeleteConfirmed) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this $itemType?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await onDeleteConfirmed();
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

Future<void> _showDeleteItemDialog(BuildContext context, int quizId, int questionId, int optionId, QuizRepository repository) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Choose Item to Delete'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context, 'Quiz', () async {
                    await repository.deleteQuiz(quizId);
                  });
                },
                child: Text('Delete Quiz'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context, 'Question', () async {
                    await repository.deleteQuestion(questionId);
                  });
                },
                child: Text('Delete Question'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context, 'Option', () async {
                    await repository.deleteOption(optionId);
                  });
                },
                child: Text('Delete Option'),
              ),
            ],
          ),
        ),
      );
    },
  );
}



class QuizzesScreen extends StatefulWidget {
  final QuizRepository _quizRepository;

  QuizzesScreen(this._quizRepository);

  @override
  _QuizzesScreenState createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  late Future<List<List<dynamic>>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = _processQuizzes(widget._quizRepository.getQuizzes());
  }

  Future<List<List<dynamic>>> _processQuizzes(Future<List<dynamic>> quizzesFuture) async {
    final quizzes = await quizzesFuture;
    final List<List<dynamic>> result = [];

    for (final quiz in quizzes) {
      final List<dynamic> quizQuestions = await _processQuizQuestions(quiz['id']);
      result.add([quiz['id'], quiz['title'], quizQuestions]);
    }

    return result;
  }

  Future<List<dynamic>> _processQuizQuestions(int quizId) async {
    final List<dynamic> questions = await widget._quizRepository.getQuizQuestions(quizId);
    return questions;
  }

  Future<int> _createQuestion(int quizId, String question) async {
    return await widget._quizRepository.createQuestion(quizId, question);
  }

  Future<void> _createQuestionOption(int questionId, String option, bool isCorrect) async {
    await widget._quizRepository.createOption(questionId, option, isCorrect);
  }

  Widget _getCorrectOptionWidget(String option, bool isCorrect, TextEditingController optionController, int questionId, int quizId, String questionText, String optionText, int optionId) {
  if (isCorrect) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: Colors.green),
      title: TextFormField(
        controller: optionController,
        decoration: InputDecoration(
          labelText: option,
          labelStyle: TextStyle(color: Colors.green),
          border: InputBorder.none,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                    quizId: quizId,
                    questionId: questionId,
                    optionId: optionId,
                    question: questionText,
                    option: optionText,
                    isCorrect: isCorrect,
                    quizRepository: widget._quizRepository,
                  ),
                ),
              );
            },
          ),
          IconButton(
  icon: Icon(Icons.delete),
  onPressed: () async {
    await _showDeleteItemDialog(context, quizId, questionId, optionId, widget._quizRepository);
;
  },
),

        ],
      ),
    );
  } else {
    return ListTile(
      leading: Icon(Icons.cancel, color: Colors.red),
      title: TextFormField(
        controller: optionController,
        decoration: InputDecoration(
          labelText: option,
          border: InputBorder.none,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                    quizId: quizId,
                    questionId: questionId,
                    optionId: optionId,
                    question: questionText,
                    option: optionText,
                    isCorrect: isCorrect,
                    quizRepository: widget._quizRepository,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Implement delete functionality here
            },
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes'),
      ),
      body: FutureBuilder(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          final List<List<dynamic>> quizzes = snapshot.data as List<List<dynamic>>;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final quizId = quiz[0] as int;
              final quizTitle = quiz[1] as String;
              final List<dynamic> questions = quiz[2];

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz ID: $quizId',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Quiz Title: $quizTitle',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...questions.map<Widget>((question) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question['question'] as String,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...(question['options'] as List<dynamic>)
  .map((option) => _getCorrectOptionWidget(
      option['option'] as String,
      option['isCorrect'] as bool,
      TextEditingController(),
      question['id'] as int, // Changed 'questionId' to 'question['id']'
      quizId,
      question['question'] as String,
      option['option'] as String,
      option['id'] as int, // Pass the option id here
  ),
)
.toList(),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddQuestionScreen(quizId: quizId, quizRepository: widget._quizRepository),
                            ),
                          );
                        },
                        child: Icon(Icons.add, size: 24),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class QuizListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz List'),
      ),
      body: FutureBuilder(
        future: QuizRepository().getQuizzes(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching quizzes'),
            );
          } else {
            final quizzes = snapshot.data;
            return ListView.builder(
              itemCount: quizzes?.length,
              itemBuilder: (context, index) {
                final quiz = quizzes?[index];
                final quizId = quiz['id'];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoQuizScreen(
                            quizId: quizId,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(quiz['title']),
                      leading: CircleAvatar(
                        child: Text('$quizId'),
                      ),
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



class DoQuizScreen extends StatefulWidget {
  final int quizId;

  DoQuizScreen({required this.quizId});

  @override
  _DoQuizScreenState createState() => _DoQuizScreenState();
}

class _DoQuizScreenState extends State<DoQuizScreen> {
  QuizRepository _quizRepository = QuizRepository();
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    _questions = await _quizRepository.getQuizQuestions(widget.quizId);
    setState(() {});
  }

  Future<void> _submitAnswer(bool? isCorrect, {bool isSkipped = false}) async {
  if (isCorrect == null) {
    // User skipped the question
    if (!isSkipped) {
      _moveToNextQuestion();
    }
  } else {
    // Check if the answer is correct
    if (isCorrect) {
      // Increment score if the answer is correct
      setState(() {
        _score++; // assuming _score is initialized as 0
      });
    }

    _moveToNextQuestion();
  }
}

void _moveToNextQuestion() {
  setState(() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      // Show final score screen
      _showFinalScoreScreen();
    }
  });
}

void _showFinalScoreScreen() {
  showDialog(
    context: context,
    builder: (context) {
      print('Final score screen displayed'); // Add this line to see if the dialog is being displayed
      return AlertDialog(
        title: Text('Quiz Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your score is $_score/${_questions.length}'),
            SizedBox(height: 10),
            if (_score == _questions.length)
              Text(
                'Congratulations! You got all the questions correct!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset quiz and go back to previous screen
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0; // Reset score
              });
            },
            child: Text('Take Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Go Back'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Do Quiz'),
      ),
      body: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          if (index == _currentQuestionIndex) {
            final question = _questions[index];
            final questionId = question['id'];
            final questionText = question['question'];
            final options = question['options'];

            return Column(
              children: [
                Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '$questionId. $questionText',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, optionIndex) {
                    final option = options[optionIndex];
                    final optionText = option['option'];
                    final optionId = option['id'];

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(optionText),
                        onTap: () {
                          _submitAnswer(option['is_correct'],
                              isSkipped: optionId == null);
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
