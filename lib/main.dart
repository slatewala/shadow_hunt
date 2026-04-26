import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const ShadowHuntApp());

class ShadowHuntApp extends StatelessWidget {
  const ShadowHuntApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Shadow Hunt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const GamePage(),
      );
}

enum ShapeKind { circle, square, triangle, diamond, hexagon, star, plus, heart }

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _sfx = AudioPlayer();
  final _rng = Random();
  ShapeKind _target = ShapeKind.circle;
  List<ShapeKind> _choices = [];
  bool _showing = true;
  bool _gameOver = false;
  int _score = 0;
  int _best = 0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _hideTimer?.cancel();
    final all = ShapeKind.values.toList()..shuffle(_rng);
    _target = all.first;
    _choices = (all.take(4).toList()..shuffle(_rng));
    if (!_choices.contains(_target)) _choices[0] = _target;
    _showing = true;
    _gameOver = false;
    if (mounted) setState(() {});
    final flashMs = max(280, 700 - _score * 12);
    _hideTimer = Timer(Duration(milliseconds: flashMs), () {
      if (!mounted) return;
      setState(() => _showing = false);
    });
  }

  void _pick(ShapeKind k) {
    if (_gameOver) { _newRound(); return; }
    if (_showing) return;
    if (k == _target) {
      _sfx.play(AssetSource('sfx.wav'));
      setState(() {
        _score++;
        if (_score > _best) _best = _score;
      });
      Timer(const Duration(milliseconds: 250), _newRound);
    } else {
      setState(() => _gameOver = true);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _sfx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 16),
          Text('$_score',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
          Text('best $_best · ${_gameOver ? "MISS · TAP ANY" : (_showing ? "WATCH" : "PICK")}',
              style: TextStyle(
                  color: _gameOver ? const Color(0xFFFF6B6B)
                                   : const Color(0xFFE94560))),
          const SizedBox(height: 16),
          // silhouette area
          Expanded(
            flex: 4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: _showing ? 1.0 : 0.0,
                  child: CustomPaint(
                    painter: _ShapePainter(_target, const Color(0xFF000000)),
                  ),
                ),
              ),
            ),
          ),
          // 4 choices
          Expanded(
            flex: 3,
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              mainAxisSpacing: 14, crossAxisSpacing: 14,
              children: _choices.map((k) =>
                GestureDetector(
                  onTap: _gameOver
                      ? () => _newRound()
                      : (_showing ? null : () => _pick(k)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE94560), width: 2),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: CustomPaint(
                      painter: _ShapePainter(k, const Color(0xFFE94560)),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeKind kind;
  final Color color;
  _ShapePainter(this.kind, this.color);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color;
    final cx = s.width/2, cy = s.height/2;
    final r = min(s.width, s.height) * 0.42;
    switch (kind) {
      case ShapeKind.circle:
        c.drawCircle(Offset(cx, cy), r, p);
        break;
      case ShapeKind.square:
        c.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r*1.7, height: r*1.7), p);
        break;
      case ShapeKind.triangle:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r*0.95, cy + r*0.7)
          ..lineTo(cx - r*0.95, cy + r*0.7)
          ..close();
        c.drawPath(path, p);
        break;
      case ShapeKind.diamond:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r, cy)
          ..close();
        c.drawPath(path, p);
        break;
      case ShapeKind.hexagon:
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final a = i * pi/3 - pi/2;
          final x = cx + r * cos(a), y = cy + r * sin(a);
          if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        c.drawPath(path, p);
        break;
      case ShapeKind.star:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final rr = i.isEven ? r : r * 0.45;
          final a = i * pi/5 - pi/2;
          final x = cx + rr * cos(a), y = cy + rr * sin(a);
          if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        c.drawPath(path, p);
        break;
      case ShapeKind.plus:
        c.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r*1.8, height: r*0.7), p);
        c.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r*0.7, height: r*1.8), p);
        break;
      case ShapeKind.heart:
        final path = Path();
        path.moveTo(cx, cy + r*0.7);
        path.cubicTo(cx + r*1.4, cy, cx + r*0.6, cy - r, cx, cy - r*0.3);
        path.cubicTo(cx - r*0.6, cy - r, cx - r*1.4, cy, cx, cy + r*0.7);
        c.drawPath(path, p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) =>
      old.kind != kind || old.color != color;
}
