class UserModel {
  final String? name;
  final String? email;
  final String? dob;
  final String? bio;

  UserModel({
    this.name,
    this.email,
    this.dob,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      dob: json['dob'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
      data['name'] = this.name;
      data['email'] = this.email;
      data['dob'] = this.dob;
      data['bio'] = this.bio;

      return data;
  }
}
