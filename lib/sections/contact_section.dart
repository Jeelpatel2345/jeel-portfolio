import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const kBg     = Color(0xFF070710);
const kTeal   = Color(0xFF00F5C4);
const kPurple = Color(0xFF7C5CFC);
const kPink   = Color(0xFFFF4D8D);
const kBlue   = Color(0xFF3D9BFF);
const kYellow = Color(0xFFFFD93D);

// ─── Animated warp-tunnel painter ────────────────────────────────────────────
class _WarpPainter extends CustomPainter {
  final double t;
  _WarpPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 1; i <= 12; i++) {
      final phase = (t + i / 12) % 1.0;
      final r = phase * math.max(size.width, size.height) * 0.85;
      final opacity = (1 - phase) * 0.12;
      final paint = Paint()
        ..color = kTeal.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Radial spokes
    for (int i = 0; i < 16; i++) {
      final angle = 2 * math.pi * i / 16;
      final phase = (t * 2 + i / 16) % 1.0;
      final len = phase * math.max(size.width, size.height) * 0.6;
      final opacity = (1 - phase) * 0.06;
      final paint = Paint()
        ..color = kPurple.withOpacity(opacity)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + len * math.cos(angle), cy + len * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WarpPainter old) => old.t != t;
}

// ─── Floating particle system ─────────────────────────────────────────────────
class _Particle {
  double x, y, vx, vy, size, opacity, phase;
  Color color;
  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.size, required this.opacity,
    required this.phase, required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = (p.x + p.vx * t) % 1.0;
      final y = (p.y + p.vy * t) % 1.0;
      final flicker = (math.sin(t * 3 + p.phase) + 1) / 2;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        Paint()..color = p.color.withOpacity(p.opacity * flicker),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

// ─── Diagonal stripe painter ──────────────────────────────────────────────────
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.015)..strokeWidth = 1;
    for (double i = -size.height; i < size.width + size.height; i += 32) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ─── Animated reveal ──────────────────────────────────────────────────────────
class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _Reveal({required this.child, this.delay = Duration.zero});
  @override State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(widget.delay, () { if (mounted) _c.forward(); });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _slide,
    child: FadeTransition(opacity: _fade, child: widget.child),
  );
}

// ─── Neon text field ──────────────────────────────────────────────────────────
class _NeonField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool multiline;
  final TextEditingController controller;
  final Color accent;

  const _NeonField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.accent,
    this.multiline = false,
  });

  @override State<_NeonField> createState() => _NeonFieldState();
}

class _NeonFieldState extends State<_NeonField> with SingleTickerProviderStateMixin {
  bool _focused = false;
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _glow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(children: [
            Icon(widget.icon, size: 13, color: _focused ? widget.accent : Colors.white.withOpacity(0.35)),
            const SizedBox(width: 7),
            Text(widget.label, style: TextStyle(
              fontFamily: 'monospace', fontSize: 11, letterSpacing: 1.5,
              color: _focused ? widget.accent : Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w600,
            )),
          ]),
          const SizedBox(height: 8),
          // Field container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focused ? widget.accent.withOpacity(0.7) : Colors.white.withOpacity(0.08),
                width: _focused ? 1.5 : 1,
              ),
              color: _focused ? widget.accent.withOpacity(0.04) : Colors.white.withOpacity(0.025),
              boxShadow: _focused ? [BoxShadow(color: widget.accent.withOpacity(0.15 * _glow.value), blurRadius: 20, spreadRadius: 2)] : [],
            ),
            child: Focus(
              onFocusChange: (f) {
                setState(() => _focused = f);
                f ? _ctrl.forward() : _ctrl.reverse();
              },
              child: TextFormField(
                controller: widget.controller,
                maxLines: widget.multiline ? 5 : 1,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Send button with animation ───────────────────────────────────────────────
class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});
  @override State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _sending = false;
  bool _sent = false;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _handleTap() async {
    if (_sending || _sent) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() { _sending = false; _sent = true; });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _sent = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) { setState(() => _hovered = true); _ctrl.forward(); },
      onExit: (_) { setState(() => _hovered = false); _ctrl.reverse(); },
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: _sent
                ? const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF00E5A0)])
                : LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _hovered
                  ? [kTeal, kPurple]
                  : [kTeal.withOpacity(0.85), kPurple.withOpacity(0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: (_sent ? kTeal : kTeal).withOpacity(_hovered ? 0.45 : 0.25),
                blurRadius: _hovered ? 28 : 14,
                spreadRadius: _hovered ? 3 : 0,
              ),
            ],
          ),
          child: Center(
            child: _sending
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_sent ? Icons.check_circle_rounded : Icons.send_rounded, color: Colors.black, size: 18),
              const SizedBox(width: 10),
              Text(
                _sent ? 'MESSAGE SENT! 🎉' : 'SEND MESSAGE',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1.5),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Contact info card ────────────────────────────────────────────────────────
