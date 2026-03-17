import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'About Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AboutSection( ),
    );
  }
}

// ─── Constants ────────────────────────────────────────────────────────────────

const kBg = Color(0xFF0A0A0F);
const kTeal = Color(0xFF00F5C4);
const kPurple = Color(0xFF6C63FF);
const kPink = Color(0xFFFF6B9D);
const kYellow = Color(0xFFFFD93D);

// ─── Diagonal stripe painter (background texture) ────────────────────────────

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 28) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Animated reveal wrapper ─────────────────────────────────────────────────

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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _slide,
    child: FadeTransition(opacity: _fade, child: widget.child),
  );
}

// ─── Orbiting dots around avatar ─────────────────────────────────────────────

class _OrbitPainter extends CustomPainter {
  final double angle;
  _OrbitPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    void drawOrbit(double r, Color color, double dotR, double speed, int count) {
      final orbitPaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(cx, cy), r, orbitPaint);
      final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
      for (int i = 0; i < count; i++) {
        final a = angle * speed + (2 * math.pi / count) * i;
        canvas.drawCircle(
            Offset(cx + r * math.cos(a), cy + r * math.sin(a)), dotR, dotPaint);
      }
    }

    drawOrbit(130, kTeal, 4, 1.0, 3);
    drawOrbit(155, kPurple, 3, -0.7, 2);
    drawOrbit(108, kPink, 2.5, 1.4, 4);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.angle != angle;
}

// ─── Animated avatar card ────────────────────────────────────────────────────

class _AvatarCard extends StatefulWidget {
  const _AvatarCard();

  @override
  State<_AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<_AvatarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitCtrl;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5C4).withOpacity(0.45),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
            ),
          ),

          // Avatar
          Container(
            width: 205,
            height: 205,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1C2E), Color(0xFF12122A)],
              ),
              border: Border.all(color: kTeal.withOpacity(0.5), width: 2.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    "assets/profile.jpg",
                    width: 190,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatBadge extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FloatBadge(
      {required this.icon, required this.label, required this.color});

  @override
  State<_FloatBadge> createState() => _FloatBadgeState();
}

class _FloatBadgeState extends State<_FloatBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1800 + math.Random().nextInt(600)))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value * -6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withOpacity(0.2), blurRadius: 12)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12, color: widget.color),
              const SizedBox(width: 5),
              Text(widget.label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skill bar ───────────────────────────────────────────────────────────────

class _SkillBar extends StatefulWidget {
  final String name;
  final double percent;
  final Color color;
  final Duration delay;

  const _SkillBar(
      {required this.name,
        required this.percent,
        required this.color,
        required this.delay});

  @override
  State<_SkillBar> createState() => _SkillBarState();
}

class _SkillBarState extends State<_SkillBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.5,
                  )),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => Text(
                  '${(_anim.value * widget.percent).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: widget.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _anim.value * widget.percent / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.6),
                        widget.color,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: widget.color.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info chip ───────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Timeline item ───────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final String year;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLast;

  const _TimelineItem({
    required this.year,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: year
          SizedBox(
            width: 52,
            child: Text(year,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                )),
          ),
          // Center: dot + line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: color.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Right: content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.45),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String tag;
  final String title;
  const _SectionLabel({required this.tag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: kTeal,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        Text(title,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            )),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(width: 32, height: 2, color: kTeal),
            const SizedBox(width: 6),
            Container(width: 8, height: 2, color: kPurple),
            const SizedBox(width: 6),
            Container(width: 3, height: 2, color: kPink),
          ],
        ),
      ],
    );
  }
}

