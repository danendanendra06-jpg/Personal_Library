import 'package:flutter/material.dart';
import '../../utils/db_book.dart';
import '../../widgets/book_card.dart';
import '../book_detail/book_detail_page.dart';
import '../book_management/book_form_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final DbBook _db = DbBook();
  final Color primaryColor = const Color(0xFF0D1B2A);
  final Color secondaryColor = const Color(0xFF1B263B);
  final Color goldColor = const Color(0xFFE9C46A);

  List<Map<String, dynamic>> _wishlistBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);
    final allBooks = await _db.getDetailedBooks(); // Ambil semua
    setState(() {
      _wishlistBooks = allBooks.where((b) => b['status'] == 'Wishlist').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        title: const Text('Wishlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: goldColor))
          : _wishlistBooks.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada buku di Wishlist.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _wishlistBooks.length,
                  itemBuilder: (context, index) {
                    final book = _wishlistBooks[index];
                    return BookCard(
                      bookMap: book,
                      onView: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookDetailPage(bookMap: book)),
                        );
                        _loadWishlist(); // Refresh kalo sepulangnya statusnya diganti
                      },
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookFormPage(existingBook: book)),
                        );
                        _loadWishlist();
                      },
                      onDelete: () async {
                        await _db.deleteBook(book['id_book']);
                        _loadWishlist();
                      },
                    );
                  },
                ),
    );
  }
}
