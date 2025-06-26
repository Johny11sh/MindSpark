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

  CFavoriteModel(
      {this.id,
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
        this.pivot});

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
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['teacher_id'] = this.teacherId;
    data['subject_id'] = this.subjectId;
    data['lecturesCount'] = this.lecturesCount;
    data['subscriptions'] = this.subscriptions;
    data['image'] = this.image;
    data['sources'] = this.sources;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['rating'] = this.rating;
    data['subscription_count'] = this.subscriptionCount;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['course_id'] = this.courseId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}