class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String copyValue;
  final Color color;
  final bool canCopy;
  const _ContactCard({
    required this.icon, required this.label,
    required this.value, required this.copyValue,
    required this.color, this.canCopy = true,
  });
  @override State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.copyValue));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.canCopy ? _copy : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _hovered ? widget.color.withOpacity(0.07) : Colors.white.withOpacity(0.025),
            border: Border.all(color: _hovered ? widget.color.withOpacity(0.45) : Colors.white.withOpacity(0.07)),
            boxShadow: _hovered ? [BoxShadow(color: widget.color.withOpacity(0.18), blurRadius: 20)] : [],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.color.withOpacity(0.3)),
                boxShadow: _hovered ? [BoxShadow(color: widget.color.withOpacity(0.25), blurRadius: 12)] : [],
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.label, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white.withOpacity(0.35), letterSpacing: 1.5)),
              const SizedBox(height: 3),
              Text(widget.value, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
            ])),
            if (widget.canCopy) AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _copied
                  ? Icon(Icons.check_rounded, key: const ValueKey('check'), color: kTeal, size: 16)
                  : Icon(Icons.copy_rounded, key: const ValueKey('copy'), color: Colors.white.withOpacity(0.25), size: 14),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Social button ────────────────────────────────────────────────────────────
class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final String handle;
  final Color color;
  const _SocialBtn({required this.icon, required this.label, required this.handle, required this.color});
  @override State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _hovered ? widget.color.withOpacity(0.1) : Colors.white.withOpacity(0.025),
          border: Border.all(color: _hovered ? widget.color.withOpacity(0.55) : Colors.white.withOpacity(0.07)),
          boxShadow: _hovered ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 18)] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(widget.icon, color: _hovered ? widget.color : Colors.white.withOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: _hovered ? widget.color : Colors.white.withOpacity(0.3), letterSpacing: 1.2)),
            Text(widget.handle, style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: _hovered ? Colors.white : Colors.white.withOpacity(0.65), fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward_rounded, size: 14, color: _hovered ? widget.color : Colors.transparent),
        ]),
      ),
    );
  }
}

// ─── Availability indicator ───────────────────────────────────────────────────
class _AvailabilityBadge extends StatefulWidget {
  const _AvailabilityBadge();
  @override State<_AvailabilityBadge> createState() => _AvailabilityBadgeState();
}

class _AvailabilityBadgeState extends State<_AvailabilityBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: kTeal.withOpacity(0.08),
          border: Border.all(color: kTeal.withOpacity(0.3 + _pulse.value * 0.2)),
          boxShadow: [BoxShadow(color: kTeal.withOpacity(0.1 + _pulse.value * 0.1), blurRadius: 16)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Stack(alignment: Alignment.center, children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: kTeal.withOpacity(0.25 * _pulse.value))),
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: kTeal)),
          ]),
          const SizedBox(width: 10),
          const Text('AVAILABLE FOR HIRE', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: kTeal, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        ]),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
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

// ─── Footer bar ───────────────────────────────────────────────────────────────
class _FooterBar extends StatelessWidget {
  const _FooterBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
        color: Colors.white.withOpacity(0.015),
      ),
      child: Row(children: [
        RichText(text: const TextSpan(
          style: TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w700),
          children: [
            TextSpan(text: '<', style: TextStyle(color: kTeal)),
            TextSpan(text: 'Jeel vekariya', style: TextStyle(color: Colors.white)),
            TextSpan(text: '/>', style: TextStyle(color: kPurple)),
          ],
        )),
        const Spacer(),
        Text('Made with ', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white.withOpacity(0.3))),
        const Icon(Icons.favorite_rounded, color: kPink, size: 14),
        Text(' & Flutter', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white.withOpacity(0.3))),
        const Spacer(),
        Text('© 2026 Jeel Vekariya', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withOpacity(0.2))),
      ]),
    );
  }
}

