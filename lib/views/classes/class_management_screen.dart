import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/language_provider.dart';

class ClassModel {
  final int id;
  final String className;
  final String section;
  final String academicYear;
  final String stage;

  ClassModel({required this.id, required this.className, required this.section,
    required this.academicYear, required this.stage});

  factory ClassModel.fromJson(Map<String, dynamic> j) => ClassModel(
    id: j['id'] ?? 0,
    className: j['class_name'] ?? '',
    section: j['section'] ?? '',
    academicYear: j['academic_year'] ?? '',
    stage: j['stage'] ?? '',
  );
}

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});
  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

// Standard NEP-2020 style stage mapping: Foundational (Nur-2), Preparatory (3-5),
// Middle (6-8), Secondary (9-12)
const _allClassNames = ['Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4',
    'Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12'];

String _stageForClass(String className) {
  const foundational = ['Nursery','LKG','UKG','Class 1','Class 2'];
  const preparatory = ['Class 3','Class 4','Class 5'];
  const middle = ['Class 6','Class 7','Class 8'];
  if (foundational.contains(className)) return 'Foundational';
  if (preparatory.contains(className)) return 'Preparatory';
  if (middle.contains(className)) return 'Middle';
  return 'Secondary';
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  List<ClassModel> _classes = [];
  bool _loading = true;
  bool _bulkAdding = false;
  String _filterStage = 'All';
  String? _error;

  final _stages = ['All', 'Foundational', 'Preparatory', 'Middle', 'Secondary'];

  final _stageColors = {
        'Foundational': Colors.green,
        'Preparatory':  Colors.blue,
        'Middle':       Colors.orange,
        'Secondary':    Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await apiService.get('/classes');
      debugPrint('CLASSES API RESPONSE: $response');
      final rawList = response['data'] ?? response['classes'] ?? response;
      if (rawList is! List) {
        throw Exception('Unexpected response shape: ${response.runtimeType} -> $response');
      }
      setState(() {
        _classes = rawList
          .map((j) => ClassModel.fromJson(j)).toList();
        const order = ['Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4','Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12'];
        _classes.sort((a, b) {
          final ai = order.indexOf(a.className);
          final bi = order.indexOf(b.className);
          if (ai == -1 && bi == -1) return a.className.compareTo(b.className);
          if (ai == -1) return 1;
          if (bi == -1) return -1;
          return ai.compareTo(bi);
        });
        _loading = false;
      });
    } catch (e) {
      debugPrint('CLASSES FETCH ERROR: $e');
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<ClassModel> get _filtered => _filterStage == 'All'
    ? _classes
    : _classes.where((c) => c.stage == _filterStage).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LanguageProvider>().t('classes')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/admin'),
        ),
        actions: [
          IconButton(
            icon: _bulkAdding
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.playlist_add),
            tooltip: 'Setup Nursery to Class 12',
            onPressed: _bulkAdding ? null : () => _showBulkAddDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClassDialog(context),
          ),
        ],
      ),
      body: Column(children: [
        // Stage summary
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _stageStat('Foundational', _classes.where((c) => c.stage == 'Foundational').length, Colors.green),
            _stageStat('Preparatory', _classes.where((c) => c.stage == 'Preparatory').length, Colors.blue),
            _stageStat('Middle', _classes.where((c) => c.stage == 'Middle').length, Colors.orange),
            _stageStat('Secondary', _classes.where((c) => c.stage == 'Secondary').length, Colors.purple),
          ]),
        ),
        const Divider(height: 1),

        // Filter chips
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: _stages.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_stages[i], style: const TextStyle(fontSize: 12)),
                selected: _filterStage == _stages[i],
                onSelected: (_) => setState(() => _filterStage = _stages[i]),
                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ),

        // Classes list
        _loading
          ? const Expanded(child: Center(child: CircularProgressIndicator()))
          : _error != null
            ? Expanded(child: Center(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text('Failed to load classes:\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _fetchClasses, child: const Text('Retry')),
                ]))))
            : _filtered.isEmpty
              ? const Expanded(child: Center(child: Text('No classes found')))
              : Expanded(child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final c = _filtered[i];
                  final color = _stageColors[c.stage] ?? Colors.grey;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text(
                          c.className.replaceAll('Class ', '').replaceAll('Nursery', 'N').replaceAll('UKG', 'U').replaceAll('LKG', 'L'),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)))),
                      title: Text('${c.className} - Section ${c.section}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text('${c.academicYear} • ${c.stage} Stage',
                        style: const TextStyle(fontSize: 11)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(c.stage,
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),

                      ]),
                    ),
                  );
                },
              )),
      ]),
    );
  }

  Future<void> _deleteClass(int id) async {
    try {
      await apiService.delete('/classes/$id');
      _fetchClasses();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red));
    }
  }

  Widget _stageStat(String label, int count, Color color) => Column(children: [
    Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);

  void _showAddClassDialog(BuildContext context) {
    String className = 'Nursery';
    String section = 'A';
    String year = '2025-26';
    final classes = ['Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4',
        'Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Class'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: className,
              decoration: const InputDecoration(labelText: 'Class'),
              items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setS(() => className = v!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: section,
              decoration: const InputDecoration(labelText: 'Section'),
              items: ['A','B','C','D'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setS(() => section = v!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: year,
              decoration: const InputDecoration(labelText: 'Academic Year'),
              items: ['2024-25','2025-26','2026-27'].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (v) => setS(() => year = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await apiService.post('/classes', {
        'class_name': className,
        'section': section,
        'academic_year': year,
        'stage': _stageForClass(className),
                  });
                  _fetchClasses();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class added!'), backgroundColor: Colors.green));
                } catch (e) {}
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkAddDialog(BuildContext context) {
    String year = '2025-26';
    String section = 'A';
    // Sirf woh classes jo abhi list me nahi hain
    final existing = _classes.map((c) => c.className).toSet();
    final toAdd = _allClassNames.where((c) => !existing.contains(c)).toList();

    if (toAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nursery se Class 12 tak saari classes already added hain!')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Setup Nursery to Class 12'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${toAdd.length} classes create hongi (Section $section ke saath):',
              style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: toAdd.map((c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
            )).toList()),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: section,
              decoration: const InputDecoration(labelText: 'Section'),
              items: ['A','B','C','D'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setS(() => section = v!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: year,
              decoration: const InputDecoration(labelText: 'Academic Year'),
              items: ['2024-25','2025-26','2026-27'].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (v) => setS(() => year = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _bulkAddClasses(toAdd, section, year);
              },
              child: const Text('Create All'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bulkAddClasses(List<String> classNames, String section, String year) async {
    setState(() => _bulkAdding = true);
    int success = 0;
    int failed = 0;
    for (final className in classNames) {
      try {
        await apiService.post('/classes', {
          'class_name': className,
          'section': section,
          'academic_year': year,
          'stage': _stageForClass(className),
        });
        success++;
      } catch (e) {
        debugPrint('BULK ADD FAILED for $className: $e');
        failed++;
      }
    }
    await _fetchClasses();
    setState(() => _bulkAdding = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(failed == 0
          ? '$success classes added successfully!'
          : '$success added, $failed failed'),
        backgroundColor: failed == 0 ? Colors.green : Colors.orange,
      ));
    }
  }
}