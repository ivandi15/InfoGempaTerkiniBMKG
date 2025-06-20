import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(GempaApp());

// Widget utama aplikasi
class GempaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gempa Terkini BMKG',
      debugShowCheckedModeBanner: false,
      // Untuk menggunakan tema gelap dengan latar belakang abu-abu gelap
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        useMaterial3: true,
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Roboto', // Untuk font jika tersedia
            ),
      ),
      home: GempaPage(), // Untuk menampilkan halaman utama
    );
  }
}

// Clas halaman utama aplikasi
class GempaPage extends StatefulWidget {
  @override
  _GempaPageState createState() => _GempaPageState();
}

class _GempaPageState extends State<GempaPage> {
  List<dynamic> gempaList = []; // Untuk menyimpan daftar data gempa
  bool isLoading = true; // Untuk loading indicator

  @override
  void initState() {
    super.initState();
    fetchGempaData(); // Ambil data saat halaman dimulai
  }

  // Fungsi untuk mengambil data gempa dari API BMKG
  Future<void> fetchGempaData() async {
    final url = Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        gempaList = jsonData['Infogempa']['gempa'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat data gempa');
    }
  }

  // Bagian untuk menentukan warna berdasarkan magnitudo gempa
  Color getMagnitudeColor(double magnitude) {
    if (magnitude < 3.0) return const Color.fromARGB(255, 255, 255, 255);
    if (magnitude < 4.0) return Color.fromARGB(255, 0, 255, 72); // Hijau
    if (magnitude < 5.0) return Color.fromARGB(255, 255, 230, 0); // Kuning
    if (magnitude < 6.0) return Color.fromARGB(255, 255, 153, 0); // Jingga
    return Color.fromARGB(255, 255, 0, 0); // Merah
  }

  // Widget untuk kotak legenda warna
  Widget _buildLegendBox(String label, String range, Color bgColor, Color textColor) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 2),
          Text(
            range,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Header aplikasi berisi judul dan legenda warna
  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Gempa Terkini",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Data diambil dari Badan Meteorologi, Klimatologi, dan Geofisika (BMKG)!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          // Baris legenda warna
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendBox("Putih", "< 3", Colors.white, Colors.black),
              _buildLegendBox("Hijau", "3.0 - 3.9", Color.fromARGB(255, 0, 255, 72), Colors.black),
              _buildLegendBox("Kuning", "4.0 - 4.9", Color.fromARGB(255, 255, 230, 0), Colors.black),
              _buildLegendBox("Jingga", "5.0 - 5.9", Color.fromARGB(255, 255, 153, 0), Colors.black),
              _buildLegendBox("Merah", "≥ 6", Color.fromARGB(255, 255, 0, 0), Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  // Bagian untuk menampilkan card data gempa
  Widget buildGempaCard(dynamic gempa) {
    double magnitude = double.tryParse(gempa['Magnitude']) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C), // warna latar belakang kartu
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Lokasi gempa
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  gempa['Wilayah'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(thickness: 2, color: Colors.white30),
          const SizedBox(height: 10),

          // Bagian keterangan Magnitudo
          Row(
            children: [
              Icon(Icons.speed, size: 20, color: Colors.orange),
              const SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getMagnitudeColor(magnitude),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Magnitudo: ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "${gempa['Magnitude']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Bagian keterangan Kedalaman
          Row(
            children: [
              Icon(Icons.vertical_align_bottom, size: 20, color: Colors.lightBlueAccent),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Kedalaman: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "${gempa['Kedalaman']}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Bagian keterangan Waktu
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 20, color: Colors.lightGreenAccent),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Waktu: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "${gempa['Tanggal']} ${gempa['Jam']}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Membangun seluruh tampilan aplikasi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchGempaData,
              child: ListView(
                children: [
                  buildHeader(),
                  ...gempaList.map((g) => buildGempaCard(g)).toList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
