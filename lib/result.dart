import 'package:flutter/material.dart';
import 'package:Quizing/QuizPage.dart';

class ResultPage extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final List<bool> isAnswerCorrectList;
  final List<String> correctAnswersList;
  final List<Question> questions;
  final List<String?> selectedAnswers;

  ResultPage({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.isAnswerCorrectList,
    required this.correctAnswersList,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    int incorrectAnswers = totalQuestions - correctAnswers;
    double score = (correctAnswers / totalQuestions) * 100;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/img/background.png'), // Result sayfasının arka plan resmi
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/img/quizlogo.png', // Result sayfasının logo resmi
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.white, // Container'ın arka plan rengi
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    Text(
                      'Toplam Soru: $totalQuestions',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Doğru Cevaplar: $correctAnswers',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Yanlış Cevaplar: $incorrectAnswers',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Puan: ',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.red, // Kırmızı renk
                        fontWeight: FontWeight.bold, // Bold yazı
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Yanlış Cevaplanan Sorular:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: totalQuestions,
                  itemBuilder: (context, index) {
                    if (!isAnswerCorrectList[index]) {
                      Question question = questions[index];
                      String selectedOption =
                          selectedAnswers[index] ?? "Belirtilmemiş";

                      return Container(
                        color: Colors.white, // Açık mavi arka plan rengi
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Soru ${index + 1}:',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                '${question.question}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Seçilen Şık: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$selectedOption',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Doğru Cevap: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${question.correctAnswer}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow, // Butonun arka plan rengi (sarı)
                ),
                child: Text(
                  'Ana Sayfaya Geri Dön',
                  style: TextStyle(
                    color: Colors.black, // Yazı rengi (siyah)
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
