import 'package:flutter/material.dart';
import 'package:my_first_flutter_app/services/tmdb_api.dart';
import 'package:my_first_flutter_app/services/cache_manager.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News',
      debugShowCheckedModeBanner: false,
      home: NewsList(),
    );
  }
}

class NewsList extends StatefulWidget {
  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final TMDBApi api = TMDBApi();
  final CacheManager cacheManager = CacheManager();
  List<dynamic> news = [];
  int currentPage = 1; // Текущая страница
  bool isLoading = false;
  bool hasMoreNews = true;
  Set<int> loadedNewsIds = Set(); // Для отслеживания загруженных новостей

  @override
  void initState() {
    super.initState();
    loadCachedNews();
    loadNews();
  }

  Future<void> loadNews({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      setState(() {
        currentPage = 1;
        news.clear(); // Очищаем список при обновлении
        loadedNewsIds
            .clear(); // Очищаем множество идентификаторов при обновлении
        hasMoreNews = true;
      });
    }

    if (!hasMoreNews) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('Fetching news from API... Page: $currentPage');
      List<dynamic> fetchedNews = await api.fetchNews(currentPage);
      print('Fetched news: ${fetchedNews.length} items');
      setState(() {
        if (fetchedNews.isEmpty) {
          hasMoreNews = false;
          print('No more news available.');
        } else {
          // Фильтруем новости, чтобы не добавлять дубликаты
          fetchedNews
              .removeWhere((newItem) => loadedNewsIds.contains(newItem['id']));
          news.addAll(fetchedNews);
          fetchedNews.forEach((newItem) => loadedNewsIds.add(newItem['id']));
          currentPage++; // Увеличение страницы после успешной загрузки данных
        }
      });
      await cacheManager.saveNews(news);
      print('News saved to cache.');
    } catch (e) {
      print("Error fetching news: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadCachedNews() async {
    print('Loading cached news...');
    List<dynamic> cachedNews = await cacheManager.getCachedNews();
    setState(() {
      news = cachedNews;
      // Заполняем множество загруженных идентификаторов
      cachedNews.forEach((newItem) => loadedNewsIds.add(newItem['id']));
    });
    print('Loaded cached news: ${news.length} items');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF253b49),
      ),
      backgroundColor: Color(0xFF0f2230),
      body: RefreshIndicator(
        onRefresh: () => loadNews(refresh: true),
        child: ListView.builder(
          itemCount: news.length + (hasMoreNews ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == news.length) {
              if (isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (hasMoreNews) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      loadNews();
                    },
                    child: Text('Load more...'),
                  ),
                );
              } else {
                return Center(
                  child: Text('No more news.',
                      style: TextStyle(color: Colors.white)),
                );
              }
            }

            var newsItem = news[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetail(news: newsItem),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ], borderRadius: BorderRadius.circular(20)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: newsItem['poster_path'] != null
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w500${newsItem['poster_path']}',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: double.infinity,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 400,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.7)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          newsItem['vote_average'].toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              newsItem['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${newsItem['release_date']}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Text(
      //     'Page: ${currentPage - 1}',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
    );
  }
}

// import 'package:flutter/material.dart';

class NewsDetail extends StatelessWidget {
  final dynamic news;

  NewsDetail({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            Text(
              'News',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                news['title'],
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF253b49),
      ),
      backgroundColor: Color(0xFF0f2230),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  news['poster_path'] != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500${news['poster_path']}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        news['vote_average'].toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            news['title'],
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            news['release_date'],
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                news['overview'],
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
