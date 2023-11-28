import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Eğer 'result.dart' dosyanız doğrudan aynı klasörde değilse, yolunu güncelleyin
import 'main.dart';
import 'result.dart';

class QuizPage extends StatelessWidget {
  final Category category;

  QuizPage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'), // Check the path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Your logo row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/img/quizlogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            // Expanded widget to take the remaining space
            Expanded(
              child: FutureBuilder<List<Question>>(
                future: _loadQuestions(category.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  } else {
                    // Soruları rastgele seç
                    List<Question> randomQuestions =
                        _selectRandomQuestions(snapshot.data!);
                    return QuizScreen(questions: randomQuestions);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Question>> _loadQuestions(String categoryName) async {
    String jsonString =
        await rootBundle.loadString('assets/$categoryName.json');
    List<dynamic> questionsData = json.decode(jsonString);

    return questionsData
        .map((question) => Question.fromJson(question))
        .toList();
  }

  List<Question> _selectRandomQuestions(List<Question> allQuestions) {
    // Tüm soruları karıştır
    allQuestions.shuffle();
    // İlk 10 soruyu al
    return allQuestions.take(10).toList();
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final ValueChanged<String?> onOptionSelected;
  final List<String?> selectedAnswers;
  final int currentPage;

  QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onOptionSelected,
    required this.selectedAnswers,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: Colors.white, // Beyaz arka plan
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Soru $questionNumber/$totalQuestions:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '${question.question}',
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20.0),
              Column(
                children: question.options.map((option) {
                  bool isCorrect = option == question.correctAnswer;
                  bool isSelected = option == selectedAnswers[currentPage];

                  Color buttonColor = isSelected
                      ? isCorrect
                          ? Colors.green
                          : Colors.red
                      : Colors.blue;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        onOptionSelected(option);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                      ),
                      child: Text(option),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.yellow),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Question {
  int id;
  String question;
  List<String> options;
  String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  QuizScreen({required this.questions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  List<String?> _selectedAnswers = List.filled(10, null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: widget.questions.length,
          itemBuilder: (context, index) {
            return QuestionCard(
              question: widget.questions[index],
              questionNumber: index + 1,
              totalQuestions: widget.questions.length,
              onOptionSelected: (selectedOption) {
                setState(() {
                  _selectedAnswers[_currentPage] = selectedOption;
                });
                if (_currentPage == widget.questions.length - 1) {
                  // Eğer son sayfadaysak, sonuç sayfasını göster
                  _showResultPage(context);
                } else {
                  Future.delayed(Duration(seconds: 1), () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
              selectedAnswers: _selectedAnswers,
              currentPage: _currentPage,
            );
          },
        ),
      ),
    );
  }

  void _showResultPage(BuildContext context) {
    int correctAnswerCount = 0;

    List<bool> isAnswerCorrectList = List.generate(
      widget.questions.length,
      (index) {
        bool isCorrect =
            _selectedAnswers[index] == widget.questions[index].correctAnswer;
        if (isCorrect) {
          correctAnswerCount++;
        }
        return isCorrect;
      },
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          totalQuestions: widget.questions.length,
          correctAnswers: correctAnswerCount,
          isAnswerCorrectList: isAnswerCorrectList,
          correctAnswersList: widget.questions
              .map((question) => question.correctAnswer)
              .toList(),
          questions: widget.questions,
          selectedAnswers: _selectedAnswers,
        ),
      ),
    );
  }
}
