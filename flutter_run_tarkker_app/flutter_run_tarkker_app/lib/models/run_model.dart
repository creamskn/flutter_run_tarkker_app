class RunModel {
  final String? id;
  final String runwhere;
  final String runperson;
  final int rundistance;

  RunModel({
    this.id,
    required this.runwhere,
    required this.runperson,
    required this.rundistance,
  });

  // แปลงจาก Object เป็น Map เพื่อส่งเข้า Supabase
  Map<String, dynamic> toMap() {
    return {
      'runwhere': runwhere, // ตรงตามรูปตาราง
      'runperson': runperson, // ตรงตามรูปตาราง
      'rundistance': rundistance, // ตรงตามรูปตาราง
    };
  }

  // แปลงจาก Map (จาก Supabase) กลับมาเป็น Object
  factory RunModel.fromMap(Map<String, dynamic> map) {
    return RunModel(
      id: map['id'],
      runwhere: map['runwhere'] ?? '',
      runperson: map['runperson'] ?? '',
      rundistance: map['rundistance'] ?? 0,
    );
  }
}
