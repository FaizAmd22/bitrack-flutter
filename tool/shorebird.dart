// Pembungkus perintah Shorebird untuk skrip melos `<app>:sb:*`. Dijalankan
// dari folder app (apps/bitrack, apps/bitrack_internal, apps/fixtrack),
// karena di sanalah shorebird.yaml dan pubspec.yaml app itu berada.
//
// Kenapa tidak memanggil `shorebird` langsung dari melos.yaml:
// - preview/promote/verify butuh versi release. Tanpa `--release-version`,
//   Shorebird menanyakannya lewat prompt, tapi melos menyalurkan stdout lewat
//   pipe sehingga Shorebird menganggap dirinya non-interaktif dan gagal.
//   Versinya dibaca di sini dari `version:` pubspec.
// - Di Windows `shorebird.bat` SELALU keluar dengan kode 0 walau gagal, jadi
//   `release` di sini memutuskan berhasil/tidaknya dari baris
//   "Published Release" di output, bukan dari exit code.
// - `shorebird.bat` juga memotong `=` pada argumen, jadi semua flag dikirim
//   dalam bentuk `--flag nilai`, dan define dibaca dari
//   apps/<app>/dart_defines.prod.json, bukan `--dart-define=K=V`.
// - stderr Shorebird digabung ke stdout; kalau tidak, melos memberi awalan
//   `ERROR:` pada setiap baris progres yang sebenarnya normal.
//
// Sengaja hanya memakai dart:io dan dijalankan dengan
// `--packages=../../tool/package_config.json` (config kosong), supaya tidak
// ikut aturan bahasa paket root dan tetap jalan di Dart SDK mana pun yang
// kebetulan pertama di PATH.
//
// Pemakaian (lewat melos, lihat skrip `<app>:sb:*` di melos.yaml):
//   release <android|ios>          -> release + salin AAB/IPA ke rilis/
//   patch <android|ios> [track]    -> kirim patch untuk release di pubspec
//   verify [path-aab]              -> cocokkan AAB dengan release di Shorebird
//   preview <android|ios> [track]  -> pasang release (+ patch track) ke HP
//   promote <nomor-patch>          -> pindahkan patch ke stable (set-track)
import 'dart:convert';
import 'dart:io';

/// Versi Flutter tim. Wajib disebut saat release: bawaan Shorebird adalah
/// Flutter terbaru, bukan versi ini. Patch otomatis memakai versi release-nya.
const _flutterVersion = '3.38.7';

/// Root repo, diturunkan dari lokasi file ini (tool/shorebird.dart).
final Directory _repoRoot = File.fromUri(Platform.script).parent.parent;

/// Nama app = nama folder tempat skrip dijalankan (bitrack / fixtrack / ...).
final String _appName = Directory.current.uri.pathSegments.lastWhere(
  (s) => s.isNotEmpty,
);

Future<void> main(List<String> args) async {
  if (args.isEmpty) _usage();

  final version = _readPubspecVersion();

  switch (args.first) {
    case 'release':
      if (args.length < 2) _usage();
      await _release(args[1], version);
    case 'patch':
      if (args.length < 2) _usage();
      await _patch(args[1], version, args.length > 2 ? args[2] : null);
    case 'verify':
      await _verify(args.length > 1 ? args[1] : null, version);
    case 'preview':
      if (args.length < 2) _usage();
      exit(
        await _shorebird([
          'preview',
          '--release-version',
          version,
          '--platform',
          args[1],
          if (args.length > 2) ...['--track', args[2]],
        ]),
      );
    case 'promote':
      if (args.length < 2 || int.tryParse(args[1]) == null) {
        _fail(
          'Nomor patch wajib diisi, mis. `melos run <app>:sb:promote 3`.\n'
          'Nomornya tercetak saat patch dibuat, atau lihat di '
          'console.shorebird.dev.',
          code: 64,
        );
      }
      await _promote(args[1], version);
    default:
      _usage();
  }
}

