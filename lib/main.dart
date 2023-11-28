import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Quizing/QuizPage.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Uygulaması',
      home: QuizHomePage(),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  @override
  _QuizHomePageState createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'), // Arka plan resmi
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
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
            Expanded(
              child: CategoryList(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final String backgroundImage;

  Category({required this.name, required this.backgroundImage});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      backgroundImage: json['backgroundImage'],
    );
  }
}

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Category> _categories = [];
  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    String jsonString = await rootBundle.loadString('assets/categories.json');
    List<dynamic> categoriesData = json.decode(jsonString);

    // Kategorileri isme göre sırala
    categoriesData.sort((a, b) => a['name'].compareTo(b['name']));

    setState(() {
      _categories = categoriesData
          .map((category) => Category.fromJson(category))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: 20.0), // Üst kısmına margin ekleyen Container
          child: Container(
            height: 40, // Dropdown yüksekliği
            child: Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 1 / 3, // Ekran genişliğinin 1/3'ü
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey, // Kapalı durumda arka plan rengi
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      items: _buildDropdownItems(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      dropdownColor: Colors.grey, // Açıldığında arka plan rengi
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Sütun sayısı
              mainAxisSpacing: 8.0, // Dikey aralık
              crossAxisSpacing: 8.0, // Yatay aralık
            ),
            itemCount: _filteredCategories().length,
            itemBuilder: (context, index) {
              return CategoryCard(category: _filteredCategories()[index]);
            },
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    List<String> categoryNames =
        _categories.map((category) => category.name).toList();
    categoryNames.sort(); // Alfabetik sıralama

    List<DropdownMenuItem<String>> items =
        ['Tümü', ...categoryNames].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    return items;
  }

  List<Category> _filteredCategories() {
    if (_selectedCategory == 'Tümü') {
      return _categories;
    } else {
      return _categories
          .where((category) => category.name == _selectedCategory)
          .toList();
    }
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Burada tıklama işlevselliğini ekleyebilirsiniz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(category: category),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Container(
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.asset(
                    category.backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
