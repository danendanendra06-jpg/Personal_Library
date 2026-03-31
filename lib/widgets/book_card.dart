import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';

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
    final String? status = bookMap['status'];
    final bool isWishlist = (bookMap['is_wishlist'] == 1);

    // Generate Bintang Rating
    String starString = '';
    for (int i = 0; i < rating; i++) {
      starString += '★';
    }

    Widget buildFallbackCover() {
      return Container(
        color: const Color(0xFF2B3A55),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white24, size: 40),
              SizedBox(height: 8),
              Text('No Cover', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasCover
                    ? (bookMap['cover_url'].toString().startsWith('http')
                        ? Image.network(
                            bookMap['cover_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => buildFallbackCover(),
                          )
                        : Image.file(
                            File(bookMap['cover_url']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => buildFallbackCover(),
                          ))
                    : buildFallbackCover(),
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
          if (status != null && status.isNotEmpty)
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
            
          // Love Icon (Pojok Kanan Atas)
          if (isWishlist)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
              ),
            ),
        ],
        ),
      ),
    );
  }
}
