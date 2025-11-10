import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _remedios = {};
  final TextEditingController _remedioController = TextEditingController();
  String _selectedConstancia = 'Única';
  TimeOfDay _selectedTime = TimeOfDay.now();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
    _initNotifications();
    _loadRemedios();
  }

  Future<void> _initNotifications() async {
    await _configureLocalTimeZone();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: (id, title, body, payload) async {});

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});

    // Request permissions
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // Attempt to set a sensible default for time zone. Avoid depending on
    // platform plugins here because some plugin versions fail to compile on
    // certain Windows dev environments/emulators. If a proper IANA timezone
    // name is required for precise scheduling, consider re-adding a
    // compatible plugin or enabling the native plugin support on the host.
    try {
      // Try to use the local system name if available from DateTime
      final name = DateTime.now().timeZoneName;
      // timeZoneName may be an abbreviation (e.g., 'BRT') which may not be
      // resolvable by the timezone package; fall back to UTC in that case.
      if (name.length > 3) {
        tz.setLocalLocation(tz.getLocation(name));
      } else {
        tz.setLocalLocation(tz.UTC);
      }
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _scheduleNotification(
      Map<String, dynamic> remedioData, DateTime scheduledDate) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final String title = 'Hora do Remédio!';
    final String body = 'Não se esqueça de tomar seu remédio: ${remedioData['nome']}';

    final timeParts = remedioData['hora'].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final tz.TZDateTime scheduledTZDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );

    // Configurar notificação com modo exato no Android 12+
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'remedio_channel_id',
        'Lembretes de Remédios',
        channelDescription: 'Notificações para lembrar de tomar remédios.',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        // Usar alarmManager para garantir entrega exata mesmo com app fechado
        fullScreenIntent: true,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Configurar notificação para repetir diariamente no mesmo horário
      matchDateTimeComponents: DateTimeComponents.time,
      // Garantir que a notificação seja entregue mesmo com o dispositivo em modo economia
      androidAllowWhileIdle: true,
    );
  }

  Future<void> _loadRemedios() async {
    _box = await Hive.openBox('remediosBox');
    final storedData = _box.get('remedios') ?? {};
    setState(() {
      _remedios = (storedData as Map).map((key, value) => MapEntry(
          DateTime.parse(key),
          List<Map<String, dynamic>>.from(
              value.map((item) => Map<String, dynamic>.from(item)))));
    });
  }

  Future<void> _saveRemedios() async {
    final dataToStore = _remedios.map(
      (key, value) => MapEntry(key.toIso8601String(), value),
    );
    await _box.put('remedios', dataToStore);
  }

  @override
  Widget build(BuildContext context) {
    final remediosForDay = _remedios[_selectedDate] ?? [];
    remediosForDay.sort((a, b) => a['hora'].compareTo(b['hora']));

    return Scaffold(
      backgroundColor: const Color(0xFFf6f2ff),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Agendador de Remédios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF491d8b),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: DatePicker(
              DateTime.now(),
              height: 100,
              initialSelectedDate: _selectedDate,
              selectionColor: const Color(0xFF007d79),
              selectedTextColor: Colors.white,
              dateTextStyle: TextStyle(color: Colors.grey[800]),
              dayTextStyle: TextStyle(color: Colors.grey[800]),
              monthTextStyle: TextStyle(color: Colors.grey[800]),
              onDateChange: (date) {
                setState(() {
                  _selectedDate = DateTime(date.year, date.month, date.day);
                });
              },
            ),
          ),
          Expanded(
            child: remediosForDay.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum remédio para este dia',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  )
                : ListView.builder(
                    itemCount: remediosForDay.length,
                    itemBuilder: (context, index) {
                      final remedio = remediosForDay[index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            remedio['nome'],
                            style: const TextStyle(
                              color: Color(0xFF491d8b), // Roxo 80
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            remedio['hora'],
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFFda1e28)),
                            onPressed: () {
                              setState(() {
                                remediosForDay.removeAt(index);
                                _saveRemedios();
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
        backgroundColor: const Color(0xFF8a3ffc),
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogAdicionar(context),
      ),
    );
  }

  void _mostrarDialogAdicionar(BuildContext context) {
    _remedioController.clear();
    _selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final hour = _selectedTime.hour.toString().padLeft(2, '0');
          final minute = _selectedTime.minute.toString().padLeft(2, '0');
          final formattedTime = '$hour:$minute';

          return AlertDialog(
            title: const Text(
              'Novo Remédio',
              style: TextStyle(
                color: Color(0xFF004144), // Marrequinha 80
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: const Color(0xFF007d79), // Marrequinha 60
                    ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _remedioController,
                      decoration: const InputDecoration(
                        hintText: 'Digite o nome do remédio',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text("Horário: $formattedTime"),
                      trailing: const Icon(
                        Icons.access_time,
                        color: Color(0xFF007d79), // Marrequinha 60
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (BuildContext context, Widget? child) {
                            return MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != _selectedTime) {
                          setStateModal(() {
                            _selectedTime = picked;
                          });
                        }
                      },
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
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF007d79), // Marrequinha 60
                ),
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007d79), // Marrequinha 60
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
                onPressed: () {
                  final text = _remedioController.text.trim();
                  if (text.isNotEmpty) {
                    final remedioData = {
                      'nome': text,
                      'hora': formattedTime,
                    };
                    _adicionarRemedioComConstancia(remedioData);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _adicionarRemedioComConstancia(Map<String, dynamic> remedioData) {
    setState(() {
      switch (_selectedConstancia) {
        case 'Única':
          _adicionarRemedio(_selectedDate, remedioData);
          break;
        case 'Diária':
          for (int i = 0; i < 365; i++) {
            final data = _selectedDate.add(Duration(days: i));
            _adicionarRemedio(data, remedioData);
          }
          break;
        case 'Semanal':
          for (int i = 0; i < 52; i++) {
            final data = _selectedDate.add(Duration(days: 7 * i));
            _adicionarRemedio(data, remedioData);
          }
          break;
        case 'Mensal':
          for (int i = 0; i < 12; i++) {
            final data = DateTime(
              _selectedDate.year,
              _selectedDate.month + i,
              _selectedDate.day,
            );
            _adicionarRemedio(data, remedioData);
          }
          break;
        case 'Dias específicos':
          _adicionarPorDiasEspecificos(remedioData);
          break;
      }
      _saveRemedios();
    });
  }

  void _adicionarPorDiasEspecificos(Map<String, dynamic> remedioData) {
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

    for (int i = 0; i < 365; i++) {
      final data = _selectedDate.add(Duration(days: i));
      final diaSemana = data.weekday;
      if (diasSelecionados.any((d) => diasMap[d] == diaSemana)) {
        _adicionarRemedio(data, remedioData);
      }
    }
  }

  void _adicionarRemedio(DateTime data, Map<String, dynamic> remedioData) {
    final dia = DateTime(data.year, data.month, data.day);
    _remedios.putIfAbsent(dia, () => []).add(remedioData);
    _scheduleNotification(remedioData, dia);
  }
}
