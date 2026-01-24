import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import '../../core/services/feedback_service.dart';

/// شاشة عرض سجل الشكاوى الخاص بالمستخدم
class FeedbackHistoryView extends StatefulWidget {
  final String userEmail;

  const FeedbackHistoryView({Key? key, required this.userEmail})
      : super(key: key);

  @override
  State<FeedbackHistoryView> createState() => _FeedbackHistoryViewState();
}

class _FeedbackHistoryViewState extends State<FeedbackHistoryView> {
  final _feedbackService = FeedbackService();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _feedbackService.getUserFeedback(widget.userEmail);
  }

  void _refresh() {
    setState(() {
      _historyFuture = _feedbackService.getUserFeedback(widget.userEmail);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'تم الحل':
        return Colors.green;
      case 'قيد المعالجة':
        return Colors.orange;
      case 'تم استقبال المشكلة':
        return Colors.blue;
      case 'جديد':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'سجل الشكاوى',
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Center(child: KLoading.progressIOSIndicator(context: context));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في جلب البيانات',
                      style: GoogleFonts.cairo(),
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
              );
            }

            final feedbackList = snapshot.data ?? [];

            if (feedbackList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد شكاوى سابقة مسجلة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'بهذا البريد: ${widget.userEmail}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                final item = feedbackList[index];
                final status = item['status'] ?? 'جديد';
                final date = DateTime.parse(item['created_at']).toLocal();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: _getStatusColor(status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['category'] ?? 'شكوى',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '📅 ${date.day}/${date.month}/${date.year}',
                      style:
                          GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'وصف الشكوى:',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['description'] ?? '',
                              style: GoogleFonts.cairo(fontSize: 13),
                            ),
                            if (item['reply'] != null &&
                                item['reply'].toString().isNotEmpty) ...[
                              const Divider(height: 32),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.reply,
                                            size: 16, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Text(
                                          'رد الإدارة:',
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['reply'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
