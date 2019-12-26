import 'dart:convert';
import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

Future main() async {
  await DotEnv().load('.env');
  runApp(NewsApp());
}

class NewsApp extends StatefulWidget {
  NewsApp({ Key key }) : super(key: key);

  @override 
  _NewsAppState createState() => _NewsAppState();
}


class _NewsAppState extends State<NewsApp> {
  Future<List<Article>> articles;

  @override
  void initState() {
    super.initState();
    articles = fetchArticles(http.Client());
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
            child: FutureBuilder<List<Article>>(
              future: articles,
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                else {
                  return _buildList(snapshot.data);
                }
                return Center(child: CircularProgressIndicator());
              }
            )
          )
        ),
      ),
    );
  }

  Widget _buildRow(Article article) {
    return ListTile(
      title: Text(
        article.title, 
        style: TextStyle(fontSize: 16.0)
        ),
      subtitle: Text(
        article.author != null ? "By: ${article.author}" : 'By: N/A',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12.0
        )
      ),
    );
  }

  Widget _buildList(List<Article> articles) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        if (index.isOdd) return Divider();
        return _buildRow(articles[index]);
      },
    );
  }
}


class NewsApiResponse {
  final String status;
  final int totalResults;
  final List<dynamic> articles;

  NewsApiResponse({
    this.status,
    this.totalResults,
    this.articles
  });

  factory NewsApiResponse.fromJson(Map<String, dynamic> json) {
    return NewsApiResponse(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: json['articles']);
  }
}

class Article {
  final Map source;
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

  factory Article.fromJson(Map<String, dynamic> json) {
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

List<Article> parseArticles(String responseBody) {
  final parsedResponse = NewsApiResponse.fromJson(json.decode(responseBody));
  return parsedResponse.articles.map<Article>((json) => Article.fromJson(json)).toList();
}

Future<List<Article>> fetchArticles(http.Client client) async {
  final apiKey = DotEnv().env['API_KEY'];

  final response = 
    await client.get('https://newsapi.org/v2/top-headlines?country=us',
    headers: { "x-api-key": "$apiKey" }
    );
  if (response.statusCode == 200) {
    return parseArticles(response.body);
  } else {
    throw Exception('Failed to load news articles');
  }
}
