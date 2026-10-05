import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_quanly_giaiui/features/auth/data/auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _repository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool retry = false}) async {
    if (retry && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final profile = await _repository.getCurrentProfile();
      if (!mounted) return;
      if (profile == null) {
        setState(() => _loadError = 'Không tìm thấy thông tin hồ sơ.');
      } else {
        setState(() {
          _name.text = profile.displayName;
          _email.text = profile.email ?? '';
          _phone.text = profile.phone ?? '';
          _address.text = profile.address ?? '';
          _avatarUrl = profile.avatarUrl;
          _loadError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = 'Không thể tải thông tin hồ sơ.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAvatar() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (image == null || !mounted) return;
      final extension = image.name.split('.').last.toLowerCase();
      const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
      if (!allowedExtensions.contains(extension)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chỉ hỗ trợ ảnh JPG, PNG hoặc WebP')),
          );
        }
        return;
      }
      final url = await _repository.uploadAvatar(
        await image.readAsBytes(),
        extension,
      );
      if (mounted) setState(() => _avatarUrl = url);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải ảnh lên: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await _repository.updateCustomerProfile(
        fullName: _name.text,
        email: _email.text,
        phone: _phone.text,
        address: _address.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật hồ sơ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _loadError != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!),
                TextButton(
                  onPressed: () => _load(retry: true),
                  child: const Text('Thử tải lại'),
                ),
              ],
            ),
          )
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _avatarUrl == null
                            ? null
                            : NetworkImage(_avatarUrl!),
                        child: _avatarUrl == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          onPressed: _saving ? null : _pickAvatar,
                          icon: const Icon(Icons.photo_camera_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Vui lòng nhập họ tên'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ mặc định',
                  ),
                ),
              ],
            ),
          ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Lưu thay đổi'),
        ),
      ),
    ),
  );
}
