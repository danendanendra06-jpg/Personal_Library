import 'package:flutter/material.dart';
import '../../utils/db_book.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D1B2A);
    const Color secondaryColor = Color(0xFF1B263B);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Master Data', style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const Text(
            'Konfigurasi Sistem',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildAddCategoryCard(context),
          const SizedBox(height: 32),
          _buildAddPublisherCard(context),
          const SizedBox(height: 32),
          _buildAddAuthorCard(context),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildAddCategoryCard(BuildContext context) {
    final controller = TextEditingController();
    return _MasterCard(
      title: 'Kategori Baru',
      icon: Icons.category_rounded,
      children: [
        _buildTextField(controller, 'Nama Kategori (contoh: Komik)'),
        const SizedBox(height: 16),
        _buildSaveButton(context, () async {
          if (controller.text.trim().isNotEmpty) {
            await DbBook().insertCategory(controller.text.trim());
            controller.clear();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori Berhasil Ditambahkan')));
          }
        }),
      ],
    );
  }

  Widget _buildAddPublisherCard(BuildContext context) {
    final controller = TextEditingController();
    return _MasterCard(
      title: 'Penerbit Baru',
      icon: Icons.business_rounded,
      children: [
        _buildTextField(controller, 'Nama Penerbit (contoh: Gramedia)'),
        const SizedBox(height: 16),
        _buildSaveButton(context, () async {
          if (controller.text.trim().isNotEmpty) {
            await DbBook().insertPublisher(controller.text.trim());
            controller.clear();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penerbit Berhasil Ditambahkan')));
          }
        }),
      ],
    );
  }

  Widget _buildAddAuthorCard(BuildContext context) {
    final nameController = TextEditingController();
    final countryController = TextEditingController();
    
    return _MasterCard(
      title: 'Penulis Baru',
      icon: Icons.person_add_rounded,
      children: [
        _buildTextField(nameController, 'Nama Lengkap (contoh: J.K. Rowling)'),
        const SizedBox(height: 16),
        _buildTextField(countryController, 'Negara Asal (contoh: Inggris)'),
        const SizedBox(height: 16),
        _buildSaveButton(context, () async {
          if (nameController.text.trim().isNotEmpty && countryController.text.trim().isNotEmpty) {
            await DbBook().insertAuthor(nameController.text.trim(), countryController.text.trim());
            nameController.clear();
            countryController.clear();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penulis Berhasil Ditambahkan')));
          }
        }),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25), // Inset feel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, VoidCallback onPressed) {
    const Color goldColor = Color(0xFFE9C46A);
    const Color primaryColor = Color(0xFF0D1B2A);
    
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: primaryColor,
          elevation: 8,
          shadowColor: goldColor.withOpacity(0.6), // Efek Glowing
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
      ),
    );
  }
}

class _MasterCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _MasterCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFE9C46A);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), // Efek Glassmorphism
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: goldColor, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'OpenSans'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }
}
