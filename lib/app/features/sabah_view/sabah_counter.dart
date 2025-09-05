

import '../../core/shard/exports/all_exports.dart';

class SabahCounter extends StatefulWidget {
  String azkarConten;
  String azkarContenDes;
  String azkarContenRepate;

  SabahCounter(
      {super.key,
      required this.azkarConten,
      required this.azkarContenDes,
      required this.azkarContenRepate});

  @override
  State<SabahCounter> createState() => _SabahCounterState();
}

class _SabahCounterState extends State<SabahCounter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AzkarProvider>(context);

    return Hero(
      tag: 'sabah',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(AppStyle.primaryColor),
          appBar: customAppBar(AppString.Ksabah, actions: [
            IconButton(
              onPressed: () {
                zakarShared(
                    azkarConten: widget.azkarConten,
                    azkarContenDes: widget.azkarContenDes,
                    azkarContenRepate: widget.azkarContenRepate,
                    subjectType: AppString.Ksabah,
                    zakarType: AppString.Ksabah,);
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
                      height: 45.h,
                    ),
                    Card(
                      elevation: 10,
                      color: Colors.black.withOpacity(0.5),
                      shape: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(AppStyle.whiteColor), width: 5)),
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
                              radius: 30,
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
                              radius: 30,
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
                        radius: 25,
                        child: Image.asset(leftArrow),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     // const urlPreview =
                    //     //     'https://www.youtube.com/watch?v=3yCm7d_';
                    //     // final url = Uri.parse(
                    //     //     'https://i.dummyjson.com/data/products/1/1.jpg');
                    //     // final resp = await http.get(url);
                    //     // final bytes = resp.bodyBytes;
                    //     // final temp = await getTemporaryDirectory();
                    //     // //== after temp path write image name and extaintion this name is display when share  ==//
                    //     // final path = '${temp.path}/iphon image.jpg';
                    //
                    //     // File(path).writeAsBytesSync(bytes);
                    //     // await Share.shareFiles([path], text:'this iphon new');
                    //
                    //
                    //   },
                    //   child: const CircleAvatar(
                    //       backgroundColor: Color(AppStyle.primaryColor),
                    //       child: Icon(Icons.share)),
                    // ),
                  ],
                ),
                ////*** show dialog in ui ****///
                controller.showDialog()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
