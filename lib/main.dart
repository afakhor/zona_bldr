import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
// 1. TAMBAHKAN IMPORT INI
import 'package:flutter_native_splash/flutter_native_splash.dart'; 
import 'dart:async';
//untuk simpan
import 'dart:convert';//taruh do atas paketshared
import 'package:shared_preferences/shared_preferences.dart';
//untuk homescreen widget
//import 'package:home_widget/home_widget.dart';
//import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;

// 1. KUNCI FOTO DI LUAR CLASS (GLOBAL)
final GlobalKey kunciFotoOtomatis = GlobalKey();

// 2. FUNGSI PENGIRIM GAMBAR - VERSI AMAN (ANTI-CRASH MEMORI)
Future<void> autoUpdateHomescreenWidget(String namaAtlet) async {
  try {
    // Pastikan context grafik dashboard-nya eksis dan terdeteksi kamera
    final boundaryContext = kunciFotoOtomatis.currentContext;
    if (boundaryContext == null) return;

    final RenderRepaintBoundary? boundary = boundaryContext.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    // Jepret gambar dengan rasio tinggi agar grafik di widget HP tajam tidak buram
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    // Konversi byte yang aman dan kompatibel dengan Flutter versi baru
    final Uint8List bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    // Ambil alamat penyimpanan internal HP untuk menaruh file foto sementara
    final direktoriHP = await getApplicationDocumentsDirectory();
    final fileGambar = File('${direktoriHP.path}/grafik_atlet_live.png');
    await fileGambar.writeAsBytes(bytes);

    // Kirim data Nama dan Alamat Foto menembus jembatan native Android
    await HomeWidget.saveWidgetData<String>('key_nama', namaAtlet);
    await HomeWidget.saveWidgetData<String>('key_path_grafik', fileGambar.path);

    // Perintahkan class Java untuk memaksa Widget di layar HP melakukan refresh/update visual
    await HomeWidget.updateWidget(
  name: 'AtletWidgetProvider',
);
    print("🚀 Widget Homescreen Berhasil Diperbarui Secara Realtime!");
  } catch (e) {
    debugPrint("⚠️ Gagal otomatisasi update widget: $e");
  }
}

void main() {


  runApp(const MyApp());


}







class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Papan Performa Member',
            theme: ThemeData(
        brightness: Brightness.light, // Ubah dari dark ke light agar latar jadi terang
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Warna abu-abu sangat muda (Slate 50) agar teks kontras
        cardColor: Colors.white, // Kartu metrik menjadi putih bersih
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1E293B)), // Tulisan utama abu-abu gelap tajam
          bodyMedium: TextStyle(color: Color(0xFF475569)), // Tulisan pendukung abu-abu sedang
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          elevation: 0,
          titleTextStyle: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==================================
//.  KODE SPLASH DIMULAI .
// ==================================

