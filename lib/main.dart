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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        useMaterial3: true,
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Roboto',
            ),
      ),
      home: GempaPage(),
    );
  }
}

class GempaPage extends StatefulWidget {
  @override
  _GempaPageState createState() => _GempaPageState();
}

class _GempaPageState extends State<GempaPage> {
  List<dynamic> gempaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGempaData();
  }

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

  Color getMagnitudeColor(double magnitude) {
    if (magnitude < 3.0) return Colors.white;
    if (magnitude < 4.0) return Color.fromARGB(255, 0, 255, 72);
    if (magnitude < 5.0) return Color.fromARGB(255, 255, 230, 0);
    if (magnitude < 6.0) return Color.fromARGB(255, 255, 153, 0);
    return Color.fromARGB(255, 255, 0, 0);
  }

  Widget _buildLegendBox(String label, String skala, String range, Color bgColor, Color textColor) {
    return Container(
      width: 70,
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
            skala,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: textColor,
            ),
          ),
          SizedBox(height: 2),
          Text(
            range,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendBox("Putih", "Skala I-II", "< 3", Colors.white, Colors.black),
              _buildLegendBox("Hijau", "Skala III-V", "3.0 - 3.9", Color.fromARGB(255, 0, 255, 72), Colors.black),
              _buildLegendBox("Kuning", "Skala VI", "4.0 - 4.9", Color.fromARGB(255, 255, 230, 0), Colors.black),
              _buildLegendBox("Jingga", "Skala VII-VIII", "5.0 - 5.9", Color.fromARGB(255, 255, 153, 0), Colors.black),
              _buildLegendBox("Merah", "Skala IX-XII", "≥ 6", Color.fromARGB(255, 255, 0, 0), Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGempaCard(dynamic gempa) {
    double magnitude = double.tryParse(gempa['Magnitude']) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
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
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: "${gempa['Magnitude']}",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.vertical_align_bottom, size: 20, color: Colors.lightBlueAccent),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Kedalaman: ",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(
                      text: "${gempa['Kedalaman']}",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 20, color: Colors.lightGreenAccent),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Waktu: ",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(
                      text: "${gempa['Tanggal']} ${gempa['Jam']}",
                      style: TextStyle(fontSize: 15, color: Colors.white),
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
