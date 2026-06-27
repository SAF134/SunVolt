import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_history_card.dart';
import '../../core/widgets/sunvolt_shimmer.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<DocumentSnapshot> _historyDocs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _limit = 8;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchFirstPage();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 100.0;
    if (maxScroll - currentScroll <= delta) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchFirstPage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasMore = true;
        _lastDocument = null;
        _historyDocs.clear();
      });
    }

    try {
      final query = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('activity_history')
          .orderBy('timestamp', descending: true)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _historyDocs.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
        if (snapshot.docs.length < _limit) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching history first page: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _lastDocument == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final query = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('activity_history')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _historyDocs.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
        if (snapshot.docs.length < _limit) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching history next page: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _deleteHistoryItem(String docId, int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('activity_history')
          .doc(docId)
          .delete();

      if (mounted) {
        setState(() {
          _historyDocs.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat berhasil dihapus secara permanen.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting history item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus riwayat: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatRelativeTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) {
      if (diff.inDays == 1) return 'Kemarin';
      return '${diff.inDays} hari yang lalu';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SunVoltAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchFirstPage,
        color: AppColors.primary,
        child: _isLoading
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Riwayat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) =>
                          const SunVoltHistorySkeleton(),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 100 + MediaQuery.paddingOf(context).bottom),
                itemCount: _historyDocs.isEmpty
                    ? 2
                    : _historyDocs.length + (_isLoadingMore ? 1 : 0) + 1,
                itemBuilder: (context, index) {
                  // Element 0 is the title header
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'Riwayat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                    );
                  }

                  // If there is no data and index is 1, show the empty state message
                  if (_historyDocs.isEmpty && index == 1) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Text(
                          'Belum ada riwayat aktivitas',
                          style: GoogleFonts.manrope(
                            color: AppColors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    );
                  }

                  // Adjust index because element 0 is the title header
                  final historyIndex = index - 1;

                  // Render shimmer at the bottom if loading more
                  if (historyIndex == _historyDocs.length) {
                    return const SunVoltHistorySkeleton();
                  }

                  final doc = _historyDocs[historyIndex];
                  final data = doc.data() as Map<String, dynamic>;
                  final isTopUp = data['type'] == 'topup';

                  // Calculate energy for top-up based on amount (Rp 2500 = 1 kWh)
                  String energyText;
                  if (isTopUp) {
                    final amountStr = (data['amount'] ?? '')
                        .toString()
                        .replaceAll(RegExp(r'[^0-9]'), '');
                    final amountNum = int.tryParse(amountStr) ?? 0;
                    final kWh = (amountNum / 2500).toStringAsFixed(2);
                    energyText = '+$kWh kWh';
                  } else {
                    final rawEnergy = data['energy'] ?? '1.00 kWh';
                    energyText = rawEnergy.toString().startsWith('-')
                        ? rawEnergy
                        : '-$rawEnergy';
                  }

                  return SunVoltHistoryCard(
                    icon: isTopUp
                        ? Icons.account_balance_wallet
                        : (data['title']?.toString().contains('Motor') == true
                            ? Icons.moped
                            : Icons.pedal_bike),
                    title: data['title'] ?? 'Transaksi',
                    station: data['subtitle'] ??
                        (isTopUp ? 'Setoran Sanbox Midtrans' : 'Stasiun SunVolt'),
                    time: _formatRelativeTime(data['timestamp'] as Timestamp?),
                    energy: energyText,
                    cost: data['amount'] ?? 'Rp 0',
                    status: 'Selesai',
                    isPositive: isTopUp,
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => SunVoltConfirmationDialog(
                          title: 'Hapus Riwayat',
                          message:
                              'Apakah Anda yakin ingin menghapus riwayat aktivitas ini? Data akan terhapus secara permanen dari aplikasi dan database.',
                          confirmLabel: 'Ya, Hapus',
                          cancelLabel: 'Batal',
                          isDestructive: true,
                          onConfirm: () => _deleteHistoryItem(doc.id, historyIndex),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
