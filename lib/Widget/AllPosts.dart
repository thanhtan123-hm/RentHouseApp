import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../MongoDb_Connect.dart';
import 'DetailPage.dart';

class Allposts extends StatefulWidget {
  const Allposts({super.key});

  @override
  State<Allposts> createState() => _AllpostsState();
}

class _AllpostsState extends State<Allposts> {
  late Future<List<Map<String, dynamic>>> _postList;
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    _postList = MongoDatabase.list_post().then((posts) {
      posts.sort((a, b) {
        DateTime dateTimeA = DateTime.parse(a['createdAt']);
        DateTime dateTimeB = DateTime.parse(b['createdAt']);
        return dateTimeB.compareTo(dateTimeA); // Sắp xếp từ mới đến cũ
      });
      return posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài đăng cho thuê',
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
                future: _postList,
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
                        childAspectRatio: 2.9 /
                            4.5, // Chỉnh tỷ lệ chiều rộng và chiều cao của mỗi mục
                      ),
                      itemCount: snapshot.data!.length,

                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var post = snapshot.data![index];
                        // DateTime now = DateTime.now();
                        // DateTime postCreatedAt =
                        //     DateTime.parse(post['createdAt']);
                        // Duration difference = now.difference(postCreatedAt);
                        // String formattedTime;
                        // if (difference.inMinutes < 60) {
                        //   formattedTime = "${difference.inMinutes} phút trước";
                        // } else if (difference.inHours < 24) {
                        //   formattedTime = "${difference.inHours} giờ trước";
                        // } else if (difference.inDays < 7) {
                        //   formattedTime = "${difference.inDays} ngày trước";
                        // } else {
                        //   formattedTime =
                        //       DateFormat('dd/MM/yyyy').format(postCreatedAt);
                        // }
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
                            // Action when a user card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(post: post)),
                            );
                          },
                          child: Card(
                            color: Colors.grey[800],
                            margin: EdgeInsets.all(8.0),
                            // Khoảng cách giữa các phần tử trong mỗi mục
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    post['imageUrls'][0],
                                    fit: BoxFit.cover,
                                    // Đảm bảo hình ảnh vừa với kích thước của card
                                    height: 170,
                                    // Điều chỉnh chiều cao của hình ảnh
                                    width: double
                                        .infinity, // Đảm bảo hình ảnh rộng bằng card
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
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 15),
                                  //SizedBox(height: 10),
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
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 20),
                                  //SizedBox(height: 10),
                                  // RichText(
                                  //   text: TextSpan(
                                  //     children: [
                                  //       WidgetSpan(
                                  //         child: Icon(Icons.access_time_filled,
                                  //             size: 16,
                                  //             color: Colors.tealAccent),
                                  //       ),
                                  //       TextSpan(
                                  //         text: ' ' + formattedTime,
                                  //         style: TextStyle(
                                  //             fontSize: 14,
                                  //             fontWeight: FontWeight.bold,
                                  //             color: Colors.tealAccent),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  //SizedBox(height: 10),
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

          // Add the second column here with similar structure as above
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
