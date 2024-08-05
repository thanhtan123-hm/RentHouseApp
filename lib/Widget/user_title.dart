import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/ChatPage.dart';

import '../MongoDb_Connect.dart';

class UserTitle extends StatefulWidget {
  const UserTitle({super.key});

  @override
  State<UserTitle> createState() => _UserTitleState();
}

class _UserTitleState extends State<UserTitle> {
  late Future<List<Map<String, dynamic>>> _listUser;
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    _listUser = MongoDatabase.list_user();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tin nhắn',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _listUser,
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
                        crossAxisCount: 1,
                        childAspectRatio: 2.9 /
                            0.5, // Chỉnh tỷ lệ chiều rộng và chiều cao của mỗi mục
                      ),
                      itemCount: snapshot.data!.length,

                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var user = snapshot.data![index];

                        return InkWell(
                          onTap: () {
                            // Action when a user card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChatPage(receiverEmail: user['email'])),
                            );
                          },
                          child: Card(
                            color: Colors.teal,
                            margin: EdgeInsets.all(8.0),
                            // Khoảng cách giữa các phần tử trong mỗi mục
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.mail,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: user['email'],
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  //SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No Chat found"));
                  }
                },
              ),
            ],
          ),

          // Add the second column here with similar structure as above
        ],
      ),
    );
  }
}
