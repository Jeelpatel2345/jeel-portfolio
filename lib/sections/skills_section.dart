import 'dart:math' as math;
import 'package:flutter/material.dart';


// ─── Palette ──────────────────────────────────────────────────────────────────
const kBg       = Color(0xFF070710);
const kTeal     = Color(0xFF00F5C4);
const kPurple   = Color(0xFF7C5CFC);
const kPink     = Color(0xFFFF4D8D);
const kBlue     = Color(0xFF3D9BFF);
const kYellow   = Color(0xFFFFD93D);
const kOrange   = Color(0xFFFF7849);

// ─── Skill model ─────────────────────────────────────────────────────────────
class SkillItem {
  final String name;
  final double level;   // 0.0 – 1.0
  final Color color;
  final IconData icon;
  const SkillItem({required this.name, required this.level, required this.color, required this.icon});
}

class SkillCategory {
  final String title;
  final String tag;
  final Color accent;
  final IconData catIcon;
  final List<SkillItem> skills;
  const SkillCategory({required this.title, required this.tag, required this.accent, required this.catIcon, required this.skills});
}

const categories = [
  SkillCategory(
    title: 'Mobile Dev',
    tag: 'MOBILE',
    accent: kTeal,
    catIcon: Icons.phone_android_rounded,
    skills: [
      SkillItem(name: 'Flutter', level: 0.85, color: kTeal, icon: Icons.flutter_dash),
      SkillItem(name: 'Dart', level: 0.75, color: kTeal, icon: Icons.code_rounded),
      SkillItem(name: 'Responsive UI', level: 0.85, color: kTeal, icon: Icons.devices),
      SkillItem(name: 'State Management', level: 0.80, color: kTeal, icon: Icons.account_tree),
      SkillItem(name: 'App Deployment', level: 0.70, color: kTeal, icon: Icons.rocket_launch),
    ],
  ),
  SkillCategory(
    title: 'Backend & DB',
    tag: 'BACKEND',
    accent: kPurple,
    catIcon: Icons.dns_rounded,
    skills: [
      SkillItem(name: 'Firebase', level: 0.75, color: kPurple, icon: Icons.local_fire_department),
      SkillItem(name: 'Backend Development', level: 0.65, color: kPurple, icon: Icons.storage),
      SkillItem(name: 'REST API', level: 0.70, color: kPurple, icon: Icons.api),
      SkillItem(name: 'Node.js', level: 0.60, color: kPurple, icon: Icons.terminal),
      SkillItem(name: 'Database Design', level: 0.65, color: kPurple, icon: Icons.dns),
    ],
  ),
  SkillCategory(
    title: 'UI / Design',
    tag: 'DESIGN',
    accent: kPink,
    catIcon: Icons.design_services_rounded,
    skills: [
      SkillItem(name: 'UI / UX Design', level: 0.80, color: kPink, icon: Icons.design_services),
      SkillItem(name: 'HTML', level: 0.75, color: kPink, icon: Icons.language),
      SkillItem(name: 'CSS', level: 0.78, color: kPink, icon: Icons.style),
      SkillItem(name: 'JavaScript', level: 0.70, color: kPink, icon: Icons.javascript),
    ],
  ),
  SkillCategory(
    title: 'Tools & DevOps',
    tag: 'TOOLS',
    accent: kBlue,
    catIcon: Icons.build_rounded,
    skills: [
      SkillItem(name: 'Python', level: 0.70, color: kBlue, icon: Icons.code),
      SkillItem(name: 'OpenCV', level: 0.65, color: kBlue, icon: Icons.visibility),
      SkillItem(name: 'Git & GitHub', level: 0.80, color: kBlue, icon: Icons.merge_type),
      SkillItem(name: 'VS Code', level: 0.90, color: kBlue, icon: Icons.code_off),
    ],
  ),
];

