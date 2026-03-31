import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/book_list/book_list_bloc.dart';
import '../book_detail/book_detail_page.dart';
import '../book_management/book_form_page.dart';
import '../master_data/master_data_page.dart';
import '../../widgets/book_card.dart';
import '../../widgets/category_chip.dart';
import '../../utils/db_book.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/db_book.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _groupBy = 'Status'; // Default Letterboxd-style
  
  @override
  void initState() {
    super.initState();
    // BLoC event (FetchBooks) dipanggil otomatis di main.dart saat provider dibuat.
  }

  void _refreshBooks() {
    final bloc = context.read<BookListBloc>();
    bloc.add(FetchBooks(
      searchQuery: _searchController.text,
      category: bloc.currentCategory, // Untuk menjaga kategori saat diketik dicari
    ));
  }



  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D1B2A);
    const Color secondaryColor = Color(0xFF1B263B);
    const Color goldColor = Color(0xFFE9C46A);

    return Scaffold(
      backgroundColor: primaryColor,
      drawer: AppDrawer(onRefresh: _refreshBooks),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _refreshBooks(); // Update daftar setiap kali mengetik
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau penulis...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white38),
                            onPressed: () {
                              _searchController.clear();
                              _refreshBooks();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Categories & Grouping Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Kategori',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _groupBy,
                        dropdownColor: primaryColor,
                        icon: const Icon(Icons.sort, color: goldColor, size: 18),
                        style: const TextStyle(color: goldColor, fontSize: 13, fontWeight: FontWeight.bold),
                        items: ['Status', 'Kategori'].map((e) => DropdownMenuItem(value: e, child: Text('Grup: $e'))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _groupBy = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<BookListBloc, BookListState>(
              builder: (context, state) {
                String currentCat = 'Semua';
                if (state is BookListLoaded) {
                   currentCat = context.read<BookListBloc>().currentCategory;
                } else if (state is BookListLoading || state is BookListInitial) {
                   currentCat = context.read<BookListBloc>().currentCategory;
                }
                
                return SizedBox(
                  height: 40,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: DbBook().getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      
                      final categories = snapshot.data!;
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                           CategoryChip(
                             label: 'Semua', 
                             isSelected: currentCat == 'Semua', 
                             onTap: () => context.read<BookListBloc>().add(FetchBooks(searchQuery: _searchController.text, category: 'Semua'))
                           ),
                           ...categories.map((c) {
                             final catName = c['category_name'] as String;
                             return CategoryChip(
                               label: catName, 
                               isSelected: currentCat == catName, 
                               onTap: () => context.read<BookListBloc>().add(FetchBooks(searchQuery: _searchController.text, category: catName))
                             );
                           }),
                        ],
                      );
                    }
                  ),
                );
              }
            ),

            const SizedBox(height: 24),

            // Book List
            // Horizontal Book Lists Grouped by Category
            const SizedBox(height: 12),
            Expanded(
              child: ClipRect(
                child: BlocBuilder<BookListBloc, BookListState>(
                  builder: (context, state) {
                  if (state is BookListLoading || state is BookListInitial) {
                    return const Center(child: CircularProgressIndicator(color: goldColor));
                  } else if (state is BookListError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  } else if (state is BookListLoaded) {
                    final books = state.books;
                    if (books.isEmpty) {
                      return const Center(child: Text('Tidak ada buku yang sesuai.', style: TextStyle(color: Colors.white54)));
                    }
                    // Dynamic Grouping Based on `_groupBy`
                    Map<String, List<Map<String, dynamic>>> groupedBooks = {};
                    for (var book in books) {
                      String groupKey = 'Uncategorized';
                      if (_groupBy == 'Kategori') {
                         groupKey = book['category_name'] ?? 'Lainnya';
                         if (groupKey.trim().isEmpty) groupKey = 'Lainnya';
                      } else if (_groupBy == 'Status') {
                         groupKey = book['status'] ?? 'Belum Ada Status';
                         if (groupKey.trim().isEmpty) groupKey = 'Belum Ada Status';
                         // Normalize
                         if (groupKey != 'Read' && groupKey != 'Reading' && groupKey != 'Wishlist') {
                           groupKey = 'Belum Ada Status';
                         }
                      }
                      
                      if (!groupedBooks.containsKey(groupKey)) groupedBooks[groupKey] = [];
                      groupedBooks[groupKey]!.add(book);
                    }

                    // Sort groups for Status
                    List<String> sortedKeys = groupedBooks.keys.toList();
                    if (_groupBy == 'Status') {
                      List<String> order = ['Reading', 'Read', 'Wishlist', 'Belum Ada Status'];
                      sortedKeys.sort((a, b) {
                        int indexA = order.indexOf(a);
                        int indexB = order.indexOf(b);
                        if (indexA == -1) indexA = 99;
                        if (indexB == -1) indexB = 99;
                        return indexA.compareTo(indexB);
                      });
                    } else {
                      sortedKeys.sort(); // Alfabetis kategoti
                    }

                    return ListView.builder(
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final groupName = sortedKeys[index];
                        final listDalamGrup = groupedBooks[groupName]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _groupBy == 'Status' ? '$groupName Tracker' : groupName,
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'OpenSans'),
                                  ),
                                  Text(
                                    '${listDalamGrup.length} buku',
                                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 220, // Ketinggian layout buku yang baru
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                scrollDirection: Axis.horizontal, // Memanjang kesamping
                                itemCount: listDalamGrup.length,
                                itemBuilder: (context, bIndex) {
                                  final book = listDalamGrup[bIndex];
                                  return BookCard(
                                    bookMap: book,
                                    onView: () async {
                                      bool? changed = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => BookDetailPage(bookMap: book)),
                                      );
                                      if (changed == true) _refreshBooks();
                                    },
                                    onEdit: () async {
                                      bool? changed = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => BookFormPage(existingBook: book)),
                                      );
                                      if (changed == true) _refreshBooks();
                                    },
                                    onDelete: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext ctx) {
                                          return AlertDialog(
                                            backgroundColor: const Color(0xFF1B263B),
                                            title: const Text('Hapus Buku', style: TextStyle(color: Colors.white)),
                                            content: Text('Hapus buku "${book["title"]}"?', style: const TextStyle(color: Colors.white70)),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  context.read<BookListBloc>().add(DeleteBook(book['id_book']));
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buku telah dihapus!')));
                                                },
                                                child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

}
