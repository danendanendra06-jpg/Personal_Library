import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DbBook {
  static final DbBook _instance = DbBook._internal();
  static Database? _database;
  static bool _isInitializing = false;

  // --- WEB IN-MEMORY DATABASE (FALLBACK) ---
  static final List<Map<String, dynamic>> _webCategories = [
    {'id_category': 1, 'category_name': 'Novel'},
    {'id_category': 2, 'category_name': 'Teknologi'},
    {'id_category': 3, 'category_name': 'Sains'},
    {'id_category': 4, 'category_name': 'Sejarah'},
  ];

  static final List<Map<String, dynamic>> _webPublishers = [
    {'id_publisher': 1, 'publisher_name': 'Bentang Pustaka', 'city': 'Yogyakarta'},
    {'id_publisher': 2, 'publisher_name': 'Prentice Hall', 'city': 'New Jersey'},
  ];

  static final List<Map<String, dynamic>> _webAuthors = [
    {'id_author': 1, 'name': 'Andrea Hirata', 'country': 'Indonesia'},
    {'id_author': 2, 'name': 'Robert C. Martin', 'country': 'USA'},
    {'id_author': 3, 'name': 'Raditya Dika', 'country': 'Indonesia'},
  ];

  static List<Map<String, dynamic>> _webBooks = [
    {
      'id_book': 1,
      'title': 'Laskar Pelangi',
      'year': 2005,
      'cover_url': '',
      'publisher_id': 1,
      'category_id': 1,
      'category_name': 'Novel',
      'publisher_name': 'Bentang Pustaka',
      'author_name': 'Andrea Hirata',
      'author_ids': [1],
    },
    {
      'id_book': 2,
      'title': 'Clean Code',
      'year': 2008,
      'cover_url': '',
      'publisher_id': 2,
      'category_id': 2,
      'category_name': 'Teknologi',
      'publisher_name': 'Prentice Hall',
      'author_name': 'Robert C. Martin',
      'author_ids': [2],
    }
  ];
  static int _webIdCounter = 3;

  factory DbBook() => _instance;
  DbBook._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Cegah balapan sinkronisasi (Race Condition) saat aplikasi baru pertama kali buka
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    if (_database != null) return _database!;

    _isInitializing = true;
    _database = await _initDatabase();
    _isInitializing = false;
    
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'library_v4.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE categories(id_category INTEGER PRIMARY KEY AUTOINCREMENT, category_name TEXT)''');
        await db.execute('''CREATE TABLE publishers(id_publisher INTEGER PRIMARY KEY AUTOINCREMENT, publisher_name TEXT, city TEXT)''');
        await db.execute('''CREATE TABLE authors(id_author INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, country TEXT)''');
        await db.execute('''CREATE TABLE books(
            id_book INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, year INTEGER, cover_url TEXT, publisher_id INTEGER, category_id INTEGER,
            FOREIGN KEY (publisher_id) REFERENCES publishers (id_publisher), FOREIGN KEY (category_id) REFERENCES categories (id_category))''');
        // Tabel Relasi Many to Many
        await db.execute('''CREATE TABLE book_author(
            id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER, author_id INTEGER,
            FOREIGN KEY (book_id) REFERENCES books (id_book), FOREIGN KEY (author_id) REFERENCES authors (id_author))''');

        await db.insert('categories', {'category_name': 'Novel'});
        await db.insert('categories', {'category_name': 'Teknologi'});
        await db.insert('categories', {'category_name': 'Sains'});
        await db.insert('categories', {'category_name': 'Sejarah'});
        await db.insert('publishers', {'publisher_name': 'Bentang Pustaka', 'city': 'Yogyakarta'});
        await db.insert('publishers', {'publisher_name': 'Prentice Hall', 'city': 'New Jersey'});
        await db.insert('authors', {'name': 'Andrea Hirata', 'country': 'Indonesia'});
        await db.insert('authors', {'name': 'Robert C. Martin', 'country': 'USA'});

        await db.insert('books', {'title': 'Laskar Pelangi', 'year': 2005, 'cover_url': '', 'publisher_id': 1, 'category_id': 1});
        await db.insert('books', {'title': 'Clean Code', 'year': 2008, 'cover_url': '', 'publisher_id': 2, 'category_id': 2});

        await db.insert('book_author', {'book_id': 1, 'author_id': 1});
        await db.insert('book_author', {'book_id': 2, 'author_id': 2});
      },
    );
  }

  // --- READ METHODS ---
  Future<List<Map<String, dynamic>>> getCategories() async {
    if (kIsWeb) return _webCategories;
    Database db = await database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getPublishers() async {
    if (kIsWeb) return _webPublishers;
    Database db = await database;
    return await db.query('publishers');
  }

  Future<List<Map<String, dynamic>>> getAuthors() async {
    if (kIsWeb) return _webAuthors;
    Database db = await database;
    return await db.query('authors');
  }

  Future<List<Map<String, dynamic>>> getDetailedBooks({String searchQuery = '', String selectedCategory = 'Semua'}) async {
    List<Map<String, dynamic>> rawData = [];
    if (kIsWeb) {
      rawData = List.from(_webBooks);
    } else {
      Database db = await database;
      // GROUP_CONCAT akan menggabungkan nama dan id author kalau ada banyak.
      rawData = await db.rawQuery('''
        SELECT b.id_book, b.title, b.year, b.cover_url, b.category_id, b.publisher_id, c.category_name, p.publisher_name, 
               GROUP_CONCAT(ba.author_id, ',') as author_ids, 
               GROUP_CONCAT(a.name, ', ') as author_name
        FROM books b
        LEFT JOIN categories c ON b.category_id = c.id_category
        LEFT JOIN publishers p ON b.publisher_id = p.id_publisher
        LEFT JOIN book_author ba ON b.id_book = ba.book_id
        LEFT JOIN authors a ON ba.author_id = a.id_author
        GROUP BY b.id_book
      ''');
    }

    var filteredData = rawData;
    if (selectedCategory != 'Semua') {
      filteredData = filteredData.where((book) => book['category_name'] == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      filteredData = filteredData.where((book) {
        return book['title'].toString().toLowerCase().contains(queryLower) || 
               book['author_name'].toString().toLowerCase().contains(queryLower);
      }).toList();
    }
    return filteredData;
  }

  // --- CRUD METHODS (INSERT, UPDATE, DELETE) ---
  Future<void> insertBook(String title, int year, String coverUrl, int categoryId, int publisherId, List<int> authorIds) async {
    if (kIsWeb) {
      final category = _webCategories.firstWhere((c) => c['id_category'] == categoryId);
      final publisher = _webPublishers.firstWhere((p) => p['id_publisher'] == publisherId);
      final authorNames = _webAuthors.where((a) => authorIds.contains(a['id_author'])).map((a) => a['name']).join(', ');
      
      _webBooks.add({
        'id_book': _webIdCounter++,
        'title': title,
        'year': year,
        'cover_url': coverUrl,
        'category_id': categoryId,
        'category_name': category['category_name'],
        'publisher_id': publisherId,
        'publisher_name': publisher['publisher_name'],
        'author_ids': authorIds,
        'author_name': authorNames,
      });
      return;
    }

    Database db = await database;
    int bookId = await db.insert('books', {
      'title': title,
      'year': year,
      'cover_url': coverUrl,
      'category_id': categoryId,
      'publisher_id': publisherId,
    });
    
    // Insert Multiple Authors into relational table
    for (int aid in authorIds) {
      await db.insert('book_author', {
        'book_id': bookId,
        'author_id': aid,
      });
    }
  }

  Future<void> updateBook(int bookId, String title, int year, String coverUrl, int categoryId, int publisherId, List<int> authorIds) async {
    if (kIsWeb) {
      final index = _webBooks.indexWhere((b) => b['id_book'] == bookId);
      if (index != -1) {
        final category = _webCategories.firstWhere((c) => c['id_category'] == categoryId);
        final publisher = _webPublishers.firstWhere((p) => p['id_publisher'] == publisherId);
        final authorNames = _webAuthors.where((a) => authorIds.contains(a['id_author'])).map((a) => a['name']).join(', ');
        
        _webBooks[index] = {
          'id_book': bookId,
          'title': title,
          'year': year,
          'cover_url': coverUrl,
          'category_id': categoryId,
          'category_name': category['category_name'],
          'publisher_id': publisherId,
          'publisher_name': publisher['publisher_name'],
          'author_ids': authorIds,
          'author_name': authorNames,
        };
      }
      return;
    }

    Database db = await database;
    await db.update('books', {
      'title': title,
      'year': year,
      'cover_url': coverUrl,
      'category_id': categoryId,
      'publisher_id': publisherId,
    }, where: 'id_book = ?', whereArgs: [bookId]);
    
    // Simplifikasi update multi author (hapus lama dan bikin baru)
    await db.delete('book_author', where: 'book_id = ?', whereArgs: [bookId]);
    for (int aid in authorIds) {
      await db.insert('book_author', {
        'book_id': bookId,
        'author_id': aid,
      });
    }
  }

  Future<void> deleteBook(int bookId) async {
    if (kIsWeb) {
      _webBooks.removeWhere((b) => b['id_book'] == bookId);
      return;
    }
    Database db = await database;
    await db.delete('book_author', where: 'book_id = ?', whereArgs: [bookId]);
    await db.delete('books', where: 'id_book = ?', whereArgs: [bookId]);
  }

  // --- MASTER DATA INSERTIONS ---
  Future<void> insertCategory(String name) async {
    if (kIsWeb) {
      _webCategories.add({'id_category': _webCategories.length + 1, 'category_name': name});
      return;
    }
    Database db = await database;
    await db.insert('categories', {'category_name': name});
  }

  Future<void> insertAuthor(String name, String country) async {
    if (kIsWeb) {
      _webAuthors.add({'id_author': _webAuthors.length + 1, 'name': name, 'country': country});
      return;
    }
    Database db = await database;
    await db.insert('authors', {'name': name, 'country': country});
  }

  Future<void> insertPublisher(String name) async {
    if (kIsWeb) {
      _webPublishers.add({'id_publisher': _webPublishers.length + 1, 'publisher_name': name, 'city': '-'});
      return;
    }
    Database db = await database;
    await db.insert('publishers', {'publisher_name': name, 'city': '-'});
  }
}
