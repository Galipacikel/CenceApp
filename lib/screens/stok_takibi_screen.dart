import 'package:flutter/material.dart';
import '../models/stock_part.dart';

class StokTakibiScreen extends StatefulWidget {
  final StockPartRepository repository;
  StokTakibiScreen({Key? key, StockPartRepository? repository})
      : repository = repository ?? MockStockPartRepository(),
        super(key: key);

  @override
  State<StokTakibiScreen> createState() => _StokTakibiScreenState();
}

class _StokTakibiScreenState extends State<StokTakibiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String search = '';
  int _currentIndex = 0;
  late Future<List<StockPart>> _futureParts;
  List<StockPart> _allParts = [];

  @override
  void initState() {
    super.initState();
    _futureParts = widget.repository.getAll();
  }

  List<StockPart> get filteredParts {
    if (search.isEmpty) return _allParts;
    return _allParts.where((p) =>
      p.name.toLowerCase().contains(search.toLowerCase()) ||
      p.code.toLowerCase().contains(search.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Stok Takibi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<StockPart>>(
        future: _futureParts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Stokta parça bulunamadı.'));
          }
          _allParts = snapshot.data!;
          final filtered = filteredParts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Parça adı veya kodu ile ara',
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => search = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Parçalar (${filtered.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_alt_outlined, size: 18),
                      label: const Text('Filtrele'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.sort, size: 18),
                      label: const Text('Sırala'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            Text('Kod: ${p.code}', style: const TextStyle(fontSize: 14)),
                            Text('Miktar ${p.quantity}', style: const TextStyle(fontSize: 14)),
                            Text('Son Güncelleme: ${p.lastUpdate}', style: const TextStyle(fontSize: 14)),
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 20),
                                const SizedBox(width: 4),
                                Text('Kritik Seviye (${p.criticalLevel})', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            if (i != filtered.length - 1) const Divider(height: 18),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF23408E),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Stok',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'Giriş/Çıkış',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Uyarılar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ayarlar',
            ),
          ],
          elevation: 0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        tooltip: 'Parça Ekle',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
} 