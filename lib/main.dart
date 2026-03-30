import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/book_list/book_list_bloc.dart';
import 'blocs/book_management/book_form_bloc.dart';
import 'screens/home/book_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookListBloc>(
          create: (context) => BookListBloc()..add(FetchBooks()),
        ),
        BlocProvider<BookFormBloc>(
          create: (context) => BookFormBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Library App',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const BookListPage(),
      ),
    );
  }
}


