import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChargingStatusScreen extends StatefulWidget {
  const ChargingStatusScreen({super.key});

  @override
  State<ChargingStatusScreen> createState() => _ChargingStatusScreenState();
}

class _ChargingStatusScreenState extends State<ChargingStatusScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Utama (Milik Anda)
  late final FirebaseFirestore _secondaryFirestore; // Kedua (Milik Teman)
  
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
  DateTime? _sessionStartTime;
  DateTime? _lastTickTime;

  // ─── Status Pengisian ───
  bool _isCharging = true;
  bool _isComplete = false;
  int _elapsedSeconds = 0;
  
  // ─── Manajemen Interupsi Relay ───
  bool _isInterrupted = false;
  int _interruptionSecondsLeft = 15;
  Timer? _interruptionTimer;
  bool _dialogShowing = false;
  StateSetter? _dialogSetState;
  bool _hasPressedWait = false;

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
    WidgetsBinding.instance.addObserver(this);
    // Menghubungkan ke database Firebase proyek sekunder teman Anda
    _secondaryFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('secondary'));
    
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

    // Cek apakah ada sesi aktif untuk user ini di stasiun sekunder untuk resume
    DateTime startTime = DateTime.now();
    if (user != null) {
      try {
        final stationDoc = await _secondaryFirestore.collection('stations').doc('station_01').get();
        final stationData = stationDoc.data();
        
        if (stationData != null && 
            stationData['charging_user_uid'] == user.uid && 
            stationData['vehicle_type'] == _vehicleType &&
            stationData['session_start_time'] != null) {
          
          // Sesi pemulihan
          final Timestamp ts = stationData['session_start_time'] as Timestamp;
          startTime = ts.toDate();
          _energyConsumedWh = (stationData['energy_consumed_wh'] as num?)?.toDouble() ?? 0.0;
          _elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
        } else {
          // Buat sesi baru
          final Map<String, dynamic> startCommand = {
            'vehicle_type': _vehicleType,
            'charging_user_uid': user.uid,
            'session_start_time': Timestamp.fromDate(startTime),
            'energy_consumed_wh': 0.0,
            'last_updated': FieldValue.serverTimestamp(),
          };
          if (_vehicleType == 'motor') {
            startCommand['relayACState'] = 'ON';
          } else {
            startCommand['relayDCState'] = 'ON';
          }
          await _secondaryFirestore.collection('stations').doc('station_01').set(
            startCommand,
            SetOptions(merge: true),
          );
        }
      } catch (e) {
        debugPrint('Gagal inisialisasi / resume perintah START: $e');
      }
    }
    
    _sessionStartTime = startTime;
    _lastTickTime = startTime;

    // Mulai mendengarkan data arus dari ESP32 melalui Firebase Kedua
    _startListeningToSensor();

    // Mulai timer waktu (setiap detik)
    _chargingTimer = Timer.periodic(
      const Duration(seconds: 1),
      _onChargingTick,
    );
  }

  /// Mendengarkan data arus dari ESP32 secara real-time melalui Firebase
  void _startListeningToSensor() {
    _sensorSubscription = _secondaryFirestore
        .collection('stations')
        .doc('station_01')
        .snapshots()
        .listen((snapshot) {
      if (!mounted || _isComplete) return;

      final data = snapshot.data();
      if (data != null) {
        // Cek apakah relay dimatikan dari luar (hardware / web admin) setelah sesi berjalan
        final String? relayState = _vehicleType == 'motor'
            ? data['relayACState'] as String?
            : data['relayDCState'] as String?;

        if (relayState == 'OFF' && _isCharging && !_isComplete && _elapsedSeconds >= 2) {
          if (!_isInterrupted) {
            setState(() {
              _isInterrupted = true;
              _currentAmps = 0.0;
              _currentPower = 0.0;
              _interruptionSecondsLeft = 15;
              _hasPressedWait = false;
            });

            // Jalankan hitung mundur interupsi (15 detik)
            _interruptionTimer?.cancel();
            _interruptionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!mounted) {
                timer.cancel();
                return;
              }
              if (_interruptionSecondsLeft > 0) {
                setState(() {
                  _interruptionSecondsLeft--;
                });
                _dialogSetState?.call(() {}); // Update teks countdown di dialog
              } else {
                timer.cancel();
                _handleInterruptionTimeout();
              }
            });

            _showInterruptionDialog();
          }
          return;
        }

        // Jika relay aktif kembali sebelum batas waktu, batalkan interupsi
        if (relayState == 'ON' && _isInterrupted) {
          setState(() {
            _isInterrupted = false;
          });
          _interruptionTimer?.cancel();
          if (_dialogShowing) {
            Navigator.of(context).pop();
            _dialogShowing = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Koneksi terhubung kembali. Pengisian daya dilanjutkan.'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }

        setState(() {
          // Membaca acCurrent untuk motor, dcCurrent untuk sepeda dari Firebase Kedua
          if (_vehicleType == 'motor') {
            _currentAmps = (data['acCurrent'] as num?)?.toDouble() ?? 0.0;
          } else {
            _currentAmps = (data['dcCurrent'] as num?)?.toDouble() ?? 0.0;
          }
          // Daya (Watt) = Arus (A) × Tegangan (V)
          _currentPower = _currentAmps * _fixedVoltage;
        });
      }
    });
  }

  /// Menampilkan dialog interupsi / koneksi terputus dengan pilihan Tunggu atau Berhenti
  void _showInterruptionDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            _dialogSetState = setDialogState;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Interupsi Pengisian',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aliran listrik dari stasiun terputus. Silakan pilih untuk menunggu koneksi kembali atau berhenti sekarang.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sisa waktu tunggu: $_interruptionSecondsLeft detik...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Tutup pop-up dan ubah sisa waktu menjadi 60 detik (1 menit)
                    Navigator.of(dialogCtx).pop();
                    _dialogShowing = false;
                    setState(() {
                      _hasPressedWait = true;
                      _interruptionSecondsLeft = 60;
                    });
                  },
                  child: Text(
                    'Tunggu',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Tutup dialog dan hentikan pengisian daya secara manual
                    Navigator.of(dialogCtx).pop();
                    _dialogShowing = false;

                    setState(() {
                      _isCharging = false;
                      _isComplete = true;
                      _currentPower = 0.0;
                      _currentAmps = 0.0;
                    });
                    _interruptionTimer?.cancel();
                    _chargingTimer?.cancel();
                    _sensorSubscription?.cancel();
                    _pulseController.stop();

                    await _recordAndFinalize();

                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Berhenti',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _dialogShowing = false;
      _dialogSetState = null;
    });
  }

  /// Dipanggil ketika batas waktu tunggu interupsi (60 detik) habis
  void _handleInterruptionTimeout() async {
    setState(() {
      _isCharging = false;
      _isComplete = true;
      _currentPower = 0.0;
      _currentAmps = 0.0;
    });
    _interruptionTimer?.cancel();
    _chargingTimer?.cancel();
    _sensorSubscription?.cancel();
    _pulseController.stop();

    if (_dialogShowing) {
      Navigator.of(context).pop();
      _dialogShowing = false;
    }

    await _recordAndFinalize();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas waktu tunggu habis. Pengisian dihentikan secara otomatis.'),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  /// Dipanggil setiap detik selama pengisian berlangsung
  void _onChargingTick(Timer timer) {
    if (!_isCharging || _isComplete) {
      timer.cancel();
      return;
    }
    if (_isInterrupted) {
      return;
    }

    setState(() {
      final now = DateTime.now();
      if (_sessionStartTime != null) {
        _elapsedSeconds = now.difference(_sessionStartTime!).inSeconds;
      } else {
        _elapsedSeconds++;
      }

      // Akumulasi energi dengan menghitung selisih waktu dinamis (deltaTime)
      if (_lastTickTime != null) {
        final double deltaTime = now.difference(_lastTickTime!).inMilliseconds / 1000.0;
        if (deltaTime > 0) {
          _energyConsumedWh += _currentPower * (deltaTime / 3600.0);
        }
      } else {
        _energyConsumedWh += _currentPower / 3600.0;
      }
      _lastTickTime = now;

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

  /// Mengirim data monitoring (daya, waktu, tarif) ke Firebase Kedua
  Future<void> _updateRealTimeData() async {
    try {
      await _secondaryFirestore.collection('stations').doc('station_01').set({
        'power_watts': _currentPower,
        'elapsed_seconds': _elapsedSeconds,
        'current_tariff': _currentTariff.round(),
        'energy_consumed_wh': _energyConsumedWh,
        'vehicle_type': _vehicleType,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Gagal mengirim data real-time ke hardware: $e');
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
      // Potong saldo dompet di Firebase Utama Anda
      await _firestore.collection('users').doc(user.uid).update({
        'balance': FieldValue.increment(-tariffAmount),
      });

      // Tambah ke riwayat aktivitas di Firebase Utama Anda
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

      // Reset status station & matikan relay di Firebase Kedua teman Anda
      await _secondaryFirestore.collection('stations').doc('station_01').set({
        'power_watts': 0,
        'elapsed_seconds': 0,
        'current_tariff': 0,
        'vehicle_type': '',
        'charging_user_uid': '',
        'session_start_time': null,
        'energy_consumed_wh': 0.0,
        'relayACState': 'OFF', // Matikan relay AC
        'relayDCState': 'OFF', // Matikan relay DC
        'acCurrent': 0,
        'dcCurrent': 0,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Gagal mencatat sesi pengisian: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncBackgroundProgress();
    }
  }

  void _syncBackgroundProgress() {
    if (!_isCharging || _isComplete || _isInterrupted || _sessionStartTime == null) return;

    setState(() {
      final now = DateTime.now();
      _elapsedSeconds = now.difference(_sessionStartTime!).inSeconds;

      if (_lastTickTime != null) {
        final double deltaTime = now.difference(_lastTickTime!).inMilliseconds / 1000.0;
        if (deltaTime > 0) {
          _energyConsumedWh += _currentPower * (deltaTime / 3600.0);
        }
      }
      _lastTickTime = now;

      _currentTariff = (_energyConsumedWh / 1000.0) * _tariffPerKWh;

      if (_currentTariff.round() >= _userBalance && _userBalance > 0) {
        _currentTariff = _userBalance.toDouble();
        _isComplete = true;
        _isCharging = false;
        _stoppedByBalance = true;
        _currentPower = 0.0;
        _pulseController.stop();
        _chargingTimer?.cancel();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recordAndFinalize();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chargingTimer?.cancel();
    _sensorSubscription?.cancel();
    _interruptionTimer?.cancel();
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
                          : (_isInterrupted
                              ? AppColors.error.withValues(alpha: 0.12)
                              : AppColors.secondaryContainer),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isComplete
                          ? (_stoppedByBalance
                              ? 'PENGISIAN DAYA DIHENTIKAN'
                              : 'PENGISIAN DAYA TELAH SELESAI')
                          : (_isInterrupted
                              ? (_hasPressedWait
                                  ? 'PENGISIAN DIINTERUPSI (TUNGGU ${_interruptionSecondsLeft}S)'
                                  : 'PENGISIAN DAYA DIINTERUPSI')
                              : 'PENGISIAN DAYA SEDANG BERLANGSUNG'),
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: _isComplete
                            ? (_stoppedByBalance
                                ? AppColors.error
                                : AppColors.secondary)
                            : (_isInterrupted
                                ? AppColors.error
                                : AppColors.onSecondaryContainer),
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.4),
                          AppColors.secondary.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      padding: const EdgeInsets.all(18.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14.5),
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
                  ),
                  const SizedBox(height: 16),

                  // ── Kartu Daya Real-time ──
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withValues(alpha: (!_isComplete ? 0.4 : 0.1) * _pulseController.value),
                              AppColors.primary.withValues(alpha: (!_isComplete ? 0.2 : 0.05) * _pulseController.value),
                            ],
                          ),
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
                        ),
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          padding: const EdgeInsets.all(22.5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14.5),
                          ),
                          child: child,
                        ),
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
                  SizedBox(height: 100 + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: _isComplete
                  ? ElevatedButton.icon(
                      onPressed: _onCompletePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.secondary.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.home_rounded),
                      label: Text(
                        'Kembali ke Beranda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : SwipeToConfirmButton(
                      onConfirm: _onStopPressed,
                      text: 'Geser untuk Berhenti',
                      activeColor: AppColors.error,
                    ),
            ),
          ),
        ),
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
  void _onStopPressed() async {
    setState(() {
      _isCharging = false;
      _isComplete = true;
      _currentPower = 0.0;
      _currentAmps = 0.0;
    });
    _chargingTimer?.cancel();
    _sensorSubscription?.cancel();
    _pulseController.stop();

    await _recordAndFinalize();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, '/main', (route) => false,
      );
    }
  }


}

