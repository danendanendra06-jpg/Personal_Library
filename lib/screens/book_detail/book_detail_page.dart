import 'package:flutter/material.dart';
import '../../utils/db_book.dart';
import '../book_management/book_form_page.dart';

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> bookMap;

  const BookDetailPage({super.key, required this.bookMap});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D1B2A);
    const Color secondaryColor = Color(0xFF1B263B);
    const Color goldColor = Color(0xFFE9C46A);

    final bookId = bookMap['id_book'];
    final title = bookMap['title'] ?? 'Unknown';
    final category = bookMap['category_name'] ?? 'Uncategorized';
    final author = bookMap['author_name'] ?? 'Unknown Author';
    final publisher = bookMap['publisher_name'] ?? 'Unknown Publisher';
    final year = bookMap['year']?.toString() ?? '-';
    
    final status = bookMap['status'] ?? 'Wishlist';
    final rating = bookMap['rating'] != null ? (bookMap['rating'] as int) : 0;
    final notes = bookMap['notes']?.toString();
    final startDate = bookMap['start_date']?.toString();
    final finishDate = bookMap['finish_date']?.toString();

    // Generate Stars
    String starStr = '';
    for(int i=0; i<rating; i++) { starStr += '★'; }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Buku',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'OpenSans'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: goldColor),
            onPressed: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookFormPage(existingBook: bookMap)),
              );
              if (updated == true) {
                // Beritahu parent (BookListPage) untuk refresh agar perubahan terlihat
                Navigator.pop(context, true); 
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _showDeleteDialog(context, bookId, title),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Cover Buku
            Center(
              child: Container(
                width: 160,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: bookMap['cover_url'] != null && bookMap['cover_url'].toString().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(bookMap['cover_url']),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {}, // Hindari error mbleber jika URL mati
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/Bangunan.jpg'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info Utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Oleh: $author",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating Stars
                  if (rating > 0)
                    Text(
                      starStr,
                      style: const TextStyle(color: goldColor, fontSize: 28, letterSpacing: 4),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Metadata Grid
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetaCol(Icons.category, 'Kategori', category, goldColor),
                  _buildDivider(),
                  _buildMetaCol(Icons.calendar_month, 'Terbit', year, goldColor),
                  _buildDivider(),
                  _buildMetaCol(Icons.business, 'Penerbit', publisher, goldColor),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Ulasan Pribadi (Letterboxd Diary-style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan Pribadi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Read' 
                              ? Colors.green.withOpacity(0.8) 
                              : (status == 'Reading' ? Colors.blue.withOpacity(0.8) : Colors.black54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (startDate != null && startDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Mulai: $startDate ${(finishDate != null && finishDate.isNotEmpty) ? " | Selesai: $finishDate" : ""}', 
                        style: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic)
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(
                      (notes == null || notes.isEmpty) 
                          ? 'Belum ada ulasan yang ditulis untuk buku ini.'
                          : notes,
                      style: TextStyle(
                        color: (notes == null || notes.isEmpty) ? Colors.white38 : Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Spasi margin
          ],
        ),
      ),
      // Tombol Pinjam dihapus karena ini library personal
    );
  }

  Widget _buildMetaCol(IconData icon, String title, String value, Color gold) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white24,
    );
  }

  void _showDeleteDialog(BuildContext context, int bookId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          title: const Text('Hapus Buku', style: TextStyle(color: Colors.white)),
          content: Text('Apakah Anda yakin ingin menghapus buku "$title"?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx); // Tutup dialog
                await DbBook().deleteBook(bookId); // Hapus dari database
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buku telah dihapus!')));
                  Navigator.pop(context, true); // Kembali ke list page dengan argumen true (refresh)
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
