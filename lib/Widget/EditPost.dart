import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:post_house_rent_app/MongoDb_Connect.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/ShowPost.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Post.dart';
import 'AccountManager.dart';
import 'LoginScreen.dart';
import 'ManagePosts.dart';

class EditPost extends StatefulWidget {
  final Map<String, dynamic> post;

  EditPost({required this.post});
  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  void initState() {
    super.initState();
    check_if_already_login();
    fetchProvinces();
    _loadPhoneData();
    _selectedType = widget.post['selectedType'] ?? '';
    _selectedRoomType = widget.post['selectedRoomType'] ?? '';
    _priceController.text = widget.post['price'].toString() ?? '';
    _areaController.text = widget.post['area'].toString() ?? '';
    selectedAmenitiesNames =
        List<String>.from(widget.post['selectedAmenitiesNames']);
    addressFromDatabase = widget.post['address'];
    print(addressFromDatabase);
    var addressParts = addressFromDatabase?.split(",");
    selectedProvinceFromDatabase =
        addressParts?[addressParts.length - 1].trim();
    selectedDistrictFromDatabase =
        addressParts?[addressParts.length - 2].trim();
    selectedCommuneFromDatabase = addressParts?[addressParts.length - 3].trim();
    selectedProvinceName = selectedProvinceFromDatabase!;
    selectedDistrictName = selectedDistrictFromDatabase!;
    selectedCommuneName = selectedCommuneFromDatabase!;
    _streetController.text = addressParts![addressParts.length - 4].trim();
    if (addressParts.length == 5) {
      _houseController.text = addressParts[addressParts.length - 5].trim();
    }
    _imageUrls = List<String>.from(widget.post['imageUrls']);
    _videoURL = widget.post['videoURL'] ?? null;
    print(_imageUrls);
    print(_videoURL);
    _topicController.text = widget.post['topic'] ?? '';
    _phoneController.text = widget.post['phone'] ?? '';
    _zalophoneController.text = widget.post['zalophone'] ?? '';
    print(_zalophoneController.text);
    _facebooklinkController.text = widget.post['facebookLink'] ?? '';
    _descriptionController.text = widget.post['description'] ?? '';
  }