/// `shorebird release`, lalu SEGERA menyalin artefaknya ke `rilis/`.
///
/// Kenapa disalin: `shorebird patch` mem-build ulang app ke folder build/
/// yang sama, jadi AAB/IPA release di sana tertimpa hasil build patch. Yang
/// di-upload ke store HARUS file di rilis/ — kalau tidak, setiap patch untuk
/// release itu ditolak di HP user dengan "hash mismatch".
Future<void> _release(String platform, String version) async {
  if (platform != 'android' && platform != 'ios') _usage();

  final ext = platform == 'android' ? 'aab' : 'ipa';
  final target = File('${_repoRoot.path}/rilis/$_appName-$version.$ext');
  if (target.existsSync()) {
    _fail(
      '${target.path} sudah ada — versi $version sudah pernah dirilis.\n'
      'Naikkan `version:` di pubspec.yaml (minimal +N) lalu jalankan lagi.',
    );
  }

  if (platform == 'ios') {
    // Sama dengan skrip melos `*:ios`: sisa native_assets dari build
    // sebelumnya pernah membuat build iOS gagal.
    final nativeAssets = Directory('build/native_assets');
    if (nativeAssets.existsSync()) nativeAssets.deleteSync(recursive: true);
  }

  final output = StringBuffer();
  await _shorebird([
    'release',
    platform,
    '--flutter-version',
    _flutterVersion,
    '--dart-define-from-file',
    'dart_defines.prod.json',
  ], capture: output);

  if (!output.toString().contains('Published Release $version')) {
    _fail(
      'Release $version GAGAL (tidak ada baris "Published Release $version" '
      'di output di atas). Tidak ada yang disalin ke rilis/.',
    );
  }

  final File built;
  if (platform == 'android') {
    built = File('build/app/outputs/bundle/release/app-release.aab');
  } else {
    final ipaDir = Directory('build/ios/ipa');
    final ipas = ipaDir.existsSync()
        ? ipaDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.ipa'))
              .toList()
        : <File>[];
    if (ipas.isEmpty) {
      _fail('Release berhasil tapi IPA tidak ditemukan di build/ios/ipa.');
    }
    built = ipas.first;
  }
  if (!built.existsSync()) {
    _fail('Release berhasil tapi ${built.path} tidak ada.');
  }

  target.parent.createSync(recursive: true);
  built.copySync(target.path);

  final store = platform == 'android' ? 'Play Console' : 'App Store Connect';
  stdout.writeln(
    '\n========================================================================\n'
    'Release $version tersimpan di:\n'
    '  ${target.path}\n'
    '\n'
    'Upload FILE INI ke $store — bukan yang di folder build/,\n'
    'karena build/ akan tertimpa oleh `shorebird patch` berikutnya.\n'
    '========================================================================',
  );
}

/// `shorebird patch` untuk release yang tertulis di pubspec.
///
/// `--release-version` WAJIB disebut. Tanpa itu Shorebird menebak versinya
/// dengan membangun ulang app memakai Flutter TERBARU (bukan versi rilis
/// kita), dan build tebakan itu gagal — yang terlihat di layar hanya
/// "Failed to build AAB", seolah patch-nya yang bermasalah.
Future<void> _patch(String platform, String version, String? track) async {
  if (platform != 'android' && platform != 'ios') _usage();

  if (platform == 'ios') {
    final nativeAssets = Directory('build/native_assets');
    if (nativeAssets.existsSync()) nativeAssets.deleteSync(recursive: true);
  }

  final output = StringBuffer();
  await _shorebird([
    'patch',
    platform,
    '--release-version',
    version,
    '--dart-define-from-file',
    'dart_defines.prod.json',
    if (track != null) ...['--track', track],
  ], capture: output);

  // Exit code tidak bisa dipercaya di Windows, jadi hasilnya dibaca dari
  // output.
  final text = output.toString();
  if (text.contains('Published Patch')) {
    stdout.writeln(
      '\nPatch untuk release $version terkirim'
      "${track == null ? '' : ' ke track $track'}.",
    );
    return;
  }
  if (text.contains('No changes detected')) {
    stdout.writeln(
      '\nTidak ada perubahan Dart dibanding release $version - '
      'tidak ada patch yang dibuat.',
    );
    return;
  }
  _fail('Patch untuk release $version GAGAL (lihat output di atas).');
}