// ─── CONTACT SCREEN ───────────────────────────────────────────────────────────
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with TickerProviderStateMixin {

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  late AnimationController _warpCtrl;
  late AnimationController _particleCtrl;
  late List<_Particle> _particles;

  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl     = TextEditingController();


  @override
  void initState() {
    super.initState();

    // Warp animation controller
    _warpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Particle animation controller
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    final rnd = math.Random(7);
    final cols = [kTeal, kPurple, kPink, kBlue];

    _particles = List.generate(
      50,
          (i) => _Particle(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        vx: (rnd.nextDouble() - 0.5) * 0.04,
        vy: (rnd.nextDouble() - 0.5) * 0.04,
        size: rnd.nextDouble() * 1.8 + 0.4,
        opacity: rnd.nextDouble() * 0.4 + 0.1,
        phase: rnd.nextDouble() * math.pi * 2,
        color: cols[rnd.nextInt(cols.length)],
      ),
    );
  }
  Future<void> sendEmail(
      String name,
      String email,
      String subject,
      String message,
      ) async {

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': 'portfolio_gmail_service',
        'template_id': 'template_b72qm89',
        'user_id': 'yl6b7x4AlM0cAAHuI',
        'template_params': {
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        }
      }),
    );
  }

  @override
  void dispose() {
    _warpCtrl.dispose();
    _particleCtrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _subjectCtrl.dispose(); _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 860;

    return Container(
        color: kBg,
        child: Stack(children: [
        // ── Diagonal stripes ──
        CustomPaint(size: size, painter: _StripePainter()),

        // ── Warp tunnel behind left panel ──
        Positioned(
          top: 0, left: 0,
          width: isWide ? size.width * 0.45 : size.width,
          height: size.height,
          child: AnimatedBuilder(
            animation: _warpCtrl,
            builder: (_, __) => CustomPaint(
              painter: _WarpPainter(_warpCtrl.value),
            ),
          ),
        ),

        // ── Floating particles ──
        AnimatedBuilder(
          animation: _particleCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _ParticlePainter(_particles, _particleCtrl.value * 10),
          ),
        ),

        // ── Ambient glows ──
        Positioned(top: -100, left: -100, child: _glow(kPurple, 380)),
        Positioned(bottom: -60, right: -60, child: _glow(kTeal, 300)),
        Positioned(top: size.height * 0.4, left: size.width * 0.5, child: _glow(kPink, 220)),

        // ── Main content ──
        SingleChildScrollView(
          child: Column(children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 60, 32, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Header ──
                _Reveal(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _AvailabilityBadge(),
                  const SizedBox(height: 24),
                  const _SectionLabel(tag: '// 05 CONTACT', title: "Let's Connect"),
                  const SizedBox(height: 14),
                  Text(
                    "Got a project? An idea? Or just want to say hi?\nMy inbox is always open.",
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white.withOpacity(0.4), height: 1.7),
                  ),
                ])),

                const SizedBox(height: 48),

                // ── Main two-panel layout ──
                isWide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // LEFT: Contact info
                  Expanded(flex: 4, child: _Reveal(delay: const Duration(milliseconds: 100), child: _leftPanel())),
                  const SizedBox(width: 32),
                  // RIGHT: Form
                  Expanded(flex: 6, child: _Reveal(delay: const Duration(milliseconds: 200), child: _formPanel())),
                ])
                    : Column(children: [
                  _Reveal(child: _formPanel()),
                  const SizedBox(height: 32),
                  _Reveal(delay: const Duration(milliseconds: 100), child: _leftPanel()),
                ]),

                const SizedBox(height: 56),

                // ── Bottom CTA strip ──
                _Reveal(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kTeal.withOpacity(0.08), kPurple.withOpacity(0.05), kPink.withOpacity(0.04)],
                      ),
                      border: Border.all(color: kTeal.withOpacity(0.18)),
                    ),
                    child: isWide
                        ? Row(children: [
                      Expanded(child: _quickReach()),
                      Container(width: 1, height: 80, color: Colors.white.withOpacity(0.08)),
                      const SizedBox(width: 32),
                      Expanded(child: _responseTime()),
                    ])
                        : Column(children: [
                      _quickReach(),
                      const SizedBox(height: 24),
                      Container(height: 1, color: Colors.white.withOpacity(0.08)),
                      const SizedBox(height: 24),
                      _responseTime(),
                    ]),
                  ),
                ),

                const SizedBox(height: 48),
              ]),
            ),

            // ── Footer ──
            _Reveal(
              delay: const Duration(milliseconds: 350),
              child: const _FooterBar(),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Left info panel ──────────────────────────────────────────────────────────
  Widget _leftPanel() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Big decorative text
      Stack(children: [
        // Shadow ghost text
        Positioned(
          left: 2, top: 2,
          child: Text('HI!', style: TextStyle(fontFamily: 'monospace', fontSize: 96, fontWeight: FontWeight.w900, color: kTeal.withOpacity(0.06), height: 1)),
        ),
        Text('HI!', style: const TextStyle(fontFamily: 'monospace', fontSize: 96, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
      ]),
      const SizedBox(height: 8),
      Text("I'm always excited to\nhear from you.", style: TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.white.withOpacity(0.5), height: 1.7)),

      const SizedBox(height: 32),

      // Contact info cards
      _ContactCard(icon: Icons.mail_rounded, label: 'EMAIL', value: 'vekariyajeel0@gmail.com', copyValue: 'vekariyajeel0@gmail.com', color: kTeal),
      const SizedBox(height: 12),
      _ContactCard(icon: Icons.phone_rounded, label: 'PHONE', value: '+91 97262 30239', copyValue: '+919726230239', color: kPurple),
      const SizedBox(height: 12),
      _ContactCard(icon: Icons.location_on_rounded, label: 'LOCATION', value: 'Rajkot, India', copyValue: 'Rajkot, India', color: kPink, canCopy: false),
      const SizedBox(height: 12),
      _ContactCard(
        icon: Icons.school_rounded,
        label: 'EDUCATION',
        value: 'B.E (Computer Engineering), KSV University, Gandhinagar',
        copyValue: 'B.E (Computer Engineering), KSV University, Gandhinagar',
        color: kBlue,
        canCopy: false,
      ),

      const SizedBox(height: 32),

      // Social links
      Text('FIND ME ON', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white.withOpacity(0.3), letterSpacing: 2.5)),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () {
          openLink("https://github.com/Jeelpatel2345");
        },
        child: _SocialBtn(
          icon: Icons.code_rounded,
          label: 'GITHUB',
          handle: 'github.com/Jeelpatel2345',
          color: kTeal,
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          openLink("https://www.linkedin.com/in/jeel-vekariya-9106b03a5/");
        },
        child: _SocialBtn(
          icon: Icons.link_rounded,
          label: 'LINKEDIN',
          handle: 'linkedin.com/in/jeel-vekariya',
          color: kBlue,
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          openLink("https://www.instagram.com/_jeel__vekariya/");
        },
        child: _SocialBtn(
          icon: Icons.link_rounded,
          label: 'INSTAGRAM',
          handle: '@_jeel__vekariya',
          color: kPink,
        ),
      ),
    ]);
  }

  // ── Form panel ───────────────────────────────────────────────────────────────
  Widget _formPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.025),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: kTeal.withOpacity(0.05), blurRadius: 40, spreadRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Form header
        Row(children: [
          Container(width: 3, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kTeal, kPurple]))),
          const SizedBox(width: 12),
          const Text('SEND A MESSAGE', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: kTeal.withOpacity(0.08), border: Border.all(color: kTeal.withOpacity(0.2))),
            child: const Text('FREE', style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: kTeal, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          ),
        ]),
        const SizedBox(height: 28),

        // Name + Email row
        LayoutBuilder(builder: (ctx, cs) {
          if (cs.maxWidth > 500) {
            return Row(children: [
              Expanded(child: _NeonField(label: 'YOUR NAME', hint: 'John Doe', icon: Icons.person_rounded, controller: _nameCtrl, accent: kTeal)),
              const SizedBox(width: 16),
              Expanded(child: _NeonField(label: 'EMAIL ADDRESS', hint: 'john@email.com', icon: Icons.mail_rounded, controller: _emailCtrl, accent: kPurple)),
            ]);
          }
          return Column(children: [
            _NeonField(label: 'YOUR NAME', hint: 'John Doe', icon: Icons.person_rounded, controller: _nameCtrl, accent: kTeal),
            const SizedBox(height: 20),
            _NeonField(label: 'EMAIL ADDRESS', hint: 'john@email.com', icon: Icons.mail_rounded, controller: _emailCtrl, accent: kPurple),
          ]);
        }),
        const SizedBox(height: 20),

        _NeonField(label: 'SUBJECT', hint: 'Project collaboration / Freelance inquiry...', icon: Icons.label_rounded, controller: _subjectCtrl, accent: kPink),
        const SizedBox(height: 20),

        _NeonField(label: 'MESSAGE', hint: 'Tell me about your project, idea, or just say hello...', icon: Icons.chat_bubble_rounded, controller: _msgCtrl, accent: kBlue, multiline: true),
        const SizedBox(height: 28),

        // Type selector
        _Reveal(child: _ProjectTypeSelector()),
        const SizedBox(height: 28),

        _SendButton(
          onTap: () async {
            await sendEmail(
              _nameCtrl.text,
              _emailCtrl.text,
              _subjectCtrl.text,
              _msgCtrl.text,
            );

            // Clear form
            _nameCtrl.clear();
            _emailCtrl.clear();
            _subjectCtrl.clear();
            _msgCtrl.clear();
          },
        ),

        const SizedBox(height: 20),
        Center(child: Text(
          '🔒  Your info is safe. No spam, ever.',
          style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.withOpacity(0.25), letterSpacing: 0.3),
        )),
      ]),
    );
  }

  // ── Quick reach section ───────────────────────────────────────────────────────
  Widget _quickReach() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bolt_rounded, color: kYellow, size: 18),
          const SizedBox(width: 8),
          const Text('QUICK REACH', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: kYellow, letterSpacing: 2, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        Text('Prefer email? Drop me a line directly at', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white.withOpacity(0.4), height: 1.6)),
        const SizedBox(height: 6),
        SelectableText('vekariyajeel0@gmail.com', style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: kTeal, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _responseTime() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.timer_rounded, color: kPurple, size: 18),
          const SizedBox(width: 8),
          const Text('RESPONSE TIME', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: kPurple, letterSpacing: 2, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _responseChip('Email', '< 24h', kTeal),
          const SizedBox(width: 10),
          _responseChip('LinkedIn', '< 48h', kBlue),
          const SizedBox(width: 10),
          _responseChip('Instagram', '< 12h', kPurple),
        ]),
      ]),
    );
  }

  Widget _responseChip(String platform, String time, Color color) {
    return Column(children: [
      Text(platform, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white.withOpacity(0.35), letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
        child: Text(time, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ),
    ]);
  }

  Widget _glow(Color color, double size) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(0.12), Colors.transparent])),
  );
}

