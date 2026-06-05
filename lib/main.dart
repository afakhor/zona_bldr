import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zona Beladiri',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller untuk menangkap ketikan input di aplikasi
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  String _namaTerpajang = "Coach Menu Active";
  String _statusTerpajang = "Sistem Siap Tempur";

  @override
  void initState() {
    super.override() ;
    _muatDataLokal();
  }

  // Fungsi mengambil data yang tersimpan di HP biar tidak hilang saat aplikasi ditutup
  Future<void> _muatDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaTerpajang = prefs.getString('saved_nama') ?? "Coach Menu Active";
      _statusTerpajang = prefs.getString('saved_status') ?? "Sistem Siap Tempur";
    });
  }

  // JURUS UTAMA: Simpan data ke Aplikasi & Tembak langsung ke Homescreen Widget!
  Future<void> _perbaruiWidgetDanApp() async {
    final namaInput = _namaController.text.trim();
    final statusInput = _statusController.text.trim();

    if (namaInput.isEmpty || statusInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form tidak boleh kosong, Coach! ❌')),
      );
      return;
    }

    // 1. Amankan data di dalam memori internal aplikasi (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_nama', namaInput);
    await prefs.setString('saved_status', statusInput);

    // 2. Lempar data melewati jembatan 'home_widget' menuju Kurir Kotlin
    await HomeWidget.saveWidgetData<String>('key_nama', namaInput);
    await HomeWidget.saveWidgetData<String>('key_status', statusInput);

    // 3. Paksa sistem Android untuk menggambar ulang tampilan widget di layar depan
    await HomeWidget.updateWidget(
      name: 'HomeScreenWidgetProvider',
      androidName: 'HomeScreenWidgetProvider',
    );

    // 4. Perbarui tampilan di dalam aplikasi
    setState(() {
      _namaTerpajang = namaInput;
      _statusTerpajang = statusInput;
    });

    // Bersihkan kotak inputan
    _namaController.clear();
    _statusController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Widget Berhasil Diperbarui! ⚡✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZONA BELADIRI PANEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[900],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Indikator Data Saat Ini
            Card(
              color: Colors.grey[200],
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('DATA WIDGET AKTIF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    const Divider(),
                    Text(_namaTerpajang, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 5),
                    Text(_statusTerpajang, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Form Input Nama Murid / Saham
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Input Nama Atlet / Indikator Utama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            // Form Input Status / Jumlah Data
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Input Status Latihan / Angka (Contoh: 20 Murid)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Eksekusi
            ElevatedButton.icon(
              onPressed: _perbaruiWidgetDanApp,
              icon: const Icon(Icons.sync_saved_locally, color: Colors.white),
              label: const Text('KIRIM KE HOMESCREEN WIDGET', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
