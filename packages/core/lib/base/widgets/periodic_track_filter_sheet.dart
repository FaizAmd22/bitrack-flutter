import 'package:bitrack_core/base/widgets/tx_inputs.dart';
import 'package:flutter/material.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

/// Cara membuka halaman Periodic Track setelah filter disubmit.
enum PeriodicFilterNavMode {
  /// Tumpuk di atas halaman saat ini (dibuka dari Vehicle Detail).
  push,

  /// Ganti halaman Periodic Track yang sedang terbuka (mengubah filter dari
  /// dalam Periodic Track), supaya tidak menumpuk dua halaman yang sama.
  replaceCurrent
}

/// Bottom sheet pemilih rentang waktu (Start Date dan End Date, sampai menit)
/// sebelum membuka halaman Periodic Track untuk satu kendaraan.
///
/// Rentang maksimal 3 hari kalender (lihat [_maxEndDate]) dan tidak boleh
/// melewati hari ini. Buka dengan [PeriodicTrackFilterSheet.open].
class PeriodicTrackFilterSheet extends StatefulWidget {
  final String licensePlate;
  final PeriodicFilterNavMode navMode;

  const PeriodicTrackFilterSheet({
    super.key,
    required this.licensePlate,
    this.navMode = PeriodicFilterNavMode.push,
  });

  static Future<void> open(
    BuildContext context, {
    required String licensePlate,
    PeriodicFilterNavMode navMode = PeriodicFilterNavMode.push,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => PeriodicTrackFilterSheet(
        licensePlate: licensePlate,
        navMode: navMode,
      ),
    );
  }

  @override
  State<PeriodicTrackFilterSheet> createState() =>
      _PeriodicTrackFilterSheetState();
}

class _PeriodicTrackFilterSheetState extends State<PeriodicTrackFilterSheet> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _start;
  DateTime? _end;

  /// Jumlah hari SETELAH tanggal start yang masih boleh dipilih.
  static const _maxRangeDays = 2;

  // Batas End Date: tanggal start + 2 hari kalender = 3 hari total (inklusif start).
  // Jam pada hari maksimal bebas dipilih (hingga 23:59:59).
  // Jika batas range melewati hari ini, gunakan akhir hari ini.
  DateTime get _maxEndDate {
    final now = DateTime.now();
    if (_start == null) {
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    final byRange = DateTime(
      _start!.year,
      _start!.month,
      _start!.day + _maxRangeDays,
      23,
      59,
      59,
    );
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return byRange.isBefore(todayEnd) ? byRange : todayEnd;
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    Navigator.of(context).pop();

    // Argumen ini dibaca halaman Periodic Track dari `ModalRoute.settings`.
    final args = {
      'startDate': _start,
      'endDate': _end,
      'licensePlate': widget.licensePlate,
    };

    // Pindah halaman setelah sheet benar-benar tertutup (frame berikutnya).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = Navigator.of(context);

      if (widget.navMode == PeriodicFilterNavMode.replaceCurrent) {
        nav.popAndPushNamed(AppRoutes.periodicTrackScreen, arguments: args);

        // nav.pushReplacementNamed(AppRoutes.periodicTrackScreen, arguments: args);
      } else {
        nav.pushNamed(AppRoutes.periodicTrackScreen, arguments: args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.8;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppStyles.plateNumberBg,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      t.periodicTrack,
                      style: AppStyles.textLBold.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                TxInputDateTime(
                  label: t.filterStartDate,
                  hintText: t.filterChooseStartDate,
                  value: _start,
                  lastDate: DateTime.now(),
                  displayFormat: 'd MMMM y HH:mm',
                  onChanged: (v) {
                    setState(() {
                      _start = v;
                      // End Date yang sudah dipilih jadi tidak valid kalau
                      // start digeser melewatinya atau rentangnya terlalu
                      // panjang; kosongkan supaya user memilih ulang.
                      if (_end != null &&
                          (_end!.isBefore(_start!) ||
                              _end!.isAfter(_maxEndDate))) {
                        _end = null;
                      }
                    });
                  },
                  validator: (v) {
                    if (v == null) return t.periodicStartDateRequired;
                    return null;
                  },
                ),

                TxInputDateTime(
                  label: t.filterEndDate,
                  hintText: t.filterChooseEndDate,
                  value: _end,
                  firstDate: _start,
                  lastDate: _maxEndDate,
                  displayFormat: 'd MMMM y HH:mm',
                  onChanged: (v) => setState(() => _end = v),
                  validator: (v) {
                    if (v == null) return t.periodicEndDateRequired;
                    if (_start != null && v.isBefore(_start!)) {
                      return t.periodicEndDateBeforeStart;
                    }
                    if (v.isAfter(_maxEndDate)) {
                      return t.periodicMaxRangeExceeded;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      foregroundColor: AppStyles.whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      t.filterSearch,
                      style: AppStyles.textMdBold.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
