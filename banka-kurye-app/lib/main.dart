import 'package0:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Web Yapılandırması
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBbNEKAFDpZCOZFhUAxR-VrHWBM_uvRpQU",
      authDomain: "banka-kurye-app.firebaseapp.com",
      projectId: "banka-kurye-app",
      storageBucket: "banka-kurye-app.firebasestorage.app",
      messagingSenderId: "148514058628",
      appId: "1:148514058628:web:40a91839064b2bf0532dd1",
    ),
  );

  runApp(const BankaKuryeApp());
}

class BankaKuryeApp extends StatelessWidget {
  const BankaKuryeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banka Kurye Takip Paneli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _adresRumuzController = TextEditingController();
  final TextEditingController _acikAdresController = TextEditingController();

  void _lokasyonEkle() async {
    if (_adresRumuzController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('lokasyonlar').add({
        'rumuz': _adresRumuzController.text,
        'acik_adres': _acikAdresController.text,
        'tarih': FieldValue.serverTimestamp(),
      });
      _adresRumuzController.clear();
      _acikAdresController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kısa adres tanımlaması eklendi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banka Kurye - Yönetici Kontrol Paneli'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Pratik Lokasyon / Rumuz Ekleme Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    const Text(
                      'Pratik Adres / Rumuz Tanımlama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _adresRumuzController,
                            decoration: const InputDecoration(
                              labelText: 'Kısa Rumuz (Örn: Kadıköy Şube)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _acikAdresController,
                            decoration: const InputDecoration(
                              labelText: 'Açık Adres Detayı',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _lokasyonEkle,
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Rumuz Kaydet'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanımlı Kısa Lokasyonlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Firebase Firestore'dan Rumuzları Anlık Çeken Liste
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('lokasyonlar').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.pin_drop, color: Colors.indigo),
                          title: Text(data['rumuz'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(data['acik_adres'] ?? 'Açık adres girilmedi'),
                        ),
                      );
                    },
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
