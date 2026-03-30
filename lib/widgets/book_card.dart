import 'package:flutter/material.dart';
import 'dart:ui';

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
    const Color goldColor = Color(0xFFE9C46A);

    final title = bookMap['title'] ?? 'Unknown';
    final author = bookMap['author_name'] ?? 'Unknown Author';
    final hasCover = bookMap['cover_url'] != null && bookMap['cover_url'].toString().isNotEmpty;
    final int rating = bookMap['rating'] != null ? (bookMap['rating'] as int) : 0;
    final String status = bookMap['status'] ?? 'Wishlist';

    // Generate Bintang Rating
    String starString = '';
    for (int i = 0; i < rating; i++) {
      starString += '★';
    }

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: RepaintBoundary(
        child: Stack(
          children: [
          // Background Cover Image (Standard Container to prevent Ink bleed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: hasCover
                    ? DecorationImage(
                        image: NetworkImage(bookMap['cover_url']),
                        fit: BoxFit.cover,
                        onError: (e, s) {},
                      )
                    : const DecorationImage(
                        image: AssetImage('assets/images/Bangunan.jpg'),
                        fit: BoxFit.cover,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          
          // Ripple Effect Overlay
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onView,
              ),
            ),
          ),
          
          // Glassmorphism Overlay (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: goldColor,
                          fontSize: 10,
                        ),
                      ),
                      if (rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            starString, // ★★★★
                            style: const TextStyle(color: goldColor, fontSize: 10, letterSpacing: 1.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Status Badge (Pojok Kiri Atas)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Read' 
                    ? Colors.green.withOpacity(0.8) 
                    : (status == 'Reading' ? Colors.blue.withOpacity(0.8) : Colors.black54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Menu Kebab
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.8), size: 20),
              color: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'view') onView();
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('Lihat Detail', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'edit', child: Text('Edit Buku', style: TextStyle(color: Colors.white))),
                const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
