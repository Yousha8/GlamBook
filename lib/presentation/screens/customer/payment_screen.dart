import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/shared/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    // Simulate real network delay
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pop(context, true); // Return true on success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.luxuryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.premiumShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'PKR ${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('**** **** **** 4242', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                        Icon(Icons.credit_card, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethodTile(Icons.credit_card, 'Credit / Debit Card', true),
            _buildPaymentMethodTile(Icons.account_balance_wallet, 'Digital Wallet', false),
            _buildPaymentMethodTile(Icons.payments, 'Cash at Salon', false),
            
            const SizedBox(height: 48),
            _isProcessing
                ? const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.vibrantPink),
                        SizedBox(height: 16),
                        Text('Securing your transaction...', style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  )
                : FadeInUp(
                    child: CustomButton(
                      text: 'Pay Now',
                      onPressed: _processPayment,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(IconData icon, String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.vibrantPink : Colors.grey.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.vibrantPink : Colors.grey),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.vibrantPink),
        ],
      ),
    );
  }
}

class AppTheme {
  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: AppColors.deepMagenta.withOpacity(0.15),
          blurRadius: 25,
          offset: const Offset(0, 10),
        ),
      ];
}
