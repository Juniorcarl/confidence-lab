import 'package:flutter/material.dart';

class ChartSeries {
  const ChartSeries(this.name, this.values, this.color);
  final String name;
  final List<double> values; // 0-100
  final Color color;
}

/// Minimal 0-100 line chart, drawn directly to avoid a chart dependency.
class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({super.key, required this.series, this.height = 180});
  final List<ChartSeries> series;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _Painter(series, scheme.outlineVariant, Theme.of(context).textTheme.bodySmall!),
          ),
        ),
        if (series.length > 1) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              for (final s in series)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 12, height: 3, color: s.color),
                  const SizedBox(width: 6),
                  Text(s.name, style: Theme.of(context).textTheme.bodySmall),
                ]),
            ],
          ),
        ],
      ],
    );
  }
}

class _Painter extends CustomPainter {
  _Painter(this.series, this.gridColor, this.labelStyle);
  final List<ChartSeries> series;
  final Color gridColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0;
    final chartW = size.width - left - 8;
    final chartH = size.height - 8;
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final v in [0, 50, 100]) {
      final y = 4 + chartH * (1 - v / 100);
      canvas.drawLine(Offset(left, y), Offset(size.width - 8, y), grid);
      final tp = TextPainter(text: TextSpan(text: '$v', style: labelStyle), textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final maxLen = series.fold<int>(0, (m, s) => s.values.length > m ? s.values.length : m);
    if (maxLen == 0) return;
    double xFor(int i) => maxLen == 1 ? left + chartW / 2 : left + chartW * i / (maxLen - 1);
    double yFor(double v) => 4 + chartH * (1 - v.clamp(0, 100) / 100);

    for (final s in series) {
      if (s.values.isEmpty) continue;
      final line = Paint()
        ..color = s.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final dot = Paint()..color = s.color;
      final path = Path()..moveTo(xFor(0), yFor(s.values[0]));
      for (var i = 1; i < s.values.length; i++) {
        path.lineTo(xFor(i), yFor(s.values[i]));
      }
      canvas.drawPath(path, line);
      for (var i = 0; i < s.values.length; i++) {
        canvas.drawCircle(Offset(xFor(i), yFor(s.values[i])), 3.5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => old.series != series;
}
