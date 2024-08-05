import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/InformationAcount.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import '../env.dart';
import 'DetailPage.dart';
import 'LoginScreen.dart';
import 'ManagePosts.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ManageRoomAppointment extends StatefulWidget {
  @override
  _ManageRoomAppointmentState createState() => _ManageRoomAppointmentState();
}

class _ManageRoomAppointmentState extends State<ManageRoomAppointment> {
  List<Map<String, dynamic>> postViews = [];
  bool _isLoading = true;
  bool _isLoadingAccept = false;
  Map<String, bool> _isLoadingCancelMap = {};

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? id = await MongoDatabase.get_IdfromUser(email);
    List<Map<String, dynamic>> list;

    list = await MongoDatabase.list_room_appointment_of_owner(id!);
    setState(() {
      postViews = list;
      _isLoading = false;
    });
  }

  void _AcceptBooking(String CustomerMail, String idOwner, String id) async {
    setState(() {
      _isLoadingAccept = true;
    });
    String username = 'tri6561@gmail.com';
    String password = PASSMAIL;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'App cho thuê phòng')
      ..recipients.add(CustomerMail)
      ..subject = 'Lịch hẹn đặt phòng'
      ..text =
          'Lịch hẹn xem phòng của bạn đã được đồng ý. Bạn có thể liên hệ thông tin của chủ bài để trao đổi thêm.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi. Vui lòng thử lại sau')),
      );
    } finally {
      bool delete = await MongoDatabase.DeleteBooking(id);
      List<Map<String, dynamic>> list;
      list = await MongoDatabase.list_room_appointment_of_owner(idOwner);
      setState(() {
        postViews = list;
        _isLoadingAccept = false;
      });
    }
  }

  void _showCancellationDialog(
      String bookingId, String mailBooking, String ownerId) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Lý do từ chối',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Nhập lý do từ chối',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String reason = reasonController.text;
                if (reason == null || reason == '') {
                  reason = 'Không rõ';
                }
                Navigator.of(context).pop(); // Close the dialog
                _cancelBooking(bookingId, reason, mailBooking, ownerId);
              },
              child: Text(
                'Xác nhận',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelBooking(String bookingId, String reason, String mailBooking,
      String ownerId) async {
    setState(() {
      _isLoadingCancelMap[bookingId] = true;
    });
    String username = 'tri6561@gmail.com';
    String password = PASSMAIL;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'App cho thuê phòng')
      ..recipients.add(mailBooking)
      ..subject = 'Lịch hẹn đặt phòng'
      ..text =
          'Lịch hẹn xem phòng của bạn đã bị từ chối. Lý do: $reason. Bạn có thể liên hệ thông tin của chủ bài để trao đổi thêm.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi. Vui lòng thử lại sau')),
      );
    } finally {
      bool delete = await MongoDatabase.DeleteBooking(bookingId);
      List<Map<String, dynamic>> list;
      list = await MongoDatabase.list_room_appointment_of_owner(ownerId);
      setState(() {
        postViews = list;
        _isLoadingCancelMap[bookingId] = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openDetailPage(String idPostBooking) async {
    Map<String, dynamic>? getPost =
        await MongoDatabase.getPostById(idPostBooking!);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(post: getPost ?? {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch hẹn',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: postViews.length,
                    itemBuilder: (context, index) {
                      var appointment = postViews[index];
                      String bookingId = appointment['_id'].toString();
                      return Card(
                        color: Colors.grey[800],
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['Day'],
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                appointment['Time'],
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'User: ' +
                                    appointment['username_person_booking'],
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Phone: ' + appointment['phone_person_booking'],
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    openDetailPage(appointment['idPost']),
                                child: Text(
                                  'bài đăng khách hẹn xem',
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: _isLoadingAccept
                                        ? null
                                        : () {
                                            _AcceptBooking(
                                              appointment[
                                                  'email_person_booking'],
                                              appointment['ownerId'],
                                              bookingId,
                                            );
                                          },
                                    child: _isLoadingAccept
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : Text(
                                            'Đồng ý',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed:
                                        _isLoadingCancelMap[bookingId] == true
                                            ? null
                                            : () {
                                                _showCancellationDialog(
                                                  bookingId,
                                                  appointment[
                                                      'email_person_booking'],
                                                  appointment['ownerId'],
                                                );
                                              },
                                    child: _isLoadingCancelMap[bookingId] ==
                                            true
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : Text(
                                            'Từ chối',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
