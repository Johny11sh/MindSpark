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
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['userName'] = userName;
    data['countryCode'] = countryCode;
    data['number'] = number;
    data['password'] = password;
    data['image'] = image;
    data['links'] = links;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['teacher_id'] = teacherId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}