/// Memindahkan patch [patch] ke track stable (= semua user release itu).
///
/// Memakai `patches set-track`, bukan `patches promote`: yang terakhir sudah
/// deprecated di Shorebird 1.6.x. Seperti [_release], berhasil/tidaknya
/// diputuskan dari output, karena exit code `shorebird.bat` di Windows
/// selalu 0.
Future<void> _promote(String patch, String version) async {
  final output = StringBuffer();
  await _shorebird([
    'patches',
    'set-track',
    '--release',
    version,
    '--patch',
    patch,
    '--track',
    'stable',
  ], capture: output);

  final text = output.toString();
  if (text.contains(
    'Patch $patch on release $version is now in channel stable',
  )) {
    stdout.writeln(
      '\nPatch $patch sekarang aktif untuk semua user release $version.',
    );
    return;
  }
  if (text.contains('already in channel')) {
    stdout.writeln(
      '\nPatch $patch memang sudah di track stable — tidak ada yang berubah.',
    );
    return;
  }
  _fail('Promote patch $patch GAGAL (lihat output di atas).');
}

/// Mencocokkan `libapp.so` (kode Dart terkompilasi) sebuah AAB dengan
/// release [version] yang tersimpan di server Shorebird.
///
/// Kalau beda, AAB itu BUKAN binary release-nya: patch apa pun untuk versi
/// ini akan ditolak di HP user dengan "hash mismatch". Jangan di-upload.
Future<void> _verify(String? pathArg, String version) async {
  final aab = _resolveAab(pathArg, version);
  stdout.writeln(
    'Memeriksa ${aab.path}\n  terhadap release $version di Shorebird...\n',
  );

  final temp = Directory.systemTemp.createTempSync('sb_verify_');
  try {
    final local = await _extract(
      aab,
      'base/lib/arm64-v8a/libapp.so',
      temp,
      'aab',
    );

    final apksDir = Directory('${temp.path}/apks')..createSync();
    await _shorebird([
      'releases',
      'get-apks',
      '--release-version',
      version,
      '--out',
      apksDir.path,
    ]);
    final apks = apksDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.apk'))
        .toList();
    if (apks.isEmpty) {
      _fail(
        'Gagal mengunduh release $version dari Shorebird (lihat output di '
        'atas).',
      );
    }
    final remote = await _extract(
      apks.first,
      'lib/arm64-v8a/libapp.so',
      temp,
      'apk',
    );

    final same = _sameBytes(local, remote);
    stdout.writeln(
      '\n========================================================================',
    );
    if (same) {
      stdout.writeln(
        'COCOK: ${aab.path}\n'
        'adalah binary release $version. Aman di-upload ke store.',
      );
    } else {
      stdout.writeln(
        'TIDAK COCOK: ${aab.path}\n'
        'BUKAN binary release $version di Shorebird — kemungkinan hasil build\n'
        'patch. JANGAN di-upload: patch untuk versi ini akan ditolak di HP\n'
        'user dengan "hash mismatch". Pakai file di rilis/.',
      );
    }
    stdout.writeln(
      '========================================================================',
    );
    exit(same ? 0 : 1);
  } finally {
    temp.deleteSync(recursive: true);
  }
}

