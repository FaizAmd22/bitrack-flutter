import 'package:ams/base/widgets/tx_inputs.dart';
import 'package:flutter/material.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';

enum PeriodicFilterNavMode { push, replaceCurrent }

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

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    Navigator.of(context).pop();

    final args = {
      'startDate': _start,
      'endDate': _end,
      'licensePlate': widget.licensePlate,
    };

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
                      'Periodic Track',
                      style: AppStyles.textLBold.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                TxInputDateTime(
                  label: 'Start Date',
                  hintText: 'Choose Start Date',
                  value: _start,
                  displayFormat: 'd MMMM y HH:mm',
                  onChanged: (v) {
                    setState(() {
                      _start = v;
                      if (_end != null &&
                          _start != null &&
                          _end!.isBefore(_start!)) {
                        _end = null;
                      }
                    });
                  },
                  validator: (v) {
                    if (v == null) return 'Start Date wajib diisi';
                    return null;
                  },
                ),

                TxInputDateTime(
                  label: 'End Date',
                  hintText: 'Choose End Date',
                  value: _end,
                  firstDate: _start,
                  displayFormat: 'd MMMM y HH:mm',
                  onChanged: (v) => setState(() => _end = v),
                  validator: (v) {
                    if (v == null) return 'End Date wajib diisi';
                    if (_start != null && v.isBefore(_start!)) {
                      return 'End Date tidak boleh lebih kecil dari Start Date';
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
                      'Search',
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
