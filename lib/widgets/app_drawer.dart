import 'package:flutter/material.dart';
import '../utils/db_book.dart';
import '../screens/book_management/book_form_page.dart';

import '../screens/home/wishlist_page.dart';

import '../screens/home/entity_detail_page.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback onRefresh;
  const AppDrawer({super.key, required this.onRefresh});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final DbBook _db = DbBook();
  final Color primaryColor = const Color(0xFF0D1B2A);
  final Color secondaryColor = const Color(0xFF1B263B);
  final Color goldColor = const Color(0xFFE9C46A);

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _authors = [];
  List<Map<String, dynamic>> _publishers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cats = await _db.getCategories();
    final auths = await _db.getAuthors();
    final pubs = await _db.getPublishers();
    setState(() {
      _categories = cats;
      _authors = auths;
      _publishers = pubs;
    });
  }

  void _showAddDialog({required String title, required String hint, String? extraHint, Function(String)? onSave, Function(String, String)? onSaveAdvanced}) {
    final TextEditingController ctrl = TextEditingController();
    final TextEditingController extraCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: goldColor), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (extraHint != null) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: extraCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: extraHint,
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: goldColor), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: Colors.black),
              onPressed: () async {
                if (ctrl.text.isNotEmpty) {
                  if (onSaveAdvanced != null) {
                    await onSaveAdvanced(ctrl.text, extraCtrl.text.isEmpty ? 'Unknown' : extraCtrl.text);
                  } else if (onSave != null) {
                    await onSave(ctrl.text);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                  widget.onRefresh();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white10,
    );
  }

  Widget _buildExpansionTile({required IconData icon, required String title, required List<Map<String, dynamic>> items, required String nameKey, required VoidCallback onAdd}) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      iconColor: goldColor,
      collapsedIconColor: Colors.white54,
      childrenPadding: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
      children: [
        ...items.map((item) => ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(item[nameKey], style: const TextStyle(color: Colors.white70, fontSize: 14)),
              leading: const Icon(Icons.circle, size: 8, color: Colors.white38),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EntityDetailPage(entityType: title, entityMap: item),
                ));
              },
            )),
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Icon(Icons.add, color: goldColor, size: 20),
          title: Text('Tambah $title', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
          onTap: onAdd,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Row(
                children: [
                   ClipRRect(
                     borderRadius: BorderRadius.all(Radius.circular(8)),
                     child: Image(
                       image: AssetImage('assets/images/app_logo.png'),
                       height: 48,
                       width: 48,
                     ),
                   ),
                  SizedBox(width: 16),
                  Text(
                    'LibraQuest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite_rounded,
                    title: 'Wishlist',
                    onTap: () {
                      Navigator.pop(context);
                      // Kalo ini halamannya adalah wishlist, ya gaboleh push lagi. Kalo bukan, pergi ke wishlist.
                      // Mengganti tumpukan layar supaya tidak muncul tombol back tapi icon menu hamburger.
                      Navigator.pushAndRemoveUntil(
                         context, 
                         MaterialPageRoute(builder: (context) => const WishlistPage()),
                         (route) => route.isFirst,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  _buildExpansionTile(
                    icon: Icons.category_rounded,
                    title: 'Kategori',
                    items: _categories,
                    nameKey: 'category_name',
                    onAdd: () {
                      _showAddDialog(
                        title: 'Tambah Kategori',
                        hint: 'Nama Kategori',
                        onSave: (val) => _db.insertCategory(val),
                      );
                    },
                  ),

                  _buildExpansionTile(
                    icon: Icons.person_rounded,
                    title: 'Author',
                    items: _authors,
                    nameKey: 'name',
                    onAdd: () {
                      _showAddDialog(
                        title: 'Tambah Author',
                        hint: 'Nama Author',
                        extraHint: 'Negara (Opsional)',
                        onSaveAdvanced: (val, extra) => _db.insertAuthor(val, extra.isEmpty ? 'Unknown' : extra),
                      );
                    },
                  ),

                  _buildExpansionTile(
                    icon: Icons.business_rounded,
                    title: 'Publisher',
                    items: _publishers,
                    nameKey: 'publisher_name',
                    onAdd: () {
                      _showAddDialog(
                        title: 'Tambah Publisher',
                        hint: 'Nama Publisher',
                        extraHint: 'Kota (Opsional)',
                        onSaveAdvanced: (val, extra) => _db.insertPublisher(val, extra.isEmpty ? '-' : extra),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    onTap: () {
                      Navigator.pop(context); // Close Drawer
                      // Exit app simulation or un-auth
                    },
                  ),
                ],
              ),
            ),
            
            // Dashed Add Book Box
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context); // close drawer first
                  bool? changed = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BookFormPage()));
                  if (changed == true) widget.onRefresh();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    // For dashed border simulation, using solid border style
                    border: Border.all(color: Colors.white24, width: 2), 
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
                          ]
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      const Text('Add new book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text('Tap to open form', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
