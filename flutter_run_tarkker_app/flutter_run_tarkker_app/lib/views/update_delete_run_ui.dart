import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/run_service.dart';
import '../models/run_model.dart';

class UpdateDeleteRunUI extends StatefulWidget {
  final RunModel run;

  const UpdateDeleteRunUI({super.key, required this.run});

  @override
  State<UpdateDeleteRunUI> createState() => _UpdateDeleteRunUIState();
}

class _UpdateDeleteRunUIState extends State<UpdateDeleteRunUI> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _whereCtrl;
  late TextEditingController _personCtrl;
  late TextEditingController _distanceCtrl;

  File? _image;
  final RunService _runService = RunService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _whereCtrl = TextEditingController(text: widget.run.runwhere);
    _personCtrl = TextEditingController(text: widget.run.runperson);
    _distanceCtrl =
        TextEditingController(text: widget.run.rundistance.toString());
  }

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

  void _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedRun = RunModel(
        id: widget.run.id,
        runwhere: _whereCtrl.text.trim(),
        runperson: _personCtrl.text.trim(),
        rundistance: int.parse(_distanceCtrl.text),
      );

      await _runService.updateRunData(updatedRun);

      if (!mounted) return;
      _showSnackBar('แก้ไขสำเร็จ');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันลบ'),
        content: Text('ลบ "${widget.run.runwhere}" ใช่หรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _runService.deleteRunData(widget.run.id.toString());

                if (!mounted) return;
                _showSnackBar('ลบเรียบร้อย');
                Navigator.pop(context, true);
              } catch (e) {
                _showSnackBar('ลบไม่สำเร็จ');
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 📷 รูป
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child:
                          _image == null ? const Icon(Icons.camera_alt) : null,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 📦 ฟอร์ม
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
                            validator: (v) => v!.isEmpty ? 'กรอกข้อมูล' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _personCtrl,
                            decoration: const InputDecoration(
                              labelText: 'วิ่งกับใคร',
                              prefixIcon: Icon(Icons.people),
                            ),
                            validator: (v) => v!.isEmpty ? 'กรอกข้อมูล' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _distanceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ระยะทาง (กม.)',
                              prefixIcon: Icon(Icons.speed),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'กรอกข้อมูล';
                              if (int.tryParse(v) == null)
                                return 'ต้องเป็นตัวเลข';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ ปุ่มแก้ไข
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateData,
                      child: const Text('บันทึกการแก้ไข'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🗑️ ปุ่มลบ
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _deleteData,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('ลบข้อมูล'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔄 loading overlay
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