  late String username = 'nologin';
  late String imageUrl = 'nologin';
  late String email = 'nologin';
  final TextEditingController _phoneController = TextEditingController();
  Future<void> _loadPhoneData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? search =
        await MongoDatabase.getUser(prefs.getString('email'));
    setState(() {
      _phoneController.text = search?['phone'];
      // Đánh dấu đã tải xong dữ liệu
    });
  }

  void check_if_already_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    var checklogin = (prefs.getBool('login') ?? true);
    print(checklogin);
    if (checklogin == false) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      imageUrl = prefs.getString('image')!;
      email = prefs.getString('email')!;
    });
  }
  //String _selectedType
  //String _selectedRoomType
  //String _areaController
  //String _priceController
  //_List<String> selectedAmenitiesNames
  //  String selectedProvince;
  //   String selectedDistrict;
  //   String selectedCommune;
  //String _streetController;
  //String? _houseController
  // String _topicController;
  // String _phoneController
  // String? _zalophoneController
  //String? _facebooklinkController
  //String _descriptionController
  //String _emailOwner
  //List<String> _imageUrls;
  //String? _videoURL;
  //Date createAt
  //Date updateAt

  //THông tin
  int _currentStep = 0;
  String _selectedType = 'Cho thuê';
  String _selectedRoomType = 'Phòng';
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Map<String, dynamic>> amenities = [
    {'name': 'Wifi', 'icon': Icons.wifi},
    {'name': 'WC riêng', 'icon': Icons.bathtub},
    {'name': 'Giữ xe', 'icon': Icons.local_parking},
    {'name': 'Tự do', 'icon': Icons.accessibility},
    {'name': 'Bếp', 'icon': Icons.kitchen},
    {'name': 'Điều hòa', 'icon': Icons.ac_unit},
    {'name': 'Tủ lạnh', 'icon': Icons.kitchen_outlined},
    {'name': 'Máy giặc', 'icon': Icons.local_laundry_service},
    {'name': 'Nội thất', 'icon': Icons.weekend},
  ];
  List<bool> selectedAmenities = List.generate(9, (index) => false);
  List<String> selectedAmenitiesNames = [];
  bool isInteger(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

// Dữ liệu lấy từ data
  String? selectedProvinceFromDatabase;
  String? selectedDistrictFromDatabase;
  String? selectedCommuneFromDatabase;
  String? addressFromDatabase;
  //Dia chi
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCommune;
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> communes = [];
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  String? selectedProvinceName = '';
  String? selectedDistrictName = '';
  String? selectedCommuneName = '';

  Future<void> fetchProvinces() async {
    final response = await http.get(Uri.parse(
        'https://api-tinh-thanh-git-main-toiyours-projects.vercel.app/province'));
    if (response.statusCode == 200) {
      setState(() {
        provinces = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<void> fetchDistricts(String idProvince) async {
    final response = await http.get(Uri.parse(
        'https://toinh-api-tinh-thanh.onrender.com/district?idProvince=$idProvince'));
    if (response.statusCode == 200) {
      setState(() {
        districts = json.decode(response.body);
        selectedDistrict =
            null; // Reset selected district when province changes
      });
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<void> fetchCommunes(String idDistrict) async {
    final response = await http.get(Uri.parse(
        'https://api-tinh-thanh-git-main-toiyours-projects.vercel.app/commune?idDistrict=$idDistrict'));
    if (response.statusCode == 200) {
      setState(() {
        communes = json.decode(response.body);
        selectedCommune = null; // Reset selected commune when district changes
      });
    } else {
      throw Exception('Failed to load communes');
    }
  }

// Hinh anh
  List<File?> _selectedImages = []; // Danh sách chứa các hình ảnh đã được chọn
  final picker = ImagePicker();
  bool _isImagePickerActive = false;
  Future<void> pickImage({int? replaceIndex}) async {
    if (!_isImagePickerActive &&
        (replaceIndex != null || _selectedImages.length < 6)) {
      _isImagePickerActive =
          true; // Đặt trạng thái trình chọn hình ảnh thành đang hoạt động
      try {
        final pickerFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
        );
        if (pickerFile != null) {
          setState(() {
            if (replaceIndex != null) {
              _selectedImages[replaceIndex] =
                  File(pickerFile.path); // Thay thế hình ảnh
            } else {
              _selectedImages
                  .add(File(pickerFile.path)); // Thêm hình ảnh vào danh sách
            }
          });
        } else {
          print("No image picked");
        }
      } catch (e) {
        print("Error picking image: $e");
      } finally {
        _isImagePickerActive =
            false; // Đặt trạng thái trình chọn hình ảnh thành không hoạt động
      }
    } else {
      if (_selectedImages.length >= 6) {
        print("Maximum number of images reached");
      }
    }
  }

  File? _selectedVideo;
  void pickVideo() async {
    // Logic để chọn video từ thiết bị
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
      });
    }
  }

  List<String> _imageUrls = [];
  String? _videoURL;
  Future<void> _uploadImages(String email) async {
    for (int i = 0; i < _selectedImages.length; i++) {
      File? image = _selectedImages[i];
      if (image != null) {
        String filename =
            '${email}_hinh${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        String? imageUrl = await _uploadFile(image, 'images/$filename');
        if (imageUrl != null) {
          setState(() {
            _imageUrls.add(imageUrl);
          });
        }
      }
    }
  }

  Future<void> _uploadVideo(String email) async {
    if (_selectedVideo != null) {
      String filename =
          '${email}_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      String? videoUrl = await _uploadFile(_selectedVideo!, 'videos/$filename');
      if (videoUrl != null) {
        setState(() {
          _videoURL = videoUrl;
        });
      }
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(path).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Chỉnh sửa bài đăng',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
              fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
            ),
          ),
          backgroundColor: Colors.grey[800],
        ),
        body: username == 'nologin' && email == 'nologin'
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Yêu cầu đăng nhập để sử dụng chức năng này.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight:
                            FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight:
                              FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              )
            : Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary: Colors.blue, // Màu chính của step
                    onPrimary: Colors.white, // Màu chữ trong step
                    secondary: Colors.blue,
                    background: Colors.black, // Màu của step đã hoàn thành
                  ),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () async {
                    if (_currentStep == 0) {
                      print(_selectedType);
                      print(_selectedRoomType);
                      print(_priceController.text);
                      print(_areaController.text);
                      print(selectedAmenitiesNames);
                      // Kiểm tra xem giá phòng và diện tích đã được nhập chưa
                      if (_areaController.text.isEmpty ||
                          _priceController.text.isEmpty) {
                        // Thông báo yêu cầu người dùng nhập giá phòng và diện tích
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Vui lòng nhập giá phòng và diện tích.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      // Kiểm tra xem area và price có phải là số không
                      if (!isInteger(_areaController.text) ||
                          !isInteger(_priceController.text)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Diện tích và giá phòng phải là số.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      if (int.parse(_areaController.text) < 10 ||
                          int.parse(_priceController.text) < 100000) {
                        // Thông báo yêu cầu người dùng nhập giá phòng và diện tích
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Vui lòng nhập giá phòng >100.000 vnd  và diện tích >10m2.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                    }
                    if (_currentStep == 1) {
                      print(selectedProvinceName);
                      print(selectedDistrictName);
                      print(selectedCommuneName);
                      print(_streetController.text);
                      print(_houseController.text);
                      if (selectedProvinceName == '' ||
                          selectedDistrictName == '' ||
                          selectedCommuneName == '' ||
                          _streetController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Vui lòng chọn tỉnh, huyện, xã , hẻm, tên đường nơi cho thuê.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                    }
                    if (_currentStep == 2) {
                      if (_imageUrls.isEmpty) {
                        if (_selectedImages.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text(
                                  'Thông báo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                content: Text(
                                  'Vui lòng chọn hình ảnh cho bài đăng ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Đóng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                                        fontWeight: FontWeight
                                            .bold, // hoặc chọn kiểu chữ phù hợp
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                      }
                    }
                    if (_currentStep == 3) {
                      if (_topicController.text.isEmpty ||
                          _topicController.text.length < 20) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Vui lòng nhập tiêu đề và tiêu đề tối thiểu 20 kí tự ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      if (_phoneController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Vui lòng nhập số điện thoại liên lạc ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      if (!_phoneController.text.isEmpty) {
                        bool checkphone = isPhoneNumber(_phoneController.text);
                        if (checkphone == false) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text(
                                  'Thông báo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                content: Text(
                                  'Nội dung số điện thoại liên lạc bạn nhập không phải sô điện thoại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Đóng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                                        fontWeight: FontWeight
                                            .bold, // hoặc chọn kiểu chữ phù hợp
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                      }
                      if (_zalophoneController.text.isEmpty == false) {
                        bool checkphone =
                            isPhoneNumber(_zalophoneController.text);
                        if (checkphone == false) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text(
                                  'Thông báo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                content: Text(
                                  'Nội dung số điện thoại zalo không phải là số điện thoại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Đóng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                                        fontWeight: FontWeight
                                            .bold, // hoặc chọn kiểu chữ phù hợp
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                      }
                      if (_facebooklinkController.text.isEmpty == false) {
                        bool checkurl = isURL(_facebooklinkController.text);
                        if (checkurl == false) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text(
                                  'Thông báo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                content: Text(
                                  'Vui lòng nhập đúng định dạng địa chỉ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Đóng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                                        fontWeight: FontWeight
                                            .bold, // hoặc chọn kiểu chữ phù hợp
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                      }
                      if (_descriptionController.text.isEmpty ||
                          _descriptionController.text.length < 20) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: Text(
                                'Thông báo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              content: Text(
                                'Vui lòng nhập mô tả và mô tả tối thiểu 20 kí tự ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight
                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight
                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      } else {
                        // Display CircularProgressIndicator while processing
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Prevent user from dismissing dialog
                          builder: (BuildContext context) {
                            return Center(
                              child:
                                  CircularProgressIndicator(), // Display CircularProgressIndicator
                            );
                          },
                        );
                        await _uploadImages(email); // Ensure this completes
                        await _uploadVideo(email); // Ensure this completes
                        String address = '';
                        if (_houseController.text == '') {
                          address = _streetController.text +
                              ', ' +
                              selectedCommuneName! +
                              ', ' +
                              selectedDistrictName! +
                              ', ' +
                              selectedProvinceName!;
                        } else {
                          address = _houseController.text +
                              ', ' +
                              _streetController.text +
                              ', ' +
                              selectedCommuneName! +
                              ', ' +
                              selectedDistrictName! +
                              ', ' +
                              selectedProvinceName!;
                        }

                        String? _IdofPost = widget.post['_id'].toString();
                        _IdofPost = _IdofPost.substring(
                            _IdofPost.indexOf('"') + 1,
                            _IdofPost.lastIndexOf('"'));
                        print(_IdofPost);
                        print(selectedAmenitiesNames);
                        print(address);
                        print(_imageUrls);
                        print(_videoURL);
                        bool check = await MongoDatabase.UpdatePost(
                            _IdofPost,
                            _selectedType,
                            _selectedRoomType,
                            int.parse(_areaController.text),
                            int.parse(_priceController.text),
                            selectedAmenitiesNames,
                            address,
                            _topicController.text,
                            _phoneController.text,
                            _zalophoneController.text,
                            _facebooklinkController.text,
                            _descriptionController.text,
                            _imageUrls,
                            _videoURL);
                        if (check == false) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text(
                                  'Thông báo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                content: Text(
                                  'Có lỗi trong quá chỉnh sửa vui lòng kiểm tra lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Đóng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                                        fontWeight: FontWeight
                                            .bold, // hoặc chọn kiểu chữ phù hợp
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Manageposts()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      }
                    }

                    // Nếu không có lỗi, tiếp tục tới bước tiếp theo
                    if (_currentStep < _getSteps().length - 1) {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    }
                  },
                  steps: _getSteps(),
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controls) {
                    return Row(
                      children: <Widget>[
                        _currentStep == 3
                            ? TextButton(
                                onPressed: controls.onStepContinue,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                ),
                                child: const Text(
                                  'Sửa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight.bold,
                                    // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: controls.onStepContinue,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                ),
                                child: const Text(
                                  'Tiếp tục',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight.bold,
                                    // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                              ),
                        SizedBox(width: 8),
                        _currentStep != 0
                            ? TextButton(
                                onPressed: controls.onStepCancel,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                ),
                                child: const Text(
                                  'Quay lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight.bold,
                                    // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  },
                ),
              ),
        backgroundColor: Colors.black);
  }

  // Xac nhan
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _zalophoneController = TextEditingController();
  final TextEditingController _facebooklinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool correctForm = true;
  bool isPhoneNumber(String input) {
    // Sử dụng biểu thức chính quy để kiểm tra xem chuỗi có phải là số điện thoại hay không
    // Biểu thức này sẽ phù hợp với các số điện thoại theo định dạng quốc tế, ví dụ: +12 3456 7890
    final RegExp phoneRegex = RegExp(r'^(?:\+?84|0)(?:\d{9,10})$');
    return phoneRegex.hasMatch(input);
  }

  bool isURL(String input) {
    // Sử dụng biểu thức chính quy để kiểm tra xem chuỗi có phải là URL hay không
    final RegExp urlRegex = RegExp(
        r'^(?:http|https):\/\/(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+(?:\/[^\s]*)?$');
    return urlRegex.hasMatch(input);
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: Text(
          'Thông tin ',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
              fontWeight: FontWeight.bold,
              fontSize: 12 // hoặc chọn kiểu chữ phù hợp
              ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Loại tin:',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold,
                    fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                    ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'Cho thuê';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedType == 'Cho thuê'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Cho thuê',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                            fontWeight: FontWeight.bold,
                            fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'Tìm người ở ghép';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedType == 'Tìm người ở ghép'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Tìm người ở ghép',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                            fontWeight: FontWeight.bold,
                            fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Loại phòng:',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold,
                    fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                    ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRoomType = 'Phòng';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedRoomType == 'Phòng'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Phòng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                            fontWeight: FontWeight.bold,
                            fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRoomType = 'Căn hộ';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedRoomType == 'Căn hộ'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Căn hộ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                            fontWeight: FontWeight.bold,
                            fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRoomType = 'Nhà';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedRoomType == 'Nhà'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Nhà',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                            fontWeight: FontWeight.bold,
                            fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Giá phòng (VND):',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                  fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                  ),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập giá phòng',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                ), // Đặt màu cho hintText
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
              controller: _priceController,
              onChanged: (value) {
                _priceController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Diện tích (m2):',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                  fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                  ),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập diện tích',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
              controller: _areaController,
              onChanged: (value) {
                _areaController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Tiện ích phòng:',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                  fontSize: 16 // hoặc chọn kiểu chữ phù hợp
                  ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                amenities.length,
                (index) {
                  bool isSelected =
                      selectedAmenitiesNames.contains(amenities[index]['name']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedAmenitiesNames
                              .remove(amenities[index]['name']);
                        } else {
                          selectedAmenitiesNames.add(amenities[index]['name']);
                        }
                      });
                    },
                    child: Chip(
                      label: Text(
                        amenities[index]['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight:
                              FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                        ),
                      ),
                      avatar: Icon(
                        amenities[index]['icon'],
                        color: isSelected ? Colors.white : Colors.white,
                      ),
                      backgroundColor: isSelected ? Colors.blue : null,
                    ),
                  );
                },
              ),
            )
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Địa chỉ ',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
              fontWeight: FontWeight.bold,
              fontSize: 12 // hoặc chọn kiểu chữ phù hợp
              ),
        ),
        content: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text('Địa chỉ hiện tại: $addressFromDatabase',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            // AnimatedContainer và DropdownButton cho tỉnh/thành phố
            SizedBox(height: 20),
            Text('* Chọn lại thông tin bên dưới nếu muốn cập nhật địa chỉ',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold,
                    fontSize: 17)),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 50.0,
              width: 400,
              // Kích thước tùy thuộc vào biến isExpanded
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[800],
                hint: Text('Chọn tỉnh/thành phố',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                      fontWeight: FontWeight.bold,
                    )),
                value: selectedProvince,
                items: provinces.map((province) {
                  return DropdownMenuItem<String>(
                    value: province['idProvince'].toString(),
                    child: Text(province['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight: FontWeight.bold,
                        )),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value;
                    districts = [];
                    selectedDistrict = null;
                    communes = [];
                    selectedCommune = null;
                    selectedProvinceName = selectedProvince != null
                        ? provinces.firstWhere((element) =>
                            element['idProvince'].toString() ==
                            selectedProvince)['name']
                        : null;
                    selectedDistrictName = null;
                    selectedCommuneName = null;
                  });
                  selectedProvinceFromDatabase = selectedProvinceName;
                  fetchDistricts(value!);
                },
              ),
            ),
            SizedBox(height: 1),
            // AnimatedContainer và DropdownButton cho quận/huyện
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 50.0,
              width: 400,
              // Kích thước tùy thuộc vào biến isExpanded
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[800],
                hint: Text('Chọn quận/huyện',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                      fontWeight: FontWeight.bold,
                    )),
                value: selectedDistrict,
                items: selectedProvince == null
                    ? []
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Chọn quận/huyện',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily:
                                    'Roboto', // hoặc chọn một font chữ khác phù hợp
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        ...districts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district['idDistrict'].toString(),
                            child: Text(district['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight.bold,
                                )),
                          );
                        }).toList(),
                      ],
                onChanged: selectedProvince == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedDistrict = value;
                          communes = [];
                          selectedCommune = null;
                          selectedDistrictName = selectedDistrict != null
                              ? districts.firstWhere((element) =>
                                  element['idDistrict'].toString() ==
                                  selectedDistrict)['name']
                              : null;
                        });
                        fetchCommunes(value!);
                      },
              ),
            ),
            SizedBox(height: 1),
            // AnimatedContainer và DropdownButton cho phường/xã
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 50.0,
              width: 400,
              // Kích thước tùy thuộc vào biến isExpanded
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[800],
                hint: Text('Chọn phường/xã',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                      fontWeight: FontWeight.bold,
                    )),
                value: selectedCommune,
                items: selectedDistrict == null
                    ? []
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Chọn phường/xã',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily:
                                    'Roboto', // hoặc chọn một font chữ khác phù hợp
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        ...communes.map((commune) {
                          return DropdownMenuItem<String>(
                            value: commune['idCommune'].toString(),
                            child: Text(commune['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                  fontWeight: FontWeight.bold,
                                )),
                          );
                        }).toList(),
                      ],
                onChanged: selectedDistrict == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedCommune = value;
                          selectedCommuneName = selectedCommune != null
                              ? communes.firstWhere((element) =>
                                  element['idCommune'].toString() ==
                                  selectedCommune)['name']
                              : null;
                        });
                      },
              ),
            ),

            SizedBox(height: 1),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'hẻm và tên đường (có thẻ điền 1 trong 2)  ',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _streetController,
              onChanged: (value) {
                _streetController.text = value;
              },
            ),
            SizedBox(height: 1),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Số nhà(nếu có)',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _houseController,
              onChanged: (value) {
                _houseController.text = value;
              },
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Hình ảnh ',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Chọn hình ảnh từ thiết bị của bạn tối đa 6 hình và 1 video.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 220, // Có thể cần chỉnh chiều cao tùy theo nhu cầu
              width: double.infinity, // Sử dụng chiều rộng toàn màn hình
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Số lượng cột là 3
                  crossAxisSpacing: 4, // Khoảng cách giữa các cột
                  mainAxisSpacing: 4, // Khoảng cách giữa các hàng
                  childAspectRatio: 1, // Tỷ lệ khung hình của các item
                ),
                itemCount: _selectedImages.length + _imageUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index < _imageUrls.length) {
                    // Hiển thị hình ảnh từ _imageUrls
                    return Image.network(
                      _imageUrls[index],
                      fit: BoxFit.cover,
                    );
                  } else if (index ==
                      _imageUrls.length + _selectedImages.length) {
                    // Chỉ cho phép thêm mới nếu số lượng hình ảnh chưa đạt tối đa
                    return InkWell(
                      onTap: () {
                        if (_selectedImages.length < 6) {
                          pickImage();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Icon(Icons.add),
                      ),
                    );
                  } else {
                    // Thực hiện thay thế hình ảnh khi nhấn vào hình ảnh đã chọn
                    int imageIndex = index - _imageUrls.length;
                    return InkWell(
                      onTap: () {
                        pickImage(replaceIndex: imageIndex);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.file(
                          _selectedImages[imageIndex]!.absolute,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 100, // Có thể cần chỉnh chiều cao tùy theo nhu cầu
              width: double.infinity, // Sử dụng chiều rộng toàn màn hình
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _videoURL != null
                  ? InkWell(
                      onTap: pickVideo,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library),
                            Text('Video đã chọn'),
                          ],
                        ),
                      ),
                    )
                  : (_selectedVideo == null
                      ? InkWell(
                          onTap: pickVideo,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Icon(Icons.add),
                          ),
                        )
                      : InkWell(
                          onTap: pickVideo,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.video_library),
                                Text('Video đã chọn'),
                              ],
                            ),
                          ),
                        )),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _selectedVideo = null;
                  _imageUrls.clear();
                  _videoURL = null;
                });
              },
              icon: Icon(Icons.refresh),
              label: Text(
                "Chọn lại",
                style: TextStyle(
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Xác nhận',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
        content: Column(
          children: <Widget>[
            SizedBox(height: 8),
            Text(
              'Tiêu đề:',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Nhập tiêu đề',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _topicController,
              onChanged: (value) {
                _topicController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Số điện thoại (liên lạc):',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại của bạn',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _phoneController,
              onChanged: (value) {
                _phoneController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Cũng cấp zalo và facebook không bắt buột nhưng giúp cho người tìm trọ có  nhiều phương tiện liên lạc với bạn hơn',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              'Số điện thoại zalo(nếu có):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại có thể liên hệ zalo với bạn',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _zalophoneController,
              onChanged: (value) {
                _zalophoneController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Link tài khoản facebook(nếu có):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'Nhập đường link facebook của bạn',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _facebooklinkController,
              onChanged: (value) {
                _facebooklinkController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Mô tả chi tiết:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines:
                  10, // Cho phép TextFormField tự động điều chỉnh chiều cao
              decoration: InputDecoration(
                hintText: 'Nhập mô tả chi tiết của bạn',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold,
              ),
              controller: _descriptionController,
              onChanged: (value) {
                _descriptionController.text = value;
              },
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
    ];
  }
}
