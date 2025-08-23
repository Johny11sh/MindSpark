// ignore_for_file: file_names

class CFavoriteModel {
  int? id;
  String? name;
  String? description;
  int? teacherId;
  int? subjectId;
  int? lecturesCount;
  int? subscriptions;
  String? image;
  String? sources;
  String? createdAt;
  String? updatedAt;
  var rating;
  int? subscriptionCount;
  Pivot? pivot;

  CFavoriteModel({
    this.id,
    this.name,
    this.description,
    this.teacherId,
    this.subjectId,
    this.lecturesCount,
    this.subscriptions,
    this.image,
    this.sources,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.subscriptionCount,
    this.pivot,
  });

  CFavoriteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    teacherId = json['teacher_id'];
    subjectId = json['subject_id'];
    lecturesCount = json['lecturesCount'];
    subscriptions = json['subscriptions'];
    image = json['image'];
    sources = json['sources'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    rating = json['rating'];
    subscriptionCount = json['subscription_count'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['teacher_id'] = teacherId;
    data['subject_id'] = subjectId;
    data['lecturesCount'] = lecturesCount;
    data['subscriptions'] = subscriptions;
    data['image'] = image;
    data['sources'] = sources;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['rating'] = rating;
    data['subscription_count'] = subscriptionCount;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? userId;
  int? courseId;
  String? createdAt;
  String? updatedAt;

  Pivot({this.userId, this.courseId, this.createdAt, this.updatedAt});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    courseId = json['course_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['course_id'] = courseId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
