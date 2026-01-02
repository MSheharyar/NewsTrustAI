import 'package:flutter/material.dart';
import '../result_view_model.dart';

class VerdictCard extends StatelessWidget {
  final ResultViewModel vm;

  const VerdictCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: vm.themeColor.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: vm.bgColor, shape: BoxShape.circle),
            child: Icon(vm.statusIcon, size: 60, color: vm.themeColor),
          ),
          const SizedBox(height: 20),
          Text(
            vm.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: vm.themeColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            vm.confidence == null
                ? "N/A (Not Verified)"
                : "${vm.confidence!.toStringAsFixed(0)}% Confidence",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildSubtitle(),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    // ✅ MAIN trusted link verification
    if (vm.isMainTrustedLink) {
      final domain = vm.linkDomain.trim();
      return Text(
        domain.isEmpty ? "Verified from main trusted source" : "Verified from: $domain",
        style: const TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }

    // ✅ Normal verify/hybrid results show matches count
    if (vm.type == ResultType.hybrid || vm.type == ResultType.verify) {
      return Text(
        "Matches found: ${vm.matchesFound}",
        style: const TextStyle(color: Colors.black54),
      );
    }

    if (vm.type == ResultType.bert) {
      return const Text(
        "Model: BERT (Sequence Classification)",
        style: TextStyle(color: Colors.black54),
      );
    }

    return const SizedBox.shrink();
  }
}