import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

class NotificationTestView extends StatelessWidget {
  const NotificationTestView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختبار التنبيهات',
          style: GoogleFonts.cairo(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'الصلوات والأوقات'),
          _buildTestButton(
            context,
            label: 'أذان الفجر',
            channelKey: 'fajr_adhan_channel_v4',
            title: 'حان وقت صلاة الفجر',
            body: 'الصلاة خير من النوم',
            category: NotificationCategory.Alarm,
          ),
          _buildTestButton(
            context,
            label: 'الأذان العادي (الظهر/العصر/المغرب/العشاء)',
            channelKey: 'adhan_channel_v4',
            title: 'حان وقت الصلاة',
            body: 'لاتنسي أذكار بعد الصلاة المفروضة',
            category: NotificationCategory.Alarm,
          ),
          _buildTestButton(
            context,
            label: 'تنبيه قبل الصلاة',
            channelKey: 'pre_prayer_channel_v1',
            title: 'اقترب وقت الصلاة',
            body: 'باقي 15 دقيقة على موعد الصلاة',
          ),
          _buildTestButton(
            context,
            label: 'إقامة الصلاة',
            channelKey: 'iqamah_channel_v1',
            title: 'إقامة الصلاة',
            body: 'قد قامت الصلاة',
          ),
          _buildTestButton(
            context,
            label: 'وقت الشروق',
            channelKey: 'shruq_channel_v1',
            title: 'وقت الشروق',
            body: 'حان موعد شروق الشمس',
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'الأذكار اليومية'),
          _buildTestButton(
            context,
            label: 'أذكار الصباح',
            channelKey: 'sabah_athkar_channel',
            title: 'أذكار الصباح',
            body: 'أصبحنا وأصبح الملك لله',
            payload: {'route': 'morning_athkar'},
          ),
          _buildTestButton(
            context,
            label: 'أذكار المساء',
            channelKey: 'mesaa_athkar_channel',
            title: 'أذكار المساء',
            body: 'أمسينا وأمسى الملك لله',
            payload: {'route': 'evening_athkar'},
          ),
          _buildTestButton(
            context,
            label: 'أذكار النوم',
            channelKey: 'sleep_athkar_channel',
            title: 'أذكار النوم',
            body: 'باسمك ربي وضعت جنبي',
            payload: {'route': 'sleep_athkar'},
          ),
          _buildTestButton(
            context,
            label: 'أذكار بعد الصلاة',
            channelKey: 'post_prayer_dhikr_channel',
            title: 'أذكار ما بعد الصلاة',
            body: 'لا تنس أذكار ما بعد الصلاة',
          ),
          _buildTestButton(
            context,
            label: 'قيام الليل',
            channelKey: 'qiam_channel',
            title: 'قيام الليل',
            body: 'وقت قيام الليل، تقبل الله طاعتكم',
            payload: {'route': 'qiyam_reminder'},
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'تنبيهات أخرى'),
          _buildTestButton(
            context,
            label: 'الصلاة على النبي ﷺ',
            channelKey: 'salawat_channel',
            title: 'ﷺ',
            body: 'اللهم صل وسلم على نبينا محمد',
            payload: {'route': 'salawat'},
          ),
          _buildTestButton(
            context,
            label: 'تذكير صيام الاثنين',
            channelKey: 'sabah_athkar_channel',
            title: 'تذكير صيام الاثنين',
            body: 'غداً يوم الاثنين، تذكير بصيام يوم في سبيل الله',
            payload: {'route': 'fasting_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'سورة الكهف (الجمعة)',
            channelKey: 'quran_channel',
            title: 'سورة الكهف',
            body:
                'قال ﷺ: «من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين»',
            payload: {'route': 'kahf_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'ساعة الاستجابة (الجمعة)',
            channelKey: 'sabah_athkar_channel',
            title: 'ساعة الاستجابة',
            body:
                'في يوم الجمعة ساعة لا يسأل الله أحد فيها شيئا وهو قائم يصلي إلا أعطاه الله إياه',
            payload: {'route': 'friday_hour_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'تذكير الأيام البيض',
            channelKey: 'sabah_athkar_channel',
            title: 'صيام الأيام البيض',
            body: 'غداً يوم 13 رجب، نذكركم بصيام الأيام البيض',
            payload: {'route': 'white_days_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'ورد القرآن',
            channelKey: 'quran_channel',
            title: 'ورد القرآن',
            body: 'لا تنس وردك اليومي من القرآن',
            payload: {'route': 'quran_wird'},
          ),
          _buildTestButton(
            context,
            label: 'حديث اليوم',
            channelKey: 'hadith_channel',
            title: 'حديث اليوم',
            body: 'قال رسول الله ﷺ: ...',
            payload: {'route': 'daily_hadith'},
          ),
          _buildTestButton(
            context,
            label: 'تذكير الزكاة',
            channelKey: 'zakat_reminder_channel',
            title: 'تذكير الزكاة',
            body: 'تذكير بمرور حول على الزكاة',
          ),
          _buildTestButton(
            context,
            label: 'تذكير الصدقة',
            channelKey: 'charity_reminder_channel',
            title: 'تذكير الصدقة',
            body: 'تصدق ولو بشق تمرة',
          ),
          _buildTestButton(
            context,
            label: 'إنجاز جديد',
            channelKey: 'achievement_unlocked_channel',
            title: 'مبروك! إنجاز جديد',
            body: 'لقد حققت إنجازاً جديداً في الصدقة',
          ),
          _buildTestButton(
            context,
            label: 'تذكير التقويم',
            channelKey: 'calendar_reminders_channel',
            title: 'حدث في التقويم',
            body: 'تذكير بمناسبة مسجلة في التقويم',
            payload: {'route': 'calendar_screen'},
          ),
          _buildTestButton(
            context,
            label: 'المناسبات الإسلامية',
            channelKey: 'sabah_athkar_channel',
            title: 'يوم عرفة',
            body:
                'قال ﷺ: صيام يوم عرفة أحتسب على الله أن يكفر السنة التي قبله والسنة التي بعده',
            payload: {
              'route': 'religious_occasion_reminder',
              'title': 'يوم عرفة',
              'body': 'تذكير بصيام يوم عرفة، ليلة العيد ومغفرة عامين من الذنوب'
            },
          ),
          _buildTestButton(
            context,
            label: 'سورة الملك',
            channelKey: 'quran_channel',
            title: 'سورة الملك',
            body:
                'قال النبي ﷺ عن سورة الملك: هي المانعة، هي المنجية، تنجيه من عذاب القبر',
            payload: {'route': 'mulk_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'صلاة الضحى',
            channelKey: 'sabah_athkar_channel',
            title: 'صلاة الضحى',
            body:
                'يصبح على كل سلامى من أحدكم صدقة.. ويجزئ من ذلك ركعتان يركعهما من الضحى',
            payload: {'route': 'duha_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'سنة اليوم',
            channelKey: 'sabah_athkar_channel',
            title: 'سنة اليوم',
            body: 'إحياء سنة من سنن المصطفى ﷺ، اضغط لتتعرف على سنة اليوم',
            payload: {'route': 'sunnah_reminder'},
          ),
          _buildTestButton(
            context,
            label: 'الدعاء بين الأذان والإقامة',
            channelKey: 'sabah_athkar_channel',
            title: 'الدعاء بين الأذان والإقامة',
            body: 'قال ﷺ: لا يُرد الدعاء بين الأذان والإقامة؛ فادعوا',
            payload: {'route': 'adhan_iqamah_reminder'},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: KColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required String label,
    required String channelKey,
    required String title,
    required String body,
    NotificationCategory category = NotificationCategory.Reminder,
    Map<String, String>? payload,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // decoration: BoxDecoration(
      //    color: AppThemeColors.cardBackgroundColor(context),
      //    borderRadius: BorderRadius.circular(12),
      //    border: Border.all(color: Colors.grey.withOpacity(0.2)),
      // ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.cardBackgroundColor(context),
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: DateTime.now().millisecond, // Unique ID for testing
              channelKey: channelKey,
              title: title,
              body: body,
              icon: 'resource://drawable/ic_stat_logoapp',
              largeIcon: 'resource://drawable/ic_stat_logoapp',
              notificationLayout: NotificationLayout.BigText,
              color: const Color(0xFF178B74),
              category: category,
              wakeUpScreen: true,
              fullScreenIntent: category == NotificationCategory.Alarm,
              criticalAlert: category == NotificationCategory.Alarm,
              payload: payload,
            ),
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('تم إرسال تنبيه: $label',
                      style: GoogleFonts.cairo())),
            );
          }
        },
        child: Row(
          children: [
            Icon(Icons.notifications_active_outlined,
                color: KColors.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