// 1. HALAMAN SPLASH SCREEN UTAMA (Klik APK -> Muncul 3 Detik)
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // SINKRONISASI: Kita buat pas 2 detik (2000 milidetik) agar pas dengan routernya!
    Timer(const Duration(milliseconds: 2000), () {
      Navigator.of(context).pushReplacement(
        SplashPageRoute(page: const MainNavigationHolder()), // Menggunakan router keren Coach
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double lebarHP = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // SAKELAR TERANG: Selaras dengan tema baru
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: lebarHP * 0.70,
                        height: lebarHP * 0.70,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/splash.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'dibuat oleh Heru Wingchun.Hapki!!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0284C7), // Ubah jadi Biru Tajam agar terbaca di latar terang
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: const Color(0xFFE2E8F0), // Loading track abu terang
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0284C7).withOpacity(0.6)), // Loading bar biru
                    minHeight: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 2. MESIN ANIMASI TRANSISI ANTAR HALAMAN (Slow-Motion 2 Detik)
class SplashPageRoute extends PageRouteBuilder {
  final Widget page;

  SplashPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 2000), // Sinkron 2 detik
          transitionsBuilder: (context, animation, secondaryAnimation, child) {

            var gerakanSirkular = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.5, curve: Curves.easeOutQuart)),
            );
            var memudarKeluar = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0.5, 1.0, curve: Curves.slowMiddle)),
            );

            double lebarHP = MediaQuery.of(context).size.width;

            return Stack(
              children: [
                FadeTransition(opacity: memudarKeluar, child: child),

                IgnorePointer(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                      CurvedAnimation(parent: animation, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
                    ),
                    child: Container(
                      color: const Color(0xFFF8FAFC), // SAKELAR TERANG: Mengubah lapisan transisi menjadi terang bersih
                      child: Center(
                        child: ScaleTransition(
                          scale: gerakanSirkular,
                          child: Image.asset(
                            'assets/splash.png', 
                            width: lebarHP * 0.45, 
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
}//akhir dari splash 

const List<String> kDaftarKlasifikasiLatihan = [
  "STRENGTH", "ENDURANCE", "SPEED", "COORDINATION", "FLEXIBILITY", "BALANCE", "REACTION TIME", 
  "POWER", "AGILITY", "MOBILITY", "MUSCULAR ENDURANCE", "CORE STABILITY", "DYNAMIC FLEXIBILITY", 
  "SPEED ENDURANCE", "REACTIVE SPEED / QUICKNESS","ANTICIPATION&SPATIAL AWARENESS", "ANTICIPATION","SPATIAL AWARENESS", 
  "OPEN AGILITY", "EXPLOSIVE STRENGTH", "STRENGTH ENDURANCE", "RATE OF FORCE DEVELOPMENT", 
  "DECELERATION ABILITY", "CHANGE OF DIRECTION", "NEURAL DRIVE", "ISO-STRENGTH", 
  "ECCENTRIC STRENGTH", "FLEXIBILITY-STRENGTH BALANCE", "CORE ROTATIONAL POWER", 
  "LATERAL QUICKNESS", "VERTICAL JUMP CAPACITY", "RECOVERY RATE", "NEURAL FATIGUE LEVEL", 
  "JOINT STABILITY", "PELVIC FLOOR CONTROL", "POSTURAL ALIGNMENT", 
  "FLEXIBILITY-NEURAL INTEGRATION", "ANAEROBIC CAPACITY", "AEROBIC EFFICIENCY", 
  "BALANCE RECOVERY", "MENTAL TOUGHNESS"
];

const List<String> kKlasifksKmampuan = ["STRENGTH" , "ENDURANCE" , "SPEED" , "COORDINATION" , "FLEXIBILITY" , "BALANCE" , "REACTION TIME" , "MUSCULAR ENDURANCE" , "POWER" , "CORE STABILITY" , "DYNAMIC FLEXIBILITY" , "SPEED ENDURANCE" , "REACTIVE SPEED" , "AGILITY" , "ANTICIPATION&SPATIAL AWARENESS" , "MOBILITY" , "OPEN AGILITY" ];

class Murid {
  final String id;
  final String nama;
  final List<List<double>> boxData; 
  final List<double> radarData; 
  List<Map<String, dynamic>> riwayatLatihanKuantitatif;
  List<Map<String, dynamic>> riwayatLatihanDurasi;

  Murid({
    required this.id, required this.nama, required this.boxData, required this.radarData,
    List<Map<String, dynamic>>? riwayatLatihanKuantitatif,
    List<Map<String, dynamic>>? riwayatLatihanDurasi,
  })  : this.riwayatLatihanKuantitatif = riwayatLatihanKuantitatif ?? [],
        this.riwayatLatihanDurasi = riwayatLatihanDurasi ?? [];
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({Key? key}) : super(key: key);
  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0; 
  bool _isPageLoading = false;
  String _selectedMuridId = "001"; 
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late List<Murid> _daftarMurid;

// 1. FUNGSI MENYIMPAN DATA SECARA PERMANEN KE HP
  Future<void> _simpanKeStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Konversi seluruh daftar murid dan riwayatnya menjadi teks JSON
    List<Map<String, dynamic>> mapMurid = _daftarMurid.map((murid) {
      return {
        'id': murid.id,
        'nama': murid.nama,
        'radarData': murid.radarData,
        'boxData': murid.boxData,
        'riwayatLatihanKuantitatif': murid.riwayatLatihanKuantitatif.map((e) => {
          'tanggal': e['tanggal'].toIso8601String(),
          'jenis': e['jenis'],
          'klasifikasi': e['klasifikasi'],
          'skor': e['skor'],
          'isReps': e['isReps'],
          'tipePembagi': e['tipePembagi'],
        }).toList(),
        'riwayatLatihanDurasi': murid.riwayatLatihanDurasi.map((e) => {
          'tanggal': e['tanggal'].toIso8601String(),
          'jenis': e['jenis'],
          'klasifikasi': e['klasifikasi'],
          'skor': e['skor'],
          'isReps': e['isReps'],
          'tipePembagi': e['tipePembagi'],
        }).toList(),
      };
    }).toList();

    String jsonString = jsonEncode(mapMurid);
    await prefs.setString('data_atlet_coach', jsonString);
    print("Data berhasil dikunci ke memori HP!");
  }
// 2. EDIT FUNGSI SIMPAN LATIHAN KUNCI MATI SIMPANSTORAGE (Anti-Bocor)
  void _simpanHasilLatihan(String idTerpilih, String jenis, String klas, double nilai, double sets, String tipe, DateTime tgl) {
    setState(() {
      // CARI MURID BERDASARKAN ID (Sembuhkan masalah lari ke murid pertama)
      final index = _daftarMurid.indexWhere((m) => m.id == idTerpilih);

      if (index != -1) {
        final dataBaru = {
          'tanggal': tgl,
          'jenis': jenis,
          'klasifikasi': klas,
          'skor': nilai,
          'isReps': true, // Sesuaikan true untuk Reps, false untuk Waktu
          'tipePembagi': tipe,
        };

        if (dataBaru['isReps'] == true) {
          _daftarMurid[index].riwayatLatihanKuantitatif.add(dataBaru);
        } else {
          _daftarMurid[index].riwayatLatihanDurasi.add(dataBaru);
        }
      }
    });

    // KUNCI MATI: Langsung simpan ke memori fisik HP
    _simpanKeStorage(); 
  }
  // 3. FUNGSI MEMANGGIL DATA SETIAP KALI APLIKASI BARU DIBUKA
  Future<void> _muatDataDariStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('data_atlet_coach');

    if (jsonString != null) {
      List<dynamic> decodedData = jsonDecode(jsonString);
      setState(() {
        _daftarMurid = decodedData.map((item) {
          var murid = Murid(
            id: item['id'],
            nama: item['nama'],
            radarData: List<double>.from(item['radarData']),
            boxData: (item['boxData'] as List).map((e) => List<double>.from(e)).toList(),
          );

          if (item['riwayatLatihanKuantitatif'] != null) {
            murid.riwayatLatihanKuantitatif = List<Map<String, dynamic>>.from(
              item['riwayatLatihanKuantitatif'].map((e) => {
                'tanggal': DateTime.parse(e['tanggal']),
                'jenis': e['jenis'],
                'klasifikasi': e['klasifikasi'],
                'skor': e['skor'],
                'isReps': e['isReps'],
                'tipePembagi': e['tipePembagi'],
              })
            );
          }

          if (item['riwayatLatihanDurasi'] != null) {
            murid.riwayatLatihanDurasi = List<Map<String, dynamic>>.from(
              item['riwayatLatihanDurasi'].map((e) => {
                'tanggal': DateTime.parse(e['tanggal']),
                'jenis': e['jenis'],
                'klasifikasi': e['klasifikasi'],
                'skor': e['skor'],
                'isReps': e['isReps'],
                'tipePembagi': e['tipePembagi'],
              })
            );
          }
          return murid;
        }).toList();
      });
    }
  }


  // 4. FUNGSI EKSPOR: MENYALIN DATABASE KE CLIPBOARD HP
  Future<void> _eksporDataBackup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('data_atlet_coach');

    if (jsonString != null) {
      await Clipboard.setData(ClipboardData(text: jsonString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Kode Backup sukses disalin! Silakan simpan di Catatan/WA Coach.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal, belum ada data atlet untuk dibackup.')),
      );
    }
  }

  // 5. FUNGSI IMPOR: MENERIMA TEMPELAN TEKS DAN MEMULIHKAN DATABASE
  Future<void> _imporDataBackup(BuildContext context, String teksBackup) async {
    try {
      if (teksBackup.trim().isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      List<dynamic> testValidasi = jsonDecode(teksBackup);

      if (testValidasi.isNotEmpty) {
        await prefs.setString('data_atlet_coach', teksBackup);
        await _muatDataDariStorage(); // Langsung segarkan data di layar dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Impor Sukses! Seluruh data zona beladiri berhasil dipulihkan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Format kode backup salah atau rusak!')),
      );
    }
  }
        // 6. TAMPILKAN DIALOG INPUT IMPOR DATA
  void _tampilkanDialogInputImpor(BuildContext context) {
    TextEditingController _controllerTeks = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Restore Data Atlet', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: TextField(
            controller: _controllerTeks,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Tempel kode teks cadangan di sini...', 
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
            ),
          ), // <--- Mengunci TextField
          actions: [ // <--- SEKARANG SAH MASUK DI DALAM ALERTDIALOG
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('BATAL', style: TextStyle(color: Colors.blueGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
              onPressed: () {
                String txt = _controllerTeks.text;
                Navigator.pop(context);
                _imporDataBackup(context, txt); 
              },
              child: const Text('PROSES', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ); // <--- Menutup AlertDialog dengan Sempurna
      }, // <--- Menutup Builder showDialog
    ); // <--- Menutup Fungsi Utama showDialog
  }

  @override
  void initState() {
    super.initState();
    _daftarMurid = [];
    _muatDataDariStorage(); // <--- Ini yang menarik data lama dari memori HP saat app dibuka

  }

  Murid get _currentMurid => _daftarMurid.firstWhere(
        (m) => m.id == _selectedMuridId, 
        orElse: () => _daftarMurid.isNotEmpty 
            ? _daftarMurid.first 
            : Murid(id: "000", nama: "BELUM ADA SISWA", boxData: List.generate(7, (_) => [0,0,0,0,0,0]), radarData: List.generate(10, (_) => 0.0)),
      );


  List<double> get _teamAverageBoxScores {
    List<double> averages = List.generate(7, (_) => 0.0);
    if (_daftarMurid.isEmpty) return averages;
    for (int i = 0; i < 7; i++) {
      double sum = 0;
      int count = 0;
      for (var murid in _daftarMurid) {
        if (i < murid.boxData.length && murid.boxData[i].length > 3) {
          if (murid.boxData[i][3] > 0) { 
            sum += murid.boxData[i][3];
            count++;
          }
        }
      }
      averages[i] = count > 0 ? sum / count : 0.0;
    }
    return averages;
  }

  List<double> get _teamAverageRadar {
    List<double> averages = List.generate(10, (_) => 0.0);
    if (_daftarMurid.isEmpty) return averages;
    for (int i = 0; i < 10; i++) {
      double sum = 0;
      int count = 0;
      for (var murid in _daftarMurid) {
        if (i < murid.radarData.length) {
          if (murid.radarData[i] > 0) {
            sum += murid.radarData[i];
            count++;
          }
        }
      }
      averages[i] = count > 0 ? sum / count : 0.0;
    }
    return averages;
  }

  int _dapatkanBoxIndex(String klasifikasi) {
    final String upper = klasifikasi.toUpperCase();
    if (upper == "STRENGTH" || upper == "POWER" || upper == "CORE STABILITY") return 0;
    if (upper == "ENDURANCE" || upper == "MUSCULAR ENDURANCE") return 1;
    if (upper == "SPEED" || upper == "SPEED ENDURANCE") return 2;
    if (upper == "COORDINATION" || upper == "ANTICIPATION & SPATIAL AWARENESS") return 3;
    if (upper == "FLEXIBILITY" || upper == "DYNAMIC FLEXIBILITY") return 4;
    if (upper == "BALANCE") return 5;
    if (upper == "REACTION TIME" || upper == "REACTIVE SPEED / QUICKNESS") return 6;
    return -1;
  }
  // --- TAMBAHKAN FUNGSI INI DI DALAM _MainNavigationHolderState ---
  int _dapatkanRadarIndex(String klasifikasi) {
    switch (klasifikasi.toUpperCase()) {
      case "MUSCULAR ENDURANCE": return 0;
      case "POWER": return 1;
      case "CORE STABILITY": return 2;
      case "DYNAMIC FLEXIBILITY": return 3;
      case "SPEED ENDURANCE": return 4;
      case "REACTIVE SPEED": return 5;
      case "AGILITY": return 6;
      case "ANTICIPATION&SPATIAL AWARENESS": return 7;
      case "MOBILITY": return 8;
      case "OPEN AGILITY": return 9;
      default: return -1;
    }
  }

    void _simpanDataKuantitatif(String id, String jenis, String klas, double reps, double sets, String tipePembagi, DateTime tgl) {
    setState(() {
      int idx = _daftarMurid.indexWhere((m) => m.id == id);
      if (idx != -1) {
        double pembagi = (tipePembagi == 'J') ? 15.0 : 25.0;
        double skorGrafik = (reps * sets) / pembagi; 
        double volumeHistory = reps * sets;

        _daftarMurid[idx].riwayatLatihanKuantitatif.add({
          'tanggal': tgl, 
          'jenis': jenis, 
          'klasifikasi': klas, 
          'skor': volumeHistory, 
          'isReps': true, 
          'tipePembagi': tipePembagi
        });

        // 1. RADAR KUANTITATIF (REPS)
        int rIdx = _dapatkanRadarIndex(klas);
        if (rIdx != -1 && rIdx < _daftarMurid[idx].radarData.length) {
          List<double> semuaSkorRadar = _daftarMurid[idx].riwayatLatihanKuantitatif
              .where((item) => item['klasifikasi'] == klas)
              .map((item) {
                double pembagiI = (item['tipePembagi'] == 'J') ? 15.0 : 25.0;
                double skorSederhana = ((item['skor'] ?? 0) as num).toDouble() / pembagiI;

                if (skorSederhana < 1.0) {
                  return math.pow(skorSederhana, 1.5).toDouble(); 
                } else {
                  return skorSederhana; 
                }
              }).toList();

          if (semuaSkorRadar.isNotEmpty) {
            double total = semuaSkorRadar.reduce((a, b) => a + b);
            double rataRata = total / semuaSkorRadar.length;
            _daftarMurid[idx].radarData[rIdx] = rataRata.clamp(0.0, 1.2);
          }
        }

        // 2. BOXPLOT KUANTITATIF
        int bIdx = _dapatkanBoxIndex(klas);
        if (bIdx != -1 && bIdx < _daftarMurid[idx].boxData.length) {
          List<double> dataLama = List<double>.from(_daftarMurid[idx].boxData[bIdx]);
          if (dataLama.every((v) => v == 0.0)) {
            dataLama.clear();
          }

          dataLama.add(skorGrafik);
          dataLama.sort();

          double min = dataLama.first;
          double max = dataLama.last;
          double median = dataLama[dataLama.length ~/ 2];
          double q1 = dataLama[(dataLama.length * 0.25).floor()];
          double q3 = dataLama[(dataLama.length * 0.75).floor().clamp(0, dataLama.length - 1)];
          double current = skorGrafik; 

          _daftarMurid[idx].boxData[bIdx] = [min, q1, median, current, q3, max];
        }

        _selectedMuridId = id;
      }
    });
     _simpanKeStorage();
  }

  void _simpanDataDurasi(String id, String jenis, String klas, double waktu, double sets, String tipePembagi, DateTime tgl) {
    setState(() {
      int idx = _daftarMurid.indexWhere((m) => m.id == id);
      if (idx != -1) {
        double pembagi = (tipePembagi == 'J') ? 60.0 : 90.0;
        double skorGrafik = (waktu * sets) / pembagi;
        double volumeHistory = waktu * sets;

        _daftarMurid[idx].riwayatLatihanDurasi.add({
          'tanggal': tgl, 
          'jenis': jenis, 
          'klasifikasi': klas, 
          'skor': volumeHistory, 
          'isReps': false, 
          'tipePembagi': tipePembagi
        });

        // 1. RADAR DURASI (WAKTU)
        int rIdx = _dapatkanRadarIndex(klas);
        if (rIdx != -1 && rIdx < _daftarMurid[idx].radarData.length) {
          List<double> semuaSkorRadar = _daftarMurid[idx].riwayatLatihanDurasi
              .where((item) => item['klasifikasi'] == klas)
              .map((item) {
                double pembagiI = (item['tipePembagi'] == 'J') ? 60.0 : 90.0;
                double skorSederhana = ((item['skor'] ?? 0) as num).toDouble() / pembagiI;

                if (skorSederhana > 0) {
                  double skorDibalik = 1.0 / skorSederhana; 
                  if (skorDibalik < 1.0) {
                    return math.pow(skorDibalik, 1.5).toDouble(); 
                  } else {
                    return skorDibalik; 
                  }
                }
                return 0.0;
              }).toList();

          if (semuaSkorRadar.isNotEmpty) {
            double total = semuaSkorRadar.reduce((a, b) => a + b);
            double rataRata = total / semuaSkorRadar.length;
            _daftarMurid[idx].radarData[rIdx] = rataRata.clamp(0.0, 1.2);
          }
        }

        // 2. BOXPLOT DURASI
        int bIdx = _dapatkanBoxIndex(klas);
        if (bIdx != -1 && bIdx < _daftarMurid[idx].boxData.length) {
          List<double> dataLama = List<double>.from(_daftarMurid[idx].boxData[bIdx]);
          if (dataLama.every((v) => v == 0.0)) {
            dataLama.clear();
          }

          dataLama.add(skorGrafik);
          dataLama.sort();

          double min = dataLama.first;
          double max = dataLama.last;
          double median = dataLama[dataLama.length ~/ 2];
          double q1 = dataLama[(dataLama.length * 0.25).floor()];
          double q3 = dataLama[(dataLama.length * 0.75).floor().clamp(0, dataLama.length - 1)];
          double current = skorGrafik;

          _daftarMurid[idx].boxData[bIdx] = [min, q1, median, current, q3, max];
        }

        _selectedMuridId = id;
      }
    });
     _simpanKeStorage();
  }

  @override
  Widget build(BuildContext context) {
    List<Murid> filtered = _daftarMurid.where((m) => m.nama.contains(_searchQuery.toUpperCase()) || m.id.contains(_searchQuery)).toList();

    final List<Widget> pages = [
      DashboardAtletPage(activeMurid: _currentMurid, teamBoxAverages: _teamAverageBoxScores, teamRadarAverages: _teamAverageRadar, dapatkanBoxIndexFunc: _dapatkanBoxIndex),
      DaftarMuridPage(
        daftarMurid: filtered, selectedId: _selectedMuridId, namaController: _namaController, searchController: _searchController,
        onSearchChanged: (v) => setState(() => _searchQuery = v),
        onSelect: (id) => setState(() { _selectedMuridId = id; _currentIndex = 0; }), 
        onDelete: (m) {
  setState(() => _daftarMurid.remove(m));
  _simpanKeStorage(); // Agar murid yang dihapus tidak muncul lagi saat buka aplikasi
},
                onAdd: () {
          if (_namaController.text.trim().isEmpty) return;

          // 1. Definisikan maxId DI LUAR setState agar bisa dibaca di bawahnya
          int maxId = 0; 

          setState(() {
            for (var m in _daftarMurid) {
              int? cId = int.tryParse(m.id);
              if (cId != null && cId > maxId) maxId = cId;
            }

            // Sekarang nextId aman membaca maxId tanpa eror
            String nextId = (maxId + 1).toString().padLeft(3, '0');

            _daftarMurid.add(
              Murid(
                id: nextId, 
                nama: _namaController.text.trim().toUpperCase(), 
                boxData: List.generate(7, (_) => [0, 0, 0, 0, 0, 0]), 
                radarData: List.generate(10, (_) => 0.0),
                riwayatLatihanKuantitatif: [], // Kantong riwayat kuantitatif baru
                riwayatLatihanDurasi: [],      // Kantong riwayat durasi baru
              )
            );

            // Langsung kunci agar dashboard otomatis mengarah ke murid baru ini
            _selectedMuridId = nextId; 
          });

          _namaController.clear();

          // Kunci permanen ke memori HP Coach
          _simpanKeStorage(); 
        },

         onEkspor: () => _eksporDataBackup(context),
         onImpor: () => _tampilkanDialogInputImpor(context),
      ),
      InputLatihanKuantitatifPage(daftarMurid: _daftarMurid, selectedMuridId: _selectedMuridId, onMuridChanged: (id) => setState(() => _selectedMuridId = id!), onSimpan: _simpanDataKuantitatif),
      InputLatihanDurasiPage(daftarMurid: _daftarMurid, selectedMuridId: _selectedMuridId, onMuridChanged: (id) => setState(() => _selectedMuridId = id!), onSimpan: _simpanDataDurasi),
      TimelineHistoryPage(activeMurid: _currentMurid), 
    ];

        return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: pages[_currentIndex]),

          // <-- KODE FAKE SPLASH SAAT PINDAH HALAMAN -->
          if (_isPageLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0F172A), 
              child: Center(
                child: Image.asset(
                  'assets/splash.png', 
                  width: 200, 
                ),
              ),
            ),
        ],
      ),
// ...

            bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // <-- UBAH onTap agar SPLASHED -->
        onTap: (i) {
          // 1. Jika Coach mengklik menu yang sama, abaikan (jangan putar animasi)
          if (_currentIndex == i) return; 

          // 2. Jalankan transisi sinematik 2 detik melewati gerbang SplashPageRoute
          Navigator.of(context).push(
            SplashPageRoute(page: pages[i]), // 'pages' adalah list halaman menu Coach
          ).then((_) {
            // 3. Setelah animasi 2 detik selesai, kunci posisi halaman aktif
            setState(() {
              _currentIndex = i;
            });
          });
        },
        backgroundColor: const Color(0xFF1E293B), 
// ...
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: const Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'DAFTAR SISWA'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'INPUT REPS'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'INPUT WAKTU'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'HISTORY'),
        ],
      ),
    );
  }
}

