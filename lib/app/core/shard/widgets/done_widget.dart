import '../exports/all_exports.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(AppString.KForYou),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Image.asset(
                doneZakar,
              )),
              SizedBox(
                height: 10.h,
              ),
              Text(
                AppString.KSabahDaialogText,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              SizedBox(
                height: 15.h,
              ),
              Text(
                AppString.KZakarSleepFeaturesDes,
                style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp),
              ),
              SizedBox(
                height: 10.h,
              ),
              const Divider(
                color: Color(AppStyle.primaryColor),
                thickness: 2,
                indent: 150,
                endIndent: 150,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  AppString.doneText,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontFamily: AppStyle.fontFamily,
                      height: 1.8.h,
                      fontSize: 17.5.sp),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
