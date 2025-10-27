// ignore: file_names
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monitoramento_saude_familiar/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LineChartSample13 extends StatefulWidget {
  const LineChartSample13({super.key});

  @override
  State<LineChartSample13> createState() => _LineChartSample13State();
}

class _LineChartSample13State extends State<LineChartSample13> {
  List<List<FlSpot>>? monthlyMedicationData;
  int _currentMonthIndex = 0;
  late final List<String> monthsNames;
  List<Map<String, double>>? monthlyCategoryData;
  final List<Color> categoryColors = [
    AppColors.contentColorBlue,
    AppColors.contentColorYellow,
    AppColors.contentColorGreen,
    AppColors.contentColorOrange,
    AppColors.contentColorPink,
    AppColors.contentColorPurple,
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
    return Column(
      children: [
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Remédios Tomados em 2025',
              style: TextStyle(
                color: AppColors.contentColorOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Tooltip(
              message: 'Dados fictícios de 2025',
              child: IconButton(
                  onPressed: () {
                    // Ação opcional, como mostrar um diálogo informativo
                  },
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.contentColorOrange,
                    size: 18,
                  )),
            )
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
                  color: AppColors.contentColorBlue,
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
          child: Stack(
            children: [
              if (monthlyMedicationData != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0.0,
                    right: 18.0,
                  ),
                  child: LineChart(
                    LineChartData(
                      clipData: const FlClipData.all(),
                      minY: overallMinCount,
                      maxY: overallMaxCount + 2, // Add some padding
                      minX: 0,
                      maxX: 31,
                      lineBarsData: (monthlyMedicationData == null ||
                              monthlyMedicationData![_currentMonthIndex].isEmpty)
                          ? []
                          : [
                              LineChartBarData(
                                spots: monthlyMedicationData![_currentMonthIndex],
                                isCurved: true,
                                curveSmoothness: 0.3,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.contentColorBlue,
                                    AppColors.contentColorCyan,
                                  ],
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.contentColorBlue.withAlpha((255 * 0.3).round()),
                                      AppColors.contentColorCyan.withAlpha(0),
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
                  ),
                ),
              if (monthlyMedicationData == null)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Categorias de Remédios',
          style: TextStyle(
            color: AppColors.contentColorOrange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        AspectRatio(
          aspectRatio: 1.6,
          child: _buildPieChart(),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
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

    final totalValue = categoryData.values.fold(0.0, (a, b) => a + b);
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    categoryData.forEach((category, value) {
      final percentage = (value / totalValue) * 100;
      final section = PieChartSectionData(
        color: categoryColors[colorIndex % categoryColors.length],
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.contentColorWhite,
        ),
      );
      sections.add(section);
      colorIndex++;
    });

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),
        const SizedBox(width: 20),
        _buildLegend(categoryData),
      ],
    );
  }

  Widget _buildLegend(Map<String, double> categoryData) {
    int colorIndex = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryData.keys.map((category) {
        final color = categoryColors[colorIndex % categoryColors.length];
        colorIndex++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(category),
            ],
          ),
        );
      }).toList(),
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
          : Colors.blueGrey.withAlpha((255 * 0.3).round()),
      strokeWidth: isZero ? 0.8 : 0.4,
      dashArray: isZero ? null : [8, 4],
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
            '$day/${_currentMonthIndex + 1}\n',
            textStyle,
            children: [
              TextSpan(
                text: 'Remédios: $count',
                style: const TextStyle(color: AppColors.contentColorCyan),
              ),
            ],
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