// ─── Circuit board background painter ────────────────────────────────────────
class CircuitPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<_CircuitNode> nodes;

  CircuitPainter({required this.progress, required this.color, required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withOpacity(0.07)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw circuit traces
    for (final node in nodes) {
      // Horizontal + vertical L-shaped traces
      for (final conn in node.connections) {
        if (conn < nodes.length) {
          final other = nodes[conn];
          final path = Path();
          path.moveTo(node.x * size.width, node.y * size.height);
          path.lineTo(other.x * size.width, node.y * size.height);
          path.lineTo(other.x * size.width, other.y * size.height);
          canvas.drawPath(path, linePaint);

          // Animated signal dot travelling along trace
          final t = (progress * 2 + node.phase) % 1.0;
          final midX = other.x * size.width;
          final startY = node.y * size.height;
          final endY = other.y * size.height;
          final totalLen = (midX - node.x * size.width).abs() + (endY - startY).abs();
          final seg1 = (midX - node.x * size.width).abs() / totalLen;

          double sigX, sigY;
          if (t < seg1) {
            sigX = node.x * size.width + (midX - node.x * size.width) * (t / seg1);
            sigY = startY;
          } else {
            sigX = midX;
            sigY = startY + (endY - startY) * ((t - seg1) / (1 - seg1));
          }

          canvas.drawCircle(Offset(sigX, sigY), 2.5, Paint()..color = color.withOpacity(0.7));
          canvas.drawCircle(Offset(sigX, sigY), 6, Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.fill);
        }
      }

      // Node circles
      canvas.drawCircle(
          Offset(node.x * size.width, node.y * size.height), 4, dotPaint);
      canvas.drawCircle(
          Offset(node.x * size.width, node.y * size.height), 4, glowPaint..color = color.withOpacity(0.35));

      // Small square pads
      final pad = Rect.fromCenter(
        center: Offset(node.x * size.width, node.y * size.height),
        width: 10, height: 10,
      );
      canvas.drawRect(pad, Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }
  }

  @override
  bool shouldRepaint(CircuitPainter old) => old.progress != progress;
}

class _CircuitNode {
  final double x, y, phase;
  final List<int> connections;
  const _CircuitNode(this.x, this.y, this.phase, this.connections);
}

List<_CircuitNode> _buildNodes(math.Random rnd, int count) {
  final nodes = List.generate(count, (i) => _CircuitNode(
    rnd.nextDouble(),
    rnd.nextDouble(),
    rnd.nextDouble(),
    [],
  ));
  // Build connections list separately (immutable workaround)
  return List.generate(count, (i) {
    final conns = <int>[];
    for (int j = 0; j < count; j++) {
      if (j != i) {
        final dx = nodes[i].x - nodes[j].x;
        final dy = nodes[i].y - nodes[j].y;
        if (math.sqrt(dx * dx + dy * dy) < 0.3 && conns.length < 2) {
          conns.add(j);
        }
      }
    }
    return _CircuitNode(nodes[i].x, nodes[i].y, nodes[i].phase, conns);
  });
}

// ─── Radial skill ring painter ────────────────────────────────────────────────
class RadialRingPainter extends CustomPainter {
  final double animValue;
  final double level;
  final Color color;

  RadialRingPainter({required this.animValue, required this.level, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 8;

    // Track
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5);

    // Arc
    final sweep = 2 * math.pi * level * animValue;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Glow arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    // Tip dot
    if (sweep > 0.01) {
      final angle = -math.pi / 2 + sweep;
      final tx = cx + r * math.cos(angle);
      final ty = cy + r * math.sin(angle);
      canvas.drawCircle(Offset(tx, ty), 5, Paint()..color = color);
      canvas.drawCircle(Offset(tx, ty), 10, Paint()..color = color.withOpacity(0.25));
    }

    // Dashed tick marks
    for (int i = 0; i < 36; i++) {
      final a = 2 * math.pi * i / 36 - math.pi / 2;
      final inner = r - 12;
      final outer = r - 8;
      canvas.drawLine(
        Offset(cx + inner * math.cos(a), cy + inner * math.sin(a)),
        Offset(cx + outer * math.cos(a), cy + outer * math.sin(a)),
        Paint()..color = color.withOpacity(0.2)..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(RadialRingPainter old) => old.animValue != animValue || old.level != level;
}

// ─── Skill ring card ──────────────────────────────────────────────────────────
class _SkillRingCard extends StatefulWidget {
  final SkillItem skill;
  final Duration delay;
  const _SkillRingCard({required this.skill, required this.delay});

  @override
  State<_SkillRingCard> createState() => _SkillRingCardState();
}

class _SkillRingCardState extends State<_SkillRingCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.skill;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _hovered ? s.color.withOpacity(0.06) : Colors.white.withOpacity(0.02),
          border: Border.all(color: _hovered ? s.color.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
          boxShadow: _hovered ? [BoxShadow(color: s.color.withOpacity(0.2), blurRadius: 20)] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80, height: 80,
              child: Stack(alignment: Alignment.center, children: [
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => CustomPaint(
                    size: const Size(80, 80),
                    painter: RadialRingPainter(animValue: _anim.value, level: s.level, color: s.color),
                  ),
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.color.withOpacity(0.1),
                    border: Border.all(color: s.color.withOpacity(0.3)),
                  ),
                  child: Icon(s.icon, color: s.color, size: 20),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            Text(s.name, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Text(
                '${(s.level * _anim.value * 100).toInt()}%',
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: s.color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category panel ───────────────────────────────────────────────────────────
class _CategoryPanel extends StatefulWidget {
  final SkillCategory cat;
  final Duration delay;
  final List<_CircuitNode> nodes;
  const _CategoryPanel({required this.cat, required this.delay, required this.nodes});

  @override
  State<_CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<_CategoryPanel> with TickerProviderStateMixin {
  late AnimationController _circCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _circCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () { if (mounted) _fadeCtrl.forward(); });
  }

  @override
  void dispose() { _circCtrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.02),
            border: Border.all(color: cat.accent.withOpacity(0.18)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(children: [
            // Animated circuit board background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _circCtrl,
                builder: (_, __) => CustomPaint(
                  painter: CircuitPainter(
                    progress: _circCtrl.value,
                    color: cat.accent,
                    nodes: widget.nodes,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cat.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cat.accent.withOpacity(0.35)),
                        boxShadow: [BoxShadow(color: cat.accent.withOpacity(0.2), blurRadius: 12)],
                      ),
                      child: Icon(cat.catIcon, color: cat.accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cat.tag, style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: cat.accent, letterSpacing: 2.5, fontWeight: FontWeight.w700)),
                      Text(cat.title, style: const TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    ]),
                    const Spacer(),
                    // Skill count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cat.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cat.accent.withOpacity(0.25)),
                      ),
                      child: Text('${cat.skills.length} skills', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: cat.accent, fontWeight: FontWeight.w600)),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Skill rings grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cat.skills.asMap().entries.map((e) => _SkillRingCard(
                      skill: e.value,
                      delay: widget.delay + Duration(milliseconds: 200 + e.key * 120),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Hexagon skill badge (soft skills) ───────────────────────────────────────
class _HexBadgePainter extends CustomPainter {
  final Color color;
  _HexBadgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = math.pi / 180 * (60 * i - 30);
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.12));
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.35)..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SoftSkillBadge extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SoftSkillBadge({required this.label, required this.icon, required this.color});

  @override
  State<_SoftSkillBadge> createState() => _SoftSkillBadgeState();
}

class _SoftSkillBadgeState extends State<_SoftSkillBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 1600 + math.Random().nextInt(800)))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _anim.value * -5),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 68, height: 68,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(size: const Size(68, 68), painter: _HexBadgePainter(widget.color)),
                Icon(widget.icon, color: widget.color, size: _hovered ? 26 : 22),
              ]),
            ),
            const SizedBox(height: 6),
            Text(widget.label, textAlign: TextAlign.center, style: TextStyle(
              fontFamily: 'monospace', fontSize: 10,
              color: _hovered ? widget.color : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600, letterSpacing: 0.3,
            )),
          ]),
        ),
      ),
    );
  }
}