// ─── Project type selector ────────────────────────────────────────────────────
class _ProjectTypeSelector extends StatefulWidget {
  @override State<_ProjectTypeSelector> createState() => _ProjectTypeSelectorState();
}

class _ProjectTypeSelectorState extends State<_ProjectTypeSelector> {
  int _selected = -1;

  final types = [
    (Icons.phone_android_rounded, 'Mobile App', kTeal),
    (Icons.web_rounded, 'Web App', kPurple),
    (Icons.design_services_rounded, 'UI Design', kPink),
    (Icons.handshake_rounded, 'Consult', kBlue),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.category_rounded, size: 13, color: kYellow),
        const SizedBox(width: 7),
        Text('PROJECT TYPE', style: TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 1.5, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: types.asMap().entries.map((e) {
        final sel = _selected == e.key;
        final t = e.value;
        return GestureDetector(
          onTap: () => setState(() => _selected = sel ? -1 : e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: sel ? t.$3.withOpacity(0.15) : Colors.white.withOpacity(0.03),
              border: Border.all(color: sel ? t.$3.withOpacity(0.6) : Colors.white.withOpacity(0.08)),
              boxShadow: sel ? [BoxShadow(color: t.$3.withOpacity(0.2), blurRadius: 12)] : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(t.$1, size: 14, color: sel ? t.$3 : Colors.white.withOpacity(0.35)),
              const SizedBox(width: 7),
              Text(t.$2, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: sel ? t.$3 : Colors.white.withOpacity(0.45), fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ]),
          ),
        );
      }).toList()),
    ]);
  }
}