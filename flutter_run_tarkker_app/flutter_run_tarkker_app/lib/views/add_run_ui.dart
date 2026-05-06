import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/run_service.dart';
import '../models/run_model.dart';

class AddRunUI extends StatefulWidget {
  const AddRunUI({super.key});

  @override
  State<AddRunUI> createState() => _AddRunUIState();
}

class _AddRunUIState extends State<AddRunUI> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _whereCtrl = TextEditingController();
  final TextEditingController _personCtrl = TextEditingController();
  final TextEditingController _distanceCtrl = TextEditingController();

  File? _image;
  final RunService _runService = RunService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('ไม่สามารถเปิดกล้องได้');
    }
  }

  void _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newRun = RunModel(
        runwhere: _whereCtrl.text.trim(),
        runperson: _personCtrl.text.trim(),
        rundistance: int.parse(_distanceCtrl.text),
      );

      await _runService.insertRunData(newRun);

      if (!mounted) return;
      _showSnackBar('บันทึกสำเร็จ');

      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _whereCtrl.dispose();
    _personCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มข้อมูลการวิ่ง')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : null,
                      child: _image == null
                          ? const Icon(Icons.camera_alt, size: 30)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _whereCtrl,
                            decoration: const InputDecoration(
                              labelText: 'วิ่งที่ไหน',
                              prefixIcon: Icon(Icons.place),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'กรอกข้อมูล' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _personCtrl,
                            decoration: const InputDecoration(
                              labelText: 'วิ่งกับใคร',
                              prefixIcon: Icon(Icons.people),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'กรอกข้อมูล' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _distanceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ระยะทาง (กม.)',
                              prefixIcon: Icon(Icons.speed),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรอกข้อมูล';
                              }
                              if (int.tryParse(value) == null) {
                                return 'ต้องเป็นตัวเลข';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveData,
                      child: const Text('บันทึก'),
                    ),
                  ),

                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
