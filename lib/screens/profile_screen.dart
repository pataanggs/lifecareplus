import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '/widgets/rounded_button.dart';
import '/services/auth_service.dart';
import '/utils/show_snackbar.dart';
import '/models/user_profile.dart';
import '/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final fullNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserProfile? _user;
  File? _profileImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    // Delay loading to ensure widget is mounted
    Future.microtask(() => _loadUserData());
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final user = await _authService.getUserProfile(userId);
      if (user == null) {
        if (!mounted) return;
        showSnackBar(context, 'Tidak dapat memuat data pengguna');
        return;
      }

      if (!mounted) return;
      setState(() {
        _user = user;
        fullNameController.text = user.fullName;
        nicknameController.text = user.nickname;
        phoneController.text = user.phone;
        ageController.text = user.age?.toString() ?? '0';
        heightController.text = user.height?.toString() ?? '0';
        weightController.text = user.weight?.toString() ?? '0';
        _currentProfileImageUrl = user.profileImageUrl;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!mounted) return;
      showSnackBar(context, 'Terjadi kesalahan saat memuat data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null && mounted) {
        setState(() {
          _profileImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        showSnackBar(context, 'Gagal memilih gambar: $e');
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return null;

      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      if (mounted) {
        showSnackBar(context, 'Gagal mengunggah gambar: $e');
      }
      return null;
    }
  }

  Future<void> _saveUserProfile() async {
    if (_user == null) return; // Should not happen if UI is loaded correctly

    // Basic validation
    if (fullNameController.text.isEmpty ||
        nicknameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        ageController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty) {
      showSnackBar(context, 'Semua data yang dapat diubah harus diisi');
      return;
    }

    // Ensure _user!.uid is accessible and valid.
    if (_user!.uid == null || _user!.uid!.isEmpty) {
      debugPrint('User UID is missing, cannot update profile.');
      showSnackBar(context, 'Kesalahan: ID Pengguna tidak ditemukan.');
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      String? profileImageUrl = _currentProfileImageUrl;

      // Upload new profile image if selected
      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(_profileImage!);
        // If upload failed and profileImageUrl is null, decide on behavior
        // (e.g., use old one, or prevent saving if upload is critical)
      }

      // These values are not directly editable in this screen's UI
      final String userEmail = _user!.email;
      final String userGender = _user!.gender;

      // Prepare data for AuthService.updateUserProfile
      final String newFullName = fullNameController.text;
      final String newNickname = nicknameController.text;
      final String newPhone = phoneController.text;
      final int newAge = int.tryParse(ageController.text) ?? _user!.age ?? 0;
      final double newHeight =
          double.tryParse(heightController.text) ?? _user!.height ?? 0.0;
      final double newWeight =
          double.tryParse(weightController.text) ?? _user!.weight ?? 0.0;

      // Call AuthService to update the profile in Firestore
      await _authService.updateUserProfile(
        uid: _user!.uid!,
        fullName: newFullName,
        nickname: newNickname,
        phone: newPhone,
        age: newAge,
        height: newHeight,
        weight: newWeight,
        profileImageUrl: profileImageUrl,
      );

      // Update local _user state optimistically
      setState(() {
        _user = UserProfile(
          uid: _user!.uid,
          fullName: newFullName,
          nickname: newNickname,
          email: userEmail,
          phone: newPhone,
          gender: userGender,
          age: newAge,
          height: newHeight,
          weight: newWeight,
          profileImageUrl: profileImageUrl,
        );
        _currentProfileImageUrl = profileImageUrl;
        _profileImage = null; // Clear the selected file image
      });

      if (!mounted) return;
      showSnackBar(context, 'Profil berhasil diperbarui');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (!mounted) return;
      showSnackBar(context, 'Terjadi kesalahan saat menyimpan profil: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (!mounted) return;
      showSnackBar(context, 'Terjadi kesalahan saat keluar');
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF05606B),
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              image:
                                  _profileImage != null
                                      ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                      : _currentProfileImageUrl != null &&
                                          _currentProfileImageUrl!.isNotEmpty
                                      ? DecorationImage(
                                        image: NetworkImage(
                                          _currentProfileImageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                (_profileImage == null &&
                                        (_currentProfileImageUrl == null ||
                                            _currentProfileImageUrl!.isEmpty))
                                    ? const Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    )
                                    : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD6E56C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Personal Info
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      label: 'Nama Lengkap',
                      controller: fullNameController,
                      hint: 'Masukkan nama lengkap anda',
                    ),

                    _buildInputField(
                      label: 'Nama Panggilan',
                      controller: nicknameController,
                      hint: 'Masukkan nama panggilan anda',
                    ),

                    _buildInputField(
                      label: 'Email',
                      enabled: false, // Email can't be changed
                      initialValue: _user?.email ?? '',
                      hint: 'Email anda',
                    ),

                    _buildInputField(
                      label: 'Nomor Handphone',
                      controller: phoneController,
                      hint: '+628 1234 5678 90',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 24),

                    // Physical Info
                    const Text(
                      'Informasi Fisik',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      label: 'Jenis Kelamin',
                      enabled: false, // Gender can't be changed
                      initialValue: _user?.gender ?? '',
                      hint: 'Jenis kelamin anda',
                    ),

                    _buildInputField(
                      label: 'Umur',
                      controller: ageController,
                      hint: 'Umur anda',
                      keyboardType: TextInputType.number,
                    ),

                    _buildInputField(
                      label: 'Tinggi (cm)',
                      controller: heightController,
                      hint: 'Tinggi badan dalam cm',
                      keyboardType: TextInputType.number,
                    ),

                    _buildInputField(
                      label: 'Berat (kg)',
                      controller: weightController,
                      hint: 'Berat badan dalam kg',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 40),

                    // Save button
                    RoundedButton(
                      text: _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                      onPressed: _isSaving ? null : () { _saveUserProfile(); }, // Corrected line
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: double.infinity,
                      height: 50,
                      elevation: 3,
                    )
                  ],
                ),
              ),
    );
  }

  Widget _buildInputField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required String hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller ?? TextEditingController(text: initialValue),
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.grey.shade700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor:
                enabled
                    ? Colors.white
                    : Colors.grey.shade300, // Differentiate disabled fill
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
