import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


// ─── Constants ────────────────────────────────────────────────────────────────
const kBg = Color(0xFF0A0A0F);
const kTeal = Color(0xFF00F5C4);
const kPurple = Color(0xFF6C63FF);
const kPink = Color(0xFFFF6B9D);
const kYellow = Color(0xFFFFD93D);
const kOrange = Color(0xFFFF9F43);

// ─── Project Data Model ───────────────────────────────────────────────────────
class ProjectData {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;
  final Color accentColor;
  final Color secondColor;
  final String image;
  final List<String> features;
  final bool isFeatured;
  final String githubUrl;
  final VoidCallback? onTap;

  const ProjectData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.accentColor,
    required this.secondColor,
    required this.image,
    required this.features,
    required this.githubUrl,
    this.onTap,
    this.isFeatured = false,
  });
}

final List<ProjectData> projects = [
  ProjectData(
    id: '01',
    title: 'Desi Kitchen',
    subtitle: 'Food Ordering App',
    description:
    'A modern food ordering app built with Flutter and Firebase with cart, billing, and admin panel.',
    tags: ['Flutter', 'Firebase', 'Provider','API'],
    accentColor: kTeal,
    secondColor: kPurple,
      image: 'assets/desi_kitchen.png',
    githubUrl: 'https://github.com/Jeelpatel2345/Desi_Kitchen',

    features: [
      'Food Ordering',
      'Cart System',
      'Firebase Backend',
      'Admin Panel'
    ],
    isFeatured: true,
  ),
  ProjectData(
    id: '02',
    title: 'Hand Gesture Detection',
    subtitle: 'Computer Vision Project',
    description:
    'A computer vision project that detects hand gestures using OpenCV and Python.',
    tags: ['Python', 'OpenCV', 'AI'],
    accentColor: kOrange,
    secondColor: kYellow,
    image: 'assets/hand_gesture.png',
    githubUrl: 'https://github.com/Jeelpatel2345/Hand-Gesture',
    features: [
      'Hand Tracking',
      'Gesture Detection',
      'OpenCV Integration',
      'Real-time Processing'
    ],
    isFeatured: false,
  ),
  ProjectData(
    id: '03',
    title: 'TRINETRA',
    subtitle: 'Fraud Detection Platform',
    description:
    'A smart fraud detection platform that identifies suspicious SMS, phone calls, and emails across multiple platforms to help users avoid scams.',
    tags: ['AI', 'Security', 'Fraud Detection'],
    accentColor: kOrange,
    secondColor: kPink,
    image: 'assets/trinetra.png',
    githubUrl: '',
    features: [
      'Call Fraud Detection',
      'SMS Scam Detection',
      'Email Threat Detection',
      'Cross-platform Security'
    ],
    isFeatured: false,
  ),
  ProjectData(
    id: '04',
    title: 'TRAVEL X',
    subtitle: 'Online Travel Booking App',
    description:
    'A smart travel booking platform that allows users to easily book hotels and automatically generate day-to-day travel itineraries for their trips.',
    tags: ['Flutter', 'Firebase', 'Travel App'],
    accentColor: kTeal,
    secondColor: kPurple,
    image: 'assets/travelx.png',
    githubUrl: '',
    features: [
      'Easy Hotel Booking',
      'Refundable Reservations',
      'Daily Travel Itinerary Generator',
      'Dedicated Travel Agent Support'
    ],
    isFeatured: false,
  ),
  ProjectData(
    id: '05',
    title: 'VRUSHSEVA',
    subtitle: 'Elderly Care Platform',
    description:
    'A smart elderly care platform that monitors daily activities, tracks health data and shares real-time information with family members to ensure safety and well-being.',
    tags: ['Flutter', 'MongoDB', 'IoT','UI/UX'],
    accentColor: kPink,
    secondColor: kPurple,
    image: 'assets/vrudhseva.png',
    githubUrl: 'https://github.com/Jeelpatel2345/VrudhSeva',
    features: [
      'Daily Activity Monitoring',
      'Live Location Tracking',
      'Caretaker Access Control',
      'Heart Rate Monitoring'
    ],
    isFeatured: true,
  ),
  ProjectData(
    id: '06',
    title: 'FRIDAY',
    subtitle: 'Virtual Assistant',
    description:
    'FRIDAY is a smart virtual assistant that helps users perform daily tasks using voice commands, launch applications, and access useful information like weather and news directly from their device.',
    tags: ['HTML', 'CSS', 'JavaScript'],
    accentColor: kPurple,
    secondColor: kTeal,
    image: 'assets/friday.png',
    githubUrl: 'https://github.com/Jeelpatel2345/FRIDAY',
    features: [
      'Voice Command Recognition',
      'Application Launcher',
      'AI Chat Assistant',
      'Weather & News Updates'
    ],
    isFeatured: true,
  ),
];

