import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:monitoramento_saude_familiar/models/profile_model.dart';
import 'package:monitoramento_saude_familiar/views/widgets/Calendario_widget.dart';
import 'package:monitoramento_saude_familiar/views/widgets/Carrosel_slider_widget.dart';
import 'package:monitoramento_saude_familiar/views/pages/Dash_page.dart';
import 'package:monitoramento_saude_familiar/views/widgets/Item_widget.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true; // <-- AJUSTE 3.1: Variável de estado de loading
  DateTime _selectedDate = DateTime.now();
  Map<int, Map<DateTime, List<Map<String, dynamic>>>> _metricas = {};
  int _currentProfileIndex = 0;
  List<Profile> _profiles = [];
  final TextEditingController _metricaController = TextEditingController();
  String _selectedMetrica = 'Glicemia em Jejum';
  final List<String> _metricasOptions = [
    'Glicemia em Jejum',
    'Glicemia Pós Brandial',
    'Pressão Arterial',
    'Oxigenação e Pulso',
    'Temperatura',
    'Personalizado'
  ];
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
  late Box<Profile> _profilesBox;
  late Box<bool> _settingsBox;
  bool _shouldPromptMainUser = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    await _initNotifications();
    await _openBoxes();
    _loadProfiles();
    await _loadMetricas();

    // <-- AJUSTE 3.2: Desliga o loading quando tudo estiver pronto
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (_shouldPromptMainUser) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showMainUserRegistrationDialog();
          }
        });
      }
    }
  }

  Future<void> _openBoxes() async {
    _box = await Hive.openBox('metricasBox');
    _profilesBox = Hive.box<Profile>('profilesBox');
    _settingsBox = await Hive.openBox<bool>('settingsBox');
  }

  void _loadProfiles() {
    final profiles = _profilesBox.values.toList();
    final hasMainUser =
        _settingsBox.get('mainUserRegistered', defaultValue: false) ?? false;
    _shouldPromptMainUser = profiles.isEmpty && !hasMainUser;
    setState(() {
      _profiles = profiles;
    });
  }

  String? _validateRequiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validatePositiveInt(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }

  String? _validatePositiveDouble(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }

  double _parseToDouble(String value) =>
      double.parse(value.replaceAll(',', '.'));

  Future<void> _addProfile(Profile profile, {bool makePrimary = false}) async {
    setState(() {
      if (makePrimary) {
        _profiles.insert(0, profile);
        _currentProfileIndex = 0;
      } else {
        _profiles.add(profile);
      }
    });
    await _saveProfiles();
  }

  Future<void> _saveProfiles() async {
    await _profilesBox.clear();
    for (var profile in _profiles) {
      _profilesBox.add(profile);
    }
  }

  void _deleteProfile(int index) {
    setState(() {
      _metricas.remove(index);
      final newMetricas = <int, Map<DateTime, List<Map<String, dynamic>>>>{};
      _metricas.forEach((key, value) {
        if (key > index) {
          newMetricas[key - 1] = value;
        } else {
          newMetricas[key] = value;
        }
      });
      _metricas = newMetricas;

      _profiles.removeAt(index);
      _saveProfiles();
      _saveMetricas();
    });
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
    final String timeZoneName;
    try {
      timeZoneName = 'America/Sao_Paulo';
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _scheduleNotification(
      Map<String, dynamic> metricaData, DateTime scheduledDate) async {
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final String title = 'Hora de registrar a Métrica!';
    final String body =
        'Não se esqueça de registrar a métrica: ${metricaData['nome']}';

    final timeParts = metricaData['hora'].split(':');
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

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'metrica_channel_id',
        'Lembretes de Métricas',
        channelDescription: 'Notificações para lembrar de registrar métricas.',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
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
      matchDateTimeComponents: DateTimeComponents.time,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> _loadMetricas() async {
    final storedData = _box.get('metricas');
    if (storedData != null && storedData is Map) {
      if (storedData.keys.isNotEmpty &&
          int.tryParse(storedData.keys.first.toString()) == null) {
        // Old format, migrate to new format
        final Map<DateTime, List<Map<String, dynamic>>> oldMetrics =
            storedData.map((key, value) => MapEntry(
                DateTime.parse(key.toString()),
                List<Map<String, dynamic>>.from((value as List)
                    .map((item) => Map<String, dynamic>.from(item)))));
        setState(() {
          _metricas = {0: oldMetrics};
        });
        _saveMetricas();
      } else {
        // New format
        setState(() {
          _metricas = storedData.map((profileIndex, profileData) =>
              MapEntry(
                  int.parse(profileIndex.toString()),
                  (profileData as Map).map((date, metrics) => MapEntry(
                      DateTime.parse(date.toString()),
                      List<Map<String, dynamic>>.from((metrics as List)
                          .map((item) => Map<String, dynamic>.from(item)))))));
        });
      }
    }
  }

  Future<void> _saveMetricas() async {
    final dataToStore = _metricas.map((profileIndex, profileData) => MapEntry(
        profileIndex.toString(),
        profileData.map(
          (key, value) => MapEntry(key.toIso8601String(), value),
        )));
    await _box.put('metricas', dataToStore);
  }

  @override
  Widget build(BuildContext context) {
    final isAddProfilePage = _currentProfileIndex == _profiles.length;

    final metricsForProfile =
        !isAddProfilePage ? _metricas[_currentProfileIndex] ?? {} : {};
    final metricsForDay = metricsForProfile[
            DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
        [];

    final List<Widget> metricItems = isAddProfilePage
        ? []
        : [
            ...metricsForDay.map((metrica) {
              final Map<dynamic, dynamic>? rawValues =
                  metrica['valores'] as Map<dynamic, dynamic>?;
              final Map<String, dynamic>? valoresFormatados = rawValues == null
                  ? null
                  : rawValues.entries.fold<Map<String, dynamic>>(
                      {},
                      (acc, entry) {
                        acc[entry.key.toString()] = entry.value;
                        return acc;
                      },
                    );
              return Item(
                nome: metrica['nome'],
                status: (metrica['valores'] == null ||
                        (metrica['valores'] as Map).isEmpty)
                    ? 'Pendente'
                    : metrica['status'] ??
                        metrica['constancia'] ??
                        "Registrado",
                hora: metrica['hora'],
                valores: valoresFormatados,
                onValueSaved: (valores) {
                  setState(() {
                    metrica['valores'] = valores;
                    metrica['status'] =
                        _getMetricStatus(metrica['nome'], valores);
                    _saveMetricas();
                  });
                },
                onDelete: () {
                  _removerMetrica(_selectedDate, metrica);
                },
                onGraphTap: () {
                  _navigateToGraphPage(metrica['nome']);
                },
              );
            }).toList()
          ];

    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00D09E),
        title: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 24),
              Text(
                "MSF",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    height: 0.8),
              ),
            ],
          ),
        ),
      ),
      // <-- AJUSTE 3.3: Adiciona o ternário de loading
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D09E),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: isLargeScreen ? 180 : 160,
                        child: CarroselSlider(
                          profiles: _profiles,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentProfileIndex = index;
                            });
                          },
                          onAddProfile: () {
                            _showAddProfileDialog();
                          },
                          onDeleteProfile: (index) {
                            _deleteProfile(index);
                          },
                        ),
                      ),
                      Calendario(
                        onDateChange: (date) {
                          setState(() {
                            _selectedDate =
                                DateTime(date.year, date.month, date.day);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (isLargeScreen) {
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 3.5,
                              children: metricItems,
                            );
                          } else {
                            return Column(
                              children: metricItems,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      // <-- AJUSTE 1: Movido para dentro do Scaffold
      floatingActionButton: isAddProfilePage
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
              onPressed: () => _mostrarDialogAdicionar(context),
            ),
    );
  }

  void _mostrarDialogAdicionar(BuildContext context) {
    _metricaController.clear();
    _selectedTime = TimeOfDay.now();

    // Reseta os dias da semana selecionados ao abrir o dialog
    _diasSemanaSelecionados.updateAll((key, value) => false);
    _selectedConstancia = 'Única'; // Reseta a constância

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final hour = _selectedTime.hour.toString().padLeft(2, '0');
          final minute = _selectedTime.minute.toString().padLeft(2, '0');
          final formattedTime = '$hour:$minute';

          return AlertDialog(
            title: const Text(
              'Nova Métrica',
              style: TextStyle(
                color: Color(0xFF004144),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: const Color(0xFF007d79),
                    ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedMetrica,
                      decoration: const InputDecoration(
                        labelText: 'Métrica',
                        border: OutlineInputBorder(),
                      ),
                      items: _metricasOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateModal(() {
                          _selectedMetrica = newValue!;
                        });
                      },
                    ),
                    if (_selectedMetrica == 'Personalizado')
                      TextField(
                        controller: _metricaController,
                        decoration: const InputDecoration(
                          hintText: 'Digite o nome da métrica personalizada',
                        ),
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text("Horário: $formattedTime"),
                      trailing: const Icon(
                        Icons.access_time,
                        color: Color(0xFF007d79),
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
                  foregroundColor: const Color(0xFF007d79),
                ),
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007d79),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
                onPressed: () {
                  String metricaNome;
                  if (_selectedMetrica == 'Personalizado') {
                    metricaNome = _metricaController.text.trim();
                  } else {
                    metricaNome = _selectedMetrica;
                  }

                  if (metricaNome.isNotEmpty) {
                    final Map<String, dynamic> metricaData = {
                      'nome': metricaNome,
                      'hora': formattedTime,
                      'constancia': _selectedConstancia,
                      'status': 'Registrado',
                    };
                    // Chama a nova função otimizada
                    _adicionarMetricaComConstancia(metricaData);
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

  // <-- AJUSTE 2: As funções _adicionarMetricaComConstancia, 
  // _adicionarPorDiasEspecificos e _adicionarMetrica 
  // são substituídas por esta única função otimizada.

  Future<void> _adicionarMetricaComConstancia(
      Map<String, dynamic> metricaData) async {
    // (Opcional: Exibir um indicador de carregamento aqui)

    final int profileIndex = _currentProfileIndex;
    // Cria um novo mapa para guardar todas as métricas a serem adicionadas
    final Map<DateTime, List<Map<String, dynamic>>> newMetricsForProfile = {};
    final List<Future<void>> notificationFutures = [];

    // 2. Executa a lógica pesada de forma assíncrona para não travar a UI
    await Future(() {
      final diasMap = {
        'Seg': DateTime.monday,
        'Ter': DateTime.tuesday,
        'Qua': DateTime.wednesday,
        'Qui': DateTime.thursday,
        'Sex': DateTime.friday,
        'Sáb': DateTime.saturday,
        'Dom': DateTime.sunday,
      };

      final List<String> diasSelecionados = _diasSemanaSelecionados.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      switch (_selectedConstancia) {
        case 'Única':
          final dia = DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day);
          newMetricsForProfile.putIfAbsent(dia, () => []).add(metricaData);
          notificationFutures.add(_scheduleNotification(metricaData, dia));
          break;
        case 'Diária':
          for (int i = 0; i < 365; i++) {
            final data = _selectedDate.add(Duration(days: i));
            final dia = DateTime(data.year, data.month, data.day);
            final metrica = Map<String, dynamic>.from(metricaData);
            newMetricsForProfile.putIfAbsent(dia, () => []).add(metrica);
            notificationFutures.add(_scheduleNotification(metrica, dia));
          }
          break;
        case 'Semanal':
          for (int i = 0; i < 52; i++) {
            final data = _selectedDate.add(Duration(days: 7 * i));
            final dia = DateTime(data.year, data.month, data.day);
            final metrica = Map<String, dynamic>.from(metricaData);
            newMetricsForProfile.putIfAbsent(dia, () => []).add(metrica);
            notificationFutures.add(_scheduleNotification(metrica, dia));
          }
          break;
        case 'Mensal':
          for (int i = 0; i < 12; i++) {
            final data = DateTime(
                _selectedDate.year, _selectedDate.month + i, _selectedDate.day);
            final dia =
                DateTime(data.year, data.month, data.day); // Normaliza o dia
            final metrica = Map<String, dynamic>.from(metricaData);
            newMetricsForProfile.putIfAbsent(dia, () => []).add(metrica);
            notificationFutures.add(_scheduleNotification(metrica, dia));
          }
          break;
        case 'Dias específicos':
          if (diasSelecionados.isEmpty) break;
          for (int i = 0; i < 365; i++) {
            final data = _selectedDate.add(Duration(days: i));
            final diaSemana = data.weekday;
            if (diasSelecionados.any((d) => diasMap[d] == diaSemana)) {
              final dia = DateTime(data.year, data.month, data.day);
              final metrica = Map<String, dynamic>.from(metricaData);
              newMetricsForProfile.putIfAbsent(dia, () => []).add(metrica);
              notificationFutures.add(_scheduleNotification(metrica, dia));
            }
          }
          break;
      }
    });

    // 3. Atualiza o estado (UI) APENAS UMA VEZ
    setState(() {
      _metricas.putIfAbsent(profileIndex, () => {});
      newMetricsForProfile.forEach((dia, metricasDia) {
        _metricas[profileIndex]!.putIfAbsent(dia, () => []).addAll(metricasDia);
      });
    });

    // 4. Salva no banco de dados (Hive) APENAS UMA VEZ
    await _saveMetricas();

    // 5. Agenda todas as notificações
    await Future.wait(notificationFutures);

    // (Opcional: Esconder o indicador de carregamento aqui)
  }

  void _removerMetrica(DateTime data, Map<String, dynamic> metricaParaRemover) {
    setState(() {
      final dia = DateTime(data.year, data.month, data.day);
      if (_metricas.containsKey(_currentProfileIndex) &&
          _metricas[_currentProfileIndex]!.containsKey(dia)) {
        _metricas[_currentProfileIndex]![dia]!.removeWhere((metrica) {
          return metrica['nome'] == metricaParaRemover['nome'] &&
              metrica['hora'] == metricaParaRemover['hora'];
        });
        if (_metricas[_currentProfileIndex]![dia]!.isEmpty) {
          _metricas[_currentProfileIndex]!.remove(dia);
        }
        _saveMetricas();
      }
    });
  }

  void _navigateToGraphPage(String metricName) {
    final profileMetrics = _metricas[_currentProfileIndex];
    if (profileMetrics == null) return;

    final List<Map<String, dynamic>> metricHistory = [];
    profileMetrics.forEach((date, metrics) {
      for (var metric in metrics) {
        if (metric['nome'] == metricName && metric['valores'] != null) {
          metricHistory.add({
            'date': date,
            'valores': metric['valores'],
          });
        }
      }
    });

    metricHistory
        .sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Dash_page(
          metricName: metricName,
          metricData: metricHistory,
        ),
      ),
    );
  }

  void _showAddProfileDialog() {
    final nomeController = TextEditingController();
    final idadeController = TextEditingController();
    final pesoController = TextEditingController();
    final alturaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Novo Perfil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      _validateRequiredText(value, 'Informe o nome'),
                ),
                TextFormField(
                  controller: idadeController,
                  decoration: const InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validatePositiveInt(value, 'Informe uma idade válida'),
                ),
                TextFormField(
                  controller: pesoController,
                  decoration: const InputDecoration(labelText: 'Peso (KG)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
                  ],
                  validator: (value) =>
                      _validatePositiveDouble(value, 'Informe um peso válido'),
                ),
                TextFormField(
                  controller: alturaController,
                  decoration:
                      const InputDecoration(labelText: 'Altura (metros)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
                  ],
                  validator: (value) =>
                      _validatePositiveDouble(value, 'Informe uma altura válida'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final profile = Profile(
                  nome: nomeController.text.trim(),
                  idade: int.parse(idadeController.text),
                  peso: _parseToDouble(pesoController.text),
                  altura: _parseToDouble(alturaController.text),
                );
                await _addProfile(profile);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showMainUserRegistrationDialog() {
    _shouldPromptMainUser = false;
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final idadeController = TextEditingController();
    final pesoController = TextEditingController();
    final alturaController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bem-vindo!'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cadastre o usuário principal para começar a monitorar.',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) =>
                        _validateRequiredText(value, 'Informe o nome'),
                  ),
                  TextFormField(
                    controller: idadeController,
                    decoration: const InputDecoration(labelText: 'Idade'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) =>
                        _validatePositiveInt(value, 'Informe uma idade válida'),
                  ),
                  TextFormField(
                    controller: pesoController,
                    decoration: const InputDecoration(labelText: 'Peso (KG)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
                    ],
                    validator: (value) =>
                        _validatePositiveDouble(value, 'Informe um peso válido'),
                  ),
                  TextFormField(
                    controller: alturaController,
                    decoration:
                        const InputDecoration(labelText: 'Altura (metros)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
                    ],
                    validator: (value) => _validatePositiveDouble(
                        value, 'Informe uma altura válida'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final profile = Profile(
                  nome: nomeController.text.trim(),
                  idade: int.parse(idadeController.text),
                  peso: _parseToDouble(pesoController.text),
                  altura: _parseToDouble(alturaController.text),
                );
                await _addProfile(profile, makePrimary: true);
                await _settingsBox.put('mainUserRegistered', true);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _metricaController.dispose();
    super.dispose();
  }

  String _getMetricStatus(String metricName, Map<String, String> values) {
    final value =
        double.tryParse(values['valor']?.replaceAll(',', '.') ?? '0') ?? 0;
    final value1 =
        double.tryParse(values['valor1']?.replaceAll(',', '.') ?? '0') ?? 0;
    final value2 =
        double.tryParse(values['valor2']?.replaceAll(',', '.') ?? '0') ?? 0;

    switch (metricName) {
      case 'Glicemia em Jejum':
        if (value > 99) return 'Alto';
        if (value >= 70 && value <= 99) return 'Normal';
        return 'Baixo';
      case 'Glicemia Pós Brandial':
        if (value > 140) return 'Alto';
        if (value >= 70 && value <= 140) return 'Normal';
        return 'Baixo';
      case 'Pressão Arterial':
        if (value1 > 120 || value2 > 80) return 'Alto';
        if ((value1 >= 90 && value1 <= 120) &&
            (value2 >= 60 && value2 <= 80)) {
          return 'Normal';
        }
        return 'Baixo';
      case 'Oxigenação e Pulso':
        if (value1 > 100 || value2 > 100) return 'Alto';
        if ((value1 >= 95 && value1 <= 100) &&
            (value2 >= 60 && value2 <= 100)) {
          return 'Normal';
        }
        return 'Baixo';
      case 'Temperatura':
        if (value > 37.2) return 'Alto';
        if (value >= 36.5 && value <= 37.2) return 'Normal';
        return 'Baixo';
      default:
        return 'Preenchido';
    }
  }
}