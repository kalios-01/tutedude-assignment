import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speakquiz/quiz_provider.dart';

import 'option_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final FlutterTts flutterTts = FlutterTts();

  void _speak(String text) async {
    await flutterTts.speak(text);
  }
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final bool quizOver = quizProvider.isQuizOver;
    final int totalQuestions = quizProvider.totalQuestions;
    final int score = quizProvider.score;
    final bool isPassed = score >= (totalQuestions / 2);

    if (quizOver) {
      return Scaffold(
        backgroundColor: isPassed ? Colors.green[50] : Colors.red[50],
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    color: isPassed ? Colors.amber : Colors.redAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'Congratulations!' : 'Better Luck Next Time!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $score / $totalQuestions',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPassed ? 'You Passed!' : 'You Failed!',
                    style: TextStyle(
                      fontSize: 20,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPassed ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => quizProvider.resetQuiz(),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart Quiz', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final question = quizProvider.currentQuestion;
    return Scaffold(
      appBar: AppBar(
        title:  Center(child: Text("SpeakQuiz",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text("Tap The Question For Audio",style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 20),)),
            Card(
              color: Colors.deepPurple[100],
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(
                  'Question ${quizProvider.currentIndex + 1} of $totalQuestions',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _speak(question.text),
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    question.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              question.options.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: OptionTile(
                  optionText: question.options[index],
                  onTap: () => quizProvider.checkAnswer(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
