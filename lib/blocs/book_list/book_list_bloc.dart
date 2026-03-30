import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/db_book.dart';

// --- EVENTS ---
abstract class BookListEvent {}

class FetchBooks extends BookListEvent {
  final String searchQuery;
  final String category;
  FetchBooks({this.searchQuery = '', this.category = 'Semua'});
}

class DeleteBook extends BookListEvent {
  final int id;
  DeleteBook(this.id);
}

// --- STATES ---
abstract class BookListState {}

class BookListInitial extends BookListState {}

class BookListLoading extends BookListState {}

class BookListLoaded extends BookListState {
  final List<Map<String, dynamic>> books;
  BookListLoaded(this.books);
}

class BookListError extends BookListState {
  final String message;
  BookListError(this.message);
}

// --- BLOC ---
class BookListBloc extends Bloc<BookListEvent, BookListState> {
  final DbBook dbBook = DbBook();
  
  String currentSearchQuery = '';
  String currentCategory = 'Semua';

  BookListBloc() : super(BookListInitial()) {
    on<FetchBooks>((event, emit) async {
      emit(BookListLoading());
      try {
         currentSearchQuery = event.searchQuery;
         currentCategory = event.category;
         
         final books = await dbBook.getDetailedBooks(
            searchQuery: event.searchQuery, 
            selectedCategory: event.category
         );
         
         emit(BookListLoaded(books));
      } catch (e) {
         emit(BookListError('Gagal memuat buku: \${e.toString()}'));
      }
    });

    on<DeleteBook>((event, emit) async {
      try {
         await dbBook.deleteBook(event.id);
         // Muat ulang daftar setelah dihapus
         add(FetchBooks(searchQuery: currentSearchQuery, category: currentCategory));
      } catch (e) {
         emit(BookListError('Gagal menghapus buku: \${e.toString()}'));
      }
    });
  }
}
