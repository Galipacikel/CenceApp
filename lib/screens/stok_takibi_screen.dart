import 'package:flutter/material.dart';

class StokTakibiScreen extends StatefulWidget {
  const StokTakibiScreen({Key? key}) : super(key: key);

  @override
  State<StokTakibiScreen> createState() => _StokTakibiScreenState();
}

class _StokTakibiScreenState extends State<StokTakibiScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> parcalar = [
    {
      'ad': 'Anakart',
      'kod': '77889',
      'miktar': 1,
      'guncelleme': '12.08.2023',
      'kritik': 2,
    },
    {
      'ad': 'Ekran',
      'kod': '44556',
      'miktar': 3,
      'guncelleme': '11.08.2023',
      'kritik': 5,
    },
    {
      'ad': 'Kablo',
      'kod': '67890',
      'miktar': 5,
      'guncelleme': '10.08.2023',
      'kritik': 3,
    },
    {
      'ad': 'Sensör',
      'kod': '12345',
      'miktar': 10,
      'guncelleme': '09.08.2023',
      'kritik': 5,
    },
    {
      'ad': 'Batarya',
      'kod': '11223',
      'miktar': 20,
      'guncelleme': '08.08.2023',
      'kritik': 10,
    },
  ];
  String search = '';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final filtered = parcalar.where((p) =>
      p['ad'].toLowerCase().contains(search.toLowerCase()) ||
      p['kod'].toLowerCase().contains(search.toLowerCase())
    ).toList();
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
      body: Padding(
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
                        Text(p['ad'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text('Kod: ${p['kod']}', style: const TextStyle(fontSize: 14)),
                        Text('Miktar ${p['miktar']}', style: const TextStyle(fontSize: 14)),
                        Text('Son Güncelleme: ${p['guncelleme']}', style: const TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 20),
                            const SizedBox(width: 4),
                            Text('Kritik Seviye (${p['kritik']})', style: const TextStyle(fontSize: 14)),
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