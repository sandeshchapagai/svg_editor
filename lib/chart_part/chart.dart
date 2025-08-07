import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const String jsonData = '''{
  "powerId": "rec1Q17otXnsspQmI",
  "type": "et-kurve-daily",
  "data": [
    {"2022":0,"2023":0,"2024":53280,"2025":0,"date":"2024-08-03T00:00:00Z","temperature":16.26},
    {"2022":0,"2023":0,"2024":33360,"2025":0,"date":"2024-08-04T00:00:00Z","temperature":14.74},
    {"2022":0,"2023":0,"2024":163040,"2025":0,"date":"2024-08-05T00:00:00Z","temperature":15.7},
    {"2022":0,"2023":0,"2024":182240,"2025":0,"date":"2024-08-06T00:00:00Z","temperature":19.58},
    {"2022":0,"2023":0,"2024":166640,"2025":0,"date":"2024-08-07T00:00:00Z","temperature":17.54},
    {"2022":0,"2023":0,"2024":209680,"2025":0,"date":"2024-08-08T00:00:00Z","temperature":15.32},
    {"2022":0,"2023":0,"2024":157120,"2025":0,"date":"2024-08-09T00:00:00Z","temperature":14.44}
  ]
}''';

// Data model for a single data point:
class EnergyData {
  final double temperature;
  final double energy;
  final Color color;
  final double animationValue;

  EnergyData(this.temperature, this.energy, this.color, this.animationValue);
}

class EnergyChart extends StatefulWidget {
  const EnergyChart({super.key});
  @override
  _EnergyChartState createState() => _EnergyChartState();
}

class _EnergyChartState extends State<EnergyChart>
    with TickerProviderStateMixin {
  late List<EnergyData> animatedData = [];
  late AnimationController _animationController;
  late AnimationController _colorAnimationController;
  late Animation<double> _animation;
  late Animation<double> _colorAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Main animation controller for chart appearance
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Color animation controller for green/yellow mixing
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _colorAnimation = CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    );

    _parseJsonAndPrepareData();

    // Start animations
    _animationController.forward();
    _startColorAnimation();

    // Listen to animation changes
    _animation.addListener(() {
      setState(() {});
    });

    _colorAnimation.addListener(() {
      _updateColors();
    });
  }

  void _startColorAnimation() {
    _colorAnimationController.repeat(reverse: true);
  }

  void _parseJsonAndPrepareData() {
    final Map<String, dynamic> parsed = json.decode(jsonData);
    final List<dynamic> rawData = parsed['data'];

    animatedData = [];

    for (var entry in rawData) {
      final double temp = (entry['temperature'] as num).toDouble();

      // Only add 2024 data for this example
      if ((entry['2024'] ?? 0) > 0) {
        animatedData.add(EnergyData(
          temp,
          (entry['2024'] as num).toDouble(),
          Colors.green, // Initial color
          _random.nextDouble(), // Random animation offset for each dot
        ));
      }
    }
  }

  void _updateColors() {
    setState(() {
      for (int i = 0; i < animatedData.length; i++) {
        // Create different animation phases for each dot
        double phase =
            (_colorAnimation.value + animatedData[i].animationValue) % 1.0;

        // Mix green and yellow based on animation phase
        Color mixedColor = Color.lerp(
          Colors.green,
          Colors.yellow,
          (sin(phase * 2 * pi) + 1) /
              2, // Creates smooth oscillation between 0 and 1
        )!;

        animatedData[i] = EnergyData(
          animatedData[i].temperature,
          animatedData[i].energy,
          mixedColor,
          animatedData[i].animationValue,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Energy vs Temperature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
            },
          ),
        ],
      ),
      body: SfCartesianChart(
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: NumericAxis(
          title: AxisTitle(text: 'Temperature (°C)'),
          minimum: 0,
          maximum: 25,
          interval: 5,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Energy (MWh)'),
          minimum: 0,
          maximum: 400000,
          interval: 100000,
        ),
        series: <ScatterSeries<EnergyData, double>>[
          ScatterSeries<EnergyData, double>(
            name: 'Energy Data (Animated)',
            dataSource: animatedData,
            xValueMapper: (EnergyData data, _) => data.temperature,
            yValueMapper: (EnergyData data, _) =>
                data.energy * _animation.value,
            pointColorMapper: (EnergyData data, _) => data.color,
            markerSettings: MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              width: 8 + (4 * _animation.value), // Animated size
              height: 8 + (4 * _animation.value),
              borderWidth: 2,
              borderColor: Colors.white,
            ),
            animationDuration: 2000,
            enableTooltip: true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add some random animated dots
          setState(() {
            for (int i = 0; i < 5; i++) {
              animatedData.add(EnergyData(
                10 + _random.nextDouble() * 15, // Random temperature
                50000 + _random.nextDouble() * 150000, // Random energy
                Colors.green,
                _random.nextDouble(),
              ));
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Random Dots',
      ),
    );
  }
}
