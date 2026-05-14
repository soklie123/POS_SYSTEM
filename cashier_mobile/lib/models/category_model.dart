class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id:    json['id'],
      name:  json['name'],
      slug:  json['slug'],
      color: json['color'],
    );
  }
}