// ─── Animated Reveal ─────────────────────────────────────────────────────────
class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _Reveal({required this.child, this.delay = Duration.zero});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _slide,
    child: FadeTransition(opacity: _fade, child: widget.child),
  );
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String tag;
  final String title;
  const _SectionLabel({required this.tag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}

// ─── Filter Tab ───────────────────────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? kTeal.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: active ? kTeal.withOpacity(0.6) : Colors.white.withOpacity(0.12)),
          boxShadow: active ? [BoxShadow(color: kTeal.withOpacity(0.2), blurRadius: 12)] : [],
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: active ? kTeal : Colors.white.withOpacity(0.4),
        )),
      ),
    );
  }
}

// ─── Diagonal stripe painter ──────────────────────────────────────────────────
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.018)..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 28) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ─── Hex grid painter (card background) ──────────────────────────────────────
class _HexPainter extends CustomPainter {
  final Color color;
  _HexPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = 0.8;
    const r = 14.0;
    const w = r * 2;
    final h = r * math.sqrt(3);
    for (double row = -h; row < size.height + h; row += h) {
      for (double col = -w; col < size.width + w; col += w * 1.5) {
        final offset = (row ~/ h).isEven ? 0.0 : w * 0.75;
        _drawHex(canvas, Offset(col + offset, row), r, p);
      }
    }
  }

  void _drawHex(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = math.pi / 180 * (60 * i - 30);
      final x = c.dx + r * math.cos(a);
      final y = c.dy + r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

extension on double {
  static const double sqrt3 = 1.7320508;
}

// ─── Featured Project Card ────────────────────────────────────────────────────
class _FeaturedCard extends StatefulWidget {
  final ProjectData project;
  const _FeaturedCard({required this.project});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? p.accentColor.withOpacity(0.5) : Colors.white.withOpacity(0.08), width: 1.5),
          color: Colors.white.withOpacity(0.03),
          boxShadow: _hovered ? [BoxShadow(color: p.accentColor.withOpacity(0.18), blurRadius: 30, spreadRadius: 4)] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Hex bg
              Positioned.fill(child: CustomPaint(painter: _HexPainter(p.accentColor))),

              // Top gradient banner
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [p.accentColor.withOpacity(0.18), p.secondColor.withOpacity(0.08)],
                    ),
                  ),
                  child: Stack(children: [
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [p.accentColor.withOpacity(0.25), Colors.transparent]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: p.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: p.accentColor.withOpacity(0.3)),
                            ),
                            child:Image.asset(
                              p.image,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(p.title, style: const TextStyle(fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: kYellow.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: kYellow.withOpacity(0.4)),
                                    ),
                                    child: const Text('FEATURED', style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: kYellow, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                  ),
                                ]),
                                const SizedBox(height: 4),
                                Text(p.subtitle, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: p.accentColor.withOpacity(0.8), letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 168, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.description, style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.white.withOpacity(0.55), height: 1.8)),
                    const SizedBox(height: 18),

                    // Features
                    Wrap(spacing: 8, runSpacing: 8, children: p.features.map((f) =>
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: p.accentColor)),
                          const SizedBox(width: 6),
                          Text(f, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(width: 12),
                        ]),
                    ).toList()),

                    const SizedBox(height: 18),
                    // Tags
                    Wrap(spacing: 8, runSpacing: 8, children: p.tags.map((t) =>
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: p.accentColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: p.accentColor.withOpacity(0.25)),
                          ),
                          child: Text(t, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: p.accentColor, fontWeight: FontWeight.w600)),
                        ),
                    ).toList()),

                    const SizedBox(height: 22),
                    Row(children: [
                      _ActionBtn(label: 'LIVE DEMO', icon: Icons.open_in_new_rounded, color: p.accentColor, filled: true),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse(p.githubUrl)),
                        child: _ActionBtn(
                          label: 'GITHUB',
                          icon: Icons.code_rounded,
                          color: Colors.white,
                          filled: false,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Regular Project Card ─────────────────────────────────────────────────────
class _ProjectCard extends StatefulWidget {
  final ProjectData project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -5.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovered ? p.accentColor.withOpacity(0.45) : Colors.white.withOpacity(0.07), width: 1.5),
          color: _hovered ? p.accentColor.withOpacity(0.04) : Colors.white.withOpacity(0.025),
          boxShadow: _hovered ? [BoxShadow(color: p.accentColor.withOpacity(0.15), blurRadius: 24, spreadRadius: 2)] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _HexPainter(p.accentColor))),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: p.accentColor.withOpacity(0.3)),
                        ),
                        child:Image.asset(
                          p.image,
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                        )
                      ),
                      Text(p.id, style: TextStyle(fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.w900, color: p.accentColor.withOpacity(0.12))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(p.title, style: const TextStyle(fontFamily: 'monospace', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(p.subtitle, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: p.accentColor.withOpacity(0.75), letterSpacing: 0.5)),
                  const SizedBox(height: 12),

                  Text(p.description, maxLines: 3, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white.withOpacity(0.45), height: 1.7)),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(spacing: 6, runSpacing: 6, children: p.tags.map((t) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.accentColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: p.accentColor.withOpacity(0.2)),
                        ),
                        child: Text(t, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: p.accentColor, fontWeight: FontWeight.w600)),
                      ),
                  ).toList()),

                  const SizedBox(height: 18),
                  const Spacer(),

                  // Footer row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.id,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.2),
                          letterSpacing: 1,
                        ),
                      ),
                      Row(children: [
                        _IconBtn(icon: Icons.open_in_new_rounded, color: p.accentColor),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse(p.githubUrl)),
                          child: _IconBtn(icon: Icons.code_rounded, color: Colors.white),
                        )
                      ]),
                    ],
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