class SwipeToConfirmButton extends StatefulWidget {
  final VoidCallback onConfirm;
  final String text;
  final Color backgroundColor;
  final Color activeColor;

  const SwipeToConfirmButton({
    super.key,
    required this.onConfirm,
    required this.text,
    this.backgroundColor = AppColors.surfaceContainerLow,
    this.activeColor = AppColors.error,
  });

  @override
  State<SwipeToConfirmButton> createState() => _SwipeToConfirmButtonState();
}

class _SwipeToConfirmButtonState extends State<SwipeToConfirmButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDragDistance = constraints.maxWidth - 56.0 - 8.0;

        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: 56 + _dragValue * maxDragDistance,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.activeColor.withValues(alpha: 0.8),
                      widget.activeColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: (1 - _dragValue).clamp(0.0, 1.0),
                  child: Text(
                    widget.text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _dragValue * maxDragDistance,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue += details.primaryDelta! / maxDragDistance;
                      _dragValue = _dragValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > 0.85) {
                      setState(() {
                        _dragValue = 1.0;
                      });
                      widget.onConfirm();
                    } else {
                      final Animation<double> animation = Tween<double>(
                        begin: _dragValue,
                        end: 0.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      animation.addListener(() {
                        setState(() {
                          _dragValue = animation.value;
                        });
                      });

                      _animController.reset();
                      _animController.forward();
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: widget.activeColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


