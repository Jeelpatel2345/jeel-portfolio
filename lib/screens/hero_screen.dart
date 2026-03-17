import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:personal_portfollio/sections/about_section.dart';
import 'package:personal_portfollio/sections/project_section.dart';
import 'package:personal_portfollio/sections/skills_section.dart';
import 'package:personal_portfollio/sections/contact_section.dart';

Future<void> openLink(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri)) {
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
      title: 'Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A0A0F)),
        useMaterial3: true,
      ),
      home: const HeroScreen(),
    );
  }
}

// ─── Animated particle background ────────────────────────────────────────────

class _Particle {
  Offset position;
  double radius;
  double speed;
  double angle;
  double opacity;

  _Particle({
    required this.position,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animValue;

  ParticlePainter(this.particles, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = const Color(0xFF00F5C4).withOpacity(p.opacity * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.radius, paint);
    }

    // Glowing accent circle (top right)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6C63FF).withOpacity(0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.15), radius: 220));
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15), 220, glowPaint);

    // Secondary glow (bottom left)
    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F5C4).withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.85), radius: 180));
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.85), 180, glowPaint2);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// ─── Typing animation widget ──────────────────────────────────────────────────

class TypingText extends StatefulWidget {
  final List<String> texts;
  final TextStyle style;

  const TypingText({super.key, required this.texts, required this.style});

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText>
    with SingleTickerProviderStateMixin {
  int _textIndex = 0;
  String _displayed = '';
  bool _deleting = false;
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _startTyping();
  }

  void _startTyping() async {
    final target = widget.texts[_textIndex];
    if (!_deleting) {
      for (int i = _displayed.length; i <= target.length; i++) {
        if (!mounted) return;
        setState(() => _displayed = target.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 90));
      }
      await Future.delayed(const Duration(milliseconds: 1400));
      _deleting = true;
    }
    if (_deleting) {
      for (int i = _displayed.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() => _displayed = target.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 55));
      }
      _deleting = false;
      _textIndex = (_textIndex + 1) % widget.texts.length;
    }
    _startTyping();
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorController,
      builder: (_, __) {
        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: _displayed),
              TextSpan(
                text: '|',
                style: widget.style.copyWith(
                  color: const Color(0xFF00F5C4)
                      .withOpacity(_cursorController.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Glitch text widget ───────────────────────────────────────────────────────

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const GlitchText({super.key, required this.text, required this.style});

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _offsetX1 = 0;
  double _offsetX2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scheduleGlitch();
  }

  void _scheduleGlitch() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
      if (!mounted) return;
      for (int i = 0; i < 6; i++) {
        setState(() {
          _offsetX1 = (math.Random().nextDouble() - 0.5) * 6;
          _offsetX2 = (math.Random().nextDouble() - 0.5) * 6;
        });
        await Future.delayed(const Duration(milliseconds: 60));
      }
      setState(() {
        _offsetX1 = 0;
        _offsetX2 = 0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(_offsetX1, 0),
          child: Text(
            widget.text,
            style: widget.style.copyWith(
              color: const Color(0xFF00F5C4).withOpacity(0.5),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(_offsetX2, 2),
          child: Text(
            widget.text,
            style: widget.style.copyWith(
              color: const Color(0xFF6C63FF).withOpacity(0.5),
            ),
          ),
        ),
        Text(widget.text, style: widget.style),
      ],
    );
  }
}

// ─── Animated button ──────────────────────────────────────────────────────────

class AnimatedOutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const AnimatedOutlineButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  State<AnimatedOutlineButton> createState() => _AnimatedOutlineButtonState();
}

class _AnimatedOutlineButtonState extends State<AnimatedOutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered
                ? widget.color.withOpacity(0.85)
                : widget.color)
                : (_hovered ? widget.color.withOpacity(0.12) : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.color.withOpacity(_hovered ? 1 : 0.6),
              width: 1.5,
            ),
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
                  color: widget.filled
                      ? Colors.black
                      : widget.color,
                  size: 18),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: widget.filled ? Colors.black : widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00F5C4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scroll indicator ─────────────────────────────────────────────────────────

