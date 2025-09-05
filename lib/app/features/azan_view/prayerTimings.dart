import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../core/shard/exports/all_exports.dart';

class PrayerTimings {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String sunrise;

  PrayerTimings({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    return PrayerTimings(
      fajr: timings['Fajr'],
      sunrise: timings['Sunrise'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
    );
  }
}


Future<PrayerTimings> fetchPrayerTimes(String city, String country) async {
  final now = DateTime.now();
  final url = Uri.parse(
    'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=5&date=${now.day}-${now.month}-${now.year}',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return PrayerTimings.fromJson(json.decode(response.body));
  } else {
    throw Exception('فشل في تحميل مواقيت الصلاة');
  }
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _cityController = TextEditingController(text: "Cairo");
  final _countryController = TextEditingController(text: "Egypt");

  PrayerTimings? _timings;
  bool _isLoading = false;

  Future<void> _getPrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      final result = await fetchPrayerTimes(
        _cityController.text,
        _countryController.text,
      );
      setState(() => _timings = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مواقيت الصلاة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'المدينة')),
            TextField(controller: _countryController, decoration: const InputDecoration(labelText: 'الدولة')),
            ElevatedButton(
              onPressed: _getPrayerTimes,
              child: const Text('عرض المواقيت'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_timings != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("الفجر: ${_timings!.fajr}"),
                  Text("الشروق: ${_timings!.sunrise}"),
                  Text("الظهر: ${_timings!.dhuhr}"),
                  Text("العصر: ${_timings!.asr}"),
                  Text("المغرب: ${_timings!.maghrib}"),
                  Text("العشاء: ${_timings!.isha}"),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
PrayerTimes getPrayerTimes(double lat, double lng) {
  final coordinates = Coordinates(lat, lng);
  final params = CalculationMethod.egyptian.getParameters();
  final date = DateComponents.from(DateTime.now());
  final prayerTimes = PrayerTimes(coordinates, date, params);
  return prayerTimes;
}

String formatTime(DateTime time) {
  return DateFormat.jm().format(time); // 12-hour format
}



