import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  const QuizCard({
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        child: ListTile(
          title: Text(title),
          subtitle: Text(description),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final String question;

  const QuestionWidget({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        question,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}

class AnswerOptionWidget extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final VoidCallback onTap;

  const AnswerOptionWidget({
    required this.answer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        answer,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : null,
        ),
      ),
    );
  }
}
