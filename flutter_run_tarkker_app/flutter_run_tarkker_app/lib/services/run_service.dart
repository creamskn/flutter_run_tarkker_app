import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/run_model.dart';

class RunService {
  final supabase = Supabase.instance.client;

  // 1. เพิ่มข้อมูล (Insert)
  Future<void> insertRunData(RunModel run) async {
    try {
      await supabase.from('run_tb').insert({
        'runwhere': run.runwhere,
        'runperson': run.runperson,
        'rundistance': run.rundistance,
      });
    } catch (e) {
      debugPrint('Insert Error: $e');
      rethrow;
    }
  }

  // 2. ดึงข้อมูลทั้งหมด (Select)
  Future<List<RunModel>> getAllRunData() async {
    try {
      final response = await supabase
          .from('run_tb')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((data) => RunModel.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Fetch Error: $e');
      throw Exception('ไม่สามารถดึงข้อมูลได้: $e');
    }
  }

  // 3. แก้ไขข้อมูล (Update) - เพิ่มใหม่เพื่อให้หน้าแก้ไขใช้งานได้
  Future<void> updateRunData(RunModel run) async {
    try {
      if (run.id == null) throw Exception('ID is required for update');

      await supabase
          .from('run_tb')
          .update({
            'runwhere': run.runwhere,
            'runperson': run.runperson,
            'rundistance': run.rundistance,
          })
          .eq('id', run.id!); // ค้นหาแถวที่จะแก้ด้วย ID
    } catch (e) {
      debugPrint('Update Error: $e');
      rethrow;
    }
  }

  // 4. ลบข้อมูล (Delete)
  Future<void> deleteRunData(String id) async {
    try {
      await supabase.from('run_tb').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete Error: $e');
      rethrow;
    }
  }
}
