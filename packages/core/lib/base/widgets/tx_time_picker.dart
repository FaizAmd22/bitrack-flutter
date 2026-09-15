import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Pemilih jam bergaya iOS: kolom jam dan menit yang digulir, menggantikan
/// jam putar Material (`showTimePicker`) yang membingungkan saat dipakai.
///
/// Tanggal pada [initial] menentukan hari yang sedang dipilih jamnya; hasilnya
/// adalah tanggal itu dengan jam dan menit yang dipilih user. Null kalau
/// dibatalkan.
///
/// [minimum] dan [maximum] dibatasi sampai ke menit. Jam putar yang lama hanya
/// membatasi tanggal, sehingga misalnya Start Date bisa diisi jam yang belum
/// terjadi hari ini.
Future<DateTime?> showTxTimePicker(
  BuildContext context, {
  required DateTime initial,
  DateTime? minimum,
  DateTime? maximum,
  bool use24HourFormat = true,
  String? title,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppStyles.whiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TxTimePickerSheet(
      initial: clampDateTime(initial, minimum, maximum),
      minimum: minimum,
      maximum: maximum,
      use24HourFormat: use24HourFormat,
      title: title,
    ),
  );
}

/// Jepit [value] ke dalam rentang [min]..[max] (masing-masing opsional).
///
/// Di mode jam, CupertinoDatePicker tidak memanggil `onDateTimeChanged`
/// sebelum user menggulir. Tanpa penjepitan ini, waktu awal yang sudah di luar
/// batas akan dikembalikan apa adanya kalau user langsung menekan Confirm.
DateTime clampDateTime(DateTime value, DateTime? min, DateTime? max) {
  if (min != null && value.isBefore(min)) return min;
  if (max != null && value.isAfter(max)) return max;
  return value;
}

class _TxTimePickerSheet extends StatefulWidget {
  const _TxTimePickerSheet({
    required this.initial,
    required this.minimum,
    required this.maximum,
    required this.use24HourFormat,
    required this.title,
  });

  final DateTime initial;
  final DateTime? minimum;
  final DateTime? maximum;
  final bool use24HourFormat;
  final String? title;

  @override
  State<_TxTimePickerSheet> createState() => _TxTimePickerSheetState();
}

class _TxTimePickerSheetState extends State<_TxTimePickerSheet> {
  late DateTime _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    t.cancel,
                    style: AppStyles.textMd.copyWith(
                      color: AppStyles.darkGrayColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.title ?? '',
                    textAlign: TextAlign.center,
                    style: AppStyles.textMdBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  // Dijepit sekali lagi: nilai terakhir dari picker sudah valid,
                  // tapi jaminan ini tidak boleh bergantung pada perilaku
                  // internal Cupertino.
                  onPressed: () => Navigator.of(context).pop(
                    clampDateTime(_selected, widget.minimum, widget.maximum),
                  ),
                  child: Text(
                    t.confirm,
                    style: AppStyles.textMdBold.copyWith(
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppStyles.bgGrayColor),
          SizedBox(
            height: 216,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                // Wajib dikunci terang. Tanpa `brightness`, Cupertino mengikuti
                // mode gelap ponsel (bukan tema app) dan mewarnai angka jam yang
                // valid PUTIH — tak terlihat di sheet yang selalu putih ini.
                // Hanya jam yang tidak valid (abu-abu) yang tampak, sehingga
                // roda terlihat kosong untuk tanggal lampau.
                brightness: Brightness.light,
                primaryColor: AppStyles.primaryColor,
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: widget.initial,
                minimumDate: widget.minimum,
                maximumDate: widget.maximum,
                use24hFormat: widget.use24HourFormat,
                onDateTimeChanged: (v) => _selected = v,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
