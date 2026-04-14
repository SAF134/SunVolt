import 'dart:async';
import 'dart:math';
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
  final _random = Random();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id', symbol: '', decimalDigits: 0,
  );

  Timer? _chargingTimer;
  bool _initialized = false;
  bool _hasRecorded = false;
  bool _stoppedByBalance = false;
  int _userBalance = 0;

  bool _notified80Percent = false;
  bool _notified100Percent = false;
  bool _notified1MinRemaining = false;

  // ─── Spesifikasi Kendaraan ───
  late String _vehicleType;
  late double _totalCapacityKWh;
  late double _chargingDurationSeconds; // durasi 15% → 100%
  late double _percentPerSecond;
  late double _baseVoltage;
  late double _baseCurrent;

  // ─── Status Pengisian ───
  double _batteryPercent = 15.0;
  static const double _startPercent = 15.0;
  bool _isCharging = true;
  bool _isComplete = false;
  int _elapsedSeconds = 0;

  // ─── Nilai Elektrik Real-time ───
  double _currentVoltage = 0.0;
  double _currentCurrent = 0.0;
  double _currentPower = 0.0;

  // ─── Finansial ───
  double _energyConsumedKWh = 0.0;
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

    if (_vehicleType == 'motor') {
      // Motor listrik: 72V × 30Ah = 2.16 kWh
      _totalCapacityKWh = 2.16;
      _chargingDurationSeconds = 15 * 60.0; // 15 menit
      _baseVoltage = 76.0;  // sedikit di atas nominal 72 V
      _baseCurrent = 3.00;
    } else {
      // Sepeda listrik: 48V × 20Ah = 0.96 kWh
      _totalCapacityKWh = 0.96;
      _chargingDurationSeconds = 10 * 60.0; // 10 menit
      _baseVoltage = 52.0;  // sedikit di atas nominal 48 V
      _baseCurrent = 1.91;
    }

    // Kecepatan pengisian: 85% dalam durasi total (dari 15% ke 100%)
    _percentPerSecond = 85.0 / _chargingDurationSeconds;

    // Nilai awal
    _updateElectricalValues();

    // Mulai timer simulasi (setiap detik)
    _chargingTimer = Timer.periodic(
      const Duration(seconds: 1),
      _onChargingTick,
    );
  }

  /// Dipanggil setiap detik selama pengisian berlangsung
  void _onChargingTick(Timer timer) {
    if (!_isCharging || _isComplete) {
      timer.cancel();
      return;
    }

    setState(() {
      _elapsedSeconds++;
      _batteryPercent =
          (_startPercent + _percentPerSecond * _elapsedSeconds).clamp(0.0, 100.0);

      _updateElectricalValues();

      // Hitung energi yang terpakai & tarif berjalan
      _energyConsumedKWh =
          (_batteryPercent - _startPercent) / 100.0 * _totalCapacityKWh;
      _currentTariff = _energyConsumedKWh * _tariffPerKWh;

      // Cek apakah tarif sudah mencapai saldo pengguna
      if (_currentTariff.round() >= _userBalance && _userBalance > 0) {
        _currentTariff = _userBalance.toDouble();
        _energyConsumedKWh = _currentTariff / _tariffPerKWh;
        _isComplete = true;
        _isCharging = false;
        _stoppedByBalance = true;
        _currentCurrent = 0.0;
        _currentPower = 0.0;
        _pulseController.stop();
        timer.cancel();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recordAndFinalize();
        });
        return;
      }

      // Notifikasi Saldo Menipis (<= 60 Detik)
      if (!_notified1MinRemaining && !_isComplete) {
        double tariffPerSecond = _percentPerSecond / 100.0 * _totalCapacityKWh * _tariffPerKWh;
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

      // Notifikasi Baterai 80% (Fase CV)
      if (_batteryPercent >= 80.0 && !_notified80Percent) {
        _notified80Percent = true;
        _showLocalNotification(
          'Baterai 80%',
          'Pengisian daya mencapai 80%. Arus listrik mulai diturunkan untuk menjaga keawetan kesehatan baterai (Fase Constant Voltage).',
          Icons.battery_charging_full_rounded,
          AppColors.secondary,
        );
      }

      // Cek apakah pengisian selesai (baterai penuh)
      if (_batteryPercent >= 100.0) {
        _batteryPercent = 100.0;
        _isComplete = true;
        _isCharging = false;
        _currentCurrent = 0.0;
        _currentPower = 0.0;
        // Tarif final
        _energyConsumedKWh = 85.0 / 100.0 * _totalCapacityKWh;
        _currentTariff = _energyConsumedKWh * _tariffPerKWh;
        _pulseController.stop();
        timer.cancel();

        if (!_notified100Percent) {
          _notified100Percent = true;
          _showLocalNotification(
            'Baterai Penuh',
            'Kendaraan Anda telah terisi 100% dan siap menempuh perjalanan selanjutnya!',
            Icons.check_circle_rounded,
            AppColors.secondary,
          );
        }

        // Otomatis catat sesi setelah frame selesai
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recordAndFinalize();
        });
      }
    });
  }

  /// Perbarui nilai tegangan, arus, dan daya dengan fluktuasi realistis
  void _updateElectricalValues() {
    if (_isComplete) return;

    double progress = (_batteryPercent - _startPercent) / 85.0;

    // Tegangan naik sedikit saat baterai terisi (profil CC-CV)
    double voltageRise = progress * 4.0;
    _currentVoltage =
        _baseVoltage + voltageRise + (_random.nextDouble() - 0.5) * 1.0;

    // Arus: konstan di fase CC, berkurang di fase CV (> 80% SoC)
    double currentMultiplier = 1.0;
    if (_batteryPercent > 80.0) {
      double cvProgress = (_batteryPercent - 80.0) / 20.0;
      currentMultiplier = 1.0 - cvProgress * 0.6; // turun hingga 40%
    }
    _currentCurrent = _baseCurrent * currentMultiplier +
        (_random.nextDouble() - 0.5) * 0.08;
    _currentCurrent = _currentCurrent.clamp(0.1, _baseCurrent * 1.1);

    // Daya = V × I
    _currentPower = _currentVoltage * _currentCurrent;
  }

  /// Teks estimasi sisa waktu
  String _getRemainingTimeText() {
    if (_isComplete && _stoppedByBalance) return 'Saldo habis';
    if (_isComplete) return 'Pengisian selesai!';
    double remainingPercent = 100.0 - _batteryPercent;
    if (_percentPerSecond <= 0) return '—';
    int remainingMinutes = (remainingPercent / _percentPerSecond / 60).ceil();
    if (remainingMinutes <= 0) return 'Hampir selesai...';
    return '$remainingMinutes menit lagi';
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

    // Hitung ulang final
    _energyConsumedKWh =
        (_batteryPercent - _startPercent) / 100.0 * _totalCapacityKWh;
    _currentTariff = _energyConsumedKWh * _tariffPerKWh;
    final int tariffAmount = _currentTariff.round();

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
        'energy': '${_energyConsumedKWh.toStringAsFixed(2)} kWh',
      });
    } catch (e) {
      debugPrint('Gagal mencatat sesi pengisian: $e');
    }
  }

  @override
  void dispose() {
    _chargingTimer?.cancel();
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
                            // Ring progress
                            CustomPaint(
                              size: const Size(280, 280),
                              painter: _RingPainter(
                                progress: _batteryPercent / 100.0,
                                backgroundColor:
                                    AppColors.surfaceContainerHigh,
                                progressColor: AppColors.secondary,
                                strokeWidth: 12,
                              ),
                            ),
                            // Konten tengah
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isComplete
                                      ? Icons.check_circle
                                      : Icons.battery_charging_full,
                                  size: 56,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${_batteryPercent.toInt()}',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 56,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '%',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _getRemainingTimeText(),
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
                                '${_energyConsumedKWh.toStringAsFixed(2)} kWh terpakai • Rp ${_tariffPerKWh.toInt()}/kWh',
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

                  // ── Tegangan & Arus ──
                  Row(
                    children: [
                      Expanded(
                        child: _dataCard(
                          'TEGANGAN',
                          _currentVoltage.toStringAsFixed(2),
                          'V',
                          Icons.flash_on_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dataCard(
                          'ARUS',
                          _currentCurrent.toStringAsFixed(2),
                          'A',
                          Icons.speed_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

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
          'Pengisian daya saat ini di ${_batteryPercent.toInt()}%. '
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

  // ─── Helper Widget ───

  Widget _dataCard(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  RING PAINTER
// ═══════════════════════════════════════════════════════════════════

class _RingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
