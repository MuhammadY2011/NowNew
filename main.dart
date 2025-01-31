import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    if (name != null && name.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(name: name),
        ),
      );
    }
  }

  Future<void> _saveName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF00008B),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "NowNew yangiliklariga xush kelibsiz! ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Ismingizni kiriting',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String name = nameController.text;
                  _saveName(name);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(name: name),
                    ),
                  );
                },
                child: const Text('Kirish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String name;

  const HomePage({super.key, required this.name});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> newsList = [
    {
      "title": "Toshkentda 29 -30 va 31 yanvar kunlari qor yog'ishi kutilmoqda",
      "image": "https://yuz.uz/imageproxy/1200x/https://yuz.uz/file/news/c567a3161d05a6177e9b920c7c77bdf8.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "2 soat oldin",
      "url": "https://yuz.uz/news/toshkentda-qor-yogishi"
    },
    {
      "title": "Ilon musk telefon ishlab chiqarmoqchi",
      "image": "https://miro.medium.com/v2/resize:fit:1148/0*JgLoF5wzbkXvOZnH.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "3 soat oldin",
      "url": "https://medium.com/elon-musk-telefon"
    },
    {
      "title": "Tik tok endi rostaniga AQSh da yopildi !",
      "image": "https://images.theconversation.com/files/582275/original/file-20240315-26-rjm6wo.jpg?ixlib=rb-4.1.0&rect=0%2C287%2C5333%2C2666&q=45&auto=format&w=1356&h=668&fit=crop",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "4 soat oldin",
      "url": "https://theconversation.com/tiktok-yopildi"
    },
    {
      "title": "Yangi texnologiyalar yarmarkasi boshlandi",
      "image": "https://static.review.uz/storage/user/posts/4/2/736__85_4276928581.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "5 soat oldin",
      "url": "https://ict.xabar.uz/uz/tahlil/2024-yilda-hayotimizni-ozgartiruvchi-10-texnol"
    },
    {
      "title": "O'zbekistonda yangi startaplar paydo bo'ldi",
      "image": "https://uzgeouniver.uz/storage/user/posts/15/2022-08-31/2022-08-31_1661947962.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "6 soat oldin",
      "url": "https://www.spot.uz/oz/2024/11/06/startup/"
    },
    {
      "title": "Abdukodir Xusanov Manchester cityda !!",
      "image": "https://i.ytimg.com/vi/Tl4gv3jv_N4/maxresdefault.jpg",
      "likes": 0,
      "dislikes": 0,
      "liked": false,
      "disliked": false,
      "comments": [],
      "time": "7 soat oldin",
      "url": "https://metaratings.by/news/oficialno-zashitnik-abdukodir-khusanov-igrok-manchester-siti-442701/"
    },
  ];

  List<Map<String, dynamic>> filteredNewsList = [];
  Timer? _timer;
  String profileImage = '';
  List<String> questions = [];

  @override
  void initState() {
    super.initState();
    filteredNewsList = newsList;
    _startTimer();
    _loadProfileImage();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(hours: 4), (timer) {
      _updateNewsList();
    });
  }

  void _updateNewsList() {
    setState(() {
      newsList.shuffle();
      filteredNewsList = newsList;
    });
  }

  void updateReaction(int index, bool isLike) {
    setState(() {
      if (isLike && !filteredNewsList[index]["liked"]) {
        filteredNewsList[index]["liked"] = true;
        filteredNewsList[index]["likes"]++;
        if (filteredNewsList[index]["disliked"]) {
          filteredNewsList[index]["disliked"] = false;
          filteredNewsList[index]["dislikes"]--;
        }
      } else if (!isLike && !filteredNewsList[index]["disliked"]) {
        filteredNewsList[index]["disliked"] = true;
        filteredNewsList[index]["dislikes"]++;
        if (filteredNewsList[index]["liked"]) {
          filteredNewsList[index]["liked"] = false;
          filteredNewsList[index]["likes"]--;
        }
      }
    });
  }

  void filterNews(String query) {
    setState(() {
      filteredNewsList = newsList
          .where((news) => news["title"]
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  void addComment(int index) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fikr qo\'shish'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: 'Fikringizni yozing...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  filteredNewsList[index]["comments"].add(commentController.text);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Qo\'shish'),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _loadProfileImage() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos?_limit=1'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        profileImage = data[0]['url'];
      });
    } else {
      throw Exception('Profil rasmini yuklab bo\'lmadi');
    }
  }

  Future<void> _loadQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      questions = prefs.getStringList('questions') ?? [];
    });
  }

  Future<void> _saveQuestion(String question) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      questions.add(question);
      prefs.setStringList('questions', questions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true, // Center the title
        title: SizedBox(
          width: 300, // Adjust the width as needed
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Izlash...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            maxLines: 2,
            onChanged: (value) {
              filterNews(value);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(newsList),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.black],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (profileImage.isNotEmpty)
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(profileImage),
                    radius: 60,
                  ),
                const SizedBox(height: 20),
                Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.white),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text("Home", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Home action
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text("Settings", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Settings action
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Logout action
                  },
                ),
                const Divider(color: Colors.white),
                ListTile(
                  leading: const Icon(Icons.telegram, color: Colors.white),
                  title: const Text("Telegram Channel", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    _launchURL("https://t.me/nownewsuz");
                  },
                ),
                const Divider(color: Colors.white),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.white),
                  title: const Text("Helper", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController helpController = TextEditingController();
                        return AlertDialog(
                          title: const Text('Yordam'),
                          content: TextField(
                            controller: helpController,
                            decoration: const InputDecoration(hintText: 'Savolingizni yozing...'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Bekor qilish'),
                            ),
                            TextButton(
                              onPressed: () {
                                String helpQuery = helpController.text;
                                _saveQuestion(helpQuery);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Yuborish'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Divider(color: Colors.white),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.white),
                  title: const Text("Messages", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Savollar'),
                          content: Container(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(questions[index]),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Yopish'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.blue],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredNewsList.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Image.network(
                        filteredNewsList[index]["image"],
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          filteredNewsList[index]["title"],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        filteredNewsList[index]["time"],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      TextButton(
                        onPressed: () => _launchURL(filteredNewsList[index]["url"]),
                        child: const Text('Batafsil', style: TextStyle(fontSize: 12)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up, color: Colors.green),
                            onPressed: () => updateReaction(index, true),
                            iconSize: 20,
                          ),
                          Text("${filteredNewsList[index]["likes"]} Likes", style: const TextStyle(fontSize: 12)),
                          IconButton(
                            icon: const Icon(Icons.thumb_down, color: Colors.red),
                            onPressed: () => updateReaction(index, false),
                            iconSize: 20,
                          ),
                          Text("${filteredNewsList[index]["dislikes"]} Dislikes", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> newsList;

  NewsSearchDelegate(this.newsList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = newsList
        .where((news) => news["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
      return ListTile(title: Text(results[index]["title"]),
        leading: Image.network(
          results[index]["image"],
          width: 50,
          fit: BoxFit.cover,
        ),
        subtitle: Text(results[index]["time"]),
        onTap: () {
          _launchURL(results[index]["url"]);
        },
      );
        },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = newsList
        .where((news) => news["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]["title"]),
          leading: Image.network(
            suggestions[index]["image"],
            width: 50,
            fit: BoxFit.cover,
          ),
          subtitle: Text(suggestions[index]["time"]),
          onTap: () {
            query = suggestions[index]["title"];
            showResults(context);
          },
        );
      },
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
