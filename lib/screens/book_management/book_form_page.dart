import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/book_management/book_form_bloc.dart';

class BookFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingBook; // Jika null = Add, jika ada = Edit

  const BookFormPage({super.key, this.existingBook});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _coverUrlController = TextEditingController();
  
  // Reading Log Controllers
  final _startDateController = TextEditingController();
  final _finishDateController = TextEditingController();
  final _notesController = TextEditingController();
  int _rating = 0;
  String? _selectedStatus = 'Wishlist';

  int? _selectedCategoryId;
  int? _selectedPublisherId;
  List<int?> _selectedAuthorIdsList = [null]; // Default 1 dropdown kosong

  @override
  void initState() {
    super.initState();
    if (widget.existingBook != null) {
      final b = widget.existingBook!;
      _titleController.text = b['title'];
      _yearController.text = b['year'].toString();
      _coverUrlController.text = b['cover_url'] ?? '';
      _selectedCategoryId = b['category_id'];
      _selectedPublisherId = b['publisher_id'];

      // Reading Logs
      _startDateController.text = b['start_date'] ?? '';
      _finishDateController.text = b['finish_date'] ?? '';
      _notesController.text = b['notes'] ?? '';
      _rating = b['rating'] ?? 0;
      _selectedStatus = b['status'] ?? 'Wishlist';
      
      // Parse author_ids from SQLite string or Web List
      final aIds = b['author_ids'];
      if (aIds is String) {
        if (aIds.trim().isNotEmpty) {
           _selectedAuthorIdsList = aIds.split(',').map((e) => int.parse(e.trim()) as int?).toList();
        }
      } else if (aIds is List) {
        _selectedAuthorIdsList = aIds.map((e) => e as int?).toList();
      } else if (aIds is int) {
        _selectedAuthorIdsList = [aIds];
      }
      
      if (_selectedAuthorIdsList.isEmpty) {
        _selectedAuthorIdsList = [null];
      }
    }
    // Memicu BLoC untuk memuat data list dropdown dari DB
    context.read<BookFormBloc>().add(LoadFormData());
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      // Membersihkan null dari list (apabila pengguna pencet tambah kolom tapi ga milih)
      final validAuthorIds = _selectedAuthorIdsList.where((id) => id != null).cast<int>().toList();

      if (_selectedCategoryId == null || _selectedPublisherId == null || validAuthorIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap lengkapi kategori, penerbit, dan minimal 1 penulis!')),
        );
        return;
      }

      FocusScope.of(context).unfocus(); // Tutup keyboard

      // Mengirimkan Event Simpan ke BLoC
      context.read<BookFormBloc>().add(
        SaveBookEvent(
          existingBook: widget.existingBook,
          title: _titleController.text,
          year: int.parse(_yearController.text),
          coverUrl: _coverUrlController.text.trim(),
          categoryId: _selectedCategoryId!,
          publisherId: _selectedPublisherId!,
          authorIds: validAuthorIds,
          startDate: _startDateController.text.trim(),
          finishDate: _finishDateController.text.trim(),
          notes: _notesController.text.trim(),
          rating: _rating,
          status: _selectedStatus,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D1B2A);
    const Color secondaryColor = Color(0xFF1B263B);
    const Color goldColor = Color(0xFFE9C46A);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(widget.existingBook != null ? 'Edit Buku' : 'Tambah Buku',
          style: const TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontWeight: FontWeight.bold),
        ),
        backgroundColor: secondaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<BookFormBloc, BookFormState>(
        listener: (context, state) {
          if (state is BookFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.existingBook != null ? 'Buku berhasil diubah!' : 'Buku baru berhasil ditambah!')),
            );
            Navigator.pop(context, true); // Kembali ke list page dan minta refresh
          } else if (state is BookFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.redAccent))),
            );
          } else if (state is BookFormDataLoaded) {
             // Jika ini nambah buku baru, inisialisasi default ke index 0
             if (widget.existingBook == null) {
                if (state.categories.isNotEmpty && _selectedCategoryId == null) _selectedCategoryId = state.categories[0]['id_category'];
                if (state.publishers.isNotEmpty && _selectedPublisherId == null) _selectedPublisherId = state.publishers[0]['id_publisher'];
                // Author default dibiarkan kosong agar mereka memilh
             }
          }
        },
        builder: (context, state) {
          if (state is BookFormLoading || state is BookFormInitial) {
            return const Center(child: CircularProgressIndicator(color: goldColor));
          }

          List<Map<String,dynamic>> cats = [];
          List<Map<String,dynamic>> pubs = [];
          List<Map<String,dynamic>> auths = [];
          
          if (state is BookFormDataLoaded) {
             cats = state.categories;
             pubs = state.publishers;
             auths = state.authors;
          } 

          if (state is BookFormSaving) {
             return const Center(child: CircularProgressIndicator(color: goldColor));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Judul Buku'),
                  _buildTextField(_titleController, 'Masukkan Judul Buku...', Icons.book, secondaryColor),
                  
                  const SizedBox(height: 16),
                  _buildLabel('Tahun Terbit'),
                  _buildTextField(_yearController, 'Contoh: 2024', Icons.calendar_today, secondaryColor, isNumber: true),

                  const SizedBox(height: 16),
                  _buildLabel('URL Gambar Sampul (Opsional)'),
                  _buildTextField(_coverUrlController, 'Contoh: https://example.com/cover.jpg', Icons.image, secondaryColor, isOptional: true),

                  const SizedBox(height: 16),
                  _buildLabel('Penerbit'),
                  _buildDropdown(
                    value: _selectedPublisherId,
                    items: pubs.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id_publisher'],
                        child: Text(p['publisher_name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPublisherId = val),
                    secondaryColor: secondaryColor,
                  ),

                  const SizedBox(height: 16),
                  _buildLabel('Kategori'),
                  _buildDropdown(
                    value: _selectedCategoryId,
                    items: cats.map((c) {
                      return DropdownMenuItem<int>(
                        value: c['id_category'],
                        child: Text(c['category_name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                    secondaryColor: secondaryColor,
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('Pilih Penulis (Bisa Lebih Dari Satu)'),
                  _buildAuthorDropdowns(auths, goldColor, secondaryColor),

                  // Batas Personal Library Form =================================
                  const SizedBox(height: 36),
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 24),
                  Text('Progress Membaca & Ulasan (Opsional)', style: TextStyle(color: goldColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Status Buku'),
                  _buildDropdown(
                    value: _selectedStatus,
                    items: ['Wishlist', 'Reading', 'Read'].map((s) {
                      return DropdownMenuItem<String>(
                        value: s,
                        child: Text(s),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val),
                    secondaryColor: secondaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Start & Finish Date Row
                  Row(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Mulai Baca'),
                          _buildDateField(_startDateController, 'YYYY-MM-DD', Icons.calendar_today, secondaryColor),
                        ],
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Selesai Baca'),
                          _buildDateField(_finishDateController, 'YYYY-MM-DD', Icons.check_circle_outline, secondaryColor),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Rating Buku (1-5 Bintang)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: goldColor,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Catatan atau Kesan Pesan'),
                  _buildTextField(_notesController, 'Tulis review singkat kamu disini...', Icons.edit_note, secondaryColor, isOptional: true, maxLines: 4),
                  // ==============================================================

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: primaryColor,
                        elevation: 8,
                        shadowColor: goldColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        widget.existingBook != null ? 'SIMPAN PERUBAHAN' : 'TAMBAH BUKU',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 6),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'OpenSans'),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, Color color, {bool isNumber = false, bool isOptional = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFFE9C46A).withOpacity(0.7)) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: maxLines == 1 ? 0 : 20),
        ),
        validator: (value) => !isOptional && (value == null || value.isEmpty) ? 'Form ini wajib diisi' : null,
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField( // Tidak pakai mutlak divalidasi karna opsional
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFE9C46A),
                    onPrimary: Colors.black,
                    surface: Color(0xFF1B263B),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            controller.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: const Color(0xFFE9C46A).withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged, required Color secondaryColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: secondaryColor,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAuthorDropdowns(List<Map<String,dynamic>> authors, Color gold, Color secondary) {
    if (authors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('Belum ada penulis. Tambahkan di Pengaturan Master Data.', style: TextStyle(color: Colors.white54)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _selectedAuthorIdsList.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _selectedAuthorIdsList[i],
                    items: authors.map((a) {
                      return DropdownMenuItem<int>(
                        value: a['id_author'],
                        child: Text(a['name'] + ' (' + a['country'] + ')'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedAuthorIdsList[i] = val;
                      });
                    },
                    secondaryColor: secondary,
                  ),
                ),
                if (_selectedAuthorIdsList.length > 1) // Tampilkan tombol hapus kalau kolom > 1
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _selectedAuthorIdsList.removeAt(i);
                      });
                    },
                  ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedAuthorIdsList.add(null);
            });
          },
          icon: Icon(Icons.add, color: gold),
          label: Text('Tambah Penulis', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
