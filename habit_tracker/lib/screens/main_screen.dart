import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Kinetix Theme Colors
  final Color bgColor = const Color(0xFF151515);
  final Color primaryColor = const Color(0xFFD4FF00); // Neon Lime
  final Color secondaryColor = const Color(0xFFB4A6FF); // Pastel Purple
  final Color cardColor = const Color(0xFF2A2A2C);
  final Color mutedColor = const Color(0xFF3A3A3C);
  final Color mutedTextColor = const Color(0xFF8E8E93);
  final Color destructiveColor = const Color(0xFFFF453A); // Red dot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // extendBody allows the scrolling content to go under the floating nav bar
      extendBody: true,
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // Padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildProgressSection(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Your Chores',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCompletedChore('Make the Bed', 'Morning routine'),
              _buildProgressChore('Read 30 Pages', 'Personal growth', 12, 30),
              _buildSimpleChore('Drink 2L Water', 'Health'),
              _buildWorkoutChore('Workout', '45 mins'),
            ],
          ),
        ),
      ),

      // Floating Navigation Bar
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Thursday, Oct 24', // TODO: Make dynamic
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: mutedColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_rounded, color: primaryColor, size: 24),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: destructiveColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(text: '4'),
                    TextSpan(
                      text: '/5',
                      style: TextStyle(fontSize: 24, color: mutedTextColor),
                    ),
                  ],
                ),
              ),
              Text(
                'Almost there!',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Keep up the momentum.',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
          
          // Circular Progress Indicator Stack
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  color: mutedColor,
                ),
                CircularProgressIndicator(
                  value: 0.8, // 4/5 progress
                  strokeWidth: 12,
                  backgroundColor: Colors.transparent,
                  color: primaryColor,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: primaryColor,
                    size: 36,
                    shadows: [
                      Shadow(
                        color: primaryColor.withOpacity(0.6),
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CHORE CARD WIDGETS ---

  Widget _buildCompletedChore(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            child: Icon(Icons.check_circle_rounded, color: bgColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mutedTextColor,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(subtitle, style: GoogleFonts.nunitoSans(fontSize: 14, color: mutedTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChore(String title, String subtitle, int current, int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: secondaryColor.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.menu_book_rounded, color: secondaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(subtitle, style: GoogleFonts.nunitoSans(fontSize: 14, color: mutedTextColor)),
                    ],
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: secondaryColor),
                  children: [
                    TextSpan(text: '$current'),
                    TextSpan(text: '/$total', style: TextStyle(fontSize: 16, color: mutedTextColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Custom thick progress bar
          Container(
            height: 32,
            width: double.infinity,
            decoration: BoxDecoration(color: mutedColor, borderRadius: BorderRadius.circular(16)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: current / total,
              child: Container(
                decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChore(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: mutedColor, width: 4),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: GoogleFonts.nunitoSans(fontSize: 14, color: mutedTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutChore(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.fitness_center_rounded, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(subtitle, style: GoogleFonts.nunitoSans(fontSize: 14, color: mutedTextColor)),
                    ],
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 12)],
                ),
                child: Icon(Icons.play_arrow_rounded, color: bgColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(color: mutedColor, borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.6), blurRadius: 10)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FLOATING NAV BAR ---

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.95), // Slight transparency for modern feel
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.home_rounded, color: primaryColor, size: 32, shadows: [Shadow(color: primaryColor.withOpacity(0.6), blurRadius: 8)]),
            Icon(Icons.calendar_month_rounded, color: mutedTextColor, size: 28),
            Icon(Icons.bar_chart_rounded, color: mutedTextColor, size: 28),
            Icon(Icons.settings_rounded, color: mutedTextColor, size: 28),
          ],
        ),
      ),
    );
  }
}