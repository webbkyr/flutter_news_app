import 'dart:convert';
import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override 
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  Future<NewsApiResponse> data;
  List<Article> articles;
  // final _newsArticles = List<Article>;


  @override
  void initState() {
    super.initState();
    data = fetchPost();
    // articles.add(Article.fromJson(json.decode(data));

  }

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('News App'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: FutureBuilder<NewsApiResponse>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemBuilder: (context, i) {
                      return Text('news is here');
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              }
            )
          )
        ),
      ),
    );
  }
}

/* API call */
class NewsApiResponse {
  final String status;
  final int totalResults;
  final List<Map> articles;

  NewsApiResponse({ this.status, this.totalResults, this.articles });

  factory NewsApiResponse.fromJson(Map<dynamic, dynamic> json) {
    return NewsApiResponse(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: json['articles']
    );
  }
}

class Article {
  final Map<String, Map> source;
  final String id;
  final String name;
  final String author;
  final String title;
  final String description;


  Article({ 
    this.source, 
    this.id, 
    this.name, 
    this.author,
    this.title,
    this.description 
  });

  factory Article.fromJson(Map<dynamic, dynamic> json) {
    return Article(
      source: json['source'],
      id: json['userId'],
      name: json['name'],
      author: json['author'],
      title: json['title'],
      description: json['description']
    );
  }
}

Future<NewsApiResponse> fetchPost() async {
  final apiKey = DotEnv().env['API_KEY'];
  final response = await http.get(
    'https://newsapi.org/v2/top-headlines?country=us',
    headers: { "x-api-key": "$apiKey" }
    );
  print(response.body);
  print(response.statusCode);
      
  if (response.statusCode == 200) {
    return NewsApiResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

