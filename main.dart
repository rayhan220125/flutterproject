import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Meal App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<dynamic> recipes = [];

  Future<void> fetchRecipes() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=%'));

    if (response.statusCode == 200) {
      setState(() {
        recipes = json.decode(response.body)['meals'];
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('My Meal App',
              style: TextStyle(
                color: const Color.fromARGB(255, 250, 251, 250),
              ))),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index]['strMeal']),
            leading: recipes[index]['strMealThumb'] != null
                ? Expanded(
                    child: Image.network(
                      recipes[index]['strMealThumb'],
                      fit: BoxFit.cover,
                    ),
                  )
                : SizedBox.shrink(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecipeDetailsPage(recipe: recipes[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeDetailsPage extends StatelessWidget {
  final dynamic recipe;

  RecipeDetailsPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['strMeal']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipe['strMealThumb'] != null
                ? Image.network(
                    recipe['strMealThumb'],
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Failed to load image');
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(height: 16.0),
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            for (int i = 1; i <= 20; i++)
              recipe['strIngredient$i'] != null
                  ? Text(
                      '- ${recipe['strIngredient$i']} ${recipe['strMeasure$i']}')
                  : SizedBox.shrink(),
            SizedBox(height: 16.0),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(recipe['strInstructions']),
          ],
        ),
      ),
    );
  }
}
