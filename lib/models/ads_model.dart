class AdsModel {
  String id;
  String? uid;
  String? imageUrl;
  String? name;
  String? type;
  String? description;
  String? price;
  String? location;
  String? userName;
  String? userEmail;
  String? userNumber;
  String? createdAt;

  bool isLiked;

  AdsModel({
    this.id = '',
    this.uid,
    this.imageUrl,
    this.name,
    this.type,
    this.description,
    this.price,
    this.location,
    this.userName,
    this.userEmail,
    this.userNumber,
    this.createdAt,
    this.isLiked = false,
  });

  factory AdsModel.fromJson(Map<String, dynamic> json) {
    return AdsModel(
      id: json['id'] ?? '',
      uid: json['uid'],
      imageUrl: json['imageUrl'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      price: json['price'],
      location: json['location'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      userNumber: json['userNumber'],
      createdAt: json['createdAt'],
      isLiked: json['isLiked'] ?? false,
    );
  }


  Map<String, dynamic> toJson() => {
    'uid': uid,
    'imageUrl': imageUrl,
    'name': name,
    'type': type,
    'description': description,
    'price': price,
    'location': location,
    'userName': userName,
    'userEmail': userEmail,
    'userNumber': userNumber,
    'createdAt': createdAt,
    'isLiked': isLiked,
  };
}
