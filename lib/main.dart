import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wi-Fi Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WifiScanScreen(),
    );
  }
}

class WifiScanScreen extends StatefulWidget {
  const WifiScanScreen({super.key});

  @override
  State<WifiScanScreen> createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends State<WifiScanScreen> {
  List<WiFiAccessPoint> accessPoints = [];
  bool isScanning = false;

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
    });

    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wi-Fi skan qilish mumkin emas!')),
      );
      setState(() {
        isScanning = false;
      });
      return;
    }

    await WiFiScan.instance.startScan();

    final canGetResults = await WiFiScan.instance.canGetScannedResults();
    if (canGetResults == CanGetScannedResults.yes) {
      final results = await WiFiScan.instance.getScannedResults();
      setState(() {
        accessPoints = results;
        isScanning = false;
      });
    } else {
      setState(() {
        isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Natijalarni olishda xatolik!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wi-Fi Scanner')),
      body:
          accessPoints.isEmpty
              ? const Center(child: Text('Wi-Fi tarmoqlari topilmadi'))
              : ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemCount: accessPoints.length,
                itemBuilder: (context, index) {
                  final wifi = accessPoints[index];
                  return Card(
                    child: ListTile(
                      title: Text(wifi.ssid.isEmpty ? 'Noma’lum' : wifi.ssid),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("level: ${wifi.level} dBm"),
                          Text("bssid: ${wifi.bssid}"),
                          Text("capabilities: ${wifi.capabilities}"),
                          Text("ssid: ${wifi.ssid}"),
                          Text("centerFrequency0: ${wifi.centerFrequency0}"),
                          Text("centerFrequency1: ${wifi.centerFrequency1}"),
                          Text("channelWidth: ${wifi.channelWidth}"),
                          Text("frequency: ${wifi.frequency}"),
                          Text(
                            "is80211mcResponder: ${wifi.is80211mcResponder}",
                          ),
                          Text("isPasspoint: ${wifi.isPasspoint}"),
                          Text("standard: ${wifi.standard}"),
                          Text("timestamp: ${wifi.timestamp}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: IconButton.filled(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: isScanning ? null : startScan,
        icon: Icon(Icons.search),
      ),
    );
  }
}
