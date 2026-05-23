import 'package:equatable/equatable.dart';

class ServiceCategory extends Equatable {
  const ServiceCategory({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.iconUrl,
  });

  final String categoryId;
  final String name;
  final String description;
  final String iconUrl;

  @override
  List<Object?> get props => [categoryId, name, description, iconUrl];
}
