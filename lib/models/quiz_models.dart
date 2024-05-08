class User {
  final String id;
  final String email;
  final String password; // Note: For demonstration purposes only, use secure authentication methods in production

  User({
    required this.id,
    required this.email,
    required this.password,
  });
}

class Quiz {
  final int id;
  final String title;
  final String description;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
  });
}

class Question {
  final int id;
  final int quizId;
  final String text;

  Question({
    required this.id,
    required this.quizId,
    required this.text,
  });
}

class Answer {
  final int id;
  final int questionId;
  final String text;
  final bool isCorrect;

  Answer({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });
}