// ─── Animated section label ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String tag;
  final String title;
  const _SectionLabel({required this.tag, required this.title});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(tag, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: kTeal, letterSpacing: 3, fontWeight: FontWeight.w600)),
    const SizedBox(height: 6),
    Text(title, style: const TextStyle(fontFamily: 'monospace', fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
    const SizedBox(height: 8),
    Row(children: [
      Container(width: 32, height: 2, color: kTeal),
      const SizedBox(width: 6),
      Container(width: 8, height: 2, color: kPurple),
      const SizedBox(width: 6),
      Container(width: 3, height: 2, color: kPink),
    ]),
  ]);
}

// ─── Constellation background painter ────────────────────────────────────────
class _ConstellationPainter extends CustomPainter {
  final double t;
  final List<Offset> pts;
  _ConstellationPainter(this.t, this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = kTeal.withOpacity(0.05)..strokeWidth = 0.6;
    for (int i = 0; i < pts.length; i++) {
      for (int j = i + 1; j < pts.length; j++) {
        final a = pts[i].scale(size.width, size.height);
        final b = pts[j].scale(size.width, size.height);
        if ((a - b).distance < size.width * 0.22) canvas.drawLine(a, b, p);
      }
    }
    for (final pt in pts) {
      final o = pt.scale(size.width, size.height);
      canvas.drawCircle(o, 1.5, Paint()..color = kTeal.withOpacity(0.18));
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter old) => old.t != t;
}

// ─── SKILLS SCREEN ────────────────────────────────────────────────────────────
class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});
  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Prebuilt circuit nodes per category
  late final List<List<_CircuitNode>> _catNodes;
  late final List<Offset> _constellationPts;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(42);
    _catNodes = List.generate(categories.length, (_) => _buildNodes(rnd, 14));
    _constellationPts = List.generate(30, (_) => Offset(rnd.nextDouble(), rnd.nextDouble()));

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerCtrl.forward();
  }

  @override
  void dispose() { _bgCtrl.dispose(); _headerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 860;

    return Container(
        color: kBg,
        child: Stack(children: [
        // ── Constellation bg ──
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _ConstellationPainter(_bgCtrl.value, _constellationPts),
          ),
        ),

        // ── Ambient glows ──
        Positioned(top: -120, left: -120, child: _glow(kPurple, 400)),
        Positioned(bottom: -80, right: -80, child: _glow(kTeal, 350)),
        Positioned(top: size.height * 0.4, right: -60, child: _glow(kPink, 250)),

        // ── Scroll content ──
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header ──
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _SectionLabel(tag: '// 04 SKILLS', title: 'My Arsenal'),
                  const SizedBox(height: 14),
                  Text(
                    'Technologies & tools I wield to bring ideas to life.',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white.withOpacity(0.4), letterSpacing: 0.5),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 48),

            // ── Category panels ──
            isWide
                ? Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _CategoryPanel(cat: categories[0], delay: const Duration(milliseconds: 100), nodes: _catNodes[0])),
                const SizedBox(width: 20),
                Expanded(child: _CategoryPanel(cat: categories[1], delay: const Duration(milliseconds: 200), nodes: _catNodes[1])),
              ]),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _CategoryPanel(cat: categories[2], delay: const Duration(milliseconds: 300), nodes: _catNodes[2])),
                const SizedBox(width: 20),
                Expanded(child: _CategoryPanel(cat: categories[3], delay: const Duration(milliseconds: 400), nodes: _catNodes[3])),
              ]),
            ])
                : Column(children: categories.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _CategoryPanel(cat: e.value, delay: Duration(milliseconds: 100 + e.key * 100), nodes: _catNodes[e.key]),
            )).toList()),

            const SizedBox(height: 56),

            // ── Divider ──
            Row(children: [
              Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: kTeal)),
              ),
              Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
            ]),

            const SizedBox(height: 48),

            // ── Soft skills section ──
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 3, height: 18, color: kYellow),
                    const SizedBox(width: 10),
                    Text('SOFT SKILLS & TRAITS', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withOpacity(0.4), letterSpacing: 2.5)),
                  ]),
                  const SizedBox(height: 28),

                  // Glowing container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kYellow.withOpacity(0.05), kOrange.withOpacity(0.03)],
                      ),
                      border: Border.all(color: kYellow.withOpacity(0.15)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 20,
                      runSpacing: 24,
                      children: const [
                        _SoftSkillBadge(label: 'Problem\nSolving', icon: Icons.psychology_rounded, color: kYellow),
                        _SoftSkillBadge(label: 'Team\nWork', icon: Icons.group_rounded, color: kTeal),
                        _SoftSkillBadge(label: 'Clean\nCode', icon: Icons.clean_hands_rounded, color: kPurple),
                        _SoftSkillBadge(label: 'Fast\nLearner', icon: Icons.bolt_rounded, color: kPink),
                        _SoftSkillBadge(label: 'Attention\nto Detail', icon: Icons.center_focus_strong_rounded, color: kBlue),
                        _SoftSkillBadge(label: 'Creative\nThinking', icon: Icons.lightbulb_rounded, color: kOrange),
                        _SoftSkillBadge(label: 'Time\nManagement', icon: Icons.timer_rounded, color: kYellow),
                        _SoftSkillBadge(label: 'Open\nSource', icon: Icons.diversity_3_rounded, color: kTeal),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 56),

            // ── Learning banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [kTeal.withOpacity(0.08), kPurple.withOpacity(0.06)],
                ),
                border: Border.all(color: kTeal.withOpacity(0.18)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kTeal.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: kTeal, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Always Learning', style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text('Currently exploring:AI integration in Flutter,Advanced Flutter animations,Computer Vision with Python.',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white.withOpacity(0.45), height: 1.6)),
                ])),
                const SizedBox(width: 16),
                Wrap(spacing: 8, children: [
                  _miniTag('AI', kPink),
                  _miniTag('Flutter ', kOrange),
                  _miniTag('Firebase & backend', kPurple),
                ])
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _glow(Color color, double size) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.withOpacity(0.12), Colors.transparent]),
    ),
  );

  Widget _miniTag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: color, fontWeight: FontWeight.w700)),
  );
}