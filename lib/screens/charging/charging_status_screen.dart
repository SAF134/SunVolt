import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChargingStatusScreen extends StatefulWidget {
  const ChargingStatusScreen({super.key});

  @override
  State<ChargingStatusScreen> createState() => _ChargingStatusScreenState();
}

class _ChargingStatusScreenState extends State<ChargingStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _currencyFormat = NumberFormat.currency(
    locale: 'id', symbol: '', decimalDigits: 0,
  );

  Timer? _chargingTimer;
  StreamSubscription? _sensorSubscription;
  bool _initialized = false;
  bool _hasRecorded = false;
  bool _stoppedByBalance = false;
  int _userBalance = 0;

  bool _notified1MinRemaining = false;

  // ─── Spesifikasi Kendaraan ───
  late String _vehicleType;
  late double _fixedVoltage; // 54.6V untuk sepeda (DC), 220V untuk motor (AC)

  // ─── Status Pengisian ───
  bool _isCharging = true;
  bool _isComplete = false;
  int _elapsedSeconds = 0;

  // ─── Nilai Elektrik Real-time (dari ESP32 via Firebase) ───
  double _currentAmps = 0.0;   // Arus dari ESP32
  double _currentPower = 0.0;  // Daya = Arus × Tegangan

  // ─── Finansial ───
  double _energyConsumedWh = 0.0;  // Akumulasi energi dalam Watt-hour
  double _currentTariff = 0.0;
  static const double _tariffPerKWh = 2500.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeCharging();
    }
  }

  /// Inisialisasi parameter berdasarkan jenis kendaraan
  void _initializeCharging() async {
    _vehicleType =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'bike';

    // Ambil saldo pengguna saat ini
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      _userBalance = doc.data()?['balance'] ?? 0;
    }

    // Tetapkan tegangan sesuai jenis kendaraan
    if (_vehicleType == 'motor') {
      _fixedVoltage = 220.0;  // Motor listrik: Output AC 220V
    } else {
      _fixedVoltage = 54.6;   // Sepeda listrik: Output DC 54.6V
    }

    // Mulai mendengarkan data arus dari ESP32 melalui Firebase
    _startListeningToSensor();

    // Mulai timer waktu (setiap detik)
    _chargingTimer = Timer.periodic(
      const Duration(seconds: 1),
      _onChargingTick,
    );
  }

  /// Mendengarkan data arus dari ESP32 secara real-time melalui Firebase
  void _startListeningToSensor() {
    _sensorSubscription = _firestore
        .collection('stations')
        .doc('station_1')
        .snapshots()
        .listen((snapshot) {
      if (!mounted || _isComplete) return;

      final data = snapshot.data();
      if (data != null && data.containsKey('current_amps')) {
        setState(() {
          _currentAmps = (data['current_amps'] as num).toDouble();
          // Daya (Watt) = Arus (A) × Tegangan (V)
          _currentPower = _currentAmps * _fixedVoltage;
        });
      }
    });
  }

  /// Dipanggil setiap detik selama pengisian berlangsung
  void _onChargingTick(Timer timer) {
    if (!_isCharging || _isComplete) {
      timer.cancel();
      return;
    }

    setState(() {
      _elapsedSeconds++;

      // Akumulasi energi: Daya (W) × waktu (1 detik) = Watt-second → konversi ke Wh
      _energyConsumedWh += _currentPower / 3600.0;

      // Tarif berjalan (Rp) = Energi (kWh) × Tarif per kWh
      _currentTariff = (_energyConsumedWh / 1000.0) * _tariffPerKWh;

      // Update data monitoring ke Firebase (setiap 5 detik)
      if (_elapsedSeconds % 5 == 0) {
        _updateRealTimeData();
      }

      // Cek apakah tarif sudah mencapai saldo pengguna
      if (_currentTariff.round() >= _userBalance && _userBalance > 0) {
        _currentTariff = _userBalance.toDouble();
        _isComplete = true;
        _isCharging = false;
        _stoppedByBalance = true;
        _currentPower = 0.0;
        _pulseController.stop();
        timer.cancel();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recordAndFinalize();
        });
        return;
      }

      // Notifikasi Saldo Menipis (<= 60 Detik estimasi)
      if (!_notified1MinRemaining && !_isComplete && _currentPower > 0) {
        double tariffPerSecond = (_currentPower / 3600.0 / 1000.0) * _tariffPerKWh;
        int remainingBalance = _userBalance - _currentTariff.round();
        if (tariffPerSecond > 0) {
          double secondsLeft = remainingBalance / tariffPerSecond;
          if (secondsLeft <= 60 && secondsLeft > 0) {
            _notified1MinRemaining = true;
            _showLocalNotification(
              'Saldo Menipis',
              'Sisa saldo Anda hanya cukup untuk pengisian sekitar 1 menit lagi. Pengisian akan berhenti otomatis jika saldo habis.',
              Icons.account_balance_wallet_rounded,
              AppColors.error,
            );
          }
        }
      }
    });
  }

  /// Mengirim data monitoring (daya, waktu, tarif) ke Firebase
  Future<void> _updateRealTimeData() async {
    try {
      await _firestore.collection('stations').doc('station_1').set({
        'power_watts': _currentPower,
        'elapsed_seconds': _elapsedSeconds,
        'current_tariff': _currentTariff.round(),
        'vehicle_type': _vehicleType,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Gagal mengirim data real-time: $e');
    }
  }

  /// Teks waktu yang berjalan
  String _getElapsedTimeText() {
    if (_isComplete && _stoppedByBalance) return 'Dihentikan';
    if (_isComplete) return 'Selesai';
    int minutes = _elapsedSeconds ~/ 60;
    int seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  void _showLocalNotification(String title, String message, IconData icon, Color color) {
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Catat sesi pengisian ke Firestore lalu tandai sudah dicatat
  Future<void> _recordAndFinalize() async {
    if (_hasRecorded) return;
    _hasRecorded = true;

    final user = _auth.currentUser;
    if (user == null) return;

    _chargingTimer?.cancel();
    _sensorSubscription?.cancel();

    final int tariffAmount = _currentTariff.round();
    final double energyKWh = _energyConsumedWh / 1000.0;

    final String title = _vehicleType == 'motor'
        ? 'Pengisian Motor Listrik'
        : 'Pengisian Sepeda Listrik';

    try {
      // Potong saldo dompet
      await _firestore.collection('users').doc(user.uid).update({
        'balance': FieldValue.increment(-tariffAmount),
      });

      // Tambah ke riwayat aktivitas
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activity_history')
          .add({
        'title': title,
        'subtitle': 'Stasiun SunVolt',
        'amount':
            '-Rp ${_currencyFormat.format(tariffAmount).trim()}',
        'isPositive': false,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'charging',
        'energy': '${energyKWh.toStringAsFixed(2)} kWh',
        'duration_seconds': _elapsedSeconds,
      });

      // Reset status station di Firebase
      await _firestore.collection('stations').doc('station_1').set({
        'power_watts': 0,
        'elapsed_seconds': 0,
        'current_tariff': 0,
        'vehicle_type': '',
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Gagal mencatat sesi pengisian: $e');
    }
  }

  @override
  void dispose() {
    _chargingTimer?.cancel();
    _sensorSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SunVoltAppBar(
            trailing: SaldoBadge(showLabel: false),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── Status Badge ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isComplete
                          ? (_stoppedByBalance
                              ? AppColors.error.withValues(alpha: 0.12)
                              : AppColors.secondary.withValues(alpha: 0.15))
                          : AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isComplete
                          ? (_stoppedByBalance
                              ? 'PENGISIAN DAYA DIHENTIKAN'
                              : 'PENGISIAN DAYA TELAH SELESAI')
                          : 'PENGISIAN DAYA SEDANG BERLANGSUNG',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: _isComplete
                            ? (_stoppedByBalance
                                ? AppColors.error
                                : AppColors.secondary)
                            : AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Energy Orb ──
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow effect (hanya saat mengisi)
                            if (!_isComplete) ...[
                              // Gelombang energi luar
                              Container(
                                width: 220 + (_pulseController.value * 40),
                                height: 220 + (_pulseController.value * 40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondary.withValues(alpha: 0.04),
                                ),
                              ),
                              // Inti energi bercahaya
                              Container(
                                width: 200 + (_pulseController.value * 15),
                                height: 200 + (_pulseController.value * 15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondary.withValues(alpha: 0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withValues(alpha: 0.2 * _pulseController.value),
                                      blurRadius: 30 * _pulseController.value,
                                      spreadRadius: 5 * _pulseController.value,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Ring outline statis (tanpa animasi progress)
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surfaceContainerHigh,
                                  width: 12,
                                ),
                              ),
                            ),
                            // Konten tengah
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isComplete
                                      ? Icons.check_circle
                                      : Icons.timer,
                                  size: 48,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getElapsedTimeText(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Waktu Berjalan',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _isComplete
                        ? (_stoppedByBalance
                            ? 'Saldo Tidak Mencukupi'
                            : 'Pengisian Daya Selesai!')
                        : 'Menuju Perjalanan Bersih Anda',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Kartu Tarif Berjalan ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryContainer
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tarif Berjalan',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .account_balance_wallet_rounded,
                                    color: AppColors.primaryContainer,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rp ${_currencyFormat.format(_currentTariff.round()).trim()}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                              '${(_energyConsumedWh / 1000.0).toStringAsFixed(2)} kWh terpakai • Rp ${_tariffPerKWh.toInt()}/kWh',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Kartu Daya Real-time ──
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8),
                            if (!_isComplete)
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.15 * _pulseController.value),
                                blurRadius: 20 * _pulseController.value,
                                spreadRadius: 2 * _pulseController.value,
                              ),
                          ],
                          border: !_isComplete ? Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3 * _pulseController.value),
                            width: 1.5,
                          ) : Border.all(color: Colors.transparent),
                        ),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daya Real-time',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.secondary,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _currentPower
                                            .toStringAsFixed(2),
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' W',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt,
                              color:
                                  AppColors.onSecondaryFixedVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),



                  // ── Tombol Aksi ──
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _isComplete
                          ? _onCompletePressed
                          : _onStopPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isComplete
                            ? AppColors.secondary
                            : AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: (_isComplete
                                ? AppColors.secondary
                                : AppColors.error)
                            .withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        _isComplete
                            ? Icons.home_rounded
                            : Icons.stop_circle,
                      ),
                      label: Text(
                        _isComplete
                            ? 'Kembali ke Beranda'
                            : 'Berhenti Mengisi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Aksi Tombol ───

  /// Saat pengisian selesai → langsung kembali ke beranda
  void _onCompletePressed() {
    Navigator.pushNamedAndRemoveUntil(
      context, '/main', (route) => false,
    );
  }

  /// Saat pengguna ingin berhenti sebelum 100%
  void _onStopPressed() {
    SunVoltConfirmationDialog.show(
      context,
      title: 'Berhenti Mengisi Daya?',
      message:
          'Pengisian daya sudah berjalan ${_elapsedSeconds ~/ 60} menit ${_elapsedSeconds % 60} detik. '
          'Tarif yang akan dikenakan: Rp ${_currencyFormat.format(_currentTariff.round()).trim()}. '
          'Apakah Anda yakin ingin berhenti?',
      isDestructive: true,
      onConfirm: () {
        SunVoltConfirmationDialog.show(
          context,
          title: 'Konfirmasi Akhir',
          message:
              'Saldo Rp ${_currencyFormat.format(_currentTariff.round()).trim()} '
              'akan dipotong dari dompet Anda. Lanjutkan?',
          isDestructive: true,
          onConfirm: () async {
            setState(() {
              _isCharging = false;
            });
            await _recordAndFinalize();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context, '/main', (route) => false,
              );
            }
          },
        );
      },
    );
  }


}


