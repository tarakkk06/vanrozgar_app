import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_dashboard_screen.dart';
import 'gis_resource_map_screen.dart';
import 'livelihood_ideas_screen.dart';
import 'what_if_simulator_screen.dart';
import 'voice_ai_assistant_screen.dart';
import 'choose_village_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);

    final List<Widget> screens = [
      const HomeDashboardScreen(),
      const GisResourceMapScreen(),
      const LivelihoodIdeasScreen(),
      const WhatIfSimulatorScreen(),
      const VoiceAiAssistantScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: provider.currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: provider.currentTabIndex,
        onTap: (index) => provider.setTabIndex(index),
      ),
    );
  }
}
