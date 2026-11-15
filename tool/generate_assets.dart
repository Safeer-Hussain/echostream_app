import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  final iconsDir = Directory('assets/icons');
  final imagesDir = Directory('assets/images');
  if (!iconsDir.existsSync()) iconsDir.createSync(recursive: true);
  if (!imagesDir.existsSync()) imagesDir.createSync(recursive: true);

  // 1. App Icon (512x512): Acoustic Studio Emblem on dark obsidian
  generateAppIcon('assets/icons/app_icon.png');

  // 2. Album / Podcast Covers (512x512)
  generateCover(
    'assets/images/ambient_architecture.png',
    title: 'Ambient Architecture',
    subtitle: 'Spatial Acoustic Textures',
    baseColor: img.ColorRgb8(18, 24, 38),
    accentColor: img.ColorRgb8(56, 189, 248),
    secondaryColor: img.ColorRgb8(129, 140, 248),
    patternType: 0,
  );

  generateCover(
    'assets/images/systems_engineering_weekly.png',
    title: 'Systems Engineering',
    subtitle: 'Distributed Systems & Compilers',
    baseColor: img.ColorRgb8(24, 20, 36),
    accentColor: img.ColorRgb8(168, 85, 247),
    secondaryColor: img.ColorRgb8(236, 72, 153),
    patternType: 1,
  );

  generateCover(
    'assets/images/deep_focus_frequencies.png',
    title: 'Deep Focus Frequencies',
    subtitle: '40Hz Gamma & Binaural Beats',
    baseColor: img.ColorRgb8(15, 23, 42),
    accentColor: img.ColorRgb8(34, 197, 94),
    secondaryColor: img.ColorRgb8(6, 182, 212),
    patternType: 2,
  );

  generateCover(
    'assets/images/midnight_synthwave.png',
    title: 'Midnight Synthwave',
    subtitle: 'Analog Synthesizers & Neon',
    baseColor: img.ColorRgb8(26, 16, 37),
    accentColor: img.ColorRgb8(244, 63, 94),
    secondaryColor: img.ColorRgb8(139, 92, 246),
    patternType: 3,
  );

  generateCover(
    'assets/images/ai_research_briefing.png',
    title: 'AI Research Briefing',
    subtitle: 'Frontier Models & Architecture',
    baseColor: img.ColorRgb8(17, 24, 39),
    accentColor: img.ColorRgb8(14, 165, 233),
    secondaryColor: img.ColorRgb8(99, 102, 241),
    patternType: 4,
  );

  generateCover(
    'assets/images/lossless_master.png',
    title: 'Lossless Studio Master',
    subtitle: '192kHz 24-Bit Pure DAC Session',
    baseColor: img.ColorRgb8(20, 20, 28),
    accentColor: img.ColorRgb8(234, 179, 8),
    secondaryColor: img.ColorRgb8(249, 115, 22),
    patternType: 0,
  );

  generateCover(
    'assets/images/acoustic_sessions.png',
    title: 'Acoustic Chamber',
    subtitle: 'Warm Analogue Resonance',
    baseColor: img.ColorRgb8(28, 22, 18),
    accentColor: img.ColorRgb8(245, 158, 11),
    secondaryColor: img.ColorRgb8(217, 119, 6),
    patternType: 2,
  );

  generateCover(
    'assets/images/tech_keynotes.png',
    title: 'Global Tech Keynote',
    subtitle: 'Architecture & Innovation',
    baseColor: img.ColorRgb8(15, 28, 38),
    accentColor: img.ColorRgb8(20, 184, 166),
    secondaryColor: img.ColorRgb8(59, 130, 246),
    patternType: 1,
  );

  // 3. Host Avatars (256x256)
  generateAvatar('assets/images/avatar_host_1.png', img.ColorRgb8(56, 189, 248), 'DR');
  generateAvatar('assets/images/avatar_host_2.png', img.ColorRgb8(168, 85, 247), 'SH');
  generateAvatar('assets/images/avatar_host_3.png', img.ColorRgb8(34, 197, 94), 'EL');
  generateAvatar('assets/images/avatar_host_4.png', img.ColorRgb8(244, 63, 94), 'MK');

  print('Assets generation complete!');
}

void generateAppIcon(String path) {
  final size = 512;
  final image = img.Image(width: size, height: size);

  // Background: Dark obsidian (#0B0F19 to #030712)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final t = (x + y) / (size * 2);
      final r = (11 * (1 - t) + 3 * t).round();
      final g = (15 * (1 - t) + 7 * t).round();
      final b = (25 * (1 - t) + 18 * t).round();
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  final cx = size ~/ 2;
  final cy = size ~/ 2;

  // Concentric harmonic waveform rings (cyan to violet)
  for (int r = 190; r >= 130; r -= 15) {
    final ringColor = img.ColorRgb8(
      (99 + (190 - r) * 2).clamp(0, 255),
      (102 + (190 - r)).clamp(0, 255),
      (241).clamp(0, 255),
    );
    img.drawCircle(image, x: cx, y: cy, radius: r, color: ringColor);
  }

  // Draw inner dark circle to create ring
  img.fillCircle(image, x: cx, y: cy, radius: 125, color: img.ColorRgb8(10, 14, 23));

  // Precision condenser capsule glyph (vertical pill with mesh lines)
  final capsuleColor = img.ColorRgb8(56, 189, 248);
  final capsuleTop = cy - 70;
  final capsuleBottom = cy + 40;
  final capsuleLeft = cx - 35;
  final capsuleRight = cx + 35;

  img.fillRect(image, x1: capsuleLeft, y1: capsuleTop, x2: capsuleRight, y2: capsuleBottom, color: img.ColorRgb8(30, 41, 59));
  img.drawRect(image, x1: capsuleLeft, y1: capsuleTop, x2: capsuleRight, y2: capsuleBottom, color: capsuleColor);

  // Mesh horizontal lines
  for (int y = capsuleTop + 10; y < capsuleBottom - 10; y += 10) {
    img.drawLine(image, x1: capsuleLeft + 5, y1: y, x2: capsuleRight - 5, y2: y, color: img.ColorRgb8(125, 211, 252));
  }

  // Waveform pulse bars at bottom
  for (int i = -4; i <= 4; i++) {
    final h = (sin((i + 4) * 0.7) * 35 + 15).round();
    final barX = cx + i * 14;
    img.fillRect(
      image,
      x1: barX - 4,
      y1: cy + 75 - h,
      x2: barX + 4,
      y2: cy + 75 + h,
      color: img.ColorRgb8(168, 85, 247),
    );
  }

  File(path).writeAsBytesSync(img.encodePng(image));
}

