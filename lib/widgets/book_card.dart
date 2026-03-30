import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final Map<String, dynamic> bookMap;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.bookMap,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const Color secondaryColor = Color(0xFF1B263B);
    const Color goldColor = Color(0xFFE9C46A);

    final title = bookMap['title'] ?? 'Unknown';
    final category = bookMap['category_name'] ?? 'Uncategorized';
    final author = bookMap['author_name'] ?? 'Unknown Author';
    final publisher = bookMap['publisher_name'] ?? 'Unknown Publisher';
    final year = bookMap['year']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          InkWell(
            onTap: onView,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 36), // Padding kanan buat ruang ikon titik 3
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Book Cover Network / Placeholder
                  Container(
                    width: 80,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      image: bookMap['cover_url'] != null && bookMap['cover_url'].toString().isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(bookMap['cover_url']),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {}, // Hindari error mbleber jika link invalid
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/Bangunan.jpg'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Book Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            color: goldColor.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Oleh: $author",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.date_range, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              year,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: goldColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                publisher,
                                style: TextStyle(
                                  color: goldColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tombol Titik Tiga (Action Menu)
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: const Color(0xFF0D1B2A), // Warna background pop up gelap
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'view') onView();
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'view', child: Text('Lihat Detail', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'edit', child: Text('Edit Buku', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
