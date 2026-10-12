import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({
    super.key,
    required this.billet,
    required this.onSpeak,
    required this.onIgnorer,
    required this.onArrive,
  });

  final Billet billet;
  final Future<void> Function() onSpeak;
  final VoidCallback onIgnorer;
  final VoidCallback onArrive;

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSpeak());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.billet;
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Rappel de départ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final scale = 1 + _pulse.value * 0.12;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                b.compagnie.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${b.depart} → ${b.arrivee}',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              Text(
                'Départ à ${b.heure}',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Veuillez vous préparer pour vous rendre à la gare choisie, afin d\'effectuer votre déplacement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    icon: Icons.check_circle_outline,
                    label: 'Je suis en route',
                    color: Colors.green,
                    onTap: () {
                      widget.onArrive();
                      Navigator.of(context).pop();
                    },
                  ),
                  _buildButton(
                    icon: Icons.close_rounded,
                    label: 'Ignorer',
                    color: Colors.redAccent,
                    onTap: () {
                      widget.onIgnorer();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Ce rappel reviendra dans 10 minutes si vous ignorez.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