// ─── Action button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.filled,this.onTap,});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? widget.color.withOpacity(0.85) : widget.color)
                : (_hovered ? widget.color.withOpacity(0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: widget.color.withOpacity(_hovered ? 0.8 : 0.4)),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 14)]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 14,
                  color: widget.filled ? Colors.black : widget.color),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: widget.filled ? Colors.black : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _IconBtn({required this.icon, required this.color});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _hovered ? widget.color.withOpacity(0.55) : Colors.white.withOpacity(0.1)),
          color: _hovered ? widget.color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(widget.icon, size: 15, color: _hovered ? widget.color : Colors.white.withOpacity(0.35)),
      ),
    );
  }
}

// ─── Counter stat widget ──────────────────────────────────────────────────────
class _CounterStat extends StatefulWidget {
  final int target;
  final String suffix;
  final String label;
  final Color color;
  const _CounterStat({required this.target, required this.suffix, required this.label, required this.color});

  @override
  State<_CounterStat> createState() => _CounterStatState();
}

class _CounterStatState extends State<_CounterStat> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        children: [
          RichText(text: TextSpan(
            style: TextStyle(fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.w900, color: widget.color),
            children: [
              TextSpan(text: '${(_anim.value * widget.target).toInt()}'),
              TextSpan(text: widget.suffix, style: const TextStyle(fontSize: 18)),
            ],
          )),
          const SizedBox(height: 4),
          Text(widget.label, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white.withOpacity(0.35), letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

// ─── MAIN PROJECTS SCREEN ─────────────────────────────────────────────────────
class ProjectsScreen extends StatefulWidget {

  final VoidCallback onLetsTalk;

  const ProjectsScreen({
    Key? key,
    required this.onLetsTalk,
  }) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _activeFilter = 'ALL';
  final filters = ['ALL', 'FLUTTER', 'FIREBASE', 'UI/UX', 'API'];

  List<ProjectData> get _filtered {
    if (_activeFilter == 'ALL') return projects;
    return projects.where((p) => p.tags.any((t) => t.toUpperCase().contains(_activeFilter))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final featured = _filtered.where((p) => p.isFeatured).toList();
    final regular = _filtered.where((p) => !p.isFeatured).toList();

    return Container(
      color: kBg,
      child: Stack(children: [
        CustomPaint(size: size, painter: _StripePainter()),

        // Ambient glows
        Positioned(top: 100, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [kPurple.withOpacity(0.1), Colors.transparent])))),
        Positioned(bottom: 200, left: -80, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [kTeal.withOpacity(0.08), Colors.transparent])))),

        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _Reveal(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const _SectionLabel(tag: '// 03 PROJECTS', title: 'What I\'ve Built'),
                    const Spacer(),

                    if (isWide)
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse("https://github.com/Jeelpatel2345");
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: kTeal.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.open_in_new_rounded, color: kTeal, size: 14),
                                SizedBox(width: 8),
                                Text(
                                  'VIEW ALL ON GITHUB',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: kTeal,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Filter tabs ──
              _Reveal(
                delay: const Duration(milliseconds: 150),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filters.map((f) => _FilterTab(
                    label: f,
                    active: _activeFilter == f,
                    onTap: () => setState(() => _activeFilter = f),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 40),

              // ── Featured section ──
              if (featured.isNotEmpty) ...[
                _Reveal(
                  delay: const Duration(milliseconds: 200),
                  child: Row(children: [
                    Container(width: 3, height: 18, color: kYellow),
                    const SizedBox(width: 10),
                    Text('FEATURED PROJECTS', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withOpacity(0.4), letterSpacing: 2.5)),
                  ]),
                ),
                const SizedBox(height: 20),

                isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: featured.asMap().entries.map((e) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: e.key > 0 ? 16 : 0),
                      child: _Reveal(delay: Duration(milliseconds: 250 + e.key * 100), child: _FeaturedCard(project: e.value)),
                    ),
                  )).toList(),
                )
                    : Column(
                  children: featured.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _FeaturedCard(project: p),
                  )).toList(),
                ),
                const SizedBox(height: 44),
              ],

              // ── All projects grid ──
              if (regular.isNotEmpty) ...[
                _Reveal(
                  delay: const Duration(milliseconds: 300),
                  child: Row(children: [
                    Container(width: 3, height: 18, color: kPurple),
                    const SizedBox(width: 10),
                    Text('ALL PROJECTS', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withOpacity(0.4), letterSpacing: 2.5)),
                  ]),
                ),
                const SizedBox(height: 20),

                LayoutBuilder(builder: (context, constraints) {
                  final cols = constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 450 ? 2 : 1);
                  return Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: regular.asMap().entries.map((e) {
                      final cardWidth = (constraints.maxWidth - (cols - 1) * 18) / cols;
                      return SizedBox(
                        width: cardWidth,
                        height: 360,
                        child: _Reveal(
                          delay: Duration(milliseconds: 350 + e.key * 80),
                          child: _ProjectCard(project: e.value),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],

              // ── Empty state ──
              if (_filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 16),
                      Text('No projects found for "$_activeFilter"',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white.withOpacity(0.3))),
                    ]),
                  ),
                ),

              const SizedBox(height: 60),

              // ── CTA ──
              _Reveal(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kTeal.withOpacity(0.08), kPurple.withOpacity(0.06)],
                    ),
                    border: Border.all(color: kTeal.withOpacity(0.2)),
                  ),
                  child: Column(children: [
                    Text('Have a project in mind?', style: const TextStyle(fontFamily: 'monospace', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text("Let's build something amazing together.", style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white.withOpacity(0.45))),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionBtn(
                          label: "LET'S TALK",
                          icon: Icons.chat_rounded,
                          color: kTeal,
                          filled: true,
                          onTap: widget.onLetsTalk,
                        ),
                      ],
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}