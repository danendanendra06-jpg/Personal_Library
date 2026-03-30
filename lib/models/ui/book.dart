class Book {
  final int? id;
  final String title;
  final String author;
  final String category;
  final double rating;
  final bool isAvailable;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.rating,
    required this.isAvailable,
  });

  // Convert a Book into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'rating': rating,
      'isAvailable': isAvailable ? 1 : 0, // SQLite doesn't have Boolean
    };
  }

  // Extract a Book object from a Map.
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      category: map['category'],
      rating: map['rating'],
      isAvailable: map['isAvailable'] == 1,
    );
  }
}
