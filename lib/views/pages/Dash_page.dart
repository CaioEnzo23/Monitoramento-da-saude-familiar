// Force recompilation
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:monitoramento_saude_familiar/theme/app_colors.dart'; // Não foi usado, removi o import
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Dash_page extends StatefulWidget {
  final String metricName;
  final List<Map<String, dynamic>> metricData;

  const Dash_page({
    super.key,
    required this.metricName,
    required this.metricData,
  });

  @override
  State<Dash_page> createState() => _Dash_pageState();
}

class _Dash_pageState extends State<Dash_page> {
  List<List<FlSpot>>? _monthlyMetricData;
  List<List<FlSpot>>? _monthlyMetricData2;
  bool _isDualValue = false;
  int _currentMonthIndex = 0;
  late final List<String> _monthsNames;
  double _overallMinY = 0;
  double _overallMaxY = 5;
  double _lastMeasurement = 0;
  double _lastMeasurement2 = 0; // Esta variável agora será populada
  Map<String, int> _riskCounts1 = {'Baixo': 0, 'Normal': 0, 'Alto': 0};
  Map<String, int> _riskCounts2 = {'Baixo': 0, 'Normal': 0, 'Alto': 0};

  @override
  void initState() {
    super.initState();
    _isDualValue = widget.metricName == 'Pressão Arterial' ||
        widget.metricName == 'Oxigenação e Pulso';
    _monthsNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    _processMetricData();
  }

  String _getRiskCategory(double value) {
    switch (widget.metricName) {
      case 'Glicemia em Jejum':
        if (value < 70) return 'Baixo';
        if (value <= 99) return 'Normal';
        return 'Alto';
      // Ajuste para refletir o gauge (Pressão Sistólica)
      case 'Pressão Arterial':
        if (value < 90) return 'Baixo';
        if (value <= 120) return 'Normal';
        // Amarelo (120-139) ainda conta como 'Alto' no histograma por simplicidade
        return 'Alto';
      // Ajuste para refletir o gauge (O2)
      case 'Oxigenação e Pulso':
        if (value < 95) return 'Baixo'; // 90-94 é amarelo, < 90 vermelho
        return 'Normal'; // 95-100 é verde
      case 'Temperatura': // Renomeado para 'Temperatura'
        if (value < 36.5) return 'Baixo';
        if (value <= 37.2) return 'Normal';
        return 'Alto';
      // Adicionado
      case 'Glicemia Pós Brandial':
        if (value < 70) return 'Baixo';
        if (value <= 140) return 'Normal';
        return 'Alto';
      default:
        return 'Normal';
    }
  }

  String _getRiskCategory2(double value) {
    switch (widget.metricName) {
      case 'Pressão Arterial': // Diastólica
        if (value < 60) return 'Baixo';
        if (value <= 80) return 'Normal';
        return 'Alto';
      case 'Oxigenação e Pulso': // Pulso (BPM)
        if (value < 60) return 'Baixo';
        if (value <= 100) return 'Normal';
        return 'Alto';
      default:
        return 'Normal';
    }
  }