class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator();

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        children: [
          Text(
            'SCROLL',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 3,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 8),
          Transform.translate(
            offset: Offset(0, _anim.value * 6),
            child: Icon(Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.3), size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── MAIN HERO SCREEN ─────────────────────────────────────────────────────────

class HeroScreen extends StatefulWidget {
  const HeroScreen({super.key});

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen>
    with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();

  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey skillsKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;
  final List<_Particle> _particles = [];
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Particles
    _particleController = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    final rnd = math.Random();
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        position: Offset(
            rnd.nextDouble() * 400, rnd.nextDouble() * 800),
        radius: rnd.nextDouble() * 2 + 0.5,
        speed: rnd.nextDouble() * 0.3 + 0.1,
        angle: rnd.nextDouble() * math.pi * 2,
        opacity: rnd.nextDouble() * 0.5 + 0.1,
      ));
    }

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Particle / glow background ──
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) {
              return CustomPaint(
                size: size,
                painter: ParticlePainter(_particles, _particleController.value),
              );
            },
          ),

          // ── Subtle grid overlay ──
          CustomPaint(
            size: size,
            painter: _GridPainter(),
          ),

          // ── Main content ──
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [

                  // ── Nav bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: 'JeelVekariya',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        if (isWide)
                          Row(
                            children: [
                              for (final item in ['About', 'Projects', 'Skills', 'Contact'])
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (item == "About") {
                                        scrollToSection(aboutKey);
                                      } else if (item == "Projects") {
                                        scrollToSection(projectsKey);
                                      } else if (item == "Skills") {
                                        scrollToSection(skillsKey);
                                      } else if (item == "Contact") {
                                        scrollToSection(contactKey);
                                      }
                                    },
                                    child: _NavItem(label: item),
                                  ),
                                ),
                            ],
                          ),

                        GestureDetector(
                          onTap: () => scrollToSection(contactKey),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF00F5C4).withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'CONTACT ME',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFF00F5C4),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ),

                  // ── Hero body ──
                  Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: SlideTransition(
                      position: _slideIn,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: isWide
                              ? Row(
                            children: [
                              Expanded(flex: 6, child: _heroLeft()),
                              const SizedBox(width: 60),
                              Expanded(flex: 4, child: _heroRight()),
                            ],
                          )
                              : Column(
                            children: [
                              _heroLeft(),
                              const SizedBox(height: 48),
                              _heroRight(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Scroll indicator ──
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: _ScrollIndicator(),
                  ),

                  // ── ABOUT SECTION ──
                  AboutSection(key: aboutKey),

                  ProjectsScreen(
                    key: projectsKey,
                    onLetsTalk: () => scrollToSection(contactKey),
                  ),


                  SkillsScreen(key: skillsKey),

                  ContactScreen(key: contactKey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00F5C4).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00F5C4).withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00F5C4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Open to opportunities',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: const Color(0xFF00F5C4).withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Hello, I\'m',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 10),

        GlitchText(
          text: 'Jeel Vekariya',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 16),

        TypingText(
          texts: const [
            'Flutter Developer',
            'Mobile App Engineer',
            'Firebase & Backend Developer',
            'UI/UX Builder',
          ],
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00F5C4),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'I build mobile apps and web interfaces using Flutter\n'
              'and Firebase. I enjoy creating clean UI and solving\n'
              'real-world problems through technology.',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 15,
            color: Colors.white.withOpacity(0.5),
            height: 1.8,
          ),
        ),

        const SizedBox(height: 36),

        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            AnimatedOutlineButton(
              label: 'VIEW PROJECTS',
              icon: Icons.arrow_forward,
              color: const Color(0xFF00F5C4),
              filled: true,
              onTap: () => scrollToSection(projectsKey),
            ),
            AnimatedOutlineButton(
              label: 'DOWNLOAD RESUME',
              icon: Icons.download_rounded,
              color: Colors.white,
                onTap: () async {
                  final url = Uri.parse(
                      "https://drive.google.com/uc?export=download&id=1NrU4XmFBUkF3mDKZuMGxqteFnCmU8Z4U"
                  );

                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                }
            ),
          ],
        ),

        const SizedBox(height: 32),

        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: const [
            _StatCard(value: '5+', label: 'PROJECTS'),
            _StatCard(value: '3+', label: 'TECH STACK'),
            _StatCard(value: '2+', label: 'YEARS EXPERIENCE'),
          ],
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Text(
              'FIND ME ON',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 2.5,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 30,
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(width: 16),

            for (final data in [
              (Icons.code, 'https://github.com/Jeelpatel2345'),
              (Icons.link, 'https://www.linkedin.com/in/jeel-vekariya-9106b03a5/'),
              (Icons.alternate_email, 'https://www.instagram.com/_jeel__vekariya/'),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => openLink(data.$2),
                  child: _SocialIcon(
                    icon: data.$1,
                    label: data.$2,
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }

  Widget _heroRight() {
    return Center(
      child: Container(
        width: 540,
        height: 540,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF00F5C4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5C4).withOpacity(0.3),
              blurRadius: 140,
              spreadRadius: 50,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            "assets/profile.jpg",
            fit: BoxFit.cover,
            alignment: const Alignment(-0.25, 0),
          ),
        ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final String label;
  const _NavItem({required this.label});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _hovered ? const Color(0xFF00F5C4) : Colors.white.withOpacity(0.5),
          letterSpacing: 1,
        ),
        child: Text(widget.label),
      ),
    );
  }
}

// ─── Social icon ─────────────────────────────────────────────────────────────

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  const _SocialIcon({required this.icon, required this.label});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF00F5C4).withOpacity(0.6)
                  : Colors.white.withOpacity(0.1),
            ),
            borderRadius: BorderRadius.circular(4),
            color: _hovered
                ? const Color(0xFF00F5C4).withOpacity(0.08)
                : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered
                ? const Color(0xFF00F5C4)
                : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

// ─── Grid painter ─────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}