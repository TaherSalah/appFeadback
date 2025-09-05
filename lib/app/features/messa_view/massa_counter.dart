

import '../../core/shard/exports/all_exports.dart';

class MassaCounter extends StatefulWidget {
  String azkarConten;
  String azkarContenDes;
  String azkarContenRepate;

  MassaCounter(
      {super.key,
      required this.azkarConten,
      required this.azkarContenDes,
      required this.azkarContenRepate});

  @override
  State<MassaCounter> createState() => _MassaCounterState();
}

class _MassaCounterState extends State<MassaCounter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AzkarProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(AppStyle.primaryColor),
        appBar: customAppBar(AppString.KMessa, actions: [
          IconButton(
            onPressed: () {
              zakarShared(
                  azkarConten: widget.azkarConten,
                  azkarContenDes: widget.azkarContenDes,
                  azkarContenRepate: widget.azkarContenRepate,
                  subjectType: AppString.KMessa,
                  zakarType: AppString.KMessa);
            },
            icon: const Icon(Icons.share),
          ),
        ]),
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25.h,
                  ),
                  Card(
                    elevation: 10,
                    color: Colors.black.withOpacity(0.5),
                    shape:  OutlineInputBorder(
                        borderSide: BorderSide(
                            color: const Color(AppStyle.whiteColor), width: 5.w)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Text('${controller.counter}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.sp,
                              color: Colors.white)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.incrementCount();
                    },
                    child: AzkerItemBuilder(
                        azkarTitle: widget.azkarConten,
                        azkarDes: widget.azkarContenDes,
                        azkarRepate: widget.azkarContenRepate),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.incrementCount();
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 30.r,
                            child: Image.asset(
                              click,
                              color: Colors.green,
                            )),
                      ),
                      SizedBox(
                        width: 150.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.restCount();
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 30.r,
                            child: Image.asset(
                              arrow,
                              color: Colors.red.shade700,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 25.r,
                      child: Image.asset(leftArrow),
                    ),
                  ),
                ],
              ),
              ////*** show dialog in ui ****///
              controller.showDialog()
            ],
          ),
        ),
      ),
    );
  }
}
