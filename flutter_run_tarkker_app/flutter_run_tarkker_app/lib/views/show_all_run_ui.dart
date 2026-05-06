import 'package:flutter/material.dart';
import '../services/run_service.dart';
import '../models/run_model.dart';
import 'add_run_ui.dart';
import 'update_delete_run_ui.dart';

class ShowAllRunUI extends StatefulWidget {
  const ShowAllRunUI({super.key});

  @override
  State<ShowAllRunUI> createState() => _ShowAllRunUIState();
}

class _ShowAllRunUIState extends State<ShowAllRunUI> {
  final RunService _runService = RunService();

  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Tracker')),

      body: FutureBuilder<List<RunModel>>(
        future: _runService.getAllRunData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final runList = snapshot.data ?? [];

          if (runList.isEmpty) {
            return const Center(child: Text('ยังไม่มีข้อมูลการวิ่ง'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: runList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = runList[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.directions_run,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.runwhere,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'ระยะทาง ${item.rundistance} กม. • ${item.runperson}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    bool? refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateDeleteRunUI(run: item),
                      ),
                    );

                    if (refresh == true) {
                      _refreshData();
                    }
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRunUI()),
          ).then((value) => _refreshData());
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มข้อมูล'),
      ),
    );
  }
}
