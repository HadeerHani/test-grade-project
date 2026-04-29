import 'package:flutter/material.dart';
import 'package:second_project/screens/welcome_screen_modified.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';

class JobDetailsScreen extends StatefulWidget {
  final String serviceName;
  final bool isEdit;
  final Map<String, dynamic>? editData;
  final int? index;
  const JobDetailsScreen({super.key, required this.serviceName,this.isEdit=false,
  this.editData,
  this.index,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _budgetController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // لو isEdit بـ true، املأ الخانات بالبيانات القديمة
    _dateController = TextEditingController(text: widget.isEdit ? widget.editData!['date'] : "");
    _timeController = TextEditingController(text: widget.isEdit ? "10:00 AM" : ""); 
    _budgetController = TextEditingController(text: widget.isEdit ? widget.editData!['price'].toString() : "");
    _descriptionController = TextEditingController(text: widget.isEdit ? (widget.editData!['description'] ?? "") : "");
  }
  @override
void dispose() {
  // تنظيف الـ controllers من الذاكرة عند الخروج من الصفحة
  _dateController.dispose();
  _timeController.dispose();
  _budgetController.dispose();
  _descriptionController.dispose();
  super.dispose();
}
  // ميثود لإظهار النتيجة (Date Picker)
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryLightBeige,
      appBar: AppBar(
        title: Text(widget.isEdit
        ? "Edit ${widget.serviceName}"
         : "${widget.serviceName} Request",
          // style: const TextStyle(color: Colors.white)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Job Details ",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tell us when, where, and what needs fixing. Required fields are marked.",
              style: TextStyle(color: AppColors.textgrey, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // السطر بتاع التاريخ والوقت
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    "Date (Required)",
                    "02/07/2026",
                    controller: _dateController,
                    suffixIcon: Icons.calendar_month,
                    onTap: () => _selectDate(context), // فتح النتيجة عند الضغط
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInputField(
                    "Time (Required)",
                    "10:00 AM",
                    controller: _timeController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildInputField(
              controller: _budgetController,
             // onChanged:(val)=>_budgetController.text=val,
              "Proposed Budget (USD - Required)",
              "Max budget (e.g., 150)",
            ),

            const SizedBox(height: 20),
            _buildInputField(
              "Description of Job (Required)",
              "Describe the issue in detail (e.g., Leaky pipe under the sink...)",
              maxLines: 4,
            ),

            const SizedBox(height: 20),
            const Text(
              "Photo Reference (Optional)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 10),
            // مكان زرار الصورة (فاضي حالياً بناءً على طلبك)
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.button, // اللون البيج في الصورة
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryDarkGreen,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Add Photo of Job Site",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildInputField(
              "Detailed Location / Access Notes (Required)",
              "456 Customer Ave, Apt 1A, use side gate.",
            ),

            const SizedBox(height: 30),

            // زرار الـ Post
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            onPressed: () {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  if (widget.isEdit) {
    // حالة التعديل: بنحدث بالقيم الجديدة ونخليها Pending
   /* userProvider.updateRequestStatus(
     widget.index ??0,
     _dateController.text,
     widget.serviceName,
     _budgetController.text
    );*/
    userProvider.updateRequestStatus(
  index: widget.index ?? 0, // 👈 ضيفي اسم البراميتر هنا
  newDate: _dateController.text, // 👈 والاسم هنا
  newTitle: widget.serviceName, // 👈 والاسم هنا
  newprice: _budgetController.text, // 👈 والاسم هنا
);
  } else {
    // حالة إضافة طلب جديد: بنقرأ من الـ Controllers
    userProvider.addRequest({
      'title': widget.serviceName, // ضيفي 'title' هنا عشان الـ Provider بيستخدمه
      'serviceType': widget.serviceName,
      'date': _dateController.text,
      'time': _timeController.text,
      'description': _descriptionController.text,
      'price': _budgetController.text,
      //.isEmpty?_budgetController.text:'0',
      'status': 'Pending',
    });
  }
  

  // الرجوع للصفحة السابقة بعد الحفظ
  Navigator.pop(context);
},
              //onPressed: () {},
              child: Text(
                widget.isEdit ? "Update Request" : "Post Job & Find Worker",
                style: TextStyle(
                  color: AppColors.secondaryLightBeige,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود مساعدة لبناء الخانات (Textfields) عشان الكود يبقى منظم
  Widget _buildInputField(
    String label,
    String hint, {
    int maxLines = 1,
    TextEditingController? controller,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: onTap != null, // لو فيه نتيجة خليه للقراءة فقط
          onTap: onTap,
          onChanged: (val){if(controller!=null)controller.text=val;},
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