void generateCover(
  String path, {
  required String title,
  required String subtitle,
  required img.ColorRgb8 baseColor,
  required img.ColorRgb8 accentColor,
  required img.ColorRgb8 secondaryColor,
  required int patternType,
}) {
  final size = 512;
  final image = img.Image(width: size, height: size);

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final t = y / size;
      final r = (baseColor.r * (1 - t * 0.4)).round();
      final g = (baseColor.g * (1 - t * 0.4)).round();
      final b = (baseColor.b * (1 - t * 0.4)).round();
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  final cx = size ~/ 2;
  final cy = size ~/ 2;

  if (patternType == 0) {
    // Waveform circles
    for (int rad = 40; rad < 220; rad += 25) {
      img.drawCircle(image, x: cx, y: cy, radius: rad, color: accentColor);
    }
  } else if (patternType == 1) {
    // Grid geometric mesh
    for (int i = 50; i < size; i += 40) {
      img.drawLine(image, x1: i, y1: 50, x2: i, y2: size - 50, color: secondaryColor);
      img.drawLine(image, x1: 50, y1: i, x2: size - 50, y2: i, color: secondaryColor);
    }
    img.drawCircle(image, x: cx, y: cy, radius: 80, color: accentColor);
  } else if (patternType == 2) {
    // Frequency sine curves
    for (int i = -3; i <= 3; i++) {
      for (int x = 40; x < size - 40; x++) {
        final y = (cy + i * 25 + sin(x * 0.03 + i) * 35).round();
        if (y >= 0 && y < size) {
          image.setPixelRgb(x, y, accentColor.r, accentColor.g, accentColor.b);
          image.setPixelRgb(x, (y + 1).clamp(0, size - 1), secondaryColor.r, secondaryColor.g, secondaryColor.b);
        }
      }
    }
  } else if (patternType == 3) {
    // Synthwave horizon sun
    img.fillCircle(image, x: cx, y: cy, radius: 100, color: accentColor);
    for (int y = cy - 20; y < cy + 100; y += 12) {
      img.fillRect(image, x1: cx - 110, y1: y, x2: cx + 110, y2: y + 4, color: baseColor);
    }
    for (int x = 60; x <= size - 60; x += 30) {
      img.drawLine(image, x1: cx, y1: cy + 40, x2: x, y2: size - 40, color: secondaryColor);
    }
  } else {
    // Tech node constellation
    final rand = Random(42);
    final nodes = <Point<int>>[];
    for (int i = 0; i < 18; i++) {
      nodes.add(Point(rand.nextInt(380) + 66, rand.nextInt(380) + 66));
    }
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if (nodes[i].distanceTo(nodes[j]) < 130) {
          img.drawLine(image, x1: nodes[i].x, y1: nodes[i].y, x2: nodes[j].x, y2: nodes[j].y, color: secondaryColor);
        }
      }
      img.fillCircle(image, x: nodes[i].x, y: nodes[i].y, radius: 6, color: accentColor);
    }
  }

  // Draw sleek branding bar
  img.fillRect(image, x1: 40, y1: size - 85, x2: size - 40, y2: size - 45, color: img.ColorRgb8(15, 23, 42));
  img.drawRect(image, x1: 40, y1: size - 85, x2: size - 40, y2: size - 45, color: accentColor);

  File(path).writeAsBytesSync(img.encodePng(image));
}

void generateAvatar(String path, img.ColorRgb8 accent, String initials) {
  final size = 256;
  final image = img.Image(width: size, height: size);

  final cx = size ~/ 2;
  final cy = size ~/ 2;

  // Background circle
  img.fillCircle(image, x: cx, y: cy, radius: 120, color: img.ColorRgb8(30, 41, 59));
  img.drawCircle(image, x: cx, y: cy, radius: 120, color: accent);
  img.drawCircle(image, x: cx, y: cy, radius: 114, color: accent);

  // Stylized head & shoulders
  img.fillCircle(image, x: cx, y: cy - 25, radius: 45, color: accent);
  img.fillCircle(image, x: cx, y: cy + 110, radius: 85, color: accent);
  img.fillCircle(image, x: cx, y: cy + 130, radius: 75, color: img.ColorRgb8(15, 23, 42));

  File(path).writeAsBytesSync(img.encodePng(image));
}
