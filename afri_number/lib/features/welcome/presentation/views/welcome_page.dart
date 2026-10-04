import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _skip() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: r.space(20),
            vertical: r.space(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP LOGO
              WelcomeHeader(scale: r.scale),

              // 2. SWIPEABLE CONTENT (PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Page 1: Multi-devise / Numéro International
                    _buildPageSlide(
                      r: r,
                      cards: WelcomeCards(scale: r.scale, screenWidth: r.width),
                      slogan: WelcomeSlogan(scale: r.scale),
                    ),

                    // Page 2: Paiement Local / Mobile Money
                    _buildPageSlide(
                      r: r,
                      cards: WelcomePaymentCards(
                        scale: r.scale,
                        screenWidth: r.width,
                      ),
                      slogan: WelcomePaymentSlogan(scale: r.scale),
                    ),

                    // Page 3: Connectivité + IA / Mode Zéro Data & SMS
                    _buildPageSlide(
                      r: r,
                      cards: WelcomeConnectivityCards(
                        scale: r.scale,
                        screenWidth: r.width,
                      ),
                      slogan: WelcomeConnectivitySlogan(scale: r.scale),
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.space(12)),

              // 3. FOOTER (INDICATEURS + BOUTONS)
              WelcomeFooter(
                scale: r.scale,
                currentIndex: _currentPage,
                pageCount: 3,
                onNext: _nextPage,
                onSkip: _skip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageSlide({
    required Responsive r,
    required Widget cards,
    required Widget slogan,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  cards,
                  const Spacer(),
                  slogan,
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
