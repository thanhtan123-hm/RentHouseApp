class Post {
  String? ownerId;
  String selectedType;
  String selectedRoomType;
  int area;
  int price;
  List<String> selectedAmenitiesNames;
  String address;
  String topic;
  String phone;
  String? zalophone;
  String? facebookLink;
  String description;
  List<String> imageUrls;
  String? videoURL;
  DateTime createdAt;
  DateTime updatedAt;

  Post({
    required this.ownerId,
    required this.selectedType,
    required this.selectedRoomType,
    required this.area,
    required this.price,
    required this.selectedAmenitiesNames,
    required this.address,
    required this.topic,
    required this.phone,
    this.zalophone,
    this.facebookLink,
    required this.description,
    required this.imageUrls,
    this.videoURL,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'ownerId': ownerId,
        'selectedType': selectedType,
        'selectedRoomType': selectedRoomType,
        'area': area,
        'price': price,
        'selectedAmenitiesNames': selectedAmenitiesNames,
        'address': address,
        'topic': topic,
        'phone': phone,
        'zalophone': zalophone,
        'facebookLink': facebookLink,
        'description': description,
        'imageUrls': imageUrls,
        'videoURL': videoURL,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
