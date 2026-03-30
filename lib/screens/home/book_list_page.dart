import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/book_list/book_list_bloc.dart';
import '../book_detail/book_detail_page.dart';
import '../book_management/book_form_page.dart';
import '../master_data/master_data_page.dart';
import '../../widgets/book_card.dart';
import '../../widgets/category_chip.dart';
import '../../utils/db_book.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final TextEditingController _searchController = TextEditingController();
  
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MasterDataPage()),
                      );
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.settings, color: goldColor),
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

            // Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Kategori',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Daftar Buku',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
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
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          bookMap: books[index],
                          onView: () async {
                            bool? changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailPage(bookMap: books[index]),
                              ),
                            );
                            if (changed == true) {
                              final bloc = context.read<BookListBloc>();
                              bloc.add(FetchBooks(searchQuery: _searchController.text, category: bloc.currentCategory));
                            }
                          },
                          onEdit: () async {
                            bool? changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookFormPage(existingBook: books[index]),
                              ),
                            );
                            if (changed == true) {
                              final bloc = context.read<BookListBloc>();
                              bloc.add(FetchBooks(searchQuery: _searchController.text, category: bloc.currentCategory));
                            }
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xFF1B263B),
                                  title: const Text('Hapus Buku', style: TextStyle(color: Colors.white)),
                                  content: Text('Hapus buku "${books[index]['title']}"?', style: const TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        context.read<BookListBloc>().add(DeleteBook(books[index]['id_book']));
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
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: goldColor,
        onPressed: () async {
          // Navigasi ke Form Tambah Buku
          bool? changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookFormPage()),
          );
          if (changed == true) {
            context.read<BookListBloc>().add(FetchBooks(searchQuery: _searchController.text, category: context.read<BookListBloc>().currentCategory));
          }
        },
        child: const Icon(Icons.add, color: primaryColor),
      ),
    );
  }

}
