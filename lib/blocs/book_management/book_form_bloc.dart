import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/db_book.dart';

// --- EVENTS ---
abstract class BookFormEvent {}

class LoadFormData extends BookFormEvent {}

class SaveBookEvent extends BookFormEvent {
  final Map<String, dynamic>? existingBook;
  final String title;
  final int year;
  final String coverUrl;
  final int categoryId;
  final int publisherId;
  final List<int> authorIds; // Sekarang menerima Array/List untuk multiple authors

  SaveBookEvent({
    this.existingBook,
    required this.title,
    required this.year,
    required this.coverUrl,
    required this.categoryId,
    required this.publisherId,
    required this.authorIds,
  });
}

// --- STATES ---
abstract class BookFormState {}

class BookFormInitial extends BookFormState {}

class BookFormLoading extends BookFormState {}

class BookFormDataLoaded extends BookFormState {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> publishers;
  final List<Map<String, dynamic>> authors;

  BookFormDataLoaded({
    required this.categories,
    required this.publishers,
    required this.authors,
  });
}

class BookFormSaving extends BookFormState {}

class BookFormSuccess extends BookFormState {}

class BookFormError extends BookFormState {
  final String message;
  BookFormError(this.message);
}

// --- BLOC ---
class BookFormBloc extends Bloc<BookFormEvent, BookFormState> {
  final DbBook dbBook = DbBook();

  BookFormBloc() : super(BookFormInitial()) {
    on<LoadFormData>((event, emit) async {
       emit(BookFormLoading());
       try {
          final cats = await dbBook.getCategories();
          final pubs = await dbBook.getPublishers();
          final auths = await dbBook.getAuthors();
          emit(BookFormDataLoaded(categories: cats, publishers: pubs, authors: auths));
       } catch (e) {
          emit(BookFormError('Gagal memuat dropdown: \${e.toString()}'));
       }
    });

    on<SaveBookEvent>((event, emit) async {
       emit(BookFormSaving());
       try {
          if (event.existingBook != null) {
              await dbBook.updateBook(event.existingBook!['id_book'], event.title, event.year, event.coverUrl, event.categoryId, event.publisherId, event.authorIds);
          } else {
              await dbBook.insertBook(event.title, event.year, event.coverUrl, event.categoryId, event.publisherId, event.authorIds);
          }
          emit(BookFormSuccess());
       } catch (e) {
          emit(BookFormError('Gagal menyimpan buku: \${e.toString()}'));
       }
    });
  }
}
