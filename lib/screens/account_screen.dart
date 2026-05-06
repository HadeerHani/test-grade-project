import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'welcome_screen_modified.dart';
import 'user_provider.dart';

class AccountScreen extends StatefulWidget {
  final List<String> selectedSkills;
  const AccountScreen({super.key, required this.selectedSkills});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  late TextEditingController _ssnController;

  @override
  void initState() {
    super.initState();
    final up = Provider.of<UserProvider>(context, listen: false);
    
    // Determine which data to show based on role
    bool isWorker = up.userRole == 'worker';
    
    _nameController = TextEditingController(text: isWorker ? up.workerName : up.userName);
    _emailController = TextEditingController(text: isWorker ? up.workerEmail : up.userEmail);
    _phoneController = TextEditingController(text: isWorker ? up.workerPhone : up.userPhone);
    _addressController = TextEditingController(text: isWorker ? up.workerAddress : up.userAddress);
    _bioController = TextEditingController(text: isWorker ? up.workerBio : up.userBio);
    _ssnController = TextEditingController(text: up.workerSSN);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null && mounted) {
      final up = Provider.of<UserProvider>(context, listen: false);
      if (up.userRole == 'worker') {
        up.updateWorkerData(image: File(image.path));
      } else {
        up.updateUserData(image: File(image.path));
      }
    }
  }

  void _saveChanges() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (up.userRole == 'worker') {
      up.updateWorkerData(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
        ssn: _ssnController.text,
      );
    } else {
      up.updateUserData(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
      );
    }
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    const cardBackground = Color(0xFFF2EFE9);
    const Color greyLabel = Color(0xFFA59D8B);

    return Consumer<UserProvider>(
      builder: (context, up, child) {
        bool isWorker = up.userRole == 'worker';
        String displayName = isWorker ? up.workerName : up.userName;
        File? displayImage = isWorker ? up.workerImage : up.userImage;

        return Scaffold(
          backgroundColor: AppColors.backgroundWhite,
          appBar: AppBar(
            title: const Text("My Account"),
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit, color: AppColors.backgroundWhite),
                onPressed: () {
                  if (isEditing) {
                    _saveChanges();
                  } else {
                    setState(() {
                      isEditing = true;
                      // Update controllers with latest provider data before editing
                      _nameController.text = isWorker ? up.workerName : up.userName;
                      _emailController.text = isWorker ? up.workerEmail : up.userEmail;
                      _phoneController.text = isWorker ? up.workerPhone : up.userPhone;
                      _addressController.text = isWorker ? up.workerAddress : up.userAddress;
                      _bioController.text = isWorker ? up.workerBio : up.userBio;
                    });
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(displayName, displayImage, isWorker),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoCard(cardBackground, greyLabel, isWorker, up),
                      if (isWorker) ...[
                        const SizedBox(height: 16),
                        _buildWorkerStatusCard(cardBackground, greyLabel, up),
                      ],
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, File? image, bool isWorker) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 65,
              backgroundColor: const Color(0xFFF2EFE9),
              backgroundImage: image != null ? FileImage(image) : null,
              child: image == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 55, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            if (isEditing)
              GestureDetector(
                onTap: _pickImage,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF2EFE9),
                  child: Icon(Icons.camera_alt, size: 20, color: AppColors.primaryDarkGreen),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          name.isEmpty ? "User" : name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
        ),
        Text(
          isWorker ? "Professional Worker" : "Verified Customer",
          style: const TextStyle(color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard(Color cardBackground, Color greyLabel, bool isWorker, UserProvider up) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDarkGreen),
          ),
          const SizedBox(height: 15),
          _infoRow("NAME", _nameController, "Your Name", greyLabel, isWorker ? up.workerName : up.userName),
          if (isWorker) _infoRow("SSN", _ssnController, "ID Number", greyLabel, up.workerSSN),
          _infoRow("EMAIL", _emailController, "email@example.com", greyLabel, isWorker ? up.workerEmail : up.userEmail),
          _infoRow("PHONE", _phoneController, "Contact number", greyLabel, isWorker ? up.workerPhone : up.userPhone),
          _infoRow("ADDRESS", _addressController, "Your Location", greyLabel, isWorker ? up.workerAddress : up.userAddress),
          const SizedBox(height: 15),
          const Text("BIO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          isEditing
              ? TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Tell us about yourself...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                )
              : Text((isWorker ? up.workerBio : up.userBio).isEmpty ? "No bio available" : (isWorker ? up.workerBio : up.userBio), 
                  style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, TextEditingController controller, String hint, Color greyLabel, String displayValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: greyLabel, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: hint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                )
              : Text(displayValue.isEmpty ? "Not set" : displayValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildWorkerStatusCard(Color cardBackground, Color greyLabel, UserProvider up) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.verified, color: AppColors.primaryDarkGreen, size: 28),
              SizedBox(width: 12),
              Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Verified", style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 40, color: AppColors.primaryDarkGreen),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                up.workerCategory.isNotEmpty ? "Category: ${up.workerCategory}" : "Category: Not Set", 
                style: const TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w500)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<UserProvider>(context, listen: false).logout();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 16)),
        child: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
