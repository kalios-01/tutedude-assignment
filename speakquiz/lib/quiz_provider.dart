import 'package:flutter/material.dart';
import 'package:speakquiz/question.dart';

class QuizProvider with ChangeNotifier {
  int _currentIndex = 0;
  int _score = 0;

  final List<Question> _questions = [
    Question(
      text: "What is the capital of France?",
      options: ["Berlin", "Madrid", "Paris", "Rome"],
      correctIndex: 2,
    ),
    Question(
      text: "What color is the sky?",
      options: ["Green", "Blue", "Red", "Yellow"],
      correctIndex: 1,
    ),
    Question(
      text: "Which planet is known as the Red Planet?",
      options: ["Earth", "Mars", "Jupiter", "Saturn"],
      correctIndex: 1,
    ),
    Question(
      text: "Who wrote the play 'Romeo and Juliet'?",
      options: ["Leo Tolstoy", "William Shakespeare", "Mark Twain", "Charles Dickens"],
      correctIndex: 1,
    ),
    Question(
      text: "How many continents are there on Earth?",
      options: ["5", "6", "7", "8"],
      correctIndex: 2,
    ),
    Question(
      text: "Which gas do plants absorb from the atmosphere?",
      options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"],
      correctIndex: 1,
    ),
    Question(
      text: "What is the largest ocean on Earth?",
      options: ["Atlantic", "Indian", "Arctic", "Pacific"],
      correctIndex: 3,
    ),
    Question(
      text: "Which language is the most spoken worldwide?",
      options: ["English", "Mandarin Chinese", "Spanish", "Hindi"],
      correctIndex: 1,
    ),
    Question(
      text: "Which animal is known as the King of the Jungle?",
      options: ["Elephant", "Tiger", "Lion", "Cheetah"],
      correctIndex: 2,
    ),
    Question(
      text: "What is H2O commonly known as?",
      options: ["Salt", "Hydrogen", "Water", "Oxygen"],
      correctIndex: 2,
    ),
  ];

  int get currentIndex => _currentIndex;
  int get score => _score;
  Question get currentQuestion => _questions[_currentIndex];
  bool get isQuizOver => _currentIndex >= _questions.length;
  int get totalQuestions => _questions.length;

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == currentQuestion.correctIndex) {
      _score++;
    }
    _currentIndex++;
    notifyListeners();
  }

  void resetQuiz() {
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }
}
