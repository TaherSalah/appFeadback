import '../../../../core/shard/exports/all_exports.dart' show StatefulWidget, ValueChanged, VoidCallback, State, TextEditingController, BuildContext, Widget, EdgeInsets, Color, Offset, SizedBox, Icon, Text, LinearGradient, Center, Theme, Brightness, TextDirection, Colors, Clip, BorderRadius, Alignment, BoxShadow, BoxDecoration, MainAxisSize, SizeExtension, FontWeight, TextStyle, TextAlign, OutlineInputBorder, InputDecoration, TextField, Icons, Navigator, IconButton, OutlinedButton, BorderSide, RoundedRectangleBorder, Expanded, ElevatedButton, Row, Column, Container, BoxShape, Align, Positioned, Stack, Dialog, Directionality;

class NoteDialogWidget extends StatefulWidget {
  final String? initialText;
  final ValueChanged<String> onSave;
  final VoidCallback onDelete;

  const NoteDialogWidget({
    this.initialText,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<NoteDialogWidget> createState() => _NoteDialogWidgetState();
}

class _NoteDialogWidgetState extends State<NoteDialogWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // جسم الديالوج
            Container(
              padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                      : [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Text(
                    'خواطري حول الصفحة',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // النص التوضيحي
                  Text(
                    'سجل ما تعلمته أو تدبرته من هذه الصفحة ليسهل عليك العودة إليه لاحقاً.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.indigo.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),

                  // حقل إدخال الخواطر
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    style:
                    TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "اكتب ما في ذهنك هنا...",
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey[600]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white12
                          : Colors.white.withOpacity(0.6),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // الأزرار
                  Row(
                    children: [
                      if (widget.initialText != null) ...[
                        IconButton(
                          onPressed: () {
                            widget.onDelete();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                          tooltip: 'حذف الخاطرة',
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.indigo.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A237E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              widget.onSave(_controller.text);
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('حفظ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // الأيقونة الدائرية أعلى الديالوج
            Positioned(
              top: -35,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3F51B5).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}