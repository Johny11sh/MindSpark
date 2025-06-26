class TFavoriteModel {
  int? id;
  String? name;
  String? userName;
  String? countryCode;
  String? number;
  String? password;
  String? image;
  String? links;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  TFavoriteModel(
      {this.id,
        this.name,
        this.userName,
        this.countryCode,
        this.number,
        this.password,
        this.image,
        this.links,
        this.createdAt,
        this.updatedAt,
        this.pivot});

  TFavoriteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    userName = json['userName'];
    countryCode = json['countryCode'];
    number = json['number'];
    password = json['password'];
    image = json['image'];
    links = json['links'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['userName'] = this.userName;
    data['countryCode'] = this.countryCode;
    data['number'] = this.number;
    data['password'] = this.password;
    data['image'] = this.image;
    data['links'] = this.links;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? userId;
  int? teacherId;
  String? createdAt;
  String? updatedAt;

  Pivot({this.userId, this.teacherId, this.createdAt, this.updatedAt});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    teacherId = json['teacher_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['teacher_id'] = this.teacherId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}