// ==================== HALAMAN 1: DASHBOARD PERFORMANCE ====================
class DashboardAtletPage extends StatelessWidget {
  final Murid activeMurid;
  final List<double> teamBoxAverages;
  final List<double> teamRadarAverages;
  final int Function(String) dapatkanBoxIndexFunc;

  const DashboardAtletPage({
    Key? key, 
    required this.activeMurid, 
    required this.teamBoxAverages, 
    required this.teamRadarAverages, 
    required this.dapatkanBoxIndexFunc
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
// 3. TARUH PEMICU OTOMATISNYA DI SINI (Tepat setelah kurung kurawal build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoUpdateHomescreenWidget(activeMurid.nama);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Navy Deep
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC), // Slate Clean
        title: const Text(
          "PAPAN PERFORMA", 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
        ), 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== KARTU PROFIL ATLET ====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B), 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155), width: 1), 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'PAPAN PERFORMA KOMPREHENSIF',
                    style: TextStyle(
                      color: Colors.blueGrey[300],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${activeMurid.id} - ${activeMurid.nama}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8), 
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== GRAFIK BOXPLOT ====================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: const Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      const Text(
                        'DISTRIBUSI MOTORIK TIM VS INDIVIDU (BOXPLOT)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250, 
                    child: MetaBoxplotChart(
                      boxData: activeMurid.boxData, 
                      teamAverages: teamBoxAverages,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== GRAFIK RADAR (FIXED & BERSIH) ====================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: const Color(0xFF22C55E)), 
                      const SizedBox(width: 8),
                      const Text(
                        'PROFIL BIOMOTORIK METRIKS RADAR (10 DIMENSI)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF22C55E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320, 
                    child: MetaRadarChart(
                      dataIndividu: activeMurid.radarData, 
                      rataRataTim: teamRadarAverages,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== TABEL MATRIKS ANALISIS GERAK ====================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      const Text(
                        'MATRIKS ANALISIS GERAK & REKOMENDASI TAKTIS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1050, 
                      child: Table(
                        border: TableBorder.all(color: const Color(0xFF334155), width: 1), 
                        columnWidths: const {
                          0: FlexColumnWidth(1.8),
                          1: FlexColumnWidth(2.3),
                          2: FlexColumnWidth(2.5),
                          3: FlexColumnWidth(2.3),
                          4: FlexColumnWidth(2.3),
                          5: FlexColumnWidth(3.4)
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFF0F172A)), 
                            children: [
                              _buildHeaderCell('KOMPONEN'),
                              _buildHeaderCell('POLA BOXPLOT'),
                              _buildHeaderCell('ARTI POLA'),
                              _buildHeaderCell('KELEBIHAN'),
                              _buildHeaderCell('KEKURANGAN'),
                              _buildHeaderCell('REKOMENDASI')
                            ],
                          ),
                          _buildEvaluasiRow('STRENGTH', 'BOXPLOT', 0),
                          _buildEvaluasiRow('ENDURANCE', 'BOXPLOT', 1),
                          _buildEvaluasiRow('SPEED', 'BOXPLOT', 2),
                          _buildEvaluasiRow('COORDINATION', 'BOXPLOT', 3),
                          _buildEvaluasiRow('FLEXIBILITY', 'BOXPLOT', 4),
                          _buildEvaluasiRow('BALANCE', 'BOXPLOT', 5),
                          _buildEvaluasiRow('REACTION TIME', 'BOXPLOT', 6),
                          _buildEvaluasiRow('MUSCULAR ENDURANCE', 'BOXPLOT', 1),
                          _buildEvaluasiRow('POWER', 'BOXPLOT', 0),
                          _buildEvaluasiRow('CORE STABILITY', 'BOXPLOT', 0),
                          _buildEvaluasiRow('DYNAMIC FLEXIBILITY', 'BOXPLOT', 4),
                          _buildEvaluasiRow('SPEED ENDURANCE', 'BOXPLOT', 2),
                          _buildEvaluasiRow('REACTIVE SPEED / QUICKNESS', 'BOXPLOT', 6),
                          _buildEvaluasiRow('ANTICIPATION & SPATIAL AWARENESS', 'BOXPLOT', 3),
                          _buildEvaluasiRow('AGILITY', 'RADAR', 8),
                          _buildEvaluasiRow('MOBILITY', 'RADAR', 9),
                          _buildEvaluasiRow('OPEN/REACTIVE AGILITY', 'RADAR', 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, String> _analisisKomplet40Pola(int idx, String namaKomponen) {
    if (idx >= activeMurid.boxData.length || activeMurid.boxData[idx].length < 6) {
      return {"pola": "-", "arti": "Data fungsional belum lengkap."};
    }

    final List<double> data = activeMurid.boxData[idx];
    double min = data[0]; 
    double q1 = data[1]; 
    double q2 = data[2]; 
    double q3 = data[4]; 
    double max = data[5];

    double dLower = q2 - q1; 
    double dUpper = q3 - q2; 
    double iqr = q3 - q1; 
    double wLower = q1 - min; 
    double wUpper = max - q3;

    String skew = ""; 
    String kurtosis = "";

    if ((dUpper - dLower).abs() <= 2.0 && (wUpper - wLower).abs() <= 3.0) {
      skew = "Symmetrical";
    } else if (dUpper > dLower && wUpper > wLower) {
      skew = "Extremely Skewed Right";
    } else if (dUpper > dLower) {
      skew = "Mildly Skewed Right";
    } else if (dLower > dUpper && wLower > wUpper) {
      skew = "Extremely Skewed Left";
    } else {
      skew = "Mildly Skewed Left";
    }

    if (iqr < 10) {
      kurtosis = "Leptokurtic (Narrow)";
    } else if (iqr > 38) {
      kurtosis = "Platykurtic (Wide)";
    } else {
      kurtosis = "Mesokurtic (Optimal)";
    }

    String artiFisik = "";
    if (skew == "Symmetrical") {
      if (kurtosis == "Mesokurtic (Optimal)") {
        artiFisik = "Kondisi Peak Performance. Distribusi energi ideal & stabil.";
      } else if (kurtosis == "Leptokurtic (Narrow)") {
        artiFisik = "Stagnan/Plato. Konsisten, tapi butuh variasi beban baru.";
      } else {
        artiFisik = "Performa labil. Kadang sangat bagus, kadang drop. Fokus repetisi dasar.";
      }
    } else if (skew == "Mildly Skewed Right") {
      if (kurtosis == "Mesokurtic (Optimal)") {
        artiFisik = "Fase adaptasi positif. Otot merespons program latihan dengan baik.";
      } else if (kurtosis == "Leptokurtic (Narrow)") {
        artiFisik = "Perkembangan lambat tapi pasti. Pertahankan volume latihan sirkuit.";
      } else { 
        artiFisik = "Adaptasi tak merata. Ada potensi, tapi teknik eksekusi masih gogah.";
      }
    } else if (skew == "Extremely Skewed Right") {
      if (kurtosis == "Mesokurtic (Optimal)") {
        artiFisik = "Potensi lonjakan daya. Jaga waktu recovery agar tidak overtraining.";
      } else if (kurtosis == "Leptokurtic (Narrow)") {
        artiFisik = "Bakat terpendam di area ini. Dorong limit perlahan saat tes fungsional.";
      } else { 
        artiFisik = "Hasil anomali. Evaluasi apakah form/postur gerakan sudah sesuai standar.";
      }
    } else if (skew == "Mildly Skewed Left") {
      if (kurtosis == "Mesokurtic (Optimal)") {
        artiFisik = "Tanda awal kelelahan. Kapasitas ada, tapi eksekusi mulai terasa berat.";
      } else if (kurtosis == "Leptokurtic (Narrow)") {
        artiFisik = "Kapasitas terkunci di bawah rata-rata. Perlu drilling teknik perbaikan.";
      } else { 
        artiFisik = "Inkonsistensi akibat fatigue ringan. Kurangi durasi, tingkatkan presisi.";
      }
    } else if (skew == "Extremely Skewed Left") {
      if (kurtosis == "Mesokurtic (Optimal)") {
        artiFisik = "Kelelahan saraf pusat (CNS Fatigue). Segera turunkan beban (Deloading)!";
      } else if (kurtosis == "Leptokurtic (Narrow)") {
        artiFisik = "Titik lemah fatal. Wajib remedial & intervensi program biomekanik spesifik.";
      } else { 
        artiFisik = "Drop performa drastis. Periksa faktor luar (sakit, stres, kurang tidur).";
      }
    }

    return {"pola": "$skew\n($kurtosis)", "arti": artiFisik};
  }

  TableRow _buildEvaluasiRow(String namaKomponen, String tipeGrafik, int dataIdx) {
    bool diAtasRataTim = false; 
    bool belumAdaData = true; 
    String labelPola = "-"; 
    String labelArti = "-";

    String kelebihanText = "";
    String kekuranganText = "";
    String rekomendasiText = "";

    bool adaDataDiInput = activeMurid.riwayatLatihanKuantitatif.any((e) => e['klasifikasi'].toString().toUpperCase() == namaKomponen.toUpperCase() || dapatkanBoxIndexFunc(e['klasifikasi'].toString()) == dataIdx) ||
                        activeMurid.riwayatLatihanDurasi.any((e) => e['klasifikasi'].toString().toUpperCase() == namaKomponen.toUpperCase() || dapatkanBoxIndexFunc(e['klasifikasi'].toString()) == dataIdx) ||
                        (tipeGrafik == "BOXPLOT" && dataIdx < activeMurid.boxData.length && activeMurid.boxData[dataIdx][3] > 0) ||
                        (tipeGrafik == "RADAR" && dataIdx < activeMurid.radarData.length && activeMurid.radarData[dataIdx] > 0);

    if (tipeGrafik == "BOXPLOT") {
      Map<String, String> hasilPola = _analisisKomplet40Pola(dataIdx, namaKomponen);
      labelPola = hasilPola["pola"]!; 
      labelArti = hasilPola["arti"]!;

      if (adaDataDiInput && dataIdx < activeMurid.boxData.length) {
        belumAdaData = false;
        diAtasRataTim = activeMurid.boxData[dataIdx][3] >= (dataIdx < teamBoxAverages.length ? teamBoxAverages[dataIdx] : 0.0);

        String polaString = labelPola.toUpperCase();

        if (diAtasRataTim) {
          kelebihanText = "Unggul di kelas. Power output melompat di atas standar tim.";
          if (polaString.contains("SYMMETRICAL")) {
            kelebihanText = "Dominasi mutlak. Kapasitas tinggi didukung akurasi gerak yang sangat kokoh.";
          } else if (polaString.contains("RIGHT")) {
            kelebihanText = "Sangat eksplosif. Grafik mendeteksi adanya bakat lonjakan biomekanik.";
          }
        } else {
          kelebihanText = "Pondasi gerak terbentuk. Konsistensi teknik dasar di zona aman.";
          if (polaString.contains("NARROW")) {
            kelebihanText = "Sangat konsisten. Deviasi error gerakan sangat kecil saat kelelahan.";
          }
        }

        if (!diAtasRataTim) {
          kekuranganText = "Defisit volume target. Kalah saing secara output dari rata-rata tim.";
          if (polaString.contains("LEFT")) {
            kekuranganText = "Drop akut akibat fatigue. Saraf motorik kewalahan menahan beban.";
          } else if (polaString.contains("WIDE")) {
            kekuranganText = "Performa sangat labil. Akurasi reps berantakan jika ritme dipercepat.";
          }
        } else {
          kekuranganText = "Tantangan stagnasi. Risiko terjebak zona nyaman grafik plato.";
          if (polaString.contains("RIGHT")) {
            kekuranganText = "Otot cepat pulih namun rentan over-confidence, form gerak agak ceroboh.";
          }
        }

        if (polaString.contains("LEFT") && polaString.contains("NARROW")) {
          rekomendasiText = "EMERGENCY REMEDIAL! Hentikan sirkuit, drill ulang teknik dasar dasar.";
        } else if (polaString.contains("LEFT")) {
          rekomendasiText = "DELOADING PHASE: Potong volume latihan 30% untuk pemulihan CNS.";
        } else if (polaString.contains("RIGHT") && diAtasRataTim) {
          rekomendasiText = "UPGRADE SPESIFIK: Berikan beban khusus untuk target akselerasi prestasi.";
        } else if (polaString.contains("NARROW")) {
          rekomendasiText = "BREAK THE PLATO: Ubah variasi tempo & manipulasi rest-period sirkuit.";
        } else if (polaString.contains("WIDE")) {
          rekomendasiText = "STABILIZATION: Perbanyak repetisi statis demi mengunci memori otot.";
        } else {
          rekomendasiText = "MAINTAIN: Pertahankan periodisasi latihan, siap naik kelas.";
        }
      }
    } else {
      if (adaDataDiInput && dataIdx < activeMurid.radarData.length) {
        belumAdaData = false;
        diAtasRataTim = activeMurid.radarData[dataIdx] >= (dataIdx < teamRadarAverages.length ? teamRadarAverages[dataIdx] : 0.0);

        if (diAtasRataTim) {
          kelebihanText = "Kelincahan & Fight IQ taktis responsif, di atas rata-rata tim.";
          kekuranganText = "Memerlukan lawan tanding (sparring) sepadan agar tidak jenuh.";
          rekomendasiText = "OPEN DRILL: Libatkan dalam simulasi pertarungan situasi tak terduga.";
        } else {
          kelebihanText = "Sudah memahami pola koordinasi perubahan arah langkah.";
          kekuranganText = "Reaksi kaki lambat, jaring koordinasi masih menguncup sempit.";
          rekomendasiText = "AGILITY LADDER: Genjot drill kecepatan kaki & koordinasi motorik bawah.";
        }
      }
    }

    if (belumAdaData) {
      kelebihanText = "Data rekam kosong.";
      kekuranganText = "Menunggu uji fisik.";
      rekomendasiText = "Silakan masukkan data latihan siswa di tab REPS / WAKTU.";
    }

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(namaKomponen, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(labelPola, style: TextStyle(color: belumAdaData ? const Color(0x33FFFFFF) : Colors.amber[400], fontSize: 8))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(labelArti, style: TextStyle(color: belumAdaData ? const Color(0x33FFFFFF) : const Color(0xFF34D399), fontSize: 8))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(kelebihanText, style: const TextStyle(fontSize: 8.5, color: Colors.white70))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(kekuranganText, style: const TextStyle(fontSize: 8.5, color: Colors.white70))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(rekomendasiText, style: const TextStyle(fontSize: 8.5, color: Color(0xFF38BDF8), fontWeight: FontWeight.w500))),
      ],
    ); 
  } 
}

// ==================== HALAMAN 5: HISTORY TIMELINE ====================
class TimelineHistoryPage extends StatelessWidget {
  final Murid activeMurid;
  const TimelineHistoryPage({Key? key, required this.activeMurid}) : super(key: key);

  String _formatTanggalManual(DateTime dt) {
    final List<String> bulan = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    return "${dt.day.toString().padLeft(2, '0')} ${bulan[dt.month - 1]} ${dt.year} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> allHistory = [...activeMurid.riwayatLatihanKuantitatif, ...activeMurid.riwayatLatihanDurasi];
    allHistory.sort((a, b) => (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // TERANG: Latar belakang Slate 50
      appBar: AppBar(
        title: const Text("TIMELINE PERFORMA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), 
        backgroundColor: const Color(0xFFF8FAFC), 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)), // Panah back warna gelap
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= KARTU NAMA ATLET (BIAR MUNCUL JELAS & GAGAH) =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white, // Kartu Putih Bersih
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)), // Garis tepi tipis abu-abu
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0284C7), // Biru Taktis
                    child: Text(
                      activeMurid.id, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NAMA ATLET BE-LA DIRI",
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          activeMurid.nama.toUpperCase(), // NAMA JELAS DI SINI Coach!
                          style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= LIST TIMELINE =================
            Expanded(
              child: allHistory.isEmpty
                  ? const Center(child: Text("Belum ada riwayat latihan manual.", style: TextStyle(color: Color(0xFF64748B))))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: allHistory.length,
                      itemBuilder: (context, index) {
                        final item = allHistory[index];
                        final bool isReps = item['isReps'] ?? true;

                        // Warna Kontras Baru untuk Latar Terang
                        final Color warnaAksen = isReps ? const Color(0xFF0284C7) : const Color(0xFFEA580C); // Biru Laut / Oranye Tajam

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: warnaAksen, shape: BoxShape.circle)),
                              Container(width: 2, height: 80, color: const Color(0xFFCBD5E1)), // Garis timeline abu-abu solid terang
                            ]),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Kartu latihan putih bersih
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text(item['klasifikasi'], style: TextStyle(color: warnaAksen, fontWeight: FontWeight.bold, fontSize: 11)),
                                    Text(_formatTanggalManual(item['tanggal']), style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500)),
                                  ]),
                                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                                  Text(item['jenis'].toString().toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  const SizedBox(height: 6),
                                  // Hijau Emerald mantap untuk Capaian Skor
                                  Text(
                                    "Capaian: ${item['skor'].toStringAsFixed(0)} ${isReps ? 'Reps' : 'Detik'}", 
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HALAMAN 2: DAFTAR SISWA ====================
class DaftarMuridPage extends StatelessWidget {
  final List<Murid> daftarMurid;
  final String selectedId;
  final TextEditingController namaController, searchController;
  final ValueChanged<String> onSearchChanged;
  final Function(String) onSelect;
  final Function(Murid) onDelete;
  final VoidCallback onAdd;

  // SAKELAR DIALIRKAN DARI PUSAT ATAS COACH
  final VoidCallback onEkspor;
  final VoidCallback onImpor;

  const DaftarMuridPage({
    Key? key, 
    required this.daftarMurid, 
    required this.selectedId, 
    required this.namaController, 
    required this.searchController, 
    required this.onSearchChanged, 
    required this.onSelect, 
    required this.onDelete, 
    required this.onAdd,
    required this.onEkspor, // Tambahan parameter aman 1
    required this.onImpor,  // Tambahan parameter aman 2
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // BAGIAN BAWAH: Gelap (Navy Deep)
    backgroundColor: const Color(0xFF0F172A), 

    appBar: AppBar(
      // BAGIAN ATAS: Terang (Slate Clean)
      backgroundColor: const Color(0xFFF8FAFC), 
      title: const Text(
        "LIST NEW/MEMBER", 
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
      ), 
      elevation: 0,
      centerTitle: true,
      // PANAH BACK: Terlihat jelas di latar terang
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)), 
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. INPUT PENCARIAN MURID
            TextField(
              controller: searchController, 
              onChanged: onSearchChanged, 
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari Murid...', 
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38), 
                fillColor: const Color(0xFF1E293B),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
              ),
            ),
            const SizedBox(height: 12),

            // 2. BARIS INPUT NAMA BARU + TOMBOL DAFTAR & BACKUP
            Row(children: [
              Expanded(
                child: TextField(
                  controller: namaController, 
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'NAMA BARU', 
                    hintStyle: const TextStyle(color: Colors.white38),
                    fillColor: const Color(0xFF1E293B),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // BUTTON DAFTAR UTAMA
              ElevatedButton(
                onPressed: onAdd, 
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                child: const Text("DAFTAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 6),

              // TOMBOL EKSPOR BACKUP (HIJAU TAKTIS)
              IconButton(
                icon: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF34D399), size: 28),
                tooltip: 'Backup Data',
                onPressed: onEkspor,
              ),

              // TOMBOL IMPOR RESTORE (ORANYE TAKTIS)
              IconButton(
                icon: const Icon(Icons.system_update_alt_rounded, color: Color(0xFFF59E0B), size: 28),
                tooltip: 'Restore Data',
                onPressed: onImpor,
              ),
            ]),
            const SizedBox(height: 16),

            // 3. DAFTAR LIST KARTU ATLET
            Expanded(
              child: ListView.builder(
                itemCount: daftarMurid.length,
                itemBuilder: (context, i) {
                  final m = daftarMurid[i];
                  final bool isSelected = m.id == selectedId;
                  return Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155), width: isSelected ? 1.5 : 1)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFF0F172A), child: Text(m.id, style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold))),
                      title: Text(m.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.analytics, color: Colors.cyan), onPressed: () => onSelect(m.id)), 
                        IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => onDelete(m)),
                      ]),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
