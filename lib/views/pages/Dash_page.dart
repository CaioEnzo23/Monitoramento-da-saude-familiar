// ignore: file_names
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monitoramento_saude_familiar/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Dash_page extends StatefulWidget {
  const Dash_page({super.key});

  @override
  State<Dash_page> createState() => _Dash_pageState();
}

class _Dash_pageState extends State<Dash_page> {
  List<List<FlSpot>>? monthlyMedicationData;
  int _currentMonthIndex = 0;
  late final List<String> monthsNames;
  List<Map<String, double>>? monthlyCategoryData;
  final List<Color> categoryColors = [
    const Color(0xFF8a3ffc), // Roxo 60
    const Color(0xFF009d9a), // Marrequinha 50
    const Color(0xFFbe95ff), // Roxo 40
    const Color(0xFF3ddbd9), // Marrequinha 30
  ];

  final int minDays = 1;
  final int maxDays = 31;
  double overallMinCount = 0;
  double overallMaxCount = 5; // Default max, will be updated

  @override
  void initState() {
    monthsNames = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    _loadMedicationData();
    super.initState();
  }

  void _loadMedicationData() async {
    final rawData =
        await rootBundle.loadString('assets/data/medication_2025.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);

    final Map<DateTime, List<String>> tasks = {};
    final categories = ['Analgésico', 'Antibiótico', 'Anti-inflamatório', 'Vitamina'];
    int categoryIndex = 0;

    for (var row in csvTable.skip(1)) {
      // Skip header row
      final date = DateTime.parse(row[0]);
      final count = int.parse(row[1].toString());
      tasks[date] = List.generate(count, (index) {
        final category = categories[categoryIndex];
        categoryIndex = (categoryIndex + 1) % categories.length;
        return category;
      });
    }

    if (!mounted) {
      return;
    }

    double maxCount = 5; // Start with a default max

    setState(() {
      monthlyMedicationData = List.generate(12, (index) {
        final month = index + 1;
        final spots = <FlSpot>[];

        final tasksInMonth = tasks.entries.where(
            (entry) => entry.key.month == month && entry.key.year == 2025);

        for (final taskEntry in tasksInMonth) {
          final day = taskEntry.key.day.toDouble();
          final count = taskEntry.value.length.toDouble();
          spots.add(FlSpot(day, count));
          if (count > maxCount) {
            maxCount = count;
          }
        }
        return spots;
      });

      monthlyCategoryData = List.generate(12, (index) {
        final month = index + 1;
        final categoryCount = <String, double>{};

        final tasksInMonth = tasks.entries.where(
            (entry) => entry.key.month == month && entry.key.year == 2025);

        for (final taskEntry in tasksInMonth) {
          for (final category in taskEntry.value) {
            categoryCount[category] = (categoryCount[category] ?? 0) + 1;
          }
        }
        return categoryCount;
      });

      overallMaxCount = maxCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Remédios Tomados em 2025',
                          style: TextStyle(
                            color: Color(0xFF424242), // Cor do título alterada
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
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
                            monthsNames[_currentMonthIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF8a3ffc), // Roxo 60
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
                    ),
                    const SizedBox(height: 18),
                    AspectRatio(
                      aspectRatio: 1.4,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.linear,
                        switchOutCurve: Curves.linear,
                        child: monthlyMedicationData != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
                                  right: 18.0,
                                ),
                                child: LineChart(
                                  LineChartData(
                                    clipData: const FlClipData.all(),
                                    minY: overallMinCount,
                                    maxY: overallMaxCount + 2,
                                    minX: 0,
                                    maxX: 31,
                                    lineBarsData: (monthlyMedicationData ==
                                                null ||
                                            monthlyMedicationData![
                                                    _currentMonthIndex]
                                                .isEmpty)
                                        ? []
                                        : [
                                            LineChartBarData(
                                              spots: monthlyMedicationData![
                                                  _currentMonthIndex],
                                              isCurved: true,
                                              curveSmoothness: 0.3,
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF007d79), // Marrequinha 60
                                                  Color(0xFF009d9a), // Marrequinha 50
                                                ],
                                              ),
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: const FlDotData(show: false),
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
                                          ],
                                    gridData: FlGridData(
                                      show: true,
                                      drawHorizontalLine: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: _horizontalGridLines,
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      leftTitles: AxisTitles(
                                        drawBelowEverything: true,
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            return SideTitleWidget(
                                              meta: meta,
                                              child: Text(
                                                meta.formattedValue,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        axisNameWidget: Container(
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: const Text(
                                            'Dia do mês',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        axisNameSize: 40,
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 38,
                                          interval: 1,
                                          getTitlesWidget: _bottomTitles,
                                        ),
                                      ),
                                    ),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: _tooltipData(context),
                                    ),
                                  ),
                                  key: ValueKey<int>(_currentMonthIndex),
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
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
                      'Categorias de Remédios',
                      style: TextStyle(
                        color: Colors.grey[800], // Cor do título alterada
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AspectRatio(
                      aspectRatio: 1, // Proporção ajustada para o gráfico de barras
                      child: _buildBarChart(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (monthlyCategoryData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final categoryData = monthlyCategoryData![_currentMonthIndex];
    if (categoryData.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum dado para este mês',
          style: TextStyle(
            color: AppColors.contentColorBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    double maxValue = 0;
    for (var entry in categoryData.entries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
      }
    }

    final barGroups = <BarChartGroupData>[];
    int x = 0;
    for (var entry in categoryData.entries) {
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: categoryColors[x % categoryColors.length],
              width: 22,
              borderRadius: BorderRadius.zero,
            ),
          ],
          showingTooltipIndicators: const [0],
        ),
      );
      x++;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      child: BarChart(
        BarChartData(
          maxY: maxValue + 5,
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.transparent,
              tooltipBorder: BorderSide.none,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) {
                    return const Text('');
                  }
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < categoryData.keys.length) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 8.0,
                      child: Text(
                        categoryData.keys.elementAt(index),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Colors.transparent,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
        ),
        key: ValueKey<int>(_currentMonthIndex),
      ),
    );
  }

  bool get _canGoNext => _currentMonthIndex < 11;

  bool get _canGoPrevious => _currentMonthIndex > 0;

  void _previousMonth() {
    if (!_canGoPrevious) {
      return;
    }

    setState(() {
      _currentMonthIndex--;
    });
  }

  void _nextMonth() {
    if (!_canGoNext) {
      return;
    }
    setState(() {
      _currentMonthIndex++;
    });
  }

  FlLine _horizontalGridLines(double value) {
    final isZero = value == 0.0;
    return FlLine(
      color: isZero
          ? Colors.transparent
          : Colors.grey.withOpacity(0.2),
      strokeWidth: 0.5,
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final day = value.toInt() + 1;

    final isImportantToShow = day % 5 == 0 || day == 1;

    if (!isImportantToShow) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
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
      getTooltipColor: (touchedSpot) =>
          Colors.black.withAlpha((255 * 0.8).round()),
      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
        return touchedBarSpots.map((barSpot) {
          final textStyle = const TextStyle(
            color: AppColors.contentColorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          );

          final day = barSpot.x.toInt();
          final count = barSpot.y.toInt();

          return LineTooltipItem(
            'Dia $day: $count remédios',
            textStyle,
          );
        }).toList();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
