import 'package:flutter/material.dart';
import '../../utils/db_book.dart';
import '../../widgets/book_card.dart';
import '../book_detail/book_detail_page.dart';
import '../book_management/book_form_page.dart';

class EntityDetailPage extends StatefulWidget {
  final String entityType; // 'Kategori', 'Author', 'Publisher'
  final Map<String, dynamic> entityMap;

  const EntityDetailPage({super.key, required this.entityType, required this.entityMap});

  @override
  State<EntityDetailPage> createState() => _EntityDetailPageState();
}

class _EntityDetailPageState extends State<EntityDetailPage> {
  final DbBook _db = DbBook();
  final Color primaryColor = const Color(0xFF0D1B2A);
  final Color secondaryColor = const Color(0xFF1B263B);
  final Color goldColor = const Color(0xFFE9C46A);

  List<Map<String, dynamic>> _books = [];
  late Map<String, dynamic> _currentEntityMap;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentEntityMap = Map.from(widget.entityMap);
    _loadFilteredBooks();
  }

  Future<void> _loadFilteredBooks() async {
    setState(() => _isLoading = true);
    final allBooks = await _db.getDetailedBooks();
    List<Map<String, dynamic>> filtered = [];

    if (widget.entityType == 'Kategori') {
      filtered = allBooks.where((b) => b['category_id'] == _currentEntityMap['id_category']).toList();
    } else if (widget.entityType == 'Publisher') {
      filtered = allBooks.where((b) => b['publisher_id'] == _currentEntityMap['id_publisher']).toList();
    } else if (widget.entityType == 'Author') {
      filtered = allBooks.where((b) {
        String aids = b['author_ids'].toString();
        List<String> ids = aids.split(',');
        return ids.contains(_currentEntityMap['id_author'].toString());
      }).toList();
    }

    setState(() {
      _books = filtered;
      _isLoading = false;
    });
  }

  String _getTitle() {
    if (widget.entityType == 'Kategori') return _currentEntityMap['category_name'];
    if (widget.entityType == 'Author') return _currentEntityMap['name'];
    if (widget.entityType == 'Publisher') return _currentEntityMap['publisher_name'];
    return 'Detail';
  }

  String _getDescription() {
    if (widget.entityType == 'Kategori') {
      String name = _currentEntityMap['category_name'].toString().toLowerCase();
      if (name == 'novel') return 'Buku fiksi yang menceritakan sebuah narasi panjang, imajinatif, dan mendalam.';
      if (name == 'teknologi') return 'Membahas inovasi, pemrograman, arsitektur sistem, dan perkembangan sains terapan (IT).';
      if (name == 'sains') return 'Eksplorasi ilmu pengetahuan alam, fisika, biologi, teori alam semesta, dan penelitian empiris.';
      if (name == 'sejarah') return 'Catatan kronologis dan analisis peristiwa penting yang membentuk peradaban manusia.';
      return 'Kategori buku yang memiliki koleksi karya-karya bermutu tinggi seputar $name.';
    }
    if (widget.entityType == 'Author') {
      String country = _currentEntityMap['country'] ?? 'Unknown';
      return 'Biografi: Penulis berbakat yang berasal dari $country. Telah melahirkan karya-karya fenomenal yang tersimpan di dalam LibraQuest.';
    }
    if (widget.entityType == 'Publisher') {
      String city = _currentEntityMap['city'] ?? 'Unknown';
      return 'Profil: Perusahaan penerbitan yang berbasis di $city. Membantu mendistribusikan buku-buku terbaik ke seluruh dunia.';
    }
    return '';
  }

  void _showEditDialog() {
    final TextEditingController nameCtrl = TextEditingController(text: _getTitle());
    final TextEditingController extraCtrl = TextEditingController();
    
    String extraHint = '';
    if (widget.entityType == 'Author') {
      extraHint = 'Negara Asal';
      extraCtrl.text = _currentEntityMap['country'] ?? '';
    } else if (widget.entityType == 'Publisher') {
      extraHint = 'Kota Penerbit';
      extraCtrl.text = _currentEntityMap['city'] ?? '';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: Text('Edit ${widget.entityType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama ${widget.entityType}',
                  labelStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: goldColor), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (widget.entityType != 'Kategori') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: extraCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: extraHint,
                    labelStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: goldColor), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: Colors.black),
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  if (widget.entityType == 'Kategori') {
                    await _db.updateCategory(_currentEntityMap['id_category'], nameCtrl.text);
                    _currentEntityMap['category_name'] = nameCtrl.text;
                  } else if (widget.entityType == 'Author') {
                    await _db.updateAuthor(_currentEntityMap['id_author'], nameCtrl.text, extraCtrl.text);
                    _currentEntityMap['name'] = nameCtrl.text;
                    _currentEntityMap['country'] = extraCtrl.text;
                  } else if (widget.entityType == 'Publisher') {
                    await _db.updatePublisher(_currentEntityMap['id_publisher'], nameCtrl.text, extraCtrl.text);
                    _currentEntityMap['publisher_name'] = nameCtrl.text;
                    _currentEntityMap['city'] = extraCtrl.text;
                  }
                  
                  if (ctx.mounted) Navigator.pop(ctx);
                  setState(() {}); // refresh UI text
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        title: Text(widget.entityType, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
            tooltip: 'Edit Profil',
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Biodata/Penjelasan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _getTitle(),
                        style: TextStyle(color: goldColor, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getDescription(),
                  style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_books.length} Buku Koleksi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Grid View Books
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: goldColor))
                : _books.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada buku di kategori ini.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return BookCard(
                            bookMap: book,
                            onView: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BookDetailPage(bookMap: book)),
                              );
                              _loadFilteredBooks();
                            },
                            onEdit: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BookFormPage(existingBook: book)),
                              );
                              _loadFilteredBooks();
                            },
                            onDelete: () async {
                              await _db.deleteBook(book['id_book']);
                              _loadFilteredBooks();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
