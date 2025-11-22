import 'package:hive/hive.dart';

part 'agent_model.g.dart';

@HiveType(typeId: 0)
class AgentModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String token;

  @HiveField(3)
  final int storeID;

  @HiveField(4, defaultValue: '')
  final String username;

  @HiveField(5, defaultValue: '')
  final String password;

  AgentModel({
    required this.id,
    required this.name,
    required this.token,
    required this.storeID,
    required this.username,
    required this.password,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) => AgentModel(
    id: json['id'],
    name: json['name'],
    token: json['token'],
    storeID: json['storeID'],
    username: json['username'] ?? '',
    password: json['password'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'token': token,
    'storeID': storeID,
    'username': username,
    'password': password,
  };
}