/// Tanpa argumen: `rilis/<app>-<versi>.aab`. Dengan argumen: path relatif ke
/// folder app (tempat melos menjalankan skrip), ke root repo, atau absolut.
File _resolveAab(String? pathArg, String version) {
  final candidates = pathArg == null
      ? [File('${_repoRoot.path}/rilis/$_appName-$version.aab')]
      : [File(pathArg), File('${_repoRoot.path}/$pathArg')];
  for (final f in candidates) {
    if (f.existsSync()) return f;
  }
  _fail('AAB tidak ditemukan: ${candidates.map((f) => f.path).join(' / ')}');
}

/// Mengambil satu entri dari arsip zip (AAB/APK) ke [dir].
///
/// Pakai `tar` bawaan Windows 10+ (bsdtar, bisa membaca zip) atau `unzip` di
/// macOS/Linux, karena dart:io tidak punya pembaca zip. Di Windows path-nya
/// ditulis lengkap: `tar` dari Git Bash adalah GNU tar yang tidak bisa
/// membaca zip.
Future<File> _extract(
  File archive,
  String entry,
  Directory dir,
  String tag,
) async {
  final out = Directory('${dir.path}/$tag')..createSync();
  final ProcessResult result;
  if (Platform.isWindows) {
    final root = Platform.environment['SystemRoot'] ?? r'C:\Windows';
    result = await Process.run('$root\\System32\\tar.exe', [
      '-xf',
      archive.path,
      '-C',
      out.path,
      entry,
    ]);
  } else {
    result = await Process.run('unzip', [
      '-o',
      '-q',
      archive.path,
      entry,
      '-d',
      out.path,
    ]);
  }
  final file = File('${out.path}/$entry');
  if (result.exitCode != 0 || !file.existsSync()) {
    _fail('Gagal mengambil $entry dari ${archive.path}:\n${result.stderr}');
  }
  return file;
}

bool _sameBytes(File a, File b) {
  if (a.lengthSync() != b.lengthSync()) return false;
  final x = a.readAsBytesSync();
  final y = b.readAsBytesSync();
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}

/// Menjalankan `shorebird`, meneruskan stdout+stderr ke stdout, dan (kalau
/// [capture] diberikan) ikut menyimpan outputnya. Exit code dikembalikan apa
/// adanya — ingat: di Windows nilainya selalu 0.
Future<int> _shorebird(List<String> args, {StringBuffer? capture}) async {
  stdout.writeln('> shorebird ${args.join(' ')}');
  // runInShell: di Windows `shorebird` adalah shorebird.bat, yang hanya bisa
  // ditemukan lewat cmd.
  final process = await Process.start('shorebird', args, runInShell: true);
  void sink(String s) {
    stdout.write(s);
    capture?.write(s);
  }

  await Future.wait([
    process.stdout.transform(utf8.decoder).forEach(sink),
    process.stderr.transform(utf8.decoder).forEach(sink),
  ]);
  return process.exitCode;
}

/// `x.y.z+N` dari baris `version:` pubspec app. Build number WAJIB ada:
/// release Shorebird tercatat dengan build number-nya (mis. `1.0.9+10`).
String _readPubspecVersion() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    _fail('pubspec.yaml tidak ditemukan — jalankan dari folder app.', code: 66);
  }
  final match = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+\+\d+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  if (match == null) {
    _fail('Baris `version: x.y.z+N` di pubspec.yaml tidak dikenali.', code: 65);
  }
  return match.group(1)!;
}

Never _fail(String message, {int code = 1}) {
  stdout.writeln('\n$message');
  exit(code);
}

Never _usage() {
  _fail(
    'Pemakaian:\n'
    '  melos run <app>:sb:release:<android|ios>\n'
    '  melos run <app>:sb:patch:<android|ios>[:staging]\n'
    '  melos run <app>:sb:verify [path-aab]\n'
    '  melos run <app>:sb:preview:<android|ios>[:staging]\n'
    '  melos run <app>:sb:promote <nomor-patch>',
    code: 64,
  );
}