// ─── ABOUT ME SCREEN ─────────────────────────────────────────────────────────

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 850;
    return Container(
      color: kBg,
      child: Stack(
        children: [
          // Background texture
          CustomPaint(size: size, painter: _StripePainter()),

          // Ambient glows
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  kPurple.withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  kTeal.withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Main scroll content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top section label ──
                _Reveal(
                  child: const _SectionLabel(
                    tag: '// 01 ABOUT',
                    title: 'Who Am I?',
                  ),
                ),
                const SizedBox(height: 52),

                // ── Avatar + bio row ──
                isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Reveal(
                        delay: const Duration(milliseconds: 150),
                        child: const _AvatarCard()),
                    const SizedBox(width: 56),
                    Expanded(
                        child: _Reveal(
                            delay: const Duration(milliseconds: 250),
                            child: _BioBlock())),
                  ],
                )
                    : Column(
                  children: [
                    _Reveal(child: const _AvatarCard()),
                    const SizedBox(height: 40),
                    _Reveal(
                        delay: const Duration(milliseconds: 150),
                        child: _BioBlock()),
                  ],
                ),
                const SizedBox(height: 60),
                _Divider(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bio block ───────────────────────────────────────────────────────────────

class _BioBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quote
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: kTeal, width: 3)),
            color: kTeal.withOpacity(0.04),
          ),
          child: Text(
            '""Transforming ideas into beautiful mobile experiences with Flutter.""',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.75),
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Bio paragraphs
        Text(
        'Hey! I''m Jeel Vekariya, a Flutter and full-stack developer currently'
        ' pursuing my Bachelor''s degree in Computer Engineering at'
    'Kadi Sarva Vishwavidyalaya.'

    'I enjoy building modern mobile applications with Flutter and Firebase,'
    'focusing on clean UI, performance, and real-world problem solving.',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Colors.white.withOpacity(0.55),
            height: 2.0,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'When I\'m not building apps, you\'ll find me exploring new design '
              'trends, contributing to open source, or leveling up my backend skills '
              'with Firebase & Node.js.',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Colors.white.withOpacity(0.55),
            height: 1.9,
          ),
        ),
        const SizedBox(height: 28),

        // Info chips grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _InfoChip(
              icon: Icons.location_on_rounded,
              label: 'LOCATION',
              value: 'Rajkot, India',
              color: kTeal,
            ),
            _InfoChip(
              icon: Icons.school_rounded,
              label: 'DEGREE',
              value: 'B.E. Computer Engineering',
              color: kPurple,
            ),
            _InfoChip(
              icon: Icons.mail_rounded,
              label: 'EMAIL',
              value: 'vekariyajeel0@gmail.com',
              color: kPink,
            ),
            _InfoChip(
              icon: Icons.work_rounded,
              label: 'STATUS',
              value: 'Open to Work/Internship',
              color: kYellow,
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Download CV button
        // Download CV button
        _GlowButton(
          label: 'DOWNLOAD RESUME',
          icon: Icons.download_rounded,
          color: kTeal,
          onTap: () {
            openLink("https://drive.google.com/uc?export=download&id=1NrU4XmFBUkF3mDKZuMGxqteFnCmU8Z4U");
          },
        ),
      ],
    );
  }
}
class _TechPill extends StatefulWidget {
  final String label;
  const _TechPill({required this.label});

  @override
  State<_TechPill> createState() => _TechPillState();
}

class _TechPillState extends State<_TechPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _hovered
              ? kTeal.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _hovered
                ? kTeal.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: _hovered ? kTeal : Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InterestTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InterestTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPurple.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kPurple),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: kPurple,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ─── Glow button ─────────────────────────────────────────────────────────────

class _GlowButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;   // 👈 ADD THIS

  const _GlowButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,   // 👈 ADD THIS
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? widget.color : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: widget.color.withOpacity(0.6)),
            boxShadow: _hovered
                ? [
              BoxShadow(
                color: widget.color.withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  color: _hovered ? Colors.black : widget.color, size: 18),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _hovered ? Colors.black : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child:
            Container(height: 1, color: Colors.white.withOpacity(0.06))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: kTeal),
          ),
        ),
        Expanded(
            child:
            Container(height: 1, color: Colors.white.withOpacity(0.06))),
      ],
    );
  }
}