  void _calculateRiskCounts() {
    final counts1 = {'Baixo': 0, 'Normal': 0, 'Alto': 0};
    final counts2 = {'Baixo': 0, 'Normal': 0, 'Alto': 0};

    for (var dataPoint in widget.metricData) {
      final values = Map<String, String>.from(dataPoint['valores'] as Map);
      if (values.isEmpty) continue;

      if (_isDualValue) {
        double value1, value2;
        if (widget.metricName == 'Pressão Arterial') {
          value1 = double.tryParse(values['sistolica']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
          value2 = double.tryParse(values['diastolica']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
        } else { // Oxigenação e Pulso
          value1 = double.tryParse(values['spo2']?.replaceAll(',', '.') ?? values['valor1']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
          value2 = double.tryParse(values['bpm']?.replaceAll(',', '.') ?? values['valor2']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
        }

        if (value1 != 0.0) {
          final category1 = _getRiskCategory(value1);
          counts1[category1] = (counts1[category1] ?? 0) + 1;
        }
        if (value2 != 0.0) {
          final category2 = _getRiskCategory2(value2);
          counts2[category2] = (counts2[category2] ?? 0) + 1;
        }
      } else {
        // Correção para 'Temperatura'
        final key = values.keys.firstWhere((k) => k == 'valor' || k.isNotEmpty, orElse: () => '');
        if (key.isEmpty) continue;

        final valueToTest = double.tryParse(values[key]!.replaceAll(',', '.')) ?? 0.0;
        if (valueToTest != 0.0) {
          final category = _getRiskCategory(valueToTest);
          counts1[category] = (counts1[category] ?? 0) + 1;
        }
      }
    }

    setState(() {
      _riskCounts1 = counts1;
      _riskCounts2 = counts2;
    });
  }


  void _processMetricData() {
    if (widget.metricData.isEmpty) {
      setState(() {
        _monthlyMetricData = List.generate(12, (_) => []);
        if (_isDualValue) {
          _monthlyMetricData2 = List.generate(12, (_) => []);
        }
      });
      return;
    }

    _calculateRiskCounts();

    double minY = double.maxFinite;
    double maxY = -double.maxFinite;

    final monthlyData = List.generate(12, (_) => <FlSpot>[]);
    final monthlyData2 =
        _isDualValue ? List.generate(12, (_) => <FlSpot>[]) : null;
    
    // Garantir que a última medição seja a mais recente
    // A lista já vem ordenada da HomePage
    if (widget.metricData.isNotEmpty) {
      final lastDataPoint = widget.metricData.last;
      final values = Map<String, String>.from(lastDataPoint['valores'] as Map);

      if (values.isNotEmpty) {
         if (_isDualValue) {
            if (widget.metricName == 'Pressão Arterial') {
              _lastMeasurement = double.tryParse(values['sistolica']?.replaceAll(',', '.') ?? values['valor1']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
              _lastMeasurement2 = double.tryParse(values['diastolica']?.replaceAll(',', '.') ?? values['valor2']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
            } else { // Oxigenação e Pulso
              _lastMeasurement = double.tryParse(values['spo2']?.replaceAll(',', '.') ?? values['valor1']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
              _lastMeasurement2 = double.tryParse(values['bpm']?.replaceAll(',', '.') ?? values['valor2']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
            }
         } else {
            // Lógica para valor único
            final key = values.keys.firstWhere((k) => k == 'valor' || k.isNotEmpty, orElse: () => '');
            if (key.isNotEmpty) {
              _lastMeasurement = double.tryParse(values[key]!.replaceAll(',', '.')) ?? 0.0;
            }
         }
      }
    }


    for (var dataPoint in widget.metricData) {
      final date = dataPoint['date'] as DateTime;
      final values = Map<String, String>.from(dataPoint['valores'] as Map);

      if (values.isEmpty) continue;

      if (_isDualValue && values.length >= 2) {
        double value1, value2;
        if (widget.metricName == 'Pressão Arterial') {
          value1 = double.tryParse(values['sistolica']?.replaceAll(',', '.') ?? values['valor1']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
          value2 = double.tryParse(values['diastolica']?.replaceAll(',', '.') ?? values['valor2']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
        } else { // Oxigenação e Pulso
          value1 = double.tryParse(values['spo2']?.replaceAll(',', '.') ?? values['valor1']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
          value2 = double.tryParse(values['bpm']?.replaceAll(',', '.') ?? values['valor2']?.replaceAll(',', '.') ?? '0.0') ?? 0.0;
        }

        if (value1 < minY) minY = value1;
        if (value1 > maxY) maxY = value1;
        if (value2 < minY) minY = value2;
        if (value2 > maxY) maxY = value2;

        monthlyData[date.month - 1].add(FlSpot(date.day.toDouble(), value1));
        monthlyData2![date.month - 1].add(FlSpot(date.day.toDouble(), value2));
      } else if (!_isDualValue) {
        // Correção para 'Temperatura' e outros valores únicos
        final key = values.keys.firstWhere((k) => k == 'valor' || k.isNotEmpty, orElse: () => '');
         if (key.isEmpty) continue;
        
        final valueStr = values[key]!;
        final value = double.tryParse(valueStr.replaceAll(',', '.')) ?? 0.0;

        if (value < minY) minY = value;
        if (value > maxY) maxY = value;

        monthlyData[date.month - 1].add(FlSpot(date.day.toDouble(), value));
      }
    }

    if (minY == double.maxFinite) {
      minY = 0;
      maxY = 5; // Default range if no data
    }

    setState(() {
      _monthlyMetricData = monthlyData;
      if (_isDualValue) {
        _monthlyMetricData2 = monthlyData2;
      }
      _overallMinY = minY;
      _overallMaxY = maxY;
      if (widget.metricData.isNotEmpty) {
        final lastDate = widget.metricData.last['date'] as DateTime;
        _currentMonthIndex = lastDate.month - 1;
      } else {
        _currentMonthIndex = DateTime.now().month - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Gráfico de ${widget.metricName}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00D09E),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Histórico de ${widget.metricName}',
                        style: const TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildMonthSelector(),
                      const SizedBox(height: 18),
                      AspectRatio(
                        aspectRatio: 1.4,
                        child: _monthlyMetricData == null
                            ? const Center(child: CircularProgressIndicator())
                            : _monthlyMetricData![_currentMonthIndex].isEmpty
                                ? const Center(
                                    child: Text('Nenhum dado para este mês.'))
                                : LineChart(
                                    _mainChartData(),
                                    key: ValueKey<int>(_currentMonthIndex),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHistogramCard(),
              const SizedBox(height: 20),

              // Lógica para mostrar 1 ou 2 gauges
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Medidor da Última Métrica',
                        style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _isDualValue
                          ? Row(
                              children: [
                                Expanded(child: _buildGaugeWidget(isPrimary: true)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildGaugeWidget(isPrimary: false)),
                              ],
                            )
                          : _buildGaugeWidget(isPrimary: true),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  String _getHistogramTitle({required bool isPrimary}) {
    if (widget.metricName == 'Pressão Arterial') {
      return isPrimary ? 'Sistólica' : 'Diastólica';
    } else if (widget.metricName == 'Oxigenação e Pulso') {
      return isPrimary ? 'O₂' : 'Pulso';
    }
    return 'Resumo de Classificação';
  }

  Widget _buildHistogramCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Resumo de Classificação',
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isDualValue) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(const Color(0xFF007d79),
                      _getHistogramTitle(isPrimary: true)),
                  const SizedBox(width: 16),
                  _buildLegendItem(const Color(0xFF8a3ffc),
                      _getHistogramTitle(isPrimary: false)),
                ],
              ),
            ],
            const SizedBox(height: 18),
            AspectRatio(
              aspectRatio: 1.7,
              child: _buildHistogram(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildHistogram() {
    final counts1 = _riskCounts1;
    final counts2 = _riskCounts2;

    double maxY = 0;
    if (_isDualValue) {
      final max1 = (counts1.values.isNotEmpty
              ? counts1.values.reduce((a, b) => a > b ? a : b)
              : 0)
          .toDouble();
      final max2 = (counts2.values.isNotEmpty
              ? counts2.values.reduce((a, b) => a > b ? a : b)
              : 0)
          .toDouble();
      maxY = (max1 > max2 ? max1 : max2);
    } else {
      maxY = (counts1.values.isNotEmpty
              ? counts1.values.reduce((a, b) => a > b ? a : b)
              : 0)
          .toDouble();
    }

    if (maxY == 0) {
      maxY = 5;
    } else {
      maxY *= 1.2;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black.withAlpha(200),
            )),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Baixo';
                    break;
                  case 1:
                    text = 'Normal';
                    break;
                  case 2:
                    text = 'Alto';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                    axisSide: meta.axisSide, child: Text(text, style: style));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _isDualValue
            ? [
                _buildBarGroupData(0, counts1['Baixo']?.toDouble() ?? 0,
                    y2: counts2['Baixo']?.toDouble() ?? 0),
                _buildBarGroupData(1, counts1['Normal']?.toDouble() ?? 0,
                    y2: counts2['Normal']?.toDouble() ?? 0),
                _buildBarGroupData(2, counts1['Alto']?.toDouble() ?? 0,
                    y2: counts2['Alto']?.toDouble() ?? 0),
              ]
            : [
                _buildBarGroupData(0, counts1['Baixo']?.toDouble() ?? 0,
                    color: Colors.red.shade300), // Baixo
                _buildBarGroupData(1, counts1['Normal']?.toDouble() ?? 0,
                    color: Colors.green), // Normal
                _buildBarGroupData(2, counts1['Alto']?.toDouble() ?? 0,
                    color: Colors.red), // Alto
              ],
        gridData: FlGridData(show: false),
      ),
    );
  }

  BarChartGroupData _buildBarGroupData(int x, double y,
      {double? y2, Color? color}) {
    const width = 16.0;
    if (y2 != null) {
      // Dual value
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: const Color(0xFF007d79),
            width: width,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: y2,
            color: const Color(0xFF8a3ffc),
            width: width,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    } else {
      // Single value
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: color,
            width: 22,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }
  }

  Widget _buildMonthSelector() {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _canGoPrevious ? _previousMonth : null,
              icon: const Icon(Icons.navigate_before_rounded),
            ),
          ),
        ),
        SizedBox(
          width: 92,
          child: Text(
            _monthsNames[_currentMonthIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8a3ffc),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _canGoNext ? _nextMonth : null,
              icon: const Icon(Icons.navigate_next_rounded),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _mainChartData() {
    double minY = _overallMinY;
    double maxY = _overallMaxY;

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    } else {
      final padding = (maxY - minY) * 0.1;
      minY -= padding;
      maxY += padding;
    }

    final List<LineChartBarData> lineBars = [
      LineChartBarData(
        spots: _monthlyMetricData![_currentMonthIndex],
        isCurved: true,
        curveSmoothness: 0.3,
        gradient: const LinearGradient(
          colors: [Color(0xFF007d79), Color(0xFF009d9a)],
        ),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9ef0f0).withOpacity(0.3),
              const Color(0xFF9ef0f0).withOpacity(0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];

    if (_isDualValue &&
        _monthlyMetricData2 != null &&
        _monthlyMetricData2![_currentMonthIndex].isNotEmpty) {
      lineBars.add(
        LineChartBarData(
          spots: _monthlyMetricData2![_currentMonthIndex],
          isCurved: true,
          curveSmoothness: 0.3,
          gradient: const LinearGradient(
            colors: [Color(0xFF8a3ffc), Color(0xFFbe95ff)],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFd4bbff).withOpacity(0.3),
                const Color(0xFFd4bbff).withOpacity(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }

    return LineChartData(
      clipData: const FlClipData.all(),
      minY: minY,
      maxY: maxY,
      minX: 1,
      maxX: 31,
      lineBarsData: lineBars,
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY > minY) ? (maxY - minY) / 4 : 1,
        getDrawingHorizontalLine: _horizontalGridLines,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value == minY) return Container();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(meta.formattedValue),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text(
            'Dia do mês',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          axisNameSize: 40,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: 5,
            getTitlesWidget: _bottomTitles,
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: _tooltipData(context),
      ),
    );
  }

  bool get _canGoNext => _currentMonthIndex < 11;
  bool get _canGoPrevious => _currentMonthIndex > 0;

  void _previousMonth() {
    if (_canGoPrevious) setState(() => _currentMonthIndex--);
  }

  void _nextMonth() {
    if (_canGoNext) setState(() => _currentMonthIndex++);
  }

  FlLine _horizontalGridLines(double value) {
    return FlLine(
      color: Colors.grey.withOpacity(0.2),
      strokeWidth: 0.5,
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final day = value.toInt();

    if (day == 31) {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        day.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  LineTouchTooltipData _tooltipData(BuildContext context) {
    return LineTouchTooltipData(
      tooltipBgColor: Colors.black.withAlpha(200),
      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
        if (touchedBarSpots.isEmpty) {
          return [];
        }

        // ---- Lógica para Gráficos de Linha Dupla ----
        if (_isDualValue) {
          final day = touchedBarSpots.first.x.toInt();
          
          // Cria uma lista de tooltips, um para cada linha, para que a biblioteca os organize
          return touchedBarSpots.map((barSpot) {
            String label;
            if (widget.metricName == 'Pressão Arterial') {
              label = barSpot.barIndex == 0 ? 'Sistólica' : 'Diastólica';
            } else { // Oxigenação e Pulso
              label = barSpot.barIndex == 0 ? 'O₂' : 'Pulso';
            }

            final value = barSpot.y.toStringAsFixed(1);
            final barData = barSpot.bar;
            final color = barData.gradient?.colors.first ?? barData.color ?? Colors.white;

            return LineTooltipItem(
              'Dia $day\n$label: $value',
              TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            );
          }).toList();
        }

        // ---- Lógica para Gráficos de Linha Simples ----
        return touchedBarSpots.map((barSpot) {
          final day = barSpot.x.toInt();
          final value = barSpot.y;
          return LineTooltipItem(
            'Dia $day: ${value.toStringAsFixed(1)}',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          );
        }).toList();
      },
    );
  }

  // <-- FUNÇÃO ATUALIZADA -->
  Widget _buildGaugeWidget({required bool isPrimary}) {
    String title;
    double value;
    double min, max;
    String metricKey; // Chave para buscar os ranges corretos
    String unit;

    if (isPrimary) {
      value = _lastMeasurement;
      metricKey = widget.metricName; // Usa o nome principal da métrica

      // Define títulos, unidades e limites para os medidores PRIMÁRIOS
      if (widget.metricName == 'Pressão Arterial') {
        title = 'Sistólica';
        unit = 'mmHg';
        min = 0; max = 200;
      } else if (widget.metricName == 'Oxigenação e Pulso') {
        title = 'Oxigenação (O₂)';
        unit = '%';
        min = 80; max = 100; // O2 não precisa de 0-200
      } else if (widget.metricName == 'Glicemia em Jejum') {
        title = 'Glicemia em Jejum';
        unit = 'mg/dL';
        min = 40; max = 200;
      } 
      // <-- AJUSTE AQUI -->
      else if (widget.metricName == 'Glicemia Pós Brandial') {
        title = 'Glicemia Pós Brandial';
        unit = 'mg/dL';
        min = 40; max = 250; // Limite maior
      } 
      // <-- FIM DO AJUSTE -->
      else if (widget.metricName == 'Temperatura') { 
        title = 'Temperatura';
        unit = '°C';
        min = 34; max = 42;
      } else {
        // Fallback
        title = widget.metricName; // Usa o nome da métrica como fallback
        unit = '';
        min = 0; max = 200;
      }
    } else {
      // Lógica para medidores SECUNDÁRIOS (só será chamado se _isDualValue = true)
      value = _lastMeasurement2;
      if (widget.metricName == 'Pressão Arterial') {
        title = 'Diastólica';
        unit = 'mmHg';
        min = 0; max = 150; // Limite menor para diastólica
        metricKey = 'Pressão Arterial_Diastolica'; // Chave customizada
      } else { // Oxigenação e Pulso
        title = 'Pulso (BPM)';
        unit = 'bpm';
        min = 40; max = 180; // Limite para pulso
        metricKey = 'Oxigenação e Pulso_Pulso'; // Chave customizada
      }
    }

    return SfRadialGauge(
      title: GaugeTitle(
        text: title, // Título dinâmico
        textStyle: TextStyle(
            fontSize: _isDualValue ? 13.0 : 20.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF424242)),
      ),
      axes: <RadialAxis>[
        RadialAxis(
          minimum: min, // Mínimo dinâmico
          maximum: max, // Máximo dinâmico
          ranges: _getGaugeRanges(metricKey), // Ranges dinâmicos
          pointers: <GaugePointer>[
            NeedlePointer(
              value: value, // Valor dinâmico
              enableAnimation: true,
              animationDuration: 800,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '${value.toStringAsFixed(1)} $unit', // Valor e unidade dinâmicos
                style: TextStyle(
                    fontSize: _isDualValue ? 12.0 : 22.0,
                    fontWeight: FontWeight.bold),
              ),
              angle: 90,
              positionFactor: 0.7,
            )
          ],
        )
      ],
    );
  }

  // <-- FUNÇÃO ATUALIZADA -->
  List<GaugeRange> _getGaugeRanges(String metricName) {
    // Usando as faixas da sua nova lógica
    switch (metricName) {
      // 1. Glicemia em Jejum
      case 'Glicemia em Jejum':
        return <GaugeRange>[
          GaugeRange(startValue: 40, endValue: 70, color: Colors.red.shade300), // < 70
          GaugeRange(startValue: 70, endValue: 100, color: Colors.green), // 70-99
          GaugeRange(startValue: 100, endValue: 126, color: Colors.yellow), // 100-125
          GaugeRange(startValue: 126, endValue: 200, color: Colors.red), // > 125
        ];

      // 2. Glicemia Pós Brandial
      case 'Glicemia Pós Brandial':
        return <GaugeRange>[
          GaugeRange(startValue: 40, endValue: 70, color: Colors.red.shade300), // < 70
          GaugeRange(startValue: 70, endValue: 141, color: Colors.green), // 70-140
          GaugeRange(startValue: 141, endValue: 200, color: Colors.yellow), // 141-199
          GaugeRange(startValue: 200, endValue: 250, color: Colors.red), // > 199
        ];

      // 3. Pressão Arterial (Sistólica)
      case 'Pressão Arterial':
        return <GaugeRange>[
          GaugeRange(startValue: 0, endValue: 90, color: Colors.red.shade300), // < 90
          GaugeRange(startValue: 90, endValue: 121, color: Colors.green), // 90-120
          GaugeRange(startValue: 121, endValue: 140, color: Colors.yellow), // 121-139
          GaugeRange(startValue: 140, endValue: 200, color: Colors.red), // > 139
        ];

      // 3. Pressão Arterial (Diastólica)
      case 'Pressão Arterial_Diastolica':
        return <GaugeRange>[
          GaugeRange(startValue: 0, endValue: 60, color: Colors.red.shade300), // < 60
          GaugeRange(startValue: 60, endValue: 81, color: Colors.green), // 60-80
          GaugeRange(startValue: 81, endValue: 90, color: Colors.yellow), // 81-89
          GaugeRange(startValue: 90, endValue: 150, color: Colors.red), // > 89
        ];

      // 4. Oxigenação (O2)
      case 'Oxigenação e Pulso':
        return <GaugeRange>[
          GaugeRange(startValue: 80, endValue: 90, color: Colors.red), // < 90
          GaugeRange(startValue: 90, endValue: 95, color: Colors.yellow), // 90-94
          GaugeRange(startValue: 95, endValue: 100, color: Colors.green), // 95-100
        ];

      // 4. Pulso (BPM)
      case 'Oxigenação e Pulso_Pulso':
        return <GaugeRange>[
          GaugeRange(startValue: 40, endValue: 60, color: Colors.red.shade300), // < 60
          GaugeRange(startValue: 60, endValue: 100, color: Colors.green),
          GaugeRange(startValue: 100, endValue: 180, color: Colors.red), // > 100
        ];

      // 5. Temperatura
      case 'Temperatura':
        return <GaugeRange>[
          GaugeRange(startValue: 34, endValue: 35.0, color: Colors.red.shade300), // < 35.0
          GaugeRange(startValue: 35.0, endValue: 36.5, color: Colors.yellow.shade300), // 35.0-36.4
          GaugeRange(startValue: 36.5, endValue: 37.3, color: Colors.green), // 36.5-37.2
          GaugeRange(startValue: 37.3, endValue: 38.0, color: Colors.yellow), // 37.3-37.9
          GaugeRange(startValue: 38.0, endValue: 42, color: Colors.red), // > 37.9
        ];
      default:
        return <GaugeRange>[
          GaugeRange(startValue: 0, endValue: 100, color: Colors.grey),
        ];
    }
  }
}