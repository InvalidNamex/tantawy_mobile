import 'package:hive/hive.dart';

part 'items_groups_model.g.dart';

@HiveType(typeId: 16)
class ItemsGroupsModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String groupName;

  ItemsGroupsModel({required this.id, required this.groupName});

  factory ItemsGroupsModel.fromJson(Map<String, dynamic> json) =>
      ItemsGroupsModel(id: json['id'], groupName: json['group_name']);

  Map<String, dynamic> toJson() => {'id': id, 'group_name': groupName};
}
