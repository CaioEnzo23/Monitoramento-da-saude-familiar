import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<String>> _tasks = {};
  final TextEditingController _taskController = TextEditingController();
  String _selectedConstancia = 'Única';

  final List<String> _constancias = [
    'Única',
    'Diária',
    'Semanal',
    'Mensal',
    'Dias específicos'
  ];

  final Map<String, bool> _diasSemanaSelecionados = {
    'Seg': false,
    'Ter': false,
    'Qua': false,
    'Qui': false,
    'Sex': false,
    'Sáb': false,
    'Dom': false,
  };

  late Box _box;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _box = Hive.box('tasksBox');
    final storedData = _box.get('tasks') ?? {};
    setState(() {
      _tasks = (storedData as Map)
          .map((key, value) => MapEntry(DateTime.parse(key), List<String>.from(value)));
    });
  }

  Future<void> _saveTasks() async {
    final dataToStore = _tasks.map(
      (key, value) => MapEntry(key.toIso8601String(), value),
    );
    await _box.put('tasks', dataToStore);
  }

  @override
  Widget build(BuildContext context) {
    final tasksForDay = _tasks[_selectedDate] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendador de Tarefas'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: DatePicker(
              DateTime.now(),
              height: 100,
              initialSelectedDate: _selectedDate,
              selectionColor: Colors.black,
              selectedTextColor: Colors.white,
              onDateChange: (date) {
                setState(() {
                  _selectedDate = DateTime(date.year, date.month, date.day);
                });
              },
            ),
          ),
          Expanded(
            child: tasksForDay.isEmpty
                ? const Center(child: Text('Nenhuma tarefa para este dia'))
                : ListView.builder(
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDay[index];
                      return Card(
                        child: ListTile(
                          title: Text(task),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                tasksForDay.removeAt(index);
                                _saveTasks();
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogAdicionar(context),
      ),
    );
  }

  void _mostrarDialogAdicionar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => AlertDialog(
          title: const Text('Nova Tarefa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'Digite o nome da tarefa',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedConstancia,
                  decoration: const InputDecoration(
                    labelText: 'Constância',
                    border: OutlineInputBorder(),
                  ),
                  items: _constancias.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) {
                    setStateModal(() {
                      _selectedConstancia = value!;
                    });
                  },
                ),
                if (_selectedConstancia == 'Dias específicos') ...[
                  const SizedBox(height: 12),
                  const Text('Selecione os dias da semana:'),
                  Wrap(
                    spacing: 8,
                    children: _diasSemanaSelecionados.keys.map((dia) {
                      return FilterChip(
                        label: Text(dia),
                        selected: _diasSemanaSelecionados[dia]!,
                        selectedColor: Colors.black,
                        checkmarkColor: Colors.white,
                        onSelected: (bool selected) {
                          setStateModal(() {
                            _diasSemanaSelecionados[dia] = selected;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                _taskController.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Salvar'),
              onPressed: () {
                final text = _taskController.text.trim();
                if (text.isNotEmpty) {
                  _adicionarTarefaComConstancia(text);
                }
                _taskController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarTarefaComConstancia(String titulo) {
    setState(() {
      switch (_selectedConstancia) {
        case 'Única':
          _adicionarTarefa(_selectedDate, titulo);
          break;
        case 'Diária':
          for (int i = 0; i < 7; i++) {
            final data = _selectedDate.add(Duration(days: i));
            _adicionarTarefa(data, titulo);
          }
          break;
        case 'Semanal':
          for (int i = 0; i < 4; i++) {
            final data = _selectedDate.add(Duration(days: 7 * i));
            _adicionarTarefa(data, titulo);
          }
          break;
        case 'Mensal':
          for (int i = 0; i < 3; i++) {
            final data = DateTime(
              _selectedDate.year,
              _selectedDate.month + i,
              _selectedDate.day,
            );
            _adicionarTarefa(data, titulo);
          }
          break;
        case 'Dias específicos':
          _adicionarPorDiasEspecificos(titulo);
          break;
      }
      _saveTasks();
    });
  }

  void _adicionarPorDiasEspecificos(String titulo) {
    final diasSelecionados = _diasSemanaSelecionados.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (diasSelecionados.isEmpty) return;

    // Mapeamento: nome -> número (segunda = 1, domingo = 7)
    final diasMap = {
      'Seg': DateTime.monday,
      'Ter': DateTime.tuesday,
      'Qua': DateTime.wednesday,
      'Qui': DateTime.thursday,
      'Sex': DateTime.friday,
      'Sáb': DateTime.saturday,
      'Dom': DateTime.sunday,
    };

    for (int i = 0; i < 30; i++) {
      final data = _selectedDate.add(Duration(days: i));
      final diaSemana = data.weekday;
      if (diasSelecionados.any((d) => diasMap[d] == diaSemana)) {
        _adicionarTarefa(data, titulo);
      }
    }
  }

  void _adicionarTarefa(DateTime data, String titulo) {
    final dia = DateTime(data.year, data.month, data.day);
    _tasks.putIfAbsent(dia, () => []).add(titulo);
  }
}
