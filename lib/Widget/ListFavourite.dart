import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import 'DetailPage.dart';
import 'LoginScreen.dart';

class FavoritePost extends StatefulWidget {
  const FavoritePost({super.key});

  @override
  State<FavoritePost> createState() => _FavoritePostState();
}

class _FavoritePostState extends State<FavoritePost> {
  late Future<List<Map<String, dynamic>>> _listFavourite;
  late Future<List<Map<String, dynamic>>> _postListFavourite = Future.value([]);

  String idUser = 'noemail';
  String postId = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await getFavourite();
    await _loadPosts();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? search =
        await MongoDatabase.get_IdfromUser(prefs.getString('email'));
    setState(() {
      idUser = search!;
    });
  }

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('login') ?? true) == false;
  }

  Future<void> _loadPosts() async {
    _postListFavourite = MongoDatabase.getFavouritePosts(_listFavourite);
    print(_postListFavourite);
  }

  Future<void> getFavourite() async {
    _listFavourite = MongoDatabase.getListFavorite(idUser);
    print(_listFavourite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bài đăng đã thích'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _postListFavourite,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.9 / 4.5,
                      ),
                      itemCount: snapshot.data!.length,
                      padding: EdgeInsets.all(8.0),
                      itemBuilder: (context, index) {
                        var post = snapshot.data![index];
                        var price = post['price'] / 100000;
                        String gia = '';
                        if (price < 10) {
                          price = price * 100;
                          gia = price.toString() + ' K';
                        } else {
                          price = price / 10;
                          gia = price.toString() + ' Triệu';
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(post: post)),
                            );
                          },
                          child: Card(
                            color: Colors.grey[800],
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    post['imageUrls'][0],
                                    fit: BoxFit.cover,
                                    height: 170,
                                    width: double.infinity,
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.location_on,
                                              size: 16, color: Colors.blue),
                                        ),
                                        TextSpan(
                                          text: " " + post['address'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 15),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.square_foot,
                                              size: 18, color: Colors.blue),
                                        ),
                                        TextSpan(
                                          text: " " +
                                              post['area'].toString() +
                                              " m2",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 20),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.attach_money,
                                              size: 20, color: Colors.blue),
                                        ),
                                        TextSpan(
                                          text: " " + gia,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No post found"));
                  }
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