// ==================== HALAMAN 3: INPUT REPS ====================
class InputLatihanKuantitatifPage extends StatefulWidget {
  final List<Murid> daftarMurid;
  final String selectedMuridId;
  final ValueChanged<String?> onMuridChanged;
  final Function(String, String, String, double, double, String, DateTime) onSimpan; // Update Signature

  const InputLatihanKuantitatifPage({Key? key, required this.daftarMurid, required this.selectedMuridId, required this.onMuridChanged, required this.onSimpan}) : super(key: key);

  @override
  State<InputLatihanKuantitatifPage> createState() => _InputLatihanKuantitatifPageState();
}

class _InputLatihanKuantitatifPageState extends State<InputLatihanKuantitatifPage> {
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  String _selectedKlasifikasi = kDaftarKlasifikasiLatihan.first;
  String _selectedTipePembagi = 'J'; // Default awal pada tipe J

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    // BAGIAN BAWAH: Gelap (Navy Deep)
    backgroundColor: const Color(0xFF0F172A), 

    appBar: AppBar(
      // BAGIAN ATAS: Terang (Slate Clean)
      backgroundColor: const Color(0xFFF8FAFC), 
      title: const Text(
      "INPUT REPS", 
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
      ), 
      elevation: 0,
      centerTitle: true,
      // PANAH BACK: Terlihat jelas di latar terang
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)), 
    ),
     body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("INPUT TARGET REPETISI (KUANTITATIF)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan)),const SizedBox(height: 10),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.cyan.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
  ),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("RUMUS SKOR REPS:", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 11)),
      SizedBox(height: 4),
      Text("• Tipe J (Junior): (Reps × Sets) ÷ 15", style: TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  ),
),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: widget.selectedMuridId, 
              dropdownColor: const Color(0xFF1E293B),
              items: widget.daftarMurid.map((m) => DropdownMenuItem(value: m.id, child: Text("${m.id} - ${m.nama}", style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: widget.onMuridChanged, decoration: const InputDecoration(labelText: "Pilih Atlet", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedKlasifikasi, 
              dropdownColor: const Color(0xFF1E293B),
              items: kKlasifksKmampuan.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedKlasifikasi = v!), decoration: const InputDecoration(labelText:"BIOMOTORIK", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            // --- DROPDOWN BARU UNTUK PARAMETER PEMBAGI J / S ---
            DropdownButtonFormField<String>(
              value: _selectedTipePembagi,
              dropdownColor: const Color(0xFF1E293B),
              items: const [
                DropdownMenuItem(value: 'J', child: Text("J (Target Base: 15 Reps)", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'S', child: Text("S (Target Base: 25 Reps)", style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) => setState(() => _selectedTipePembagi = v!),
              decoration: const InputDecoration(labelText: "Parameter Pembagi Skoring", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(controller: _jenisController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nama Latihan (cth: Push Up, Sit Up)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _repsController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Jumlah Reps", border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _setsController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Jumlah Sets", border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                double reps = double.tryParse(_repsController.text) ?? 0.0;
                double sets = double.tryParse(_setsController.text) ?? 0.0;
                if (_jenisController.text.isNotEmpty && reps > 0 && sets > 0) {
                  // Mengirimkan _selectedTipePembagi ke fungsi simpan
                  widget.onSimpan(widget.selectedMuridId, _jenisController.text, _selectedKlasifikasi, reps, sets, _selectedTipePembagi, DateTime.now());
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Repetisi Tipe $_selectedTipePembagi Berhasil Disimpan!")));
                  _jenisController.clear(); _repsController.clear(); _setsController.clear();
                }
              },
              child: const Text("SIMPAN PERFORMA REPS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ))
          ]),
        ),
      ),
    );
  }
}

// ==================== HALAMAN 4: INPUT WAKTU ====================
class InputLatihanDurasiPage extends StatefulWidget {
  final List<Murid> daftarMurid;
  final String selectedMuridId;
  final ValueChanged<String?> onMuridChanged;
  final Function(String, String, String, double, double, String, DateTime) onSimpan; // Update Signature

  const InputLatihanDurasiPage({Key? key, required this.daftarMurid, required this.selectedMuridId, required this.onMuridChanged, required this.onSimpan}) : super(key: key);

  @override
  State<InputLatihanDurasiPage> createState() => _InputLatihanDurasiPageState();
}

class _InputLatihanDurasiPageState extends State<InputLatihanDurasiPage> {
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _menitController = TextEditingController();
  final TextEditingController _detikController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  String _selectedKlasifikasi = kDaftarKlasifikasiLatihan.first;
  String _selectedTipePembagi = 'J'; // Default awal pada tipe J

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // BAGIAN BAWAH: Gelap (Navy Deep)
    backgroundColor: const Color(0xFF0F172A), 

    appBar: AppBar(
      // BAGIAN ATAS: Terang (Slate Clean)
      backgroundColor: const Color(0xFFF8FAFC), 
      title: const Text(
        "INPUT LAMA WAKTU", 
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
      ), 
      elevation: 0,
      centerTitle: true,
      // PANAH BACK: Terlihat jelas di latar terang
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)), 
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("INPUT TARGET DURASI WAKTU (TIME-BASED)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),const SizedBox(height: 10),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.cyan.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
  ),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("RUMUS SKOR REPS:", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 11)),
      SizedBox(height: 4),    
      Text("• Tipe S (Senior): (Reps × Sets) ÷ 25", style: TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  ),
),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: widget.selectedMuridId, 
              dropdownColor: const Color(0xFF1E293B),
              items: widget.daftarMurid.map((m) => DropdownMenuItem(value: m.id, child: Text("${m.id} - ${m.nama}", style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: widget.onMuridChanged, decoration: const InputDecoration(labelText: "Pilih Atlet", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedKlasifikasi, 
              dropdownColor: const Color(0xFF1E293B),
              items: kKlasifksKmampuan.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedKlasifikasi = v!), decoration: const InputDecoration(labelText: "BIOMOTORIK", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            // --- DROPDOWN BARU UNTUK PARAMETER PEMBAGI J / S ---
            DropdownButtonFormField<String>(
              value: _selectedTipePembagi,
              dropdownColor: const Color(0xFF1E293B),
              items: const [
                DropdownMenuItem(value: 'J', child: Text("J (Target Base: 60 Detik)", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'S', child: Text("S (Target Base: 90 Detik)", style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) => setState(() => _selectedTipePembagi = v!),
              decoration: const InputDecoration(labelText: "Parameter Pembagi Skoring", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(controller: _jenisController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nama Latihan (cth: Plank, Kuda-Kuda)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _menitController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Menit", border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _detikController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Detik", border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _setsController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Sets", border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                double dtk = double.tryParse(_detikController.text) ?? 0.0;
                double mnt = double.tryParse(_menitController.text) ?? 0.0;
                double sets = double.tryParse(_setsController.text) ?? 0.0;
                double totalDetik = (mnt * 60) + dtk;
                if (_jenisController.text.isNotEmpty && totalDetik > 0 && sets > 0) {
                  // Mengirimkan _selectedTipePembagi ke fungsi simpan
                  widget.onSimpan(widget.selectedMuridId, _jenisController.text, _selectedKlasifikasi, totalDetik, sets, _selectedTipePembagi, DateTime.now());
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Durasi Tipe $_selectedTipePembagi Berhasil Disimpan!")));
                  _jenisController.clear(); _menitController.clear(); _detikController.clear(); _setsController.clear();
                }
              },
              child: const Text("SIMPAN PERFORMA WAKTU", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ))
          ]),
        ),
      ),
    );
  }
}
// ==================== ENGINE GRAFIK 1: BOXPLOT CUSTOM PAINT ====================
class MetaBoxplotChart extends StatelessWidget {
  final List<List<double>> boxData;
  final List<double> teamAverages;

  const MetaBoxplotChart({Key? key, required this.boxData, required this.teamAverages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CustomPaint(
        size: const Size(double.infinity, 240),
        painter: _BoxplotPainter(boxData: boxData, teamAverages: teamAverages),
      ),
    );
  }
}

class _BoxplotPainter extends CustomPainter {
  final List<List<double>> boxData;
  final List<double> teamAverages;

  _BoxplotPainter({required this.boxData, required this.teamAverages});

  @override
  void paint(Canvas canvas, Size size) {
    final int itemLength = boxData.length;
    if (itemLength == 0) return;

    double chartWidth = size.width - 50;
    double chartHeight = size.height - 40;
    double spacing = chartWidth / itemLength;

    final Paint pGaris = Paint()..color = const Color(0xFF334155)..strokeWidth = 1.0;
    final Paint pBox = Paint()..color = const Color(0xFF38BDF8).withOpacity(0.3)..style = PaintingStyle.fill;
    final Paint pBorderBox = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final Paint pMedian = Paint()..color = Colors.amber..strokeWidth = 2.0;
    final Paint pSkorKini = Paint()..color = const Color(0xFFF43F5E)..style = PaintingStyle.fill;
    final Paint pGarisHubungScore = Paint()..color = const Color(0xFFF43F5E).withOpacity(0.4)..strokeWidth = 1.0;
    final Paint pRataTim = Paint()..color = const Color(0xFF10B981)..strokeWidth = 1.5..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      double y = 10 + (chartHeight / 4) * i;
      canvas.drawLine(Offset(40, y), Offset(size.width, y), pGaris);
    }

    Offset? prevScoreOffset;

    for (int i = 0; i < itemLength; i++) {
      double x = 55 + (spacing * i) + (spacing / 4);
      List<double> d = boxData[i];
      if (d.length < 6) continue;

      double mapY(double val) {
        if (val == 0.0) return 10 + chartHeight; 
        return 10 + (chartHeight * (1.0 - (val / 100.0))).clamp(0.0, chartHeight);
      }

      double yMin = mapY(d[0]);
      double yQ1 = mapY(d[1]);
      double yQ2 = mapY(d[2]);
      double yScore = mapY(d[3]); 
      double yQ3 = mapY(d[4]);
      double yMax = mapY(d[5]);

      canvas.drawLine(Offset(x, yMin), Offset(x, yMax), pBorderBox);
      canvas.drawLine(Offset(x - 5, yMin), Offset(x + 5, yMin), pBorderBox);
      canvas.drawLine(Offset(x - 5, yMax), Offset(x + 5, yMax), pBorderBox);

      Rect rectBox = Rect.fromLTRB(x - 12, yQ3, x + 12, yQ1);
      canvas.drawRect(rectBox, pBox);
      canvas.drawRect(rectBox, pBorderBox);

      canvas.drawLine(Offset(x - 12, yQ2), Offset(x + 12, yQ2), pMedian);

      if (i < teamAverages.length && teamAverages[i] > 0) {
        double yAvg = mapY(teamAverages[i]);
        canvas.drawLine(Offset(x - 15, yAvg), Offset(x + 15, yAvg), pRataTim);
      }

      Offset currentScoreOffset = Offset(x, yScore);
      if (prevScoreOffset != null) {
        canvas.drawLine(prevScoreOffset, currentScoreOffset, pGarisHubungScore);
      }
      prevScoreOffset = currentScoreOffset;

      canvas.drawCircle(currentScoreOffset, 5.0, pSkorKini);

      final List<String> labels = ["STR", "END", "SPD", "CRD", "FLX", "BAL", "REA"];
      final txt = TextPainter(text: TextSpan(text: labels[i], style: const TextStyle(fontSize: 8, color: Colors.white60)), textDirection: TextDirection.ltr)..layout();
      txt.paint(canvas, Offset(x - (txt.width / 2), size.height - 22));
    }
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// ================================================================
// WIDGET UTAMA RADAR: SEKARANG LEBIH PADAT & MENANTANG
// ================================================================
class MetaRadarChart extends StatelessWidget {
  final List<double> dataIndividu; 
  final List<double> rataRataTim;  

  const MetaRadarChart({
    Key? key,
    required this.dataIndividu,
    required this.rataRataTim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280, // Sedikit dinaikkan agar visualisasi makin megah
          width: double.infinity,
          child: CustomPaint(
            painter: MetaRadarChartPainter(
              activeRadar: dataIndividu,
              teamRadar: rataRataTim,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Keterangan Legenda Warna
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E), 
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Performa Atlet',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24), 
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8), 
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Rata-rata Tim (All)',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

// ================================================================
// PAINTER RADAR: GRID LEBIH RAPAT, SKALA DIPERSEMPIT KE 1.2
// ================================================================
class MetaRadarChartPainter extends CustomPainter {
  final List<double> activeRadar; 
  final List<double> teamRadar;   

  final List<String> features = const ["MUSC END", "POWER", "CORE STAB", "DYNAMIC FLEX", "SPEED END", "REACTIVE SPEED", "AGILITY", "ASA/FightIQ", "MOBILITY", "REAKSI LINCAH"];

  MetaRadarChartPainter({
    required this.activeRadar,
    required this.teamRadar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 * 0.75;
    final angleStep = (2 * math.pi) / features.length;

    // --- DIKETATKAN: Batas maksimum diturunkan dari 2.0 ke 1.2 agar jaring melesat padat ke luar ---
    const double batasMaksimumSkala = 1.2; 

    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.7) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final labelStyle = TextStyle(
      color: Colors.blueGrey[200],
      fontSize: 9,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.5,
    );

    // --- GRID LEBIH RAPAT: Membuat 6 lapisan lingkaran (jarak antar batang menyempit) ---
    for (var i = 1; i <= 6; i++) {
      double nilaiSkala = i * 0.2; // Menghasilkan lingkaran 0.2, 0.4, 0.6, 0.8, 1.0, 1.2
      double r = (nilaiSkala / batasMaksimumSkala) * maxRadius;

      // Berikan warna pembeda khusus untuk lingkaran Target Ideal (1.0)
      if (i == 5) {
        canvas.drawCircle(center, r, gridPaint..color = const Color(0xFF64748B)..strokeWidth = 1.5);
      } else {
        canvas.drawCircle(center, r, gridPaint..color = const Color(0xFF334155).withOpacity(0.6)..strokeWidth = 1.0);
      }

      // Tampilkan teks skala angka desimal di grid
      if (i == 3 || i == 5) { // Tampilkan label di garis 0.6 dan 1.0 (Target)
        final textPainter = TextPainter(
          text: TextSpan(
            text: i == 5 ? "1.0 (Target)" : nilaiSkala.toStringAsFixed(1),
            style: TextStyle(
              color: i == 5 ? const Color(0xFF94A3B8) : Colors.blueGrey[600], 
              fontSize: 8, 
              fontWeight: FontWeight.bold
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(center.dx + 4, center.dy - r - 4));
      }
    }

    // Mengembalikan warna grid ke semula untuk garis jari-jari
    gridPaint..color = const Color(0xFF334155).withOpacity(0.7)..strokeWidth = 1.0;

    // Garis Jari-jari & Teks Kategori
    for (var i = 0; i < features.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final lineEnd = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, lineEnd, gridPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: features[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRadius = maxRadius + 14;
      final labelX = center.dx + labelRadius * math.cos(angle) - (textPainter.width / 2);
      final labelY = center.dy + labelRadius * math.sin(angle) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // LAPISAN TIM (BIRU): Lebih solid dan padat
    if (teamRadar.isNotEmpty) {
      final teamPath = Path();
      final teamPaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.6) 
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final teamFillPaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.1) 
        ..style = PaintingStyle.fill;

      for (var i = 0; i < features.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        double skorAman = i < teamRadar.length ? teamRadar[i] : 0.0;
        final val = skorAman.clamp(0.0, batasMaksimumSkala);
        final r = (val / batasMaksimumSkala) * maxRadius;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);

        if (i == 0) {
          teamPath.moveTo(x, y);
        } else {
          teamPath.lineTo(x, y);
        }
      }
      teamPath.close();
      canvas.drawPath(teamPath, teamFillPaint);
      canvas.drawPath(teamPath, teamPaint);
    }

    // LAPISAN INDIVIDU (HIJAU NEON): Lebar, padat, mendominasi layar
    if (activeRadar.isNotEmpty) {
      final dataPath = Path();
      final dataPaint = Paint()
        ..color = const Color(0xFF22C55E) 
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0; // Dipertebal agar gahar

      final fillPaint = Paint()
        ..color = const Color(0xFF22C55E).withOpacity(0.25) // Dipekatkan arsirannya
        ..style = PaintingStyle.fill;

      for (var i = 0; i < features.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        double skorAman = i < activeRadar.length ? activeRadar[i] : 0.0;
        final val = skorAman.clamp(0.0, batasMaksimumSkala);
        final r = (val / batasMaksimumSkala) * maxRadius;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);

        if (i == 0) {
          dataPath.moveTo(x, y);
        } else {
          dataPath.lineTo(x, y);
        }
      }
      dataPath.close();
      canvas.drawPath(dataPath, fillPaint);
      canvas.drawPath(dataPath, dataPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MetaRadarChartPainter oldDelegate) {
    return oldDelegate.activeRadar != activeRadar || oldDelegate.teamRadar != teamRadar;
